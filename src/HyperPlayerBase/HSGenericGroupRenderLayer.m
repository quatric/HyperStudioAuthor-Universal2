#import "HSGenericGroupRenderLayer.h"
#import "HSMutableMultipleObjectsAttributeSet.h"
#import "HSMutableRegion.h"
#import "SMKApplicationKitData.h"

// A render layer holding sublayer records. Each record keeps a sublayer with
// its role, root flag and transparency layer requirement; root sublayers are
// drawn through their hyper object's geometry transform.
//
// With autogrouping on, the original records are grouped into private group
// render layers (cached together) when their bounding regions overlap and
// none of their geometry is changing. _renderSublayerRecords is then the
// grouped list, _originalRenderSublayerRecords the list as the owner built
// it. Private groups with the same sublayers are shared between group layers
// through the private group registry.

typedef struct HyperPlayerBase_anon11 HSRenderSublayerRecord;
typedef struct HyperPlayerBase_anon14 HSRenderSublayerGroupRecord;

static NSString *const HSOriginalRenderSublayerRecordsKey = @"HSGenericGroupRenderLayer_originalRenderSublayerRecords";
static NSString *const HSPrivateGroupRenderLayerRole = @"HSPrivateGroupRenderLayerRole";

// attribute change sent by the observing session when attributes begin to
// change continuously (the session observes begin and end, 0xc0)
#define HSWillBeginContinuousAttributeChange 0x40
#define HSContinuousAttributeChanges 0xc0

static HSGenericGroupRenderLayer_HSPrivateGroupRenderLayerRegistry *sHSPrivateGroupRenderLayerRegistry = nil;

#pragma mark Records

// The geometry attributes of a generic record's hyper object, looked up once.
// Only root records carry geometry (the others are created resolved to nil).
static id HSRenderSublayerRecordGeometryAttributes(HSRenderSublayerRecord *aRecord)
{
    if (aRecord->isPrivateGroup)
        return nil;
    if (!aRecord->u.generic.isGeometryAttributesResolved) {
        aRecord->u.generic.geometryAttributes = [[[aRecord->renderLayer hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
        aRecord->u.generic.isGeometryAttributesResolved = YES;
    }
    return aRecord->u.generic.geometryAttributes;
}

static const void *HSRenderSublayerRecordRetain(CFAllocatorRef aAllocator, const void *aValue)
{
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)aValue;
    record->retainCount++;
    [record->renderLayer retain];
    return aValue;
}

// Frees the record itself, leaving its render layer alone.
static void HSRenderSublayerRecordDecrement(HSRenderSublayerRecord *aRecord)
{
    if (--aRecord->retainCount == 0) {
        if (!aRecord->isPrivateGroup) {
            [aRecord->u.generic.role release];
            [aRecord->u.generic.geometryAttributes release];
        }
        CFAllocatorDeallocate(kCFAllocatorDefault, aRecord);
    }
}

static void HSRenderSublayerRecordRelease(CFAllocatorRef aAllocator, const void *aValue)
{
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)aValue;
    [record->renderLayer release];
    HSRenderSublayerRecordDecrement(record);
}

static Boolean HSRenderSublayerRecordEqual(const void *aValue, const void *aValue2)
{
    return ((HSRenderSublayerRecord *)aValue)->renderLayer == ((HSRenderSublayerRecord *)aValue2)->renderLayer;
}

static CFStringRef HSRenderSublayerRecordCopyDescription(const void *aValue);
static CFStringRef HSRenderSublayerGroupRecordCopyDescription(const void *aValue);

static const CFArrayCallBacks HSRenderSublayerRecordArrayCallBacks = {
    0, HSRenderSublayerRecordRetain, HSRenderSublayerRecordRelease, HSRenderSublayerRecordCopyDescription, HSRenderSublayerRecordEqual
};

// Creates a generic record with a retain count of 1, or NULL when there's no
// role.
static HSRenderSublayerRecord *HSCreateRenderSublayerRecord(id aLayer, id aRole, BOOL aRoot, BOOL aTransparencyLayerRequirement)
{
    HSRenderSublayerRecord *record = CFAllocatorAllocate(kCFAllocatorDefault, sizeof(HSRenderSublayerRecord), 0);
    if (record == NULL)
        return NULL;
    record->u.generic.role = [aRole copy];
    if (record->u.generic.role == nil) {
        CFAllocatorDeallocate(kCFAllocatorDefault, record);
        return NULL;
    }
    record->renderLayer = [aLayer retain];
    record->u.generic.geometryAttributes = nil;
    record->u.generic.isRoot = aRoot & 1;
    record->u.generic.isGeometryAttributesResolved = (aRoot == NO);
    record->u.generic.addsTransparencyLayerRequirement = aTransparencyLayerRequirement & 1;
    record->isPrivateGroup = NO;
    record->retainCount = 1;
    return record;
}

#pragma mark Group records

static void HSRenderSublayerGroupRecordRelease(CFAllocatorRef aAllocator, const void *aValue)
{
    HSRenderSublayerGroupRecord *group = (HSRenderSublayerGroupRecord *)aValue;
    if (!group->isArray)
        HSRenderSublayerRecordRelease(NULL, group->content.record);
    else
        CFRelease(group->content.records);
    [group->region release];
    CFAllocatorDeallocate(kCFAllocatorDefault, group);
}

static const CFArrayCallBacks HSRenderSublayerGroupRecordArrayCallBacks = {
    0, NULL, HSRenderSublayerGroupRecordRelease, HSRenderSublayerGroupRecordCopyDescription, NULL
};

static HSRenderSublayerGroupRecord *HSCreateRenderSublayerGroupRecord(HSRenderSublayerRecord *aRecord, BOOL aGroupable, BOOL aBypassable, id aRegion, NSRect aRect, float aArea)
{
    HSRenderSublayerGroupRecord *group = CFAllocatorAllocate(kCFAllocatorDefault, sizeof(HSRenderSublayerGroupRecord), 0);
    if (group == NULL)
        return NULL;
    group->isArray = NO;
    HSRenderSublayerRecordRetain(NULL, aRecord);
    group->content.record = aRecord;
    group->isGroupable = aGroupable & 1;
    group->isBypassable = aBypassable & 1;
    group->region = [aRegion retain];
    group->rect = aRect;
    group->area = aArea;
    return group;
}

// Turns a single record group into a group holding an array of records.
static BOOL HSMakeRenderSublayerGroupRecordArray(HSRenderSublayerGroupRecord *aGroup)
{
    if (aGroup->isArray)
        return YES;
    CFMutableArrayRef records = CFArrayCreateMutable(kCFAllocatorDefault, 0, &HSRenderSublayerRecordArrayCallBacks);
    if (records == NULL)
        return NO;
    CFArrayAppendValue(records, aGroup->content.record);
    HSRenderSublayerRecordRelease(NULL, aGroup->content.record);
    aGroup->content.records = records;
    aGroup->isArray = YES;
    return YES;
}

// Adds the bounding region of a record, in the group layer's space.
static void HSAddRenderSublayerRecordRegion(HSRenderSublayerRecord *aRecord, HSMutableRegion *aRegion, BOOL aRegionIsEmpty)
{
    id layer = aRecord->renderLayer;
    id geometry = HSRenderSublayerRecordGeometryAttributes(aRecord);
    if (geometry == nil)
        [layer unionBoundingRegionWithRegion:aRegion];
    else if (aRegionIsEmpty) {
        [layer unionBoundingRegionWithRegion:aRegion];
        [aRegion applyAffineTransform:[geometry affineTransform]];
    } else {
        HSMutableRegion *region = [HSMutableRegion region];
        [layer unionBoundingRegionWithRegion:region];
        [region applyAffineTransform:[geometry affineTransform]];
        [aRegion addRegion:region];
    }
}

#pragma mark Shared private groups

// Sorts private group records by subrecord count, largest first.
static CFComparisonResult HSCompareBySubrecordCountDescending(const void *aValue, const void *aValue2, void *aContext)
{
    unsigned int count = ((HSRenderSublayerRecord *)aValue)->u.privateGroup.subrecordCount;
    unsigned int count2 = ((HSRenderSublayerRecord *)aValue2)->u.privateGroup.subrecordCount;
    if (count == count2)
        return kCFCompareEqualTo;
    return (count2 < count) ? kCFCompareLessThan : kCFCompareGreaterThan;
}

typedef struct {
    NSUInteger minimumCount;
    CFMutableArrayRef *candidates;
} HSSharedPrivateGroupCandidatesContext;

// Keeps the private group records all of whose sublayers were counted.
static void HSCollectSharedPrivateGroupCandidate(const void *aKey, const void *aValue, void *aContext)
{
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)aKey;
    NSUInteger count = (NSUInteger)aValue;
    HSSharedPrivateGroupCandidatesContext *context = aContext;
    if (count < context->minimumCount || count != record->u.privateGroup.subrecordCount)
        return;
    CFMutableArrayRef candidates = *context->candidates;
    if (candidates == NULL) {
        candidates = CFArrayCreateMutable(kCFAllocatorDefault, 0, &HSRenderSublayerRecordArrayCallBacks);
        *context->candidates = candidates;
        if (candidates != NULL)
            CFArrayAppendValue(candidates, record);
    } else {
        CFIndex index = CFArrayBSearchValues(candidates, CFRangeMake(0, CFArrayGetCount(candidates)), record, HSCompareBySubrecordCountDescending, NULL);
        CFArrayInsertValueAtIndex(candidates, index, record);
    }
}

static void HSAddSharedPrivateGroupRenderSublayerRecords(const void *aValue, void *aContext)
{
    [HSGenericGroupRenderLayer HSGenericGroupRenderLayer_addSharedPrivateGroupRenderSublayerRecordsWithRenderLayer:((HSRenderSublayerRecord *)aValue)->renderLayer toCountedSet:aContext];
}

#pragma mark Applier functions

static void HSPreRemoveOriginalRenderSublayerRecord(const void *aValue, void *aContext)
{
    [(HSGenericGroupRenderLayer *)aContext HSGenericGroupRenderLayer_preRemoveRenderSublayerRecord:(HSRenderSublayerRecord *)aValue asOriginal:YES];
}

static void HSPreRemoveRenderSublayerRecord(const void *aValue, void *aContext)
{
    [(HSGenericGroupRenderLayer *)aContext HSGenericGroupRenderLayer_preRemoveRenderSublayerRecord:(HSRenderSublayerRecord *)aValue asOriginal:NO];
}

static void HSPostAddOriginalRenderSublayerRecord(const void *aValue, void *aContext)
{
    [(HSGenericGroupRenderLayer *)aContext HSGenericGroupRenderLayer_postAddRenderSublayerRecord:(HSRenderSublayerRecord *)aValue asOriginal:YES];
}

static void HSPostAddRenderSublayerRecord(const void *aValue, void *aContext)
{
    [(HSGenericGroupRenderLayer *)aContext HSGenericGroupRenderLayer_postAddRenderSublayerRecord:(HSRenderSublayerRecord *)aValue asOriginal:NO];
}

static void HSRemoveRenderSublayerObserver(const void *aValue, void *aContext)
{
    [((HSRenderSublayerRecord *)aValue)->renderLayer removeObserver:aContext];
}

static void HSObserveRootGeometry(const void *aValue, void *aContext)
{
    id geometry = HSRenderSublayerRecordGeometryAttributes((HSRenderSublayerRecord *)aValue);
    if (geometry != nil)
        [[geometry attributeObservingController] addObserver:aContext selector:@selector(HSGenericGroupRenderLayer_rootGeometryAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute) withPriority:0.25];
}

static void HSStopObservingRootGeometry(const void *aValue, void *aContext)
{
    id geometry = HSRenderSublayerRecordGeometryAttributes((HSRenderSublayerRecord *)aValue);
    if (geometry != nil)
        [[geometry attributeObservingController] removeObserver:aContext selector:@selector(HSGenericGroupRenderLayer_rootGeometryAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute)];
}

static void HSStopObservingRootGeometryAndRenderSublayer(const void *aValue, void *aContext)
{
    HSStopObservingRootGeometry(aValue, aContext);
    HSRemoveRenderSublayerObserver(aValue, aContext);
}

static void HSAddGeometryAttribute(HSRenderSublayerRecord *aRecord, id aSet)
{
    id geometry = HSRenderSublayerRecordGeometryAttributes(aRecord);
    if (geometry != nil)
        [aSet addAttribute:@protocol(HSGeometryAttribute) forObject:[geometry hyperObject]];
}

static void HSAddBoundingRegionAttributes(const void *aValue, void *aContext)
{
    HSAddGeometryAttribute((HSRenderSublayerRecord *)aValue, aContext);
}

static void HSAddVisualizationAttributes(const void *aValue, void *aContext)
{
    HSAddGeometryAttribute((HSRenderSublayerRecord *)aValue, aContext);
    [((HSRenderSublayerRecord *)aValue)->renderLayer addVisualizationAttributesToSet:aContext];
}

static void HSAddVisualizationMaskAttributes(const void *aValue, void *aContext)
{
    HSAddGeometryAttribute((HSRenderSublayerRecord *)aValue, aContext);
    [((HSRenderSublayerRecord *)aValue)->renderLayer addVisualizationMaskAttributesToSet:aContext];
}

// Readds the generic records nested in private groups as current records.
static void HSPostAddNestedRenderSublayerRecord(const void *aValue, void *aContext)
{
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)aValue;
    if (!record->isPrivateGroup)
        [(HSGenericGroupRenderLayer *)aContext HSGenericGroupRenderLayer_postAddRenderSublayerRecord:record asOriginal:NO];
    else {
        CFArrayRef records = [record->renderLayer HSGenericGroupRenderLayer_renderSublayerRecords];
        CFArrayApplyFunction(records, CFRangeMake(0, CFArrayGetCount(records)), HSPostAddNestedRenderSublayerRecord, aContext);
    }
}

static void HSUngroupPrivateRenderSublayerRecord(const void *aValue, void *aContext)
{
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)aValue;
    if (record->isPrivateGroup) {
        [(HSGenericGroupRenderLayer *)aContext HSGenericGroupRenderLayer_preRemoveRenderSublayerRecord:record asOriginal:NO];
        CFArrayRef records = [record->renderLayer HSGenericGroupRenderLayer_renderSublayerRecords];
        CFArrayApplyFunction(records, CFRangeMake(0, CFArrayGetCount(records)), HSPostAddNestedRenderSublayerRecord, aContext);
    }
}

#pragma mark Descriptions

// Descriptions number records by their index in the original records of the
// layer being described, when the layer published them in the thread
// dictionary.
static CFArrayRef HSDescribedOriginalRenderSublayerRecords(void)
{
    return [[[[NSThread currentThread] threadDictionary] objectForKey:HSOriginalRenderSublayerRecordsKey] pointerValue];
}

static NSString *HSDescriptionOfRenderSublayer(HSRenderSublayerRecord *aRecord)
{
    id layer = aRecord->renderLayer;
    id object = [layer hyperObject];
    return [NSString stringWithFormat:@"<%@: 0x%lx> of <%@: 0x%lx> named \"%@\"", NSStringFromClass([layer class]), (unsigned long)layer, NSStringFromClass([object class]), (unsigned long)object, [[object queryHyperInterface:@protocol(HSObjectAttributes)] hyperName]];
}

static void HSAppendPrivateGroupSubrecordDescriptions(CFMutableStringRef aLayers, CFMutableStringRef aIndexes, HSRenderSublayerRecord *aRecord, CFArrayRef aOriginals)
{
    CFArrayRef records = [aRecord->renderLayer HSGenericGroupRenderLayer_renderSublayerRecords];
    CFIndex count = CFArrayGetCount(records);
    for (CFIndex i = 0; ; ) {
        HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(records, i);
        if (!record->isPrivateGroup) {
            if (aIndexes != NULL)
                CFStringAppendFormat(aIndexes, NULL, CFSTR("%ld"), (long)CFArrayGetFirstIndexOfValue(aOriginals, CFRangeMake(0, CFArrayGetCount(aOriginals)), record));
            if (aLayers != NULL)
                CFStringAppend(aLayers, (CFStringRef)HSDescriptionOfRenderSublayer(record));
        } else {
            if (aIndexes != NULL)
                CFStringAppend(aIndexes, CFSTR("("));
            if (aLayers != NULL)
                CFStringAppend(aLayers, CFSTR("("));
            HSAppendPrivateGroupSubrecordDescriptions(aLayers, aIndexes, record, aOriginals);
            if (aIndexes != NULL)
                CFStringAppend(aIndexes, CFSTR(")"));
            if (aLayers != NULL)
                CFStringAppend(aLayers, CFSTR(")"));
        }
        if (++i == count)
            break;
        if (aIndexes != NULL)
            CFStringAppend(aIndexes, CFSTR(", "));
        if (aLayers != NULL)
            CFStringAppend(aLayers, CFSTR(", "));
    }
}

static CFStringRef HSRenderSublayerRecordCopyDescription(const void *aValue)
{
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)aValue;
    CFArrayRef originals = HSDescribedOriginalRenderSublayerRecords();
    CFStringRef description;
    CFStringRef indexes = NULL;
    if (!record->isPrivateGroup) {
        if (originals != NULL)
            indexes = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR(": %ld"), (long)CFArrayGetFirstIndexOfValue(originals, CFRangeMake(0, CFArrayGetCount(originals)), record));
        id layer = record->renderLayer;
        id object = [layer hyperObject];
        description = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("<generic%@>{hyper-object: <%@: 0x%lx> named \"%@\", render layer: <%@: 0x%lx>, role: %@, root flag: %s, transparency layer requirement addition flag: %s}"), indexes != NULL ? indexes : CFSTR(""), NSStringFromClass([object class]), (unsigned long)object, [[object queryHyperInterface:@protocol(HSObjectAttributes)] hyperName], NSStringFromClass([layer class]), (unsigned long)layer, record->u.generic.role, record->u.generic.isRoot ? "YES" : "NO", record->u.generic.addsTransparencyLayerRequirement ? "YES" : "NO");
    } else {
        CFMutableStringRef string = CFStringCreateMutable(kCFAllocatorDefault, 0);
        CFMutableStringRef layers;
        CFMutableStringRef mutableIndexes;
        if (originals == NULL) {
            mutableIndexes = NULL;
            layers = string;
        } else {
            layers = CFStringCreateMutable(kCFAllocatorDefault, 0);
            mutableIndexes = string;
            if (mutableIndexes != NULL)
                CFStringAppend(mutableIndexes, CFSTR(": ("));
        }
        if (layers != NULL)
            CFStringAppend(layers, CFSTR(", render sub-layers: ("));
        HSAppendPrivateGroupSubrecordDescriptions(layers, mutableIndexes, record, originals);
        if (mutableIndexes != NULL)
            CFStringAppend(mutableIndexes, CFSTR(")"));
        if (layers != NULL)
            CFStringAppend(layers, CFSTR(")"));
        indexes = mutableIndexes;
        id layer = record->renderLayer;
        description = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("<private group%@>{render layer: <%@: 0x%lx>%@}"), indexes != NULL ? indexes : CFSTR(""), NSStringFromClass([layer class]), (unsigned long)layer, layers != NULL ? (CFStringRef)layers : CFSTR(""));
        if (layers != NULL)
            CFRelease(layers);
    }
    if (indexes != NULL)
        CFRelease(indexes);
    return description;
}

static CFStringRef HSRenderSublayerGroupRecordCopyDescription(const void *aValue)
{
    HSRenderSublayerGroupRecord *group = (HSRenderSublayerGroupRecord *)aValue;
    CFArrayRef originals = HSDescribedOriginalRenderSublayerRecords();
    if (!group->isArray) {
        HSRenderSublayerRecord *record = group->content.record;
        const char *groupable = group->isGroupable ? "" : "non-groupable ";
        const char *bypassable = group->isBypassable ? "" : "non-bypassable ";
        if (originals == NULL)
            return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%s%s(%@)"), groupable, bypassable, HSDescriptionOfRenderSublayer(record));
        return CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%s%s(%ld) = (%@)"), groupable, bypassable, (long)CFArrayGetFirstIndexOfValue(originals, CFRangeMake(0, CFArrayGetCount(originals)), record), HSDescriptionOfRenderSublayer(record));
    }
    CFMutableStringRef string = CFStringCreateMutable(kCFAllocatorDefault, 0);
    if (string == NULL)
        return NULL;
    CFArrayRef records = group->content.records;
    CFIndex count = CFArrayGetCount(records);
    CFStringAppend(string, group->isBypassable ? CFSTR("(") : CFSTR("non-bypassable ("));
    if (originals != NULL) {
        CFRange range = CFRangeMake(0, CFArrayGetCount(originals));
        CFStringAppendFormat(string, NULL, CFSTR("%ld"), (long)CFArrayGetFirstIndexOfValue(originals, range, CFArrayGetValueAtIndex(records, 0)));
        for (CFIndex i = 1; i < count; i++) {
            CFStringAppend(string, CFSTR(", "));
            CFStringAppendFormat(string, NULL, CFSTR("%ld"), (long)CFArrayGetFirstIndexOfValue(originals, range, CFArrayGetValueAtIndex(records, i)));
        }
        CFStringAppend(string, CFSTR(") = ("));
    }
    for (CFIndex i = 0; ; i++) {
        CFStringAppend(string, (CFStringRef)HSDescriptionOfRenderSublayer((HSRenderSublayerRecord *)CFArrayGetValueAtIndex(records, i)));
        if (i == count - 1)
            break;
        CFStringAppend(string, CFSTR(", "));
    }
    CFStringAppend(string, CFSTR(")"));
    CFStringRef description = CFStringCreateCopy(kCFAllocatorDefault, string);
    CFRelease(string);
    return description;
}

#pragma mark Private group registry helpers

static const void *HSRegisteredPrivateGroupRecordRetain(CFAllocatorRef aAllocator, const void *aValue)
{
    ((HSRenderSublayerRecord *)aValue)->retainCount++;
    return aValue;
}

static void HSRegisteredPrivateGroupRecordRelease(CFAllocatorRef aAllocator, const void *aValue)
{
    HSRenderSublayerRecordDecrement((HSRenderSublayerRecord *)aValue);
}

// private group render layer -> private group record (the registry holds the
// records without their layers, which it references weakly)
static const CFDictionaryValueCallBacks HSRegisteredPrivateGroupRecordValueCallBacks = {
    0, HSRegisteredPrivateGroupRecordRetain, HSRegisteredPrivateGroupRecordRelease, HSRenderSublayerRecordCopyDescription, NULL
};

typedef struct {
    CFMutableDictionaryRef map;
    HSRenderSublayerRecord *record;
    id registry;
} HSPrivateGroupSharingContext;

// Maps each generic sublayer of a private group (nested groups included) to
// the private group's record.
static void HSRegisterPrivateGroupSubrecord(const void *aValue, void *aContext)
{
    HSRenderSublayerRecord *subrecord = (HSRenderSublayerRecord *)aValue;
    HSPrivateGroupSharingContext *context = aContext;
    if (!subrecord->isPrivateGroup) {
        CFMutableDictionaryRef records = (CFMutableDictionaryRef)CFDictionaryGetValue(context->map, subrecord->renderLayer);
        if (records == NULL) {
            records = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &HSRegisteredPrivateGroupRecordValueCallBacks);
            if (records == NULL)
                return;
            CFDictionaryAddValue(context->map, subrecord->renderLayer, records);
            CFRelease(records);
        }
        CFDictionaryAddValue(records, context->record->renderLayer, context->record);
        [context->record->renderLayer registerWeakReferencer:context->registry];
    } else {
        CFArrayRef records = [subrecord->renderLayer HSGenericGroupRenderLayer_renderSublayerRecords];
        CFArrayApplyFunction(records, CFRangeMake(0, CFArrayGetCount(records)), HSRegisterPrivateGroupSubrecord, aContext);
    }
}

static void HSCountSharedPrivateGroupRecord(const void *aKey, const void *aValue, void *aContext)
{
    CFMutableDictionaryRef countedSet = aContext;
    NSUInteger count = (NSUInteger)CFDictionaryGetValue(countedSet, aValue);
    CFDictionarySetValue(countedSet, aValue, (const void *)(count + 1));
}

typedef struct {
    id object;
    CFMutableDataRef emptiedKeys;
} HSPrivateGroupDereferencingContext;

// Forgets a deallocated private group layer. Sublayers whose only private
// group it was are collected, to be removed after the enumeration.
static void HSDereferencePrivateGroupRenderLayer(const void *aKey, const void *aValue, void *aContext)
{
    CFMutableDictionaryRef records = (CFMutableDictionaryRef)aValue;
    HSPrivateGroupDereferencingContext *context = aContext;
    if (CFDictionaryGetCount(records) == 1) {
        if (!CFDictionaryContainsKey(records, context->object))
            return;
        if (context->emptiedKeys == NULL)
            context->emptiedKeys = CFDataCreateMutable(kCFAllocatorDefault, 0);
        if (context->emptiedKeys != NULL) {
            CFDataAppendBytes(context->emptiedKeys, (const UInt8 *)&aKey, sizeof(aKey));
            return;
        }
    }
    CFDictionaryRemoveValue(records, context->object);
}

static void HSUnregisterFromPrivateGroupRenderLayer(const void *aKey, const void *aValue, void *aContext)
{
    [(id)aKey unregisterWeakReferencer:aContext];
}

static void HSUnregisterFromPrivateGroupRenderLayers(const void *aKey, const void *aValue, void *aContext)
{
    CFDictionaryApplyFunction((CFDictionaryRef)aValue, HSUnregisterFromPrivateGroupRenderLayer, aContext);
}

#pragma mark -

@implementation HSGenericGroupRenderLayer

// Stops grouping until the records are next asked for: drops the attributes
// watched for continuous changes and marks the records invalid.
static void HSInvalidateAutogrouping(HSGenericGroupRenderLayer *self)
{
    if (self->_autogroupsRenderSublayersForEfficientCaching && self->_areRenderSublayersRecordsValid) {
        if (self->_areRenderSublayersAutogroupedForEfficientCaching) {
            [self->_visualizationAttributesExpectedToChangeContinuously removeObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesDidChangeContinuously:) ofChanges:HSActualDidAttributeChanges];
            [self->_visualizationAttributesExpectedToChangeContinuously removeAllAttributes];
        }
        self->_areRenderSublayersRecordsValid = NO;
    }
}

static void HSRaiseBeyondCapacity(void)
{
    [NSException raise:NSRangeException format:@"Trying to add sub-layer beyond layer's capacity."];
}

+ (void)HSGenericGroupRenderLayer_addSharedPrivateGroupRenderSublayerRecordsWithRenderLayer:(id)aLayer toCountedSet:(struct __CFDictionary **)aSet
{
    [sHSPrivateGroupRenderLayerRegistry addSharedPrivateGroupRenderSublayerRecordsWithRenderLayer:aLayer toCountedSet:aSet];
}

+ (void)HSGenericGroupRenderLayer_sharePrivateGroupRenderSublayerRecord:(struct HyperPlayerBase_anon11 *)aRecord
{
    if (sHSPrivateGroupRenderLayerRegistry == nil) {
        sHSPrivateGroupRenderLayerRegistry = [[HSGenericGroupRenderLayer_HSPrivateGroupRenderLayerRegistry alloc] init];
        if (sHSPrivateGroupRenderLayerRegistry == nil)
            return;
    }
    [sHSPrivateGroupRenderLayerRegistry sharePrivateGroupRenderSublayerRecord:aRecord];
}

- (void)renderLayerWantsToReexpand:(id)aReexpand
{
    [self notifyObserversWithSelector:@selector(renderLayerWantsToReexpand:)];
}

- (void)renderLayerDidChangeBoundingRegion:(id)aRegion
{
    if (_renderSublayersOperationGroupCounter == 0) {
        [self boundingRegionDidChange];
        HSInvalidateAutogrouping(self);
    }
}

- (void)renderLayerDidChangeVisualizationMaskAttributesSet:(id)aSet
{
    if (_renderSublayersOperationGroupCounter == 0)
        [self visualizationMaskAttributesSetDidChange:nil];
}

- (void)renderLayerDidChangeVisualizationAttributesSet:(id)aSet
{
    if (_renderSublayersOperationGroupCounter == 0)
        [self renderSublayersVisualizationAttributesSetDidChange];
}

// The lowest validness, the merged evaluator and the union of the inclusion
// flags of the sublayers the region reaches.
- (void)getRenderCacheValidness:(float *)aValidness validnessEvaluator:(id *)aEvaluator includeScaling:(BOOL *)aScaling includeSkewing:(BOOL *)aSkewing includeRotation:(BOOL *)aRotation includeDevicePointAligning:(BOOL *)aAligning forRegion:(id)aRegion affineTransform:(CGAffineTransform)aTransform transformationIntent:(struct HyperPlayerBase_anon12 *)aIntent
{
    if (aValidness == NULL && aEvaluator == NULL && aScaling == NULL && aSkewing == NULL && aRotation == NULL && aAligning == NULL)
        return;
    CFArrayRef records = [self HSGenericGroupRenderLayer_renderSublayerRecords];
    CFIndex count = CFArrayGetCount(records);
    if (aValidness != NULL)
        *aValidness = 1.0;
    if (aEvaluator != NULL)
        *aEvaluator = nil;
    if (aScaling != NULL)
        *aScaling = NO;
    if (aSkewing != NULL)
        *aSkewing = NO;
    if (aRotation != NULL)
        *aRotation = NO;
    if (aAligning != NULL)
        *aAligning = NO;
    for (CFIndex i = 0; i < count; i++) {
        HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_renderSublayerRecords, i);
        id layer = record->renderLayer;
        HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
        CGAffineTransform transform = aTransform;
        id geometry = HSRenderSublayerRecordGeometryAttributes(record);
        if (geometry != nil) {
            CGAffineTransform geometryTransform = [geometry affineTransform];
            transform = CGAffineTransformConcat(geometryTransform, aTransform);
            [region applyAffineTransform:CGAffineTransformInvert(geometryTransform)];
        }
        [region intersectRegion:[layer boundingRegion]];
        if ([region isEmpty])
            continue;
        float validness = 0.0;
        id evaluator = nil;
        BOOL scaling = NO, skewing = NO, rotation = NO, aligning = NO;
        [layer getRenderCacheValidness:(aValidness != NULL ? &validness : NULL) validnessEvaluator:(aEvaluator != NULL ? &evaluator : NULL) includeScaling:(aScaling != NULL ? &scaling : NULL) includeSkewing:(aSkewing != NULL ? &skewing : NULL) includeRotation:(aRotation != NULL ? &rotation : NULL) includeDevicePointAligning:(aAligning != NULL ? &aligning : NULL) forRegion:region affineTransform:transform transformationIntent:aIntent];
        if (aValidness != NULL && validness < *aValidness)
            *aValidness = validness;
        if (aEvaluator != NULL && evaluator != nil)
            *aEvaluator = (*aEvaluator != nil) ? [*aEvaluator validnessEvaluatorByMergingWithValidnessEvaluator:evaluator] : evaluator;
        if (aScaling != NULL)
            *aScaling = *aScaling || scaling;
        if (aSkewing != NULL)
            *aSkewing = *aSkewing || skewing;
        if (aRotation != NULL)
            *aRotation = *aRotation || rotation;
        if (aAligning != NULL)
            *aAligning = *aAligning || aligning;
    }
}

// Influence 2: caches if every sublayer the region reaches caches; influence
// 1: if any of them does.
- (BOOL)willCacheRenderingInRegion:(id)aRegion withTransformationIntent:(struct HyperPlayerBase_anon12 *)aIntent countOnRenderSublayersInfluence:(NSInteger)aInfluence force:(BOOL)aForce
{
    if ([super willCacheRenderingInRegion:aRegion withTransformationIntent:aIntent countOnRenderSublayersInfluence:aInfluence force:aForce])
        return YES;
    if (aForce || (aInfluence != 1 && aInfluence != 2))
        return NO;
    CFArrayRef records = [self HSGenericGroupRenderLayer_renderSublayerRecords];
    CFIndex count = CFArrayGetCount(records);
    for (CFIndex i = 0; i < count; i++) {
        HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_renderSublayerRecords, i);
        id layer = record->renderLayer;
        HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
        id geometry = HSRenderSublayerRecordGeometryAttributes(record);
        if (geometry != nil)
            [region applyAffineTransform:CGAffineTransformInvert([geometry affineTransform])];
        [region intersectRegion:[layer boundingRegion]];
        if ([region isEmpty])
            continue;
        BOOL caches = [layer willCacheRenderingInRegion:region withTransformationIntent:aIntent countOnRenderSublayersInfluence:aInfluence force:NO];
        if (aInfluence == 2 && !caches)
            return NO;
        if (aInfluence == 1 && caches)
            return YES;
    }
    return aInfluence == 2;
}

- (void)drawRegion:(id)aRegion ofRenderSublayerAtIndex:(NSUInteger)aIndex withDelegate:(id)aDelegate
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id delegate = [aDelegate delegateForRenderSublayerAtIndex:aIndex];
    if (delegate != nil && ![delegate renderLayerShouldBeRenderedInRegion:aRegion]) {
        // fixed: the original returned without releasing the pool
        [pool release];
        return;
    }
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex([self HSGenericGroupRenderLayer_renderSublayerRecords], aIndex);
    id layer = record->renderLayer;
    CGAffineTransform transform = CGAffineTransformIdentity;
    id geometry = HSRenderSublayerRecordGeometryAttributes(record);
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    if (region != nil) {
        if (geometry != nil) {
            transform = [geometry affineTransform];
            [region applyAffineTransform:CGAffineTransformInvert(transform)];
        }
        id boundingRegion = [layer boundingRegion];
        if (boundingRegion != nil) {
            [region intersectRegion:boundingRegion];
            if (![region isEmpty]) {
                [NSGraphicsContext saveGraphicsState];
                CGContextConcatCTM([[NSGraphicsContext currentContext] CGContext], transform);
                if (delegate == nil || [delegate renderLayerShouldBeDrawnInRegion:region intoRenderCache:NO]) {
                    [NSGraphicsContext saveGraphicsState];
                    [layer drawRegion:region withDelegate:delegate];
                    [NSGraphicsContext restoreGraphicsState];
                    [delegate renderLayerIsDrawnInRegion:region intoRenderCache:NO];
                }
                [NSGraphicsContext restoreGraphicsState];
            }
        }
    }
    [delegate renderLayerIsRenderedInRegion:aRegion];
    [pool release];
}

- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    CFIndex count = CFArrayGetCount([self HSGenericGroupRenderLayer_renderSublayerRecords]);
    _sublayersDrawingCounter++;
    for (CFIndex i = 0; i < count; i++)
        [self drawRegion:aRegion ofRenderSublayerAtIndex:i withDelegate:aDelegate];
    _sublayersDrawingCounter--;
}

- (BOOL)unionBoundingRegionOfSublayersVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    CFIndex count = CFArrayGetCount(_renderSublayerRecords);
    BOOL result = NO;
    for (CFIndex i = 0; i < count; i++) {
        if ([self HSGenericGroupRenderLayer_unionBoundingRegionOfConcreteAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo inSublayerAtIndex:i withRegion:aRegion])
            result = YES;
    }
    return result;
}

- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    return NO;
}

// A root sublayer of the object itself bounds the object's geometry with its
// whole bounding region.
- (BOOL)HSGenericGroupRenderLayer_unionBoundingRegionOfConcreteAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo inSublayerAtIndex:(NSUInteger)aIndex withRegion:(id *)aRegion
{
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_renderSublayerRecords, aIndex);
    id layer = record->renderLayer;
    if (record->isPrivateGroup)
        return [layer unionBoundingRegionOfConcreteAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
    BOOL isRoot = record->u.generic.isRoot;
    id geometry = HSRenderSublayerRecordGeometryAttributes(record);
    if (isRoot && [aObject hyperIdentifier] == [[layer hyperObject] hyperIdentifier] && [aSet containsProtocol:@protocol(HSGeometryAttribute)]) {
        if (geometry == nil) {
            if (*aRegion == nil)
                *aRegion = [HSMutableRegion region];
            return [layer unionBoundingRegionWithRegion:*aRegion];
        }
        HSMutableRegion *region = [HSMutableRegion region];
        if (![layer unionBoundingRegionWithRegion:region])
            return NO;
        [region applyAffineTransform:[geometry affineTransform]];
        if (*aRegion == nil)
            *aRegion = region;
        else
            [*aRegion addRegion:region];
        return YES;
    }
    if (geometry == nil)
        return [layer unionBoundingRegionOfConcreteAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:aRegion];
    HSMutableRegion *region = nil;
    if (![layer unionBoundingRegionOfConcreteAttributeSet:aSet ofHyperObject:aObject withInfo:aInfo withRegion:&region])
        return NO;
    [region applyAffineTransform:[geometry affineTransform]];
    if (*aRegion == nil)
        *aRegion = region;
    else
        [*aRegion addRegion:region];
    return YES;
}

- (id)calculateBoundingRegion
{
    HSMutableRegion *region = [HSMutableRegion region];
    CFIndex count = CFArrayGetCount(_renderSublayerRecords);
    for (CFIndex i = 0; i < count; i++)
        [self HSGenericGroupRenderLayer_unionBoundingRegionOfSublayerAtIndex:i withRegion:region];
    return [[region copy] autorelease];
}

- (BOOL)HSGenericGroupRenderLayer_unionBoundingRegionOfSublayerAtIndex:(NSUInteger)aIndex withRegion:(id)aRegion
{
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_renderSublayerRecords, aIndex);
    id geometry = HSRenderSublayerRecordGeometryAttributes(record);
    if (geometry == nil)
        return [record->renderLayer unionBoundingRegionWithRegion:aRegion];
    HSMutableRegion *region = [HSMutableRegion region];
    if (![record->renderLayer unionBoundingRegionWithRegion:region])
        return NO;
    [region applyAffineTransform:[geometry affineTransform]];
    [aRegion addRegion:region];
    return YES;
}

- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    CFArrayApplyFunction(_renderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_renderSublayerRecords)), HSAddBoundingRegionAttributes, aSet);
}

// The first sublayer is drawn straight into the destination; a later one
// needs a transparency layer when it needs one itself or adds the
// requirement while not empty.
- (BOOL)requiresTransparencyLayer
{
    CFArrayRef records = [self HSGenericGroupRenderLayer_renderSublayerRecords];
    CFIndex count = CFArrayGetCount(records);
    if (count == 0)
        return [super requiresTransparencyLayer];
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_renderSublayerRecords, 0);
    if ([record->renderLayer requiresTransparencyLayer])
        return YES;
    for (CFIndex i = 1; i < count; i++) {
        record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_renderSublayerRecords, i);
        id layer = record->renderLayer;
        if ([layer requiresTransparencyLayer])
            return YES;
        BOOL addsRequirement = NO;
        if (!record->isPrivateGroup)
            addsRequirement = record->u.generic.addsTransparencyLayerRequirement;
        else {
            NSUInteger sublayerCount = [layer renderSublayerCount];
            for (NSUInteger j = 0; j < sublayerCount; j++) {
                if ([layer transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:j]) {
                    addsRequirement = YES;
                    break;
                }
            }
        }
        if (addsRequirement && ![layer isEmpty])
            return YES;
    }
    return NO;
}

- (BOOL)isEmpty
{
    CFIndex count = CFArrayGetCount(_renderSublayerRecords);
    for (CFIndex i = 0; i < count; i++) {
        if (![((HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_renderSublayerRecords, i))->renderLayer isEmpty])
            return NO;
    }
    return YES;
}

// Ends a group of sublayer changes: notifies the visualization attribute
// changes saved at the beginning, then the bounding region change.
- (void)endRenderSublayersOperationGroup
{
    if (--_renderSublayersOperationGroupCounter != 0)
        return;
    [self HSGenericGroupRenderLayer_invalidateRenderSublayersVisualizationAttributesSet];
    if (_savedVisualizationAttributes != nil) {
        HSMutableMultipleObjectsAttributeSet *attributes = [[[HSMutableMultipleObjectsAttributeSet alloc] init] autorelease];
        [self fillVisualizationAttributesSet:attributes];
        if (![_savedVisualizationAttributes isEqualToMultipleObjectsAttributeSet:attributes])
            [self visualizationAttributesSetDidChange:attributes];
        [_savedVisualizationAttributes release];
        _savedVisualizationAttributes = nil;
    }
    if (_savedVisualizationMaskAttributes != nil) {
        HSMutableMultipleObjectsAttributeSet *attributes = [[[HSMutableMultipleObjectsAttributeSet alloc] init] autorelease];
        [self fillVisualizationMaskAttributesSet:attributes];
        if (![_savedVisualizationMaskAttributes isEqualToMultipleObjectsAttributeSet:attributes])
            [self visualizationMaskAttributesSetDidChange:attributes];
        [_savedVisualizationMaskAttributes release];
        _savedVisualizationMaskAttributes = nil;
    }
    [self boundingRegionDidChange];
}

- (void)beginRenderSublayersOperationGroup
{
    if (_renderSublayersOperationGroupCounter == 0) {
        _savedVisualizationAttributes = [[self visualizationAttributes] copy];
        _savedVisualizationMaskAttributes = [[self visualizationMaskAttributes] copy];
        HSInvalidateAutogrouping(self);
    }
    _renderSublayersOperationGroupCounter++;
}

- (void)visualizationMaskAttributesSetDidChange:(id)aChange
{
    [super visualizationMaskAttributesSetDidChange:aChange];
    if (_savedVisualizationMaskAttributes != nil) {
        [_savedVisualizationMaskAttributes release];
        _savedVisualizationMaskAttributes = [[self visualizationMaskAttributes] copy];
    }
}

- (void)fillVisualizationMaskAttributesSet:(id)aSet
{
    CFArrayApplyFunction(_renderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_renderSublayerRecords)), HSAddVisualizationMaskAttributes, aSet);
}

- (void)visualizationAttributesSetDidChange:(id)aChange
{
    [super visualizationAttributesSetDidChange:aChange];
    if (_savedVisualizationAttributes != nil) {
        [_savedVisualizationAttributes release];
        _savedVisualizationAttributes = [[self visualizationAttributes] copy];
    }
}

- (void)renderSublayersVisualizationAttributesSetDidChange
{
    [self HSGenericGroupRenderLayer_invalidateRenderSublayersVisualizationAttributesSet];
    [self visualizationAttributesSetDidChange:nil];
}

// Also drops the observing session, which watches the old attribute set.
- (void)HSGenericGroupRenderLayer_invalidateRenderSublayersVisualizationAttributesSet
{
    if (_autogroupsRenderSublayersForEfficientCaching && _observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes != nil) {
        HSInvalidateAutogrouping(self);
        [_observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes removeObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesWillBeginDidEndChangeContinuously:)];
        [_observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes release];
        _observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes = nil;
    }
    [_renderSublayersVisualizationAttributes release];
    _renderSublayersVisualizationAttributes = nil;
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    [aSet unionMultipleObjectsAttributeSet:[self renderSublayersVisualizationAttributes]];
}

- (id)renderSublayersVisualizationAttributes
{
    if (_renderSublayersVisualizationAttributes == nil) {
        HSMutableMultipleObjectsAttributeSet *attributes = [[HSMutableMultipleObjectsAttributeSet alloc] init];
        [self fillRenderSublayersVisualizationAttributesSet:attributes];
        _renderSublayersVisualizationAttributes = [attributes copy];
        [attributes release];
    }
    return _renderSublayersVisualizationAttributes;
}

- (void)fillRenderSublayersVisualizationAttributesSet:(id)aSet
{
    CFArrayApplyFunction(_renderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_renderSublayerRecords)), HSAddVisualizationAttributes, aSet);
}

// Removes all sublayers, keeping them alive in the autoreleased old records
// array until the pool drains.
- (void)disperseRenderSublayers
{
    [self beginRenderSublayersOperationGroup];
    if (_renderSublayerRecords == _originalRenderSublayerRecords) {
        CFArrayApplyFunction(_originalRenderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_originalRenderSublayerRecords)), HSPreRemoveOriginalRenderSublayerRecord, self);
        _renderSublayerRecords = CFArrayCreateMutable(kCFAllocatorDefault, _renderSublayerCapacity, &HSRenderSublayerRecordArrayCallBacks);
        if (_renderSublayerRecords == NULL) {
            _renderSublayerRecords = _originalRenderSublayerRecords;
            CFArrayRemoveAllValues(_originalRenderSublayerRecords);
        } else {
            [(id)_originalRenderSublayerRecords autorelease];
            _originalRenderSublayerRecords = _renderSublayerRecords;
        }
    } else {
        CFArrayApplyFunction(_renderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_renderSublayerRecords)), HSPreRemoveRenderSublayerRecord, self);
        if (_autogroupsRenderSublayersForEfficientCaching)
            CFArrayApplyFunction(_originalRenderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_originalRenderSublayerRecords)), HSStopObservingRootGeometry, self);
        CFArrayRemoveAllValues(_originalRenderSublayerRecords);
        [(id)_renderSublayerRecords autorelease];
        _renderSublayerRecords = _originalRenderSublayerRecords;
    }
    _areRenderSublayersAutogroupedForEfficientCaching = NO;
    [self endRenderSublayersOperationGroup];
}

- (void)removeAllRenderSublayers
{
    [self HSGenericGroupRenderLayer_renderSublayerRecords];
    [self beginRenderSublayersOperationGroup];
    CFArrayApplyFunction(_renderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_renderSublayerRecords)), HSPreRemoveOriginalRenderSublayerRecord, self);
    CFArrayRemoveAllValues(_renderSublayerRecords);
    [self endRenderSublayersOperationGroup];
}

- (void)removeRenderSublayersInRange:(NSRange)aRange
{
    [self HSGenericGroupRenderLayer_renderSublayerRecords];
    [self beginRenderSublayersOperationGroup];
    CFArrayApplyFunction(_renderSublayerRecords, CFRangeMake(aRange.location, aRange.length), HSPreRemoveOriginalRenderSublayerRecord, self);
    CFArrayReplaceValues(_renderSublayerRecords, CFRangeMake(aRange.location, aRange.length), NULL, 0);
    [self endRenderSublayersOperationGroup];
}

- (void)removeRenderSublayerAtIndex:(NSUInteger)aIndex
{
    [self HSGenericGroupRenderLayer_renderSublayerRecords];
    [self beginRenderSublayersOperationGroup];
    [self HSGenericGroupRenderLayer_preRemoveRenderSublayerRecord:(HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_renderSublayerRecords, aIndex) asOriginal:YES];
    CFArrayRemoveValueAtIndex(_renderSublayerRecords, aIndex);
    [self endRenderSublayersOperationGroup];
}

- (void)addRenderSublayersFromRenderLayer:(id)aLayer range:(NSRange)aRange
{
    if (aRange.length == 0)
        return;
    [self HSGenericGroupRenderLayer_renderSublayerRecords];
    if (_renderSublayerCapacity != 0 && _renderSublayerCapacity < CFArrayGetCount(_renderSublayerRecords) + aRange.length)
        HSRaiseBeyondCapacity();
    [self beginRenderSublayersOperationGroup];
    for (NSUInteger index = aRange.location; index < NSMaxRange(aRange); index++) {
        BOOL transparencyLayerRequirement = [aLayer transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:index];
        BOOL root = [aLayer rootFlagOfRenderSublayerAtIndex:index];
        id role = [aLayer roleOfRenderSublayerAtIndex:index];
        id sublayer = [aLayer renderSublayerAtIndex:index];
        HSRenderSublayerRecord *record = HSCreateRenderSublayerRecord(sublayer, role, root, transparencyLayerRequirement);
        if (record != NULL) {
            CFArrayAppendValue(_renderSublayerRecords, record);
            [self HSGenericGroupRenderLayer_postAddRenderSublayerRecord:record asOriginal:YES];
            HSRenderSublayerRecordRelease(NULL, record);
        }
    }
    [self endRenderSublayersOperationGroup];
}

- (void)addRenderSublayersFromRenderLayer:(id)aLayer
{
    [self addRenderSublayersFromRenderLayer:aLayer range:NSMakeRange(0, [aLayer renderSublayerCount])];
}

// A nil role keeps the replaced sublayer's role.
- (void)replaceRenderSublayerAtIndex:(NSUInteger)aIndex withRenderSublayer:(id)aSublayer role:(id)aRole rootFlag:(BOOL)aFlag transparencyLayerRequirementAdditionFlag:(BOOL)aFlag2
{
    [self HSGenericGroupRenderLayer_renderSublayerRecords];
    [self beginRenderSublayersOperationGroup];
    HSRenderSublayerRecord *oldRecord = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_renderSublayerRecords, aIndex);
    id role = aRole;
    if (role == nil)
        role = oldRecord->isPrivateGroup ? HSPrivateGroupRenderLayerRole : oldRecord->u.generic.role;
    HSRenderSublayerRecord *record = HSCreateRenderSublayerRecord(aSublayer, role, aFlag, aFlag2);
    if (record != NULL) {
        [self HSGenericGroupRenderLayer_preRemoveRenderSublayerRecord:oldRecord asOriginal:YES];
        CFArrayReplaceValues(_renderSublayerRecords, CFRangeMake(aIndex, 1), (const void **)&record, 1);
        [self HSGenericGroupRenderLayer_postAddRenderSublayerRecord:record asOriginal:YES];
        HSRenderSublayerRecordRelease(NULL, record);
    }
    [self endRenderSublayersOperationGroup];
}

- (void)insertRenderSublayer:(id)aSublayer atIndex:(NSUInteger)aIndex forRole:(id)aRole asRoot:(BOOL)aRoot addingTransparencyLayerRequirement:(BOOL)aRequirement
{
    [self HSGenericGroupRenderLayer_renderSublayerRecords];
    if (![self HSGenericGroupRenderLayer_checkSublayerIncrement])
        HSRaiseBeyondCapacity();
    HSRenderSublayerRecord *record = HSCreateRenderSublayerRecord(aSublayer, aRole, aRoot, aRequirement);
    if (record == NULL)
        return;
    [self beginRenderSublayersOperationGroup];
    CFArrayInsertValueAtIndex(_renderSublayerRecords, aIndex, record);
    [self HSGenericGroupRenderLayer_postAddRenderSublayerRecord:record asOriginal:YES];
    HSRenderSublayerRecordRelease(NULL, record);
    [self endRenderSublayersOperationGroup];
}

- (void)addRenderSublayer:(id)aSublayer forRole:(id)aRole asRoot:(BOOL)aRoot addingTransparencyLayerRequirement:(BOOL)aRequirement
{
    [self HSGenericGroupRenderLayer_renderSublayerRecords];
    if (![self HSGenericGroupRenderLayer_checkSublayerIncrement])
        HSRaiseBeyondCapacity();
    HSRenderSublayerRecord *record = HSCreateRenderSublayerRecord(aSublayer, aRole, aRoot, aRequirement);
    if (record == NULL)
        return;
    [self beginRenderSublayersOperationGroup];
    CFArrayAppendValue(_renderSublayerRecords, record);
    [self HSGenericGroupRenderLayer_postAddRenderSublayerRecord:record asOriginal:YES];
    HSRenderSublayerRecordRelease(NULL, record);
    [self endRenderSublayersOperationGroup];
}

// A private group adds the requirement when any of its sublayers does.
- (BOOL)transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex([self HSGenericGroupRenderLayer_renderSublayerRecords], aIndex);
    if (!record->isPrivateGroup)
        return record->u.generic.addsTransparencyLayerRequirement;
    id layer = record->renderLayer;
    NSUInteger count = [layer renderSublayerCount];
    for (NSUInteger i = 0; i < count; i++) {
        if ([layer transparencyLayerRequirementAdditionFlagOfRenderSublayerAtIndex:i])
            return YES;
    }
    return NO;
}

- (BOOL)rootFlagOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex([self HSGenericGroupRenderLayer_renderSublayerRecords], aIndex);
    return !record->isPrivateGroup && record->u.generic.isRoot;
}

- (id)roleOfRenderSublayerAtIndex:(NSUInteger)aIndex
{
    HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex([self HSGenericGroupRenderLayer_renderSublayerRecords], aIndex);
    return record->isPrivateGroup ? HSPrivateGroupRenderLayerRole : record->u.generic.role;
}

- (id)renderSublayerAtIndex:(NSUInteger)aIndex
{
    return ((HSRenderSublayerRecord *)CFArrayGetValueAtIndex([self HSGenericGroupRenderLayer_renderSublayerRecords], aIndex))->renderLayer;
}

- (NSUInteger)renderSublayerCount
{
    return CFArrayGetCount([self HSGenericGroupRenderLayer_renderSublayerRecords]);
}

- (id)renderSublayers
{
    CFIndex count = CFArrayGetCount([self HSGenericGroupRenderLayer_renderSublayerRecords]);
    NSMutableArray *sublayers = [NSMutableArray arrayWithCapacity:count];
    for (CFIndex i = 0; i < count; i++)
        [sublayers addObject:((HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_renderSublayerRecords, i))->renderLayer];
    return [[sublayers copy] autorelease];
}

- (BOOL)HSGenericGroupRenderLayer_checkSublayerIncrement
{
    if (_renderSublayerCapacity == 0)
        return YES;
    return CFArrayGetCount([self HSGenericGroupRenderLayer_renderSublayerRecords]) + 1 <= _renderSublayerCapacity;
}

- (NSUInteger)renderSublayerCapacity
{
    return _renderSublayerCapacity;
}

- (void)disableAutogroupingOfRenderSublayersForEfficientCaching
{
    CFArrayApplyFunction(_originalRenderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_originalRenderSublayerRecords)), HSStopObservingRootGeometry, self);
    if (_observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes != nil) {
        if (_areRenderSublayersRecordsValid && _areRenderSublayersAutogroupedForEfficientCaching) {
            [_visualizationAttributesExpectedToChangeContinuously removeObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesDidChangeContinuously:) ofChanges:HSActualDidAttributeChanges];
            _areRenderSublayersRecordsValid = NO;
        }
        [_observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes removeObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesWillBeginDidEndChangeContinuously:)];
        [_observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes release];
        _observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes = nil;
    }
    [_visualizationAttributesExpectedToChangeContinuously release];
    _visualizationAttributesExpectedToChangeContinuously = nil;
    _autogroupsRenderSublayersForEfficientCaching = NO;
}

- (void)enableAutogroupingOfRenderSublayersForEfficientCaching
{
    _areRenderSublayersRecordsValid = NO;
    _autogroupsRenderSublayersForEfficientCaching = YES;
    _observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes = [[[self renderSublayersVisualizationAttributes] sharedObservingSessionForChanges:HSContinuousAttributeChanges withPriority:0.25] retain];
    [_observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes addObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesWillBeginDidEndChangeContinuously:)];
    CFArrayApplyFunction(_originalRenderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_originalRenderSublayerRecords)), HSObserveRootGeometry, self);
}

- (void)setAutogroupsRenderSublayersForEfficientCaching:(BOOL)aCaching
{
    if (_autogroupsRenderSublayersForEfficientCaching && !aCaching)
        [self disableAutogroupingOfRenderSublayersForEfficientCaching];
    else if (!_autogroupsRenderSublayersForEfficientCaching && aCaching)
        [self enableAutogroupingOfRenderSublayersForEfficientCaching];
}

- (BOOL)autogroupsRenderSublayersForEfficientCaching
{
    return _autogroupsRenderSublayersForEfficientCaching;
}

// An attribute expected to change continuously did change: regroup.
- (void)HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesDidChangeContinuously:(id)aContinuously
{
    [_visualizationAttributesExpectedToChangeContinuously removeObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesDidChangeContinuously:) ofChanges:HSActualDidAttributeChanges];
    [_visualizationAttributesExpectedToChangeContinuously removeAllAttributes];
    _areRenderSublayersRecordsValid = NO;
}

// While grouped, attributes beginning to change continuously are watched (a
// later actual change regroups); attributes ending their continuous change
// stop being watched, or regroup when they weren't expected.
- (void)HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesWillBeginDidEndChangeContinuously:(id)aContinuously
{
    if ([aContinuously attributeChange] == HSWillBeginContinuousAttributeChange) {
        if (!_areRenderSublayersRecordsValid || !_areRenderSublayersAutogroupedForEfficientCaching)
            return;
        if (_visualizationAttributesExpectedToChangeContinuously == nil) {
            _visualizationAttributesExpectedToChangeContinuously = [[HSMutableMultipleObjectsAttributeSet alloc] init];
            if (_visualizationAttributesExpectedToChangeContinuously == nil)
                return;
        }
        id object = [aContinuously object];
        id controller = nil;
        for (id attribute in [aContinuously attributeProtocolSet]) {
            if ([_visualizationAttributesExpectedToChangeContinuously containsAttribute:attribute forObject:object])
                continue;
            if (controller == nil)
                controller = [[object queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
            [controller addObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesDidChangeContinuously:) ofChanges:HSActualDidAttributeChanges ofAttribute:attribute withPriority:0.25];
            [_visualizationAttributesExpectedToChangeContinuously addAttribute:attribute forObject:object];
        }
        return;
    }
    if (!_areRenderSublayersRecordsValid)
        return;
    if (_areRenderSublayersAutogroupedForEfficientCaching && _visualizationAttributesExpectedToChangeContinuously != nil) {
        id object = [aContinuously object];
        id attributes = [aContinuously attributeProtocolSet];
        id expectedAttributes = [_visualizationAttributesExpectedToChangeContinuously attributesForObject:object];
        if (expectedAttributes != nil && [attributes isSubsetOfProtocolSet:expectedAttributes]) {
            id controller = [[object queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
            id continuousAttributes = [controller attributesBeingChangedContinuously];
            for (id attribute in attributes) {
                if (![continuousAttributes containsProtocol:attribute]) {
                    [controller removeObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesDidChangeContinuously:) ofChanges:HSActualDidAttributeChanges ofAttribute:attribute];
                    [_visualizationAttributesExpectedToChangeContinuously removeAttribute:attribute forObject:object];
                }
            }
            return;
        }
    }
    [_visualizationAttributesExpectedToChangeContinuously removeObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesDidChangeContinuously:) ofChanges:HSActualDidAttributeChanges];
    [_visualizationAttributesExpectedToChangeContinuously removeAllAttributes];
    _areRenderSublayersRecordsValid = NO;
}

// A root sublayer's geometry changed for real (not as part of a continuous
// change): regroup.
- (void)HSGenericGroupRenderLayer_rootGeometryAttributeDidChange:(id)aChange
{
    if (!_areRenderSublayersRecordsValid)
        return;
    id controller = [[[aChange object] queryHyperInterface:@protocol(HSAttributes)] attributeObservingController];
    if (controller == nil)
        return;
    id continuousAttributes = [controller attributesBeingChangedContinuously];
    if (continuousAttributes != nil && [[aChange attributeProtocolSet] isSubsetOfProtocolSet:continuousAttributes])
        return;
    if (_areRenderSublayersAutogroupedForEfficientCaching) {
        [_visualizationAttributesExpectedToChangeContinuously removeObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesDidChangeContinuously:) ofChanges:HSActualDidAttributeChanges];
        [_visualizationAttributesExpectedToChangeContinuously removeAllAttributes];
    }
    _areRenderSublayersRecordsValid = NO;
}

- (void)HSGenericGroupRenderLayer_ungroupRenderSublayersFromEfficientCaching
{
    if (_renderSublayerRecords != _originalRenderSublayerRecords) {
        CFRelease(_renderSublayerRecords);
        _renderSublayerRecords = _originalRenderSublayerRecords;
    }
    _areRenderSublayersAutogroupedForEfficientCaching = NO;
    _areRenderSublayersRecordsValid = YES;
}

// Groups the original records for caching. Walking the records in drawing
// order, each one joins the latest groups its bounding region overlaps when
// the merged bounding rect stays no larger than the parts (scanning back only
// across bypassable groups); records with changing geometry stay alone.
// Groups of several records become private group render layers, shared with
// other group layers grouping the same sublayers.
- (void)HSGenericGroupRenderLayer_groupRenderSublayersForEfficientCaching
{
    _renderSublayersOperationGroupCounter++;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    CFAllocatorRef allocator = kCFAllocatorDefault;
    CFIndex originalCount = CFArrayGetCount(_originalRenderSublayerRecords);
    CFMutableArrayRef groups = CFArrayCreateMutable(allocator, originalCount, &HSRenderSublayerGroupRecordArrayCallBacks);
    if (groups == NULL)
        goto finish;
    [(id)groups autorelease];
    CFMutableSetRef bypassableLayers = CFSetCreateMutable(allocator, originalCount, &kCFEWeakObjectPointerSetCallBacks);
    if (bypassableLayers == NULL)
        goto finish;
    [(id)bypassableLayers autorelease];

    BOOL didGroup = NO;
    for (CFIndex recordIndex = 0; recordIndex < originalCount; recordIndex++) {
        NSAutoreleasePool *recordPool = [NSAutoreleasePool new];
        HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_originalRenderSublayerRecords, recordIndex);
        BOOL mayBeBypassed = YES;
        if ([self HSGenericGroupRenderLayer_shouldExcludeRenderSublayerRecordFromAutogrouping:record mayBeBypassed:&mayBeBypassed]) {
            HSRenderSublayerGroupRecord *group = HSCreateRenderSublayerGroupRecord(record, NO, mayBeBypassed, nil, NSZeroRect, 0.0);
            if (group == NULL) {
                // fixed: the original left the record pool unreleased
                [recordPool release];
                break;
            }
            CFArrayAppendValue(groups, group);
            [recordPool release];
            continue;
        }
        id layer = record->renderLayer;
        if (mayBeBypassed)
            CFSetAddValue(bypassableLayers, layer);
        CFIndex groupCount = CFArrayGetCount(groups);
        if (groupCount == 0) {
            HSRenderSublayerGroupRecord *group = HSCreateRenderSublayerGroupRecord(record, YES, mayBeBypassed, nil, NSZeroRect, 0.0);
            if (group == NULL) {
                [recordPool release];
                break;
            }
            CFArrayAppendValue(groups, group);
            [recordPool release];
            continue;
        }

        HSMutableRegion *bestRegion = [[HSMutableRegion alloc] init];
        [layer unionBoundingRegionWithRegion:bestRegion];
        id geometry = HSRenderSublayerRecordGeometryAttributes(record);
        if (geometry != nil)
            [bestRegion applyAffineTransform:[geometry affineTransform]];
        NSRect bestRect = [bestRegion boundingRect];
        float bestArea = bestRect.size.width * bestRect.size.height;
        HSMutableRegion *mergedRegion = bestRegion;
        NSRect mergedRect = bestRect;
        float mergedArea = bestArea;
        CFMutableArrayRef mergedIndexes = NULL;
        CFIndex bestIndexCount = -1;
        for (CFIndex groupIndex = groupCount - 1; groupIndex >= 0; groupIndex--) {
            HSRenderSublayerGroupRecord *group = (HSRenderSublayerGroupRecord *)CFArrayGetValueAtIndex(groups, groupIndex);
            if (!group->isBypassable)
                break;
            if (group->region == nil) {
                // the region of a group is computed when first needed
                group->region = [[HSMutableRegion alloc] init];
                if (group->region != nil) {
                    if (!group->isArray)
                        HSAddRenderSublayerRecordRegion(group->content.record, group->region, YES);
                    else {
                        CFIndex count = CFArrayGetCount(group->content.records);
                        for (CFIndex i = 0; i < count; i++)
                            HSAddRenderSublayerRecordRegion((HSRenderSublayerRecord *)CFArrayGetValueAtIndex(group->content.records, i), group->region, NO);
                    }
                    group->rect = [group->region boundingRect];
                    group->area = group->rect.size.width * group->rect.size.height;
                }
            }
            id groupRegion = group->region;
            NSRect groupRect = groupRegion != nil ? group->rect : NSZeroRect;
            float groupArea = groupRegion != nil ? group->area : 0.0;
            float area = mergedArea;
            if ([groupRegion intersectsRegion:mergedRegion]) {
                if (!group->isGroupable)
                    break;
                NSRect unionRect = NSUnionRect(mergedRect, groupRect);
                area = unionRect.size.width * unionRect.size.height;
                if (mergedRegion == bestRegion && mergedArea + groupArea < area)
                    mergedRegion = [mergedRegion mutableCopy];
                [mergedRegion addRegion:groupRegion];
                mergedRect = unionRect;
                if (mergedIndexes == NULL) {
                    mergedIndexes = CFArrayCreateMutable(allocator, groupCount, &kCFEUnsignedIntegerArrayCallBacks);
                    if (mergedIndexes == NULL)
                        break;
                }
                if (area <= mergedArea + groupArea) {
                    bestIndexCount = CFArrayGetCount(mergedIndexes);
                    if (bestRegion != mergedRegion) {
                        [bestRegion release];
                        bestRegion = mergedRegion;
                    }
                    bestRect = mergedRect;
                    bestArea = area;
                }
                CFArrayAppendValue(mergedIndexes, (const void *)groupIndex);
            }
            mergedArea = area;
        }
        if (mergedRegion != bestRegion)
            [mergedRegion release];

        if (bestIndexCount == -1) {
            HSRenderSublayerGroupRecord *group = HSCreateRenderSublayerGroupRecord(record, YES, mayBeBypassed, bestRegion, bestRect, bestArea);
            if (group != NULL)
                CFArrayAppendValue(groups, group);
        } else {
            // merge the groups up to the best one into it, then the record
            HSRenderSublayerGroupRecord *target = (HSRenderSublayerGroupRecord *)CFArrayGetValueAtIndex(groups, (CFIndex)CFArrayGetValueAtIndex(mergedIndexes, bestIndexCount));
            for (CFIndex k = 0; k < bestIndexCount; k++) {
                // each removal shifts the later groups down
                CFIndex sourceIndex = (CFIndex)CFArrayGetValueAtIndex(mergedIndexes, bestIndexCount - 1 - k) - k;
                HSRenderSublayerGroupRecord *source = (HSRenderSublayerGroupRecord *)CFArrayGetValueAtIndex(groups, sourceIndex);
                if (HSMakeRenderSublayerGroupRecordArray(target)) {
                    if (source->isArray)
                        CFArrayAppendArray(target->content.records, source->content.records, CFRangeMake(0, CFArrayGetCount(source->content.records)));
                    else
                        CFArrayAppendValue(target->content.records, source->content.record);
                    if (!source->isBypassable)
                        target->isBypassable = NO;
                }
                CFArrayRemoveValueAtIndex(groups, sourceIndex);
            }
            if (HSMakeRenderSublayerGroupRecordArray(target)) {
                CFArrayAppendValue(target->content.records, record);
                if (!mayBeBypassed)
                    target->isBypassable = NO;
            }
            if (target->region != bestRegion) {
                [bestRegion retain];
                [target->region release];
                target->region = bestRegion;
            }
            target->rect = bestRect;
            target->area = bestArea;
            didGroup = YES;
        }
        if (mergedIndexes != NULL)
            CFRelease(mergedIndexes);
        [bestRegion release];
        [recordPool release];
    }

    if (didGroup) {
        CFIndex groupCount = CFArrayGetCount(groups);
        CFSetCallBacks recordSetCallBacks = {0, NULL, NULL, HSRenderSublayerRecordCopyDescription, NULL, NULL};
        CFMutableSetRef usedRecords = CFSetCreateMutable(allocator, groupCount, &recordSetCallBacks);
        if (usedRecords == NULL)
            goto finish;
        [(id)usedRecords autorelease];
        CFMutableArrayRef newRecords = CFArrayCreateMutable(allocator, groupCount, &HSRenderSublayerRecordArrayCallBacks);
        if (newRecords == NULL)
            goto finish;
        for (CFIndex groupIndex = 0; groupIndex < groupCount; groupIndex++) {
            NSAutoreleasePool *groupPool = [NSAutoreleasePool new];
            HSRenderSublayerGroupRecord *group = (HSRenderSublayerGroupRecord *)CFArrayGetValueAtIndex(groups, groupIndex);
            CFIndex subrecordCount = 0;
            if (!group->isArray || (subrecordCount = CFArrayGetCount(group->content.records)) == 1) {
                // a single record stays itself
                HSRenderSublayerRecord *record = group->isArray ? (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(group->content.records, 0) : group->content.record;
                CFArrayAppendValue(newRecords, record);
                CFSetAddValue(usedRecords, record);
                [groupPool release];
                continue;
            }
            CFArrayRef subrecords = group->content.records;
            // the shared private groups made only of these sublayers, largest
            // first
            CFMutableDictionaryRef countedSet = NULL;
            CFArrayApplyFunction(subrecords, CFRangeMake(0, subrecordCount), HSAddSharedPrivateGroupRenderSublayerRecords, &countedSet);
            CFMutableArrayRef candidates = NULL;
            CFIndex candidateCount = 0;
            if (countedSet != NULL) {
                HSSharedPrivateGroupCandidatesContext context = {2, &candidates};
                CFDictionaryApplyFunction(countedSet, HSCollectSharedPrivateGroupCandidate, &context);
                candidateCount = (candidates != NULL) ? CFArrayGetCount(candidates) : 0;
                CFRelease(countedSet);
            }
            CFIndex candidateIndex = 0;
            BOOL reused = NO;
            for (; candidateIndex < candidateCount; candidateIndex++) {
                HSRenderSublayerRecord *candidate = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(candidates, candidateIndex);
                if (candidate->u.privateGroup.subrecordCount < subrecordCount)
                    break;
                unsigned int firstIndex = 0, lastIndex = UINT_MAX;
                if ([self HSGenericGroupRenderLayer_areSharedGroupRenderSublayerSubrecords:[candidate->renderLayer HSGenericGroupRenderLayer_renderSublayerRecords] subgroupOfRenderSublayerRecords:(CFMutableArrayRef)subrecords withRenderSublayerBypassablenesses:bypassableLayers firstIndex:&firstIndex lastIndex:&lastIndex]) {
                    // a shared private group of exactly these sublayers
                    CFArrayAppendValue(newRecords, candidate);
                    CFSetAddValue(usedRecords, candidate);
                    reused = YES;
                    break;
                }
            }
            if (!reused) {
                HSGenericGroupRenderLayer *privateLayer = [[HSGenericGroupRenderLayer alloc] initWithHyperObject:[self hyperObject] renderSublayerCapacity:0 cachingPolicy:3];
                if (privateLayer != nil) {
                    HSRenderSublayerRecord *privateRecord = CFAllocatorAllocate(allocator, sizeof(HSRenderSublayerRecord), 0);
                    if (privateRecord == NULL)
                        [privateLayer release];
                    else {
                        privateRecord->renderLayer = [privateLayer retain];
                        privateRecord->u.privateGroup.subrecordCount = (unsigned int)subrecordCount;
                        privateRecord->isPrivateGroup = YES;
                        privateRecord->retainCount = 1;
                        [privateLayer release];
                        [privateLayer beginRenderSublayersOperationGroup];
                        CFMutableArrayRef privateRecords = (CFMutableArrayRef)[privateLayer HSGenericGroupRenderLayer_renderSublayerRecords];
                        CFArrayAppendArray(privateRecords, subrecords, CFRangeMake(0, subrecordCount));
                        // smaller shared private groups replace their sublayers
                        for (; candidateIndex < candidateCount; candidateIndex++) {
                            HSRenderSublayerRecord *candidate = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(candidates, candidateIndex);
                            id candidateLayer = candidate->renderLayer;
                            CFMutableArrayRef candidateRecords = (CFMutableArrayRef)[candidateLayer HSGenericGroupRenderLayer_renderSublayerRecords];
                            unsigned int firstIndex = 0, lastIndex = UINT_MAX;
                            if (![self HSGenericGroupRenderLayer_areSharedGroupRenderSublayerSubrecords:candidateRecords subgroupOfRenderSublayerRecords:privateRecords withRenderSublayerBypassablenesses:bypassableLayers firstIndex:&firstIndex lastIndex:&lastIndex])
                                continue;
                            unsigned int index;
                            for (index = firstIndex; index <= lastIndex; index++) {
                                if (!CFSetContainsValue(bypassableLayers, ((HSRenderSublayerRecord *)CFArrayGetValueAtIndex(privateRecords, index))->renderLayer))
                                    break;
                            }
                            if (index > lastIndex)
                                CFSetAddValue(bypassableLayers, candidateLayer);
                            if (![candidateLayer autogroupsRenderSublayersForEfficientCaching]) {
                                // flatten the private groups nested in the shared one
                                CFIndex count = CFArrayGetCount(candidateRecords);
                                for (CFIndex i = 0; i < count; i++) {
                                    HSRenderSublayerRecord *nested = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(candidateRecords, i);
                                    if (!nested->isPrivateGroup)
                                        continue;
                                    CFArrayRef nestedRecords = [nested->renderLayer HSGenericGroupRenderLayer_renderSublayerRecords];
                                    CFIndex nestedCount = CFArrayGetCount(nestedRecords);
                                    for (CFIndex j = 1; j < nestedCount; j++) {
                                        const void *nestedRecord = CFArrayGetValueAtIndex(nestedRecords, j);
                                        CFArrayInsertValueAtIndex(candidateRecords, i + j, nestedRecord);
                                        [candidateLayer HSGenericGroupRenderLayer_postAddRenderSublayerRecord:(HSRenderSublayerRecord *)nestedRecord asOriginal:YES];
                                    }
                                    const void *firstRecord = CFArrayGetValueAtIndex(nestedRecords, 0);
                                    [candidateLayer HSGenericGroupRenderLayer_preRemoveRenderSublayerRecord:nested asOriginal:YES];
                                    CFArrayReplaceValues(candidateRecords, CFRangeMake(i, 1), &firstRecord, 1);
                                    [candidateLayer HSGenericGroupRenderLayer_postAddRenderSublayerRecord:(HSRenderSublayerRecord *)firstRecord asOriginal:YES];
                                    count += nestedCount - 1;
                                    // Quirk kept: the original steps one record
                                    // past the flattened ones, so a private group
                                    // right after them stays nested.
                                    i += (nestedCount > 1) ? nestedCount : 1;
                                }
                            }
                            CFArrayReplaceValues(privateRecords, CFRangeMake(firstIndex, lastIndex + 1 - firstIndex), (const void **)&candidate, 1);
                        }
                        CFArrayApplyFunction(privateRecords, CFRangeMake(0, CFArrayGetCount(privateRecords)), HSPostAddOriginalRenderSublayerRecord, privateLayer);
                        [privateLayer endRenderSublayersOperationGroup];
                        [HSGenericGroupRenderLayer HSGenericGroupRenderLayer_sharePrivateGroupRenderSublayerRecord:privateRecord];
                        CFArrayAppendValue(newRecords, privateRecord);
                        [self HSGenericGroupRenderLayer_postAddRenderSublayerRecord:privateRecord asOriginal:NO];
                        HSRenderSublayerRecordRelease(NULL, privateRecord);
                    }
                }
            }
            if (candidates != NULL)
                CFRelease(candidates);
            [groupPool release];
        }
        // stop observing the dropped records, start observing the reused ones
        // that weren't current
        CFIndex usedCount = CFSetGetCount(usedRecords);
        CFIndex currentCount = CFArrayGetCount(_renderSublayerRecords);
        for (CFIndex i = 0; i < currentCount; i++) {
            NSAutoreleasePool *recordPool = [NSAutoreleasePool new];
            HSRenderSublayerRecord *record = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(_renderSublayerRecords, i);
            CFSetRemoveValue(usedRecords, record);
            CFIndex count = CFSetGetCount(usedRecords);
            if (usedCount == count)
                [self HSGenericGroupRenderLayer_preRemoveRenderSublayerRecord:record asOriginal:NO];
            else
                usedCount = count;
            [recordPool release];
        }
        CFSetApplyFunction(usedRecords, HSPostAddRenderSublayerRecord, self);
        if (_renderSublayerRecords != _originalRenderSublayerRecords)
            CFRelease(_renderSublayerRecords);
        _renderSublayerRecords = newRecords;
    } else if (_renderSublayerRecords != _originalRenderSublayerRecords) {
        CFArrayApplyFunction(_renderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_renderSublayerRecords)), HSUngroupPrivateRenderSublayerRecord, self);
        CFRelease(_renderSublayerRecords);
        _renderSublayerRecords = _originalRenderSublayerRecords;
    }
    _areRenderSublayersAutogroupedForEfficientCaching = didGroup;

finish:
    // fixed: the original left the pool unreleased when an allocation failed
    [pool release];
    _renderSublayersOperationGroupCounter--;
    _areRenderSublayersRecordsValid = YES;
    if (_observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes == nil) {
        _observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes = [[[self renderSublayersVisualizationAttributes] sharedObservingSessionForChanges:HSContinuousAttributeChanges withPriority:0.25] retain];
        [_observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes addObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesWillBeginDidEndChangeContinuously:)];
    }
}

// Whether the sublayers of a shared private group (nested groups included)
// are all in aRecords and can be gathered next to each other: records moved
// over must be bypassable and must not overlap the moved one. Returns the
// gathered range.
- (BOOL)HSGenericGroupRenderLayer_areSharedGroupRenderSublayerSubrecords:(struct __CFArray *)aSubrecords subgroupOfRenderSublayerRecords:(struct __CFArray *)aRecords withRenderSublayerBypassablenesses:(struct __CFSet *)aBypassablenesses firstIndex:(unsigned int *)aIndex lastIndex:(unsigned int *)aIndex2
{
    unsigned int recordCount = (unsigned int)CFArrayGetCount(aRecords);
    CFIndex subrecordCount = CFArrayGetCount(aSubrecords);
    for (CFIndex i = 0; i < subrecordCount; i++) {
        HSRenderSublayerRecord *subrecord = (HSRenderSublayerRecord *)CFArrayGetValueAtIndex(aSubrecords, i);
        if (subrecord->isPrivateGroup) {
            if (![self HSGenericGroupRenderLayer_areSharedGroupRenderSublayerSubrecords:(CFMutableArrayRef)[subrecord->renderLayer HSGenericGroupRenderLayer_renderSublayerRecords] subgroupOfRenderSublayerRecords:aRecords withRenderSublayerBypassablenesses:aBypassablenesses firstIndex:aIndex lastIndex:aIndex2])
                return NO;
            continue;
        }
        unsigned int index = 0;
        while (index < recordCount && ((HSRenderSublayerRecord *)CFArrayGetValueAtIndex(aRecords, index))->renderLayer != subrecord->renderLayer)
            index++;
        if (index == recordCount)
            return NO;
        if (*aIndex2 == UINT_MAX) {
            *aIndex = index;
            *aIndex2 = index;
            continue;
        }
        id region = nil;
        if (index < *aIndex2) {
            // Quirk kept: the original exchanges the records after the found
            // one with those two places further, rather than moving it.
            unsigned int exchangeIndex = index + 2;
            index++;
            *aIndex2 = *aIndex2 + 1;
            for (; index < *aIndex2; index++, exchangeIndex++) {
                id layer = ((HSRenderSublayerRecord *)CFArrayGetValueAtIndex(aRecords, index))->renderLayer;
                if (!CFSetContainsValue(aBypassablenesses, layer))
                    return NO;
                if (region == nil)
                    region = [subrecord->renderLayer boundingRegion];
                if ([[layer boundingRegion] intersectsRegion:region])
                    return NO;
                CFArrayExchangeValuesAtIndices(aRecords, index, exchangeIndex);
            }
        } else {
            // move the found record down to just after the range
            for (unsigned int previous = index - 1; previous > *aIndex2; previous = index - 1) {
                id layer = ((HSRenderSublayerRecord *)CFArrayGetValueAtIndex(aRecords, previous))->renderLayer;
                if (!CFSetContainsValue(aBypassablenesses, layer))
                    return NO;
                if (region == nil)
                    region = [subrecord->renderLayer boundingRegion];
                if ([[layer boundingRegion] intersectsRegion:region])
                    return NO;
                CFArrayExchangeValuesAtIndices(aRecords, index, previous);
                index = previous;
            }
            *aIndex2 = *aIndex2 + 1;
        }
    }
    return YES;
}

static id HSDescriptionWithOriginalRenderSublayerRecords(CFArrayRef aOriginals, CFStringRef (*aDescription)(const void *), const void *aValue)
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSValue *originals = [NSValue valueWithPointer:aOriginals];
    CFStringRef description;
    if (originals == nil)
        description = aDescription(aValue);
    else {
        [threadDictionary setObject:originals forKey:HSOriginalRenderSublayerRecordsKey];
        description = aDescription(aValue);
        [threadDictionary removeObjectForKey:HSOriginalRenderSublayerRecordsKey];
    }
    return [(id)description autorelease];
}

static CFStringRef HSCopyDescriptionOfCFType(const void *aValue)
{
    return CFCopyDescription(aValue);
}

- (id)HSGenericGroupRenderLayer_descriptionForRenderSublayerRecords:(void *)aRecords
{
    return HSDescriptionWithOriginalRenderSublayerRecords(_originalRenderSublayerRecords, HSCopyDescriptionOfCFType, aRecords);
}

- (id)HSGenericGroupRenderLayer_descriptionForRenderSublayerGroupRecord:(struct HyperPlayerBase_anon14 *)aRecord
{
    return HSDescriptionWithOriginalRenderSublayerRecords(_originalRenderSublayerRecords, HSRenderSublayerGroupRecordCopyDescription, aRecord);
}

- (id)HSGenericGroupRenderLayer_descriptionForRenderSublayerRecord:(struct HyperPlayerBase_anon11 *)aRecord
{
    return HSDescriptionWithOriginalRenderSublayerRecords(_originalRenderSublayerRecords, HSRenderSublayerRecordCopyDescription, aRecord);
}

// Records whose geometry changes (temporarily or continuously) aren't
// grouped; flips, or changes the sublayer's visualization doesn't exclude,
// still let later records group across it.
- (BOOL)HSGenericGroupRenderLayer_shouldExcludeRenderSublayerRecordFromAutogrouping:(struct HyperPlayerBase_anon11 *)aAutogrouping mayBeBypassed:(BOOL *)aBypassed
{
    id visualizationAttributes = [aAutogrouping->renderLayer visualizationAttributes];
    NSEnumerator *enumerator = [visualizationAttributes objectEnumerator];
    id object;
    while ((object = [enumerator nextObject])) {
        id attributes = HSRenderSublayerRecordGeometryAttributes(aAutogrouping);
        if (attributes == nil)
            attributes = [object queryHyperInterface:@protocol(HSAttributes)];
        id controller = [attributes attributeObservingController];
        id temporaryAttributes = [controller attributesChangedTemporary];
        id continuousAttributes = [controller attributesBeingChangedContinuously];
        id changingAttributes = continuousAttributes;
        if ([temporaryAttributes count] != 0) {
            changingAttributes = temporaryAttributes;
            if ([continuousAttributes count] != 0) {
                changingAttributes = [[temporaryAttributes mutableCopy] autorelease];
                [changingAttributes unionProtocolSet:continuousAttributes];
            }
        }
        if ([changingAttributes containsProtocol:@protocol(HSWidthAttribute)] || [changingAttributes containsProtocol:@protocol(HSHeightAttribute)] || [changingAttributes containsProtocol:@protocol(HSHorizontalScaleAttribute)] || [changingAttributes containsProtocol:@protocol(HSVerticalScaleAttribute)] || [changingAttributes containsProtocol:@protocol(HSWidthScaleAttribute)] || [changingAttributes containsProtocol:@protocol(HSHeightScaleAttribute)] || [changingAttributes containsProtocol:@protocol(HSRotationAngleAttribute)] || [changingAttributes containsProtocol:@protocol(HSSkewAngleAttribute)] || [changingAttributes containsProtocol:@protocol(HSHorizontalOffsetAttribute)] || [changingAttributes containsProtocol:@protocol(HSVerticalOffsetAttribute)]) {
            *aBypassed = NO;
            return YES;
        }
        if ([changingAttributes containsProtocol:@protocol(HSHorizontalFlipAttribute)] || [changingAttributes containsProtocol:@protocol(HSVerticalFlipAttribute)] || ![visualizationAttributes excludesAttributeSet:changingAttributes forObject:object]) {
            *aBypassed = YES;
            return YES;
        }
    }
    *aBypassed = YES;
    return NO;
}

- (void)HSGenericGroupRenderLayer_preRemoveRenderSublayerRecord:(struct HyperPlayerBase_anon11 *)aRecord asOriginal:(BOOL)aOriginal
{
    id geometry = HSRenderSublayerRecordGeometryAttributes(aRecord);
    if (geometry != nil) {
        id controller = [geometry attributeObservingController];
        [self unlinkBoundingRegionFromAttribute:@protocol(HSGeometryAttribute) ofHyperObject:[geometry hyperObject] withAttributeObservingController:controller];
        if (aOriginal && _autogroupsRenderSublayersForEfficientCaching)
            [controller removeObserver:self selector:@selector(HSGenericGroupRenderLayer_rootGeometryAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute)];
    }
    [aRecord->renderLayer removeObserver:self];
}

- (void)HSGenericGroupRenderLayer_postAddRenderSublayerRecord:(struct HyperPlayerBase_anon11 *)aRecord asOriginal:(BOOL)aOriginal
{
    [aRecord->renderLayer addObserver:self];
    id geometry = HSRenderSublayerRecordGeometryAttributes(aRecord);
    if (geometry != nil) {
        id controller = [geometry attributeObservingController];
        [self linkBoundingRegionToAttribute:@protocol(HSGeometryAttribute) ofHyperObject:[geometry hyperObject] withAttributeObservingController:controller];
        if (aOriginal && _autogroupsRenderSublayersForEfficientCaching)
            [controller addObserver:self selector:@selector(HSGenericGroupRenderLayer_rootGeometryAttributeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSGeometryAttribute) withPriority:0.25];
    }
}

// The current records, regrouped or ungrouped first when invalid (not while
// drawing, nor inside an operation group).
- (struct __CFArray *)HSGenericGroupRenderLayer_renderSublayerRecords
{
    if (!_areRenderSublayersRecordsValid && _sublayersDrawingCounter == 0) {
        if (_autogroupsRenderSublayersForEfficientCaching) {
            if (_renderSublayersOperationGroupCounter == 0)
                [self HSGenericGroupRenderLayer_groupRenderSublayersForEfficientCaching];
        } else if (_areRenderSublayersAutogroupedForEfficientCaching)
            [self HSGenericGroupRenderLayer_ungroupRenderSublayersFromEfficientCaching];
        else
            _areRenderSublayersRecordsValid = YES;
    }
    return _renderSublayerRecords;
}

- (id)copyRemovingRenderSublayers
{
    return [[[self class] allocWithZone:[self zone]] initWithHyperObject:[self hyperObject] renderSublayerCapacity:_renderSublayerCapacity cachingPolicy:[self cachingPolicy]];
}

- (void)dealloc
{
    if (_autogroupsRenderSublayersForEfficientCaching) {
        if (_observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes != nil) {
            [_observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes removeObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesWillBeginDidEndChangeContinuously:)];
            [_observingSessionForContinuousChangesOfRenderSublayersAutogroupingAttributes release];
            if (_areRenderSublayersRecordsValid && _areRenderSublayersAutogroupedForEfficientCaching)
                [_visualizationAttributesExpectedToChangeContinuously removeObserver:self selector:@selector(HSGenericGroupRenderLayer_renderSublayersAutogroupingAttributesDidChangeContinuously:) ofChanges:HSActualDidAttributeChanges];
        }
        [_visualizationAttributesExpectedToChangeContinuously release];
    }
    [_renderSublayersVisualizationAttributes release];
    if (_originalRenderSublayerRecords != NULL) {
        if (_renderSublayerRecords == _originalRenderSublayerRecords)
            CFArrayApplyFunction(_renderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_renderSublayerRecords)), _autogroupsRenderSublayersForEfficientCaching ? HSStopObservingRootGeometryAndRenderSublayer : HSRemoveRenderSublayerObserver, self);
        else {
            CFArrayApplyFunction(_renderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_renderSublayerRecords)), HSRemoveRenderSublayerObserver, self);
            CFRelease(_renderSublayerRecords);
            if (_autogroupsRenderSublayersForEfficientCaching)
                CFArrayApplyFunction(_originalRenderSublayerRecords, CFRangeMake(0, CFArrayGetCount(_originalRenderSublayerRecords)), HSStopObservingRootGeometry, self);
        }
        CFRelease(_originalRenderSublayerRecords);
    }
    [super dealloc];
}

// A capacity of 0 means unlimited.
- (id)initWithHyperObject:(id)aObject renderSublayerCapacity:(NSUInteger)aCapacity cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _originalRenderSublayerRecords = CFArrayCreateMutable(kCFAllocatorDefault, aCapacity, &HSRenderSublayerRecordArrayCallBacks);
        if (_originalRenderSublayerRecords == NULL) {
            [self release];
            return nil;
        }
        _renderSublayerRecords = _originalRenderSublayerRecords;
        _renderSublayerCapacity = (unsigned int)aCapacity;
        _areRenderSublayersRecordsValid = YES;
    }
    return self;
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    return [self initWithHyperObject:aObject renderSublayerCapacity:0 cachingPolicy:aPolicy];
}

@end

// Maps sublayers to the shared private group records containing them:
// sublayer -> {private group render layer -> private group record}. Private
// group layers are referenced weakly and forgotten when deallocated.
@implementation HSGenericGroupRenderLayer_HSPrivateGroupRenderLayerRegistry

// Counts, per shared private group record containing the layer, one more
// sublayer found.
- (void)addSharedPrivateGroupRenderSublayerRecordsWithRenderLayer:(id)aLayer toCountedSet:(struct __CFDictionary **)aSet
{
    if (_renderLayerToPrivateGroupRenderSublayerRecordsMap == NULL)
        return;
    CFDictionaryRef records = CFDictionaryGetValue(_renderLayerToPrivateGroupRenderSublayerRecordsMap, aLayer);
    if (records == NULL)
        return;
    if (*aSet == NULL) {
        CFDictionaryKeyCallBacks keyCallBacks = {0, NULL, NULL, HSRenderSublayerRecordCopyDescription, NULL, NULL};
        *aSet = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &keyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (*aSet == NULL)
            return;
    }
    CFDictionaryApplyFunction(records, HSCountSharedPrivateGroupRecord, *aSet);
}

- (void)sharePrivateGroupRenderSublayerRecord:(struct HyperPlayerBase_anon11 *)aRecord
{
    if (_renderLayerToPrivateGroupRenderSublayerRecordsMap == NULL) {
        _renderLayerToPrivateGroupRenderSublayerRecordsMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (_renderLayerToPrivateGroupRenderSublayerRecordsMap == NULL)
            return;
    }
    CFArrayRef records = [aRecord->renderLayer HSGenericGroupRenderLayer_renderSublayerRecords];
    HSPrivateGroupSharingContext context = {_renderLayerToPrivateGroupRenderSublayerRecordsMap, aRecord, self};
    CFArrayApplyFunction(records, CFRangeMake(0, CFArrayGetCount(records)), HSRegisterPrivateGroupSubrecord, &context);
}

- (void)dereferenceObject:(id)aObject
{
    if (_renderLayerToPrivateGroupRenderSublayerRecordsMap == NULL)
        return;
    HSPrivateGroupDereferencingContext context = {aObject, NULL};
    CFDictionaryApplyFunction(_renderLayerToPrivateGroupRenderSublayerRecordsMap, HSDereferencePrivateGroupRenderLayer, &context);
    if (context.emptiedKeys == NULL)
        return;
    CFIndex keyCount = CFDataGetLength(context.emptiedKeys) / sizeof(void *);
    if (CFDictionaryGetCount(_renderLayerToPrivateGroupRenderSublayerRecordsMap) == keyCount)
        CFDictionaryRemoveAllValues(_renderLayerToPrivateGroupRenderSublayerRecordsMap);
    else {
        const void *const *keys = (const void *const *)CFDataGetBytePtr(context.emptiedKeys);
        for (CFIndex i = 0; i < keyCount; i++)
            CFDictionaryRemoveValue(_renderLayerToPrivateGroupRenderSublayerRecordsMap, keys[i]);
    }
    CFRelease(context.emptiedKeys);
}

- (void)dealloc
{
    if (_renderLayerToPrivateGroupRenderSublayerRecordsMap != NULL) {
        CFDictionaryApplyFunction(_renderLayerToPrivateGroupRenderSublayerRecordsMap, HSUnregisterFromPrivateGroupRenderLayers, self);
        CFRelease(_renderLayerToPrivateGroupRenderSublayerRecordsMap);
    }
    [super dealloc];
}

@end
