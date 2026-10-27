#import "HSNode.h"
#import "HyperPlayerBaseData.h"
#import "HSFunctions.h"
#import "NSEMutableProtocolSet.h"
#import "HSProtocolIdentifier.h"

@interface NSObject (HSNodeSupportingMethods)
- (id)objectWithExtraDictionary:(id)aDictionary zone:(NSZone *)aZone codingContext:(id)aContext;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority;
- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofChildrenInDepthRange:(NSRange)aRange;
- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofChildrenInDepthRange:(NSRange)aRange withPriority:(CGFloat)aPriority;
- (void)removeAttributeObserver:(id)aObserver;
- (void)registerWeakReferencer:(id)aReferencer;
- (void)unregisterWeakReferencer:(id)aReferencer;
- (id)object;
- (void)setObject:(id)aObject;
- (id)owner;
- (id)nodeDataUID;
- (id)hyperUID;
- (id)stack;
- (id)mediaUID;
- (id)hyperComments;
- (void)setHyperComments:(id)aComments;
- (id)cardGroupController;
- (id)codingOperation;
- (id)pointer;
- (void)nodeContainer:(id)aContainer didAddChild:(id)aChild;
- (void)nodeContainer:(id)aContainer willRemoveChildren:(id)aChildren;
- (void)nodeContainer:(id)aContainer didRemoveChildren:(id)aChildren;
- (void)nodeContainer:(id)aContainer didChangeOrderForChild:(id)aChild;
- (void)nodeContainerAddChildrenBeginGrouping:(id)aContainer;
- (void)nodeContainerAddChildrenEndGrouping:(id)aContainer;
- (void)nodeContainerRemoveChildrenBeginGrouping:(id)aContainer;
- (void)nodeContainerRemoveChildrenEndGrouping:(id)aContainer;
@end

static NSString *HSNodeUndoName(NSString *aKey)
{
    return [[NSBundle mainBundle] localizedStringForKey:aKey value:@"" table:@"UndoManager"];
}

// The hash table of protocols wrapped by an HSPointer map value.
static NSHashTable *HSNodeProtocolTable(NSMapTable *aMap, const void *aKey)
{
    return (NSHashTable *)[(id)NSMapGet(aMap, aKey) pointer];
}

static void HSNodeCollectDeep(id aNode, NSMutableArray *aArray)
{
    [aArray addObject:aNode];
    NSEnumerator *enumerator = [aNode hyperEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        HSNodeCollectDeep(child, aArray);
}

static void HSNodeCollectDeepLoaded(id aNode, NSMutableArray *aArray)
{
    [aArray addObject:aNode];
    NSEnumerator *enumerator = [aNode hyperLoadedNodeEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        HSNodeCollectDeepLoaded(child, aArray);
}

static void HSNodeCollectReverseDeep(id aNode, NSMutableArray *aArray)
{
    NSEnumerator *enumerator = [aNode hyperReverseEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        HSNodeCollectReverseDeep(child, aArray);
    [aArray addObject:aNode];
}

// Notifies a node sharing the changed attributes through a common unit.
static void HSNodeNotifySharingNode(const void *aKey, const void *aValue, void *aContext)
{
    id node = (id)aKey;
    [node disableGroupCardObjectsNotificationPatchForNodeData];
    [node notifyChange:(NSInteger)aContext ofAttributeSet:(id)aValue withUserInfo:nil];
    [node enableGroupCardObjectsNotificationPatchForNodeData];
}

typedef void (*HSNodeRemoveObserverIMP)(id, SEL, id, SEL, NSUInteger, void *, id);

@implementation HSNode

+ (Class)nodeDataClass
{
    return [HSNodeData class];
}

+ (id)rootNodeWithFileWrapper:(id)aWrapper explicitNodeDataProvider:(id)aProvider error:(id *)aError
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id nodeWrapper = aWrapper;
    id node = nil;
    if ([aWrapper isDirectory]) {
        nodeWrapper = nil;
        NSEnumerator *enumerator = [[[aWrapper fileWrappers] allKeys] objectEnumerator];
        NSString *name;
        while ((name = [enumerator nextObject]) != nil) {
            if ([[name pathExtension] isEqualToString:[[aWrapper preferredFilename] pathExtension]]) {
                nodeWrapper = [[aWrapper fileWrappers] objectForKey:name];
                break;
            }
        }
    }
    if (nodeWrapper != nil) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[nodeWrapper hyperDictionaryRepresentation]];
        if (aProvider != nil)
            [dictionary setObject:aProvider forKey:HSExplicitNodeDataProviderKey];
        node = [[self nodeWithDictionary:dictionary children:nil explicitNodeDataProvider:nil codingContext:[EXCodingContext defaultCodingContext]] retain];
        [node setFileWrapperRepresentation:aWrapper];
    }
    [pool release];
    if (nodeWrapper == nil && aError != NULL)
        *aError = [HSError fileErrorWithHSCode:0x103 filePath:[aWrapper filename]];
    return [node autorelease];
}

+ (id)rootNodeWithChildren:(id)aChildren support:(id)aSupport
{
    id node = [[self new] autorelease];
    [node setChildren:aChildren];
    [node setSupport:aSupport];
    return node;
}

+ (id)nodeWithDictionary:(id)aDictionary children:(id)aChildren explicitNodeDataProvider:(id)aProvider codingContext:(id)aContext
{
    if (aProvider != nil) {
        aDictionary = [NSMutableDictionary dictionaryWithDictionary:aDictionary];
        [aDictionary setObject:aProvider forKey:HSExplicitNodeDataProviderKey];
    }
    id node = [self objectWithExtraDictionary:aDictionary zone:NULL codingContext:aContext];
    if (node != nil && aChildren != nil)
        [node setChildren:aChildren];
    return node;
}

+ (id)nodeWithDictionary:(id)aDictionary children:(id)aChildren
{
    return [self nodeWithDictionary:aDictionary children:aChildren explicitNodeDataProvider:nil codingContext:[EXCodingContext defaultCodingContext]];
}

+ (id)nodeWithDictionary:(id)aDictionary explicitNodeDataProvider:(id)aProvider
{
    return [self nodeWithDictionary:aDictionary children:nil explicitNodeDataProvider:aProvider codingContext:[EXCodingContext defaultCodingContext]];
}

+ (id)nodeWithDictionary:(id)aDictionary
{
    return [self nodeWithDictionary:aDictionary children:nil explicitNodeDataProvider:nil codingContext:[EXCodingContext defaultCodingContext]];
}

+ (id)nodeWithFileWrapper:(id)aWrapper explicitNodeDataProvider:(id)aProvider
{
    return [self rootNodeWithFileWrapper:aWrapper explicitNodeDataProvider:aProvider error:NULL];
}

+ (id)nodeWithChildren:(id)aChildren
{
    return [self rootNodeWithChildren:aChildren support:nil];
}

+ (id)node
{
    return [self nodeWithChildren:nil];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionary];
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    return NO;
}

- (id)HTML5UnsupportedFunctionalityDescription
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)shouldBeExportedAsImage
{
    return NO;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return NO;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    return nil;
}

- (id)childNodeWithNodeData:(id)aData
{
    NSEnumerator *enumerator = [[self children] objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        if ([child nodeData] == aData)
            return child;
    }
    return nil;
}

- (id)nextGroupNode
{
    NSUInteger index = [self hyperIndex];
    // Fix: an unbound node has no siblings (the original ran off the array).
    if (index == NSNotFound)
        return nil;
    NSUInteger count = [_parent hyperCount];
    while (++index < count) {
        id node = [_parent hyperChildAtIndex:index];
        if ([node sharedNodeDataUID] != nil)
            return node;
    }
    return nil;
}

- (id)previousGroupNode
{
    NSUInteger index = [self hyperIndex];
    if (index == NSNotFound)
        return nil;
    while (index-- > 0) {
        id node = [_parent hyperChildAtIndex:index];
        if ([node sharedNodeDataUID] != nil)
            return node;
    }
    return nil;
}

- (id)objectsWithNodeDataUID:(id)aUID
{
    return [NSArray arrayWithObject:self];
}

- (id)anyOwningObjectForNodeData:(id)aData
{
    return nil;
}

- (void)setExplicitNodeDataProvider:(id)aProvider
{
    // Fix: the previous provider was leaked.
    [aProvider retain];
    [_explicitNodeDataProvider release];
    _explicitNodeDataProvider = aProvider;
    [_nodeData release];
    _nodeData = nil;
}

- (id)nodeDataProvider
{
    if ([self support] == nil)
        return _explicitNodeDataProvider;
    id controller = [[self support] cardGroupController];
    if (controller != nil) {
        [_explicitNodeDataProvider release];
        _explicitNodeDataProvider = nil;
    }
    return controller;
}

- (void)setSharedNodeDataUID:(id)aUID
{
    if (aUID != nil && ![aUID isEqualTo:[_nodeData nodeDataUID]]) {
        [_nodeData release];
        _nodeData = nil;
    }
    [aUID retain];
    [_sharedNodeDataUID release];
    _sharedNodeDataUID = aUID;
}

- (id)sharedNodeDataUID
{
    return _sharedNodeDataUID;
}

- (void)setLocalNodeData:(id)aData
{
    [aData retain];
    [_localNodeData setOwner:nil];
    [_localNodeData release];
    _localNodeData = aData;
    if (aData != nil) {
        [self setNodeData:aData];
        [_localNodeData setOwner:self];
    }
}

- (id)localNodeData
{
    return _localNodeData;
}

- (void)setNodeData:(id)aData
{
    [aData retain];
    [_nodeData release];
    _nodeData = aData;
}

- (id)nodeData
{
    if (_nodeData == nil && _sharedNodeDataUID != nil)
        _nodeData = [[[self nodeDataProvider] nodeDataWithUID:_sharedNodeDataUID] retain];
    return _nodeData;
}

- (NSInteger)compareWeight:(id)aWeight
{
    return [[self weight] compare:[aWeight weight] options:NSNumericSearch];
}

- (void)setWeight:(id)aWeight
{
    [self setHyperOrderWeight:aWeight];
}

- (id)weight
{
    return [self hyperOrderWeight];
}

- (void)rejectImplementation:(void *)aImplementation
{
    if (_implementationToInterfacesMap == nil)
        return;
    NSHashTable *interfaces = HSNodeProtocolTable(_implementationToInterfacesMap, aImplementation);
    if (_interfaceToImplementationMap != nil && interfaces != NULL) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSHashEnumerator enumerator = NSEnumerateHashTable(interfaces);
        void *interface;
        while ((interface = NSNextHashEnumeratorItem(&enumerator)) != NULL)
            NSMapRemove(_interfaceToImplementationMap, interface);
        NSEndHashTableEnumeration(&enumerator);
        [pool release];
    }
    NSMapRemove(_implementationToInterfacesMap, aImplementation);
}

- (void)disassociateImplementation:(id)aImplementation fromInterface:(id)aInterface
{
    if (_interfaceToImplementationMap != nil)
        NSMapRemove(_interfaceToImplementationMap, aInterface);
    if (_implementationToInterfacesMap == nil)
        return;
    NSHashTable *interfaces = HSNodeProtocolTable(_implementationToInterfacesMap, aImplementation);
    if (interfaces == NULL)
        return;
    if (NSCountHashTable(interfaces) < 2) {
        NSMapRemove(_implementationToInterfacesMap, aImplementation);
        if ([aImplementation conformsToProtocol:@protocol(HSWeakReferencing)])
            [aImplementation unregisterWeakReferencer:self];
    } else
        NSHashRemove(interfaces, aInterface);
}

- (id)implementationAssociatedWithInterface:(id)aInterface
{
    if (_interfaceToImplementationMap == nil)
        return nil;
    return (id)NSMapGet(_interfaceToImplementationMap, aInterface);
}

- (void)associateImplementation:(id)aImplementation withInterface:(id)aInterface
{
    if (_interfaceToImplementationMap == nil) {
        _interfaceToImplementationMap = NSCreateMapTable(HSProtocolMapKeyCallBacks, NSNonRetainedObjectMapValueCallBacks, 0);
        if (_interfaceToImplementationMap == nil)
            return;
    }
    NSHashTable *interfaces = NULL;
    if (_implementationToInterfacesMap == nil) {
        _implementationToInterfacesMap = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
        if (_implementationToInterfacesMap == nil)
            return;
    } else
        interfaces = HSNodeProtocolTable(_implementationToInterfacesMap, aImplementation);
    if (interfaces == NULL) {
        interfaces = NSCreateHashTable(HSProtocolHashTableCallBacks, 0);
        if (interfaces == NULL)
            return;
        id wrapper = [HSPointer wrapperForPointer:interfaces withDisposer:NSFreeHashTable];
        if (wrapper == nil) {
            NSFreeHashTable(interfaces);
            return;
        }
        NSMapInsert(_implementationToInterfacesMap, aImplementation, wrapper);
        if ([aImplementation conformsToProtocol:@protocol(HSWeakReferencing)])
            [aImplementation registerWeakReferencer:self];
    }
    NSMapInsert(_interfaceToImplementationMap, aInterface, aImplementation);
    NSHashInsert(interfaces, aInterface);
}

- (id)defaultFilename
{
    return [[self uniqueBasename] stringByAppendingPathExtension:[self wrapperExtension]];
}

- (id)uniqueBasename
{
    if (_uniqueBasename == nil) {
        id basename = [self isRoot] ? [self basename] : [(id)_parent uniqueBasenameForChild:self];
        [self setUniqueBasename:basename];
    }
    return _uniqueBasename;
}

- (void)setUniqueBasename:(id)aBasename
{
    if (_uniqueBasename != aBasename) {
        [_uniqueBasename release];
        _uniqueBasename = [aBasename retain];
    }
}

- (id)enumeratorForGenerator:(id)aGenerator
{
    if (_filenameGenerator == aGenerator)
        return [[self children] reverseObjectEnumerator];
    return nil;
}

- (id)uniqueBasenameForChild:(id)aChild
{
    return [_filenameGenerator uniqueName:[aChild basename] omittingItemIdenticalTo:aChild];
}

- (id)basename
{
    return nil;
}

- (id)preferredFilename
{
    id filename = [_fileWrapper preferredFilename];
    if (filename == nil)
        filename = [self defaultFilename];
    return filename;
}

- (id)childWrapperExtension
{
    return [self wrapperExtension];
}

- (void)willDisconnectFromSupport
{
    [_children makeObjectsPerformSelector:@selector(approveWillDisconnectFromSupport:) withObject:_support];
}

- (void)didConnectToSupport
{
    [_children makeObjectsPerformSelector:@selector(approveDidConnectToSupport:) withObject:_support];
}

- (void)approveWillDisconnectFromSupport:(id)aSupport
{
    if (_support == nil)
        [self willDisconnectFromSupport];
}

- (void)approveDidConnectToSupport:(id)aSupport
{
    if (_support == nil)
        [self didConnectToSupport];
}

- (void)willDisconnectFromParent
{
}

- (void)didConnectToParent
{
}

- (void)willDisconnectFromChildren
{
}

- (void)didConnectToChildren
{
}

- (void)willRemoveFromParent
{
}

- (void)didAddToParent
{
}

- (NSUInteger)depth
{
    NSUInteger depth = 0;
    id node = self;
    while (![node isRoot]) {
        depth++;
        node = [node hyperParent];
        if (node == nil)
            break;
    }
    return depth;
}

- (id)rootNode
{
    id node = self;
    while (![node isRoot]) {
        id parent = [node hyperParent];
        if (parent == nil)
            return self;
        node = parent;
    }
    return node;
}

- (void)removeFromParent
{
    [(HSNode *)_parent removeChild:self];
}

- (void)addChild:(id)aChild
{
    [self insertChild:aChild atIndex:[self hyperCount]];
}

- (BOOL)isBound
{
    return _parent != nil;
}

- (BOOL)isLeaf
{
    return NO;
}

- (id)originalAttributesWrapper
{
    id wrapper = [self originalWrapper];
    if ([wrapper isDirectory])
        wrapper = [[wrapper fileWrappers] objectForKey:[wrapper preferredFilename]];
    return wrapper;
}

- (id)originalWrapper
{
    return [self fileWrapper];
}

- (id)filename
{
    return [[self fileWrapper] filename];
}

- (id)fileWrapperRepresentation
{
    id dictionary = [self extraDictionaryRepresentation];
    if (dictionary != nil) {
        NSFileWrapper *attributesWrapper = [[[NSFileWrapper alloc] initWithHyperDictionary:dictionary] autorelease];
        if ([self isLeaf])
            [self setFileWrapper:attributesWrapper];
        else {
            if ([self fileWrapper] == nil) {
                NSDictionary *wrappers = [NSDictionary dictionaryWithObject:attributesWrapper forKey:[self preferredFilename]];
                [self setFileWrapper:[[[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers] autorelease]];
            } else if (_children != nil) {
                [self synchronizeRemoved];
                [self synchronizeExisting:attributesWrapper];
            }
            if (_children != nil)
                [self synchronizeAdded];
        }
    }
    return [self fileWrapper];
}

- (void)loadChildrenFromFileWrapper:(id)aWrapper
{
    if (![aWrapper isDirectory])
        return;
    NSDictionary *wrappers = [aWrapper fileWrappers];
    NSEnumerator *enumerator = [[wrappers allKeys] objectEnumerator];
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:[[wrappers allKeys] count]];
    NSMutableArray *failedWrappers = [NSMutableArray new];
    id provider = [self nodeDataProvider];
    NSString *name;
    while ((name = [enumerator nextObject]) != nil) {
        if (![[self childWrapperExtension] isEqual:[name pathExtension]])
            continue;
        id child = [HSNode nodeWithFileWrapper:[wrappers objectForKey:name] explicitNodeDataProvider:provider];
        if (child != nil)
            [children addObject:child];
        else
            [failedWrappers addObject:[wrappers objectForKey:name]];
    }
    [self setChildren:children];
    // Wrappers that could not be read are dropped from the document.
    if ([failedWrappers count] != 0) {
        enumerator = [failedWrappers objectEnumerator];
        id wrapper;
        while ((wrapper = [enumerator nextObject]) != nil)
            [aWrapper removeFileWrapper:wrapper];
    }
    [failedWrappers release];
}

- (BOOL)hasLinkedObjects
{
    return NO;
}

- (id)linkedObjects
{
    return nil;
}

- (id)localCopyIncludingNodeUnits:(BOOL)aUnits copiedLinkedObjects:(id *)aObjects
{
    return [self localCopyIncludingNodeUnits:aUnits];
}

// Returns the copy retained, as callers expect.
- (id)localCopyIncludingNodeUnits:(BOOL)aUnits
{
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:HSDisableClassSubstitutionCodingKey];
    id context = [EXCodingContext codingContextWithOperation:EXDefaultCodingOperation shouldZeroMissingValuesOnLoading:NO options:options];
    id representation = [self fullDictionaryRepresentationWithAllNodeUnits:aUnits];
    id copy = [[HSNode nodeWithDictionary:representation children:nil explicitNodeDataProvider:[self nodeDataProvider] codingContext:context] retain];

    id mediaUIDs = [[self queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs];
    NSMutableSet *ignoredUIDs = [NSMutableSet set];
    id copyUID = [[copy queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    id stack = [[self queryHyperInterface:@protocol(HSUserObjectSupport)] stack];
    NSEnumerator *cards = [[stack queryHyperInterface:@protocol(HSNodeContainer)] hyperEnumerator];
    id card;
    while ((card = [cards nextObject]) != nil) {
        [ignoredUIDs addObject:[card hyperUID]];
        NSEnumerator *objects = [card hyperEnumerator];
        id object;
        while ((object = [objects nextObject]) != nil) {
            id UID = [object hyperUID];
            if (![copyUID isEqual:UID])
                [ignoredUIDs addObject:UID];
        }
    }
    NSMutableSet *keptUIDs = [NSMutableSet setWithSet:mediaUIDs];
    [keptUIDs unionSet:ignoredUIDs];
    id refreshed = [representation mutableCopy];
    [refreshed refreshHyperUIDsAndIgnoreUIDsFromSet:keptUIDs];
    [copy loadExtraDictionaryRepresentation:refreshed];
    [refreshed release];
    return copy;
}

- (BOOL)isHyperEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    HSNode *other = aEqual;
    if ([_children count] != [other->_children count])
        return NO;
    NSUInteger index;
    for (index = 0; index < [_children count]; index++) {
        if (![[_children objectAtIndex:index] isHyperEqual:[other->_children objectAtIndex:index]])
            return NO;
    }
    NSArray *units = [_units allValues];
    NSArray *otherUnits = [other->_units allValues];
    if ([units count] != [otherUnits count])
        return NO;
    for (index = 0; index < [units count]; index++) {
        if (![[units objectAtIndex:index] isHyperEqual:[otherUnits objectAtIndex:index]])
            return NO;
    }
    return _isTemporary == other->_isTemporary;
}

- (id)copyWithZone:(NSZone *)aZone
{
    id context = [EXCodingContext codingContextWithOperation:HSCopyingCodingOperation shouldZeroMissingValuesOnLoading:NO];
    id representation = [self extraDictionaryRepresentationWithCodingContext:context];
    id provider = [self nodeDataProvider];
    if (provider != nil) {
        representation = [[representation mutableCopy] autorelease];
        [representation setObject:provider forKey:HSExplicitNodeDataProviderKey];
    }
    id copy = [[[self class] objectWithExtraDictionary:representation zone:aZone] retain];
    if ([self hyperCount] != 0) {
        NSMutableArray *children = [NSMutableArray array];
        NSEnumerator *enumerator = [self hyperEnumerator];
        id child;
        while ((child = [enumerator nextObject]) != nil)
            [children addObject:[[child copyWithZone:aZone] autorelease]];
        [copy setChildren:children];
    }
    return copy;
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [[[self keysForExtraStoringWithCodingContext:aContext] mutableCopy] autorelease];
    [keys addObject:[@"units" extraKeyForCollection]];
    [keys addObject:[@"children" extraKeyForCollection]];
    return [[keys copy] autorelease];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [NSArray arrayWithObjects:HSLocalNodeDataKey, HSSharedNodeDataUIDKey, nil];
    if ([[aContext codingOperation] isEqualTo:EXDefaultCodingOperation])
        keys = [keys arrayByAddingObject:@"hyperOrderWeight"];
    return keys;
}

- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    id representation = [super extraDictionaryRepresentationWithCodingContext:aContext];
    if (representation == nil)
        return nil;
    NSUInteger count = [_units count];
    if (count == 0)
        return representation;
    NSMutableDictionary *unitUIDs = [NSMutableDictionary dictionaryWithCapacity:count];
    if (unitUIDs == nil)
        return representation;
    NSMutableDictionary *units = [NSMutableDictionary dictionary];
    if (units == nil)
        return representation;
    id provider = [self nodeDataProvider];
    NSEnumerator *enumerator = [_units keyEnumerator];
    id role;
    while ((role = [enumerator nextObject]) != nil) {
        id unit = [_units objectForKey:role];
        id UID = [unit UID];
        id UIDString = [UID stringValue];
        if (UIDString == nil)
            continue;
        [unitUIDs setObject:UIDString forKey:role];
        // Units the provider shares are stored by it, unless asked otherwise.
        if ([provider nodeUnitWithUID:UID] != nil
            && ![[[(EXCodingContext *)aContext options] objectForKey:@"HSCodingOptionSaveNodeUnitsLocally"] boolValue])
            continue;
        id unitRepresentation = [unit extraDictionaryRepresentationWithCodingContext:aContext];
        if (unitRepresentation != nil)
            [units setObject:unitRepresentation forKey:UIDString];
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:representation];
    if (result == nil)
        return representation;
    [result setObject:unitUIDs forKey:@"unitUIDs"];
    [result setObject:units forKey:@"units"];
    return [[result copy] autorelease];
}

- (id)fullDictionaryRepresentationWithAllNodeUnits:(BOOL)aUnits
{
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:aUnits] forKey:@"HSCodingOptionSaveNodeUnitsLocally"];
    id context = [EXCodingContext codingContextWithOperation:EXDefaultCodingOperation shouldZeroMissingValuesOnLoading:NO options:options];
    id representation = [self extraDictionaryRepresentationWithCodingContext:context];
    if ([self hyperChildren] != nil) {
        NSMutableArray *children = [NSMutableArray new];
        NSEnumerator *enumerator = [[self hyperChildren] objectEnumerator];
        id child;
        while ((child = [enumerator nextObject]) != nil)
            [children addObject:[child extraDictionaryRepresentationWithCodingContext:context]];
        NSMutableDictionary *full = [representation mutableCopy];
        [full setObject:children forKey:[@"children" extraKeyForCollection]];
        [children release];
        representation = [[full copy] autorelease];
        [full release];
    }
    return representation;
}

- (id)fullDictionaryRepresentation
{
    return [self fullDictionaryRepresentationWithAllNodeUnits:YES];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    id representation = aRepresentation;
    id unitsKey = [@"units" extraKeyForCollection];
    NSDictionary *collectedUnits = [aRepresentation objectForKey:unitsKey];
    if (collectedUnits != nil) {
        NSEnumerator *enumerator = [collectedUnits keyEnumerator];
        id role;
        while ((role = [enumerator nextObject]) != nil) {
            id unitRepresentation = [collectedUnits objectForKey:role];
            if ([unitRepresentation objectForKey:EXClassNameKey] == nil)
                [[self unitForRole:role] loadExtraDictionaryRepresentation:unitRepresentation withCodingContext:aContext];
            else {
                id unit = [NSObject objectWithExtraDictionary:unitRepresentation];
                if (unit != nil)
                    [self injectUnit:unit forRole:role];
            }
        }
        representation = [[aRepresentation mutableCopy] autorelease];
        [representation removeObjectForKey:unitsKey];
    }

    NSDictionary *unitUIDs = [representation objectForKey:@"unitUIDs"];
    if (unitUIDs != nil) {
        NSDictionary *units = [representation objectForKey:@"units"];
        id provider = [self nodeDataProvider];
        // The size unit goes first, so the other units see the node's size.
        NSMutableArray *roles = [NSMutableArray arrayWithArray:[unitUIDs allKeys]];
        NSUInteger sizeIndex = [roles indexOfObject:@"Size Unit"];
        if (sizeIndex != 0 && sizeIndex != NSNotFound)
            [roles exchangeObjectAtIndex:sizeIndex withObjectAtIndex:0];
        NSEnumerator *enumerator = [[NSArray arrayWithArray:roles] objectEnumerator];
        id role;
        while ((role = [enumerator nextObject]) != nil) {
            id UIDString = [unitUIDs objectForKey:role];
            id unitRepresentation = [units objectForKey:UIDString];
            id unit = nil;
            if (unitRepresentation == nil) {
                id UID = [HSUID UIDWithString:UIDString];
                if (UID != nil)
                    unit = [provider nodeUnitWithUID:UID];
            } else if ([unitRepresentation objectForKey:EXClassNameKey] == nil) {
                [[self unitForRole:role] loadExtraDictionaryRepresentation:unitRepresentation withCodingContext:aContext];
                continue;
            } else
                unit = [NSObject objectWithExtraDictionary:unitRepresentation];
            if (unit != nil)
                [self injectUnit:unit forRole:role];
        }
        if (representation == aRepresentation)
            representation = [[representation mutableCopy] autorelease];
        [representation removeObjectForKey:@"unitUIDs"];
        [representation removeObjectForKey:@"units"];
    }
    [super loadExtraDictionaryRepresentation:representation withCodingContext:aContext];
}

- (id)uniqueBasenameForGeneration
{
    if (_uniqueBasename == nil && _fileWrapper != nil) {
        id filename = [_fileWrapper filename];
        if (filename == nil)
            filename = [_fileWrapper preferredFilename];
        return [filename stringByDeletingPathExtension];
    }
    return _uniqueBasename;
}

- (void)synchronizeAdded
{
    NSEnumerator *enumerator = [[self newChildren] objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        if ([child isTemporary])
            continue;
        id wrapper = [child fileWrapperRepresentation];
        if (wrapper != nil)
            [wrapper setFilename:[_fileWrapper addFileWrapper:wrapper]];
    }
}

- (void)synchronizeExisting:(id)aExisting
{
    NSEnumerator *enumerator = [[self oldChildren] objectEnumerator];
    if ([aExisting preferredFilename] == nil)
        [aExisting setPreferredFilename:[self preferredFilename]];
    if ([aExisting filename] == nil)
        [aExisting setFilename:[self filename]];
    id attributesWrapper = [self originalAttributesWrapper];
    // Fix: guard against removing a missing wrapper.
    if (attributesWrapper != nil)
        [_fileWrapper removeFileWrapper:attributesWrapper];
    if (aExisting != nil)
        [aExisting setFilename:[_fileWrapper addFileWrapper:aExisting]];
    NSDictionary *wrappers = [_fileWrapper fileWrappers];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        id oldWrapper = [wrappers objectForKey:[[child originalWrapper] filename]];
        if (oldWrapper != nil)
            [_fileWrapper removeFileWrapper:oldWrapper];
        if ([child isTemporary])
            continue;
        id wrapper = [child fileWrapperRepresentation];
        if (wrapper != nil)
            [_fileWrapper addFileWrapper:wrapper];
    }
}

- (void)synchronizeRemoved
{
    NSEnumerator *enumerator = [[self removedChildFilenames] objectEnumerator];
    id filename;
    while ((filename = [enumerator nextObject]) != nil) {
        id wrapper = [[_fileWrapper fileWrappers] objectForKey:filename];
        if (wrapper != nil)
            [_fileWrapper removeFileWrapper:wrapper];
    }
}

- (id)removedChildFilenames
{
    NSMutableSet *filenames = [NSMutableSet setWithSet:[self allChildFilenames]];
    [filenames minusSet:[self existingChildFilenames]];
    return filenames;
}

- (id)allChildFilenames
{
    NSArray *keys = [[_fileWrapper fileWrappers] allKeys];
    NSEnumerator *enumerator = [keys objectEnumerator];
    NSMutableSet *filenames = [NSMutableSet setWithCapacity:[keys count]];
    id filename;
    while ((filename = [enumerator nextObject]) != nil) {
        if ([[filename pathExtension] isEqual:[self childWrapperExtension]])
            [filenames addObject:filename];
    }
    return filenames;
}

- (id)existingChildFilenames
{
    NSSet *oldChildren = [self oldChildren];
    NSMutableSet *filenames = [NSMutableSet setWithCapacity:[oldChildren count]];
    NSEnumerator *enumerator = [oldChildren objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        [filenames addObject:[child filename]];
    return filenames;
}

- (id)newChildren
{
    NSMutableSet *children = [NSMutableSet setWithArray:[self children]];
    [children minusSet:[self oldChildren]];
    return children;
}

- (id)oldChildren
{
    NSArray *children = [self children];
    NSMutableSet *oldChildren = [NSMutableSet setWithCapacity:[children count]];
    NSEnumerator *enumerator = [children objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        if ([child filename] != nil)
            [oldChildren addObject:child];
    }
    return oldChildren;
}

- (NSUInteger)childrenCountFromWrapper
{
    if (!_childCountWasCalculated) {
        if (![_fileWrapper isDirectory])
            _childrenCountFromWrapper = (unsigned int)[[self hyperChildren] count];
        else {
            NSEnumerator *enumerator = [[[_fileWrapper fileWrappers] allKeys] objectEnumerator];
            _childrenCountFromWrapper = 0;
            id filename;
            while ((filename = [enumerator nextObject]) != nil) {
                if ([[filename pathExtension] isEqual:[self childWrapperExtension]])
                    _childrenCountFromWrapper++;
            }
        }
        _childCountWasCalculated = 1;
    }
    return _childrenCountFromWrapper;
}

- (void)setFileWrapperRepresentation:(id)aRepresentation
{
    if (_fileWrapper != aRepresentation) {
        [self setFileWrapper:aRepresentation];
        [_children release];
        _children = nil;
        _childCountWasCalculated = 0;
    }
}

- (BOOL)isAttributesNotificationPostingDisabled
{
    return [[self support] isAttributesNotificationPostingDisabled];
}

- (id)cardGroupController
{
    return [[self support] cardGroupController];
}

- (id)delegate
{
    return [[self support] delegate];
}

- (id)scriptController
{
    return [[self support] scriptController];
}

- (id)undoManager
{
    return [[self support] undoManager];
}

- (id)allNodesWithCurrentNodeData
{
    id owner = [[self nodeData] owner];
    if (owner == nil)
        return [NSArray arrayWithObject:self];
    return [owner objectsWithNodeDataUID:[[self nodeData] nodeDataUID]];
}

- (void)moveToBegin
{
    [self setIndex:0];
}

- (void)moveToEnd
{
    [self setIndex:[_parent hyperCount] - 1];
}

- (void)setIndex:(NSUInteger)aIndex
{
    [_parent setIndex:aIndex ofHyperChild:self];
}

- (id)cardGroupUID
{
    return [[[self hyperParent] queryHyperInterface:@protocol(HSNodeAttributes)] cardGroupUID];
}

- (void)moveToHyperBegin
{
    [[self allNodesWithCurrentNodeData] makeObjectsPerformSelector:@selector(moveToBegin)];
}

- (void)moveToHyperEnd
{
    [[self allNodesWithCurrentNodeData] makeObjectsPerformSelector:@selector(moveToEnd)];
}

- (void)decrementHyperIndex
{
    [self setHyperIndex:[self hyperIndex] - 1];
}

- (void)incrementHyperIndex
{
    [self setHyperIndex:[self hyperIndex] + 1];
}

// Group nodes move together: the other nodes sharing this node's data are
// placed at the same relative weight between their own neighbouring group
// nodes.
- (void)setHyperIndex:(NSUInteger)aIndex
{
    if ([self hyperIndex] == aIndex)
        return;
    if (aIndex == 0) {
        [self moveToHyperBegin];
        return;
    }
    if ([[self hyperParent] hyperCount] - 1 == aIndex) {
        [self moveToHyperEnd];
        return;
    }
    [self setIndex:aIndex];
    if ([self sharedNodeDataUID] == nil)
        return;
    NSMutableArray *nodes = [NSMutableArray arrayWithArray:[self allNodesWithCurrentNodeData]];
    [nodes removeObject:self];
    id parent = [self hyperParent];
    id previous = [self previousGroupNode];
    id next = [self nextGroupNode];
    double delta = [[parent children] deltaForWeight:[self weight] betweenWeight:[previous weight] andWeight:[next weight]];
    NSEnumerator *enumerator = [nodes objectEnumerator];
    id node;
    while ((node = [enumerator nextObject]) != nil) {
        id nodeParent = [node hyperParent];
        id lower = previous != nil ? [nodeParent childNodeWithNodeData:[previous nodeData]] : nil;
        id upper = next != nil ? [nodeParent childNodeWithNodeData:[next nodeData]] : nil;
        NSMutableArray *siblings = [[nodeParent children] mutableCopy];
        [siblings removeObject:node];
        id weight = [siblings weightForDelta:delta betweenWeight:[lower weight] andWeight:[upper weight]];
        NSUInteger index = [siblings hyperIndexForWeight:weight];
        [siblings release];
        [node setIndex:index];
    }
}

- (BOOL)canDecrementHyperIndex
{
    NSUInteger index = [self hyperIndex];
    return index != NSNotFound && index != 0;
}

- (BOOL)canIncrementHyperIndex
{
    NSUInteger index = [self hyperIndex];
    if (index == NSNotFound)
        return NO;
    return index < [_parent hyperCount] - 1;
}

- (NSUInteger)hyperIndex
{
    if (_parent == nil)
        return NSNotFound;
    return [_parent indexOfHyperChild:self];
}

- (void)removeFromHyperParent
{
    [_parent removeHyperChild:self];
}

- (void)setDontErase:(BOOL)aErase
{
    _dontErase = aErase ? 1 : 0;
}

- (BOOL)dontErase
{
    return _dontErase;
}

- (void)setTemporary:(BOOL)aTemporary
{
    _isTemporary = aTemporary ? 1 : 0;
}

- (BOOL)isTemporary
{
    return _isTemporary;
}

- (BOOL)isRoot
{
    return _parent == nil;
}

- (void)setSupport:(id)aSupport
{
    if ([self support] != aSupport) {
        [self notifySupportWillChange];
        _support = aSupport;
        [self notifySupportDidChange];
    }
}

- (id)support
{
    if (_support != nil)
        return _support;
    return [[(id)_parent queryHyperInterface:@protocol(HSNodeChild)] support];
}

- (void)parentSupportChange:(id)aChange
{
    if (_support == nil)
        [self notifyChange:[aChange attributeChange] ofAttributeSet:[aChange attributeProtocolSet] withUserInfo:[aChange userInfo]];
}

- (void)setHyperParent:(id)aParent
{
    if (_parent == aParent)
        return;
    if (_parent != nil)
        [self willRemoveFromParent];
    [self setParent:aParent];
    if (_parent != nil)
        [self didAddToParent];
}

- (id)hyperParent
{
    return _parent;
}

- (void)setParent:(id)aParent
{
    if (_parent == aParent)
        return;
    BOOL supportUnchanged = YES;
    if (_support == nil && [self support] != [[aParent queryHyperInterface:@protocol(HSNodeChild)] support]) {
        if ([self support] != nil)
            [self willDisconnectFromSupport];
        [self notifyChange:1 ofAttribute:@protocol(HSNodeSupportAttribute) withUserInfo:nil];
        supportUnchanged = NO;
    }
    [self notifyParentWillChange];
    [[(id)_parent attributeObservingController] removeObserver:self selector:@selector(parentSupportChange:) ofChanges:HSActualAttributeChanges ofAttribute:@protocol(HSNodeSupportAttribute)];
    _parent = aParent;
    [[aParent attributeObservingController] addObserver:self selector:@selector(parentSupportChange:) ofChanges:HSActualAttributeChanges ofAttribute:@protocol(HSNodeSupportAttribute) withPriority:0.75];
    [self notifyParentDidChange];
    if (!supportUnchanged) {
        [self notifyChange:2 ofAttribute:@protocol(HSNodeSupportAttribute) withUserInfo:nil];
        if ([self support] != nil)
            [self didConnectToSupport];
    }
}

- (void)notifyParentDidChange
{
    [self notifyChange:2 ofAttribute:@protocol(HSNodeParentAttribute) withUserInfo:nil];
    if (_parent != nil)
        [self didConnectToParent];
}

- (void)notifyParentWillChange
{
    if (_parent != nil)
        [self willDisconnectFromParent];
    [self notifyChange:1 ofAttribute:@protocol(HSNodeParentAttribute) withUserInfo:nil];
}

- (void)notifySupportDidChange
{
    [self notifyChange:2 ofAttribute:@protocol(HSNodeSupportAttribute) withUserInfo:nil];
    if (_support != nil)
        [self didConnectToSupport];
}

- (void)notifySupportWillChange
{
    if (_support != nil)
        [self willDisconnectFromSupport];
    [self notifyChange:1 ofAttribute:@protocol(HSNodeSupportAttribute) withUserInfo:nil];
}

// Children attribute observing: depth 0 is this node's children, deeper levels
// are handed on to the children with the range shifted by one.

- (void)removeObserver:(id)aObserver ofAttributesOfChildrenInDepthRange:(NSRange)aRange
{
    if (aRange.location == 0) {
        [self removeChildrenAttributeObserver:aObserver];
        if (aRange.length == 1)
            return;
        aRange.length--;
    } else
        aRange.location--;
    NSEnumerator *enumerator = [_children objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        [[child queryHyperInterface:@protocol(HSNodeContainer)] removeObserver:aObserver ofAttributesOfChildrenInDepthRange:aRange];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofAttributesOfChildrenInDepthRange:(NSRange)aRange
{
    if (aRange.location == 0) {
        [self removeChildrenAttributeObserver:aObserver selector:aSelector];
        if (aRange.length == 1)
            return;
        aRange.length--;
    } else
        aRange.location--;
    NSEnumerator *enumerator = [_children objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        [[child queryHyperInterface:@protocol(HSNodeContainer)] removeObserver:aObserver selector:aSelector ofAttributesOfChildrenInDepthRange:aRange];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces ofChildrenInDepthRange:(NSRange)aRange
{
    id *attributes = [self HSNode_attributesOfHyperInterfaces:aInterfaces];
    if (attributes != NULL)
        [self removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:attributes ofChildrenInDepthRange:aRange];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface ofChildrenInDepthRange:(NSRange)aRange
{
    id interfaces[2] = { aInterface, nil };
    [self removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:interfaces ofChildrenInDepthRange:aRange];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofChildrenInDepthRange:(NSRange)aRange
{
    if (aRange.location == 0) {
        [self removeObserver:aObserver selector:aSelector ofChanges:aChanges ofChildrenAttributes:aAttributes];
        if (aRange.length == 1)
            return;
        aRange.length--;
    } else
        aRange.location--;
    NSEnumerator *enumerator = [_children objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        [[child queryHyperInterface:@protocol(HSNodeContainer)] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofChildrenInDepthRange:aRange];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute ofChildrenInDepthRange:(NSRange)aRange
{
    if (aRange.location == 0) {
        [self removeObserver:aObserver selector:aSelector ofChanges:aChanges ofChildrenAttribute:aAttribute];
        if (aRange.length == 1)
            return;
        aRange.length--;
    } else
        aRange.location--;
    NSEnumerator *enumerator = [_children objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        [[child queryHyperInterface:@protocol(HSNodeContainer)] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofChildrenInDepthRange:aRange];
}

- (void)removeChildrenAttributeObserver:(id)aObserver
{
    [self HSNode_removeChildrenAttributeObserver:aObserver selector:NULL ofChanges:HSAllAttributeChanges withSelector:@selector(removeObserver:selector:ofChanges:ofAttribute:ofObject:) attributeParameter:NULL];
}

- (void)removeChildrenAttributeObserver:(id)aObserver selector:(SEL)aSelector
{
    [self HSNode_removeChildrenAttributeObserver:aObserver selector:aSelector ofChanges:HSAllAttributeChanges withSelector:@selector(removeObserver:selector:ofChanges:ofAttribute:ofObject:) attributeParameter:NULL];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesOfHyperInterfaces:(id *)aInterfaces
{
    id *attributes = [self HSNode_attributesOfHyperInterfaces:aInterfaces];
    if (attributes != NULL)
        [self HSNode_removeChildrenAttributeObserver:aObserver selector:aSelector ofChanges:aChanges withSelector:@selector(removeObserver:selector:ofChanges:ofAttributes:ofObject:) attributeParameter:attributes];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesOfHyperInterface:(id)aInterface
{
    id interfaces[2] = { aInterface, nil };
    [self removeObserver:aObserver selector:aSelector ofChanges:aChanges ofChildrenAttributesOfHyperInterfaces:interfaces];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesFromSet:(id)aSet
{
    Protocol **attributes = [aSet allProtocols];
    if (attributes != NULL)
        [self HSNode_removeChildrenAttributeObserver:aObserver selector:aSelector ofChanges:aChanges withSelector:@selector(removeObserver:selector:ofChanges:ofAttributes:ofObject:) attributeParameter:attributes];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributes:(id *)aAttributes
{
    [self HSNode_removeChildrenAttributeObserver:aObserver selector:aSelector ofChanges:aChanges withSelector:@selector(removeObserver:selector:ofChanges:ofAttributes:ofObject:) attributeParameter:aAttributes];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttribute:(id)aAttribute
{
    [self HSNode_removeChildrenAttributeObserver:aObserver selector:aSelector ofChanges:aChanges withSelector:@selector(removeObserver:selector:ofChanges:ofAttribute:ofObject:) attributeParameter:aAttribute];
}

// Removes the observer from every children notification center; centers left
// without observers stop listening to the children and are dropped.
- (void)HSNode_removeChildrenAttributeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges withSelector:(SEL)aSelector2 attributeParameter:(void *)aParameter
{
    if (_priorityToChildrenAttributeNotificationCentersMap == nil)
        return;
    HSNodeRemoveObserverIMP removeObserver = (HSNodeRemoveObserverIMP)[HSAttributeNotificationCenter instanceMethodForSelector:aSelector2];
    NSMapEnumerator enumerator = NSEnumerateMapTable(_priorityToChildrenAttributeNotificationCentersMap);
    void *key = NULL;
    id center = nil;
    NSMutableData *emptyKeys = nil;
    while (NSNextMapEnumeratorPair(&enumerator, &key, (void **)&center)) {
        removeObserver(center, aSelector2, aObserver, aSelector, aChanges, aParameter, nil);
        if ([center hasObservers])
            continue;
        NSEnumerator *children = [_children objectEnumerator];
        id child;
        while ((child = [children nextObject]) != nil)
            [[child attributeObservingController] removeObserver:center selector:@selector(postAttributeChangeNotification:) ofChanges:HSAllAttributeChanges ofAttribute:nil];
        if (emptyKeys == nil)
            emptyKeys = [NSMutableData dataWithBytes:&key length:sizeof(key)];
        else
            [emptyKeys appendBytes:&key length:sizeof(key)];
    }
    NSEndMapTableEnumeration(&enumerator);
    if (emptyKeys == nil)
        return;
    NSUInteger count = [emptyKeys length] / sizeof(void *);
    if (NSCountMapTable(_priorityToChildrenAttributeNotificationCentersMap) == count) {
        NSFreeMapTable(_priorityToChildrenAttributeNotificationCentersMap);
        _priorityToChildrenAttributeNotificationCentersMap = nil;
    } else {
        void * const *keys = [emptyKeys bytes];
        NSUInteger index;
        for (index = 0; index < count; index++)
            NSMapRemove(_priorityToChildrenAttributeNotificationCentersMap, keys[index]);
    }
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces ofChildrenInDepthRange:(NSRange)aRange withPriority:(CGFloat)aPriority
{
    id *attributes = [self HSNode_attributesOfHyperInterfaces:aInterfaces];
    if (attributes != NULL)
        [self addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:attributes ofChildrenInDepthRange:aRange withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface ofChildrenInDepthRange:(NSRange)aRange withPriority:(CGFloat)aPriority
{
    id interfaces[2] = { aInterface, nil };
    [self addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:interfaces ofChildrenInDepthRange:aRange withPriority:aPriority];
}

- (id *)HSNode_attributesOfHyperInterfaces:(id *)aInterfaces
{
    NSEMutableProtocolSet *attributes = [NSEMutableProtocolSet protocolSet];
    if (attributes == nil)
        return NULL;
    for (; *aInterfaces != nil; aInterfaces++)
        HSCollectHyperInterfaceAttributes(*aInterfaces, attributes);
    return (id *)[attributes allProtocols];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes ofChildrenInDepthRange:(NSRange)aRange withPriority:(CGFloat)aPriority
{
    if (aRange.location == 0) {
        [self addObserver:aObserver selector:aSelector ofChanges:aChanges ofChildrenAttributes:aAttributes withPriority:aPriority];
        if (aRange.length == 1)
            return;
        aRange.length--;
    } else
        aRange.location--;
    NSEnumerator *enumerator = [[self children] objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        [[child queryHyperInterface:@protocol(HSNodeContainer)] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofChildrenInDepthRange:aRange withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute ofChildrenInDepthRange:(NSRange)aRange withPriority:(CGFloat)aPriority
{
    if (aRange.location == 0) {
        [self addObserver:aObserver selector:aSelector ofChanges:aChanges ofChildrenAttribute:aAttribute withPriority:aPriority];
        if (aRange.length == 1)
            return;
        aRange.length--;
    } else
        aRange.location--;
    NSEnumerator *enumerator = [[self children] objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        [[child queryHyperInterface:@protocol(HSNodeContainer)] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofChildrenInDepthRange:aRange withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority
{
    [[self HSNode_childrenAttributeNotificationCenterForPriority:aPriority] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:nil withPriority:0];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority
{
    [[self HSNode_childrenAttributeNotificationCenterForPriority:aPriority] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:nil withPriority:0];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority
{
    [[self HSNode_childrenAttributeNotificationCenterForPriority:aPriority] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:nil withPriority:0];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority
{
    [[self HSNode_childrenAttributeNotificationCenterForPriority:aPriority] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:nil withPriority:0];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofChildrenAttribute:(id)aAttribute withPriority:(CGFloat)aPriority
{
    [[self HSNode_childrenAttributeNotificationCenterForPriority:aPriority] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:nil withPriority:0];
}

// One notification center per priority (keyed in units of 1/10000) relays
// every attribute change of the children.
- (id)HSNode_childrenAttributeNotificationCenterForPriority:(CGFloat)aPriority
{
    NSInteger key = lroundf((float)aPriority * 10000.0f);
    if (_priorityToChildrenAttributeNotificationCentersMap == nil) {
        _priorityToChildrenAttributeNotificationCentersMap = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
        if (_priorityToChildrenAttributeNotificationCentersMap == nil)
            return nil;
    } else {
        id center = (id)NSMapGet(_priorityToChildrenAttributeNotificationCentersMap, (void *)key);
        if (center != nil)
            return center;
    }
    id center = [[[HSAttributeNotificationCenter alloc] init] autorelease];
    if (center == nil)
        return nil;
    NSMapInsert(_priorityToChildrenAttributeNotificationCentersMap, (void *)key, center);
    if (_children != nil) {
        NSEnumerator *enumerator = [_children objectEnumerator];
        id child;
        while ((child = [enumerator nextObject]) != nil)
            [[child attributeObservingController] addObserver:center selector:@selector(postAttributeChangeNotification:) ofChanges:HSAllAttributeChanges ofAttribute:nil withPriority:aPriority];
    }
    return center;
}

- (id)hyperChildren
{
    return [NSArray arrayWithArray:[self children]];
}

- (id)hyperReverseDeepEnumerator
{
    NSMutableArray *nodes = [NSMutableArray array];
    HSNodeCollectReverseDeep(self, nodes);
    return [nodes objectEnumerator];
}

- (id)hyperDeepLoadedNodeEnumerator
{
    NSMutableArray *nodes = [NSMutableArray array];
    HSNodeCollectDeepLoaded(self, nodes);
    return [nodes objectEnumerator];
}

- (id)hyperDeepEnumerator
{
    NSMutableArray *nodes = [NSMutableArray array];
    HSNodeCollectDeep(self, nodes);
    return [nodes objectEnumerator];
}

- (id)hyperLoadedNodeEnumerator
{
    return [[[_children copy] autorelease] objectEnumerator];
}

- (id)hyperReverseEnumerator
{
    return [[self children] reverseObjectEnumerator];
}

- (id)hyperEnumerator
{
    return [[self children] objectEnumerator];
}

- (void)removeHyperChildren:(id)aChildren
{
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    NSEnumerator *enumerator = [aChildren objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        NSUInteger index = [[self children] indexOfObjectIdenticalTo:child];
        if (index != NSNotFound)
            [indexes addIndex:index];
    }
    if ([indexes count] != 0 && [indexes count] == [aChildren count])
        [self justRemoveHyperChildren:aChildren atIndexes:indexes];
    [indexes release];
}

- (void)removeHyperChild:(id)aChild
{
    [self removeHyperChildren:[NSArray arrayWithObject:aChild]];
}

- (void)justRemoveHyperChildren:(id)aChildren atIndexes:(id)aIndexes
{
    if ([aIndexes count] == 0)
        return;
    NSUInteger count = [aChildren count];
    [[self undoManager] setActionName:HSNodeUndoName(count > 1 ? @"Remove Items" : @"Remove Item")];
    [self handleTemporaryOrderChanges];
    [[[self undoManager] prepareWithInvocationTarget:self] justInsertHyperChildren:aChildren atIndexes:aIndexes];
    [self removeChildren:aChildren];
}

- (void)setIndex:(NSUInteger)aIndex ofHyperChild:(id)aChild
{
    NSUInteger oldIndex = [[self children] indexOfObjectIdenticalTo:aChild];
    if (oldIndex == NSNotFound || oldIndex == aIndex || aIndex >= [self hyperCount])
        return;
    [self handleTemporaryOrderChanges];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:HSNodeUndoName(@"Change Order")];
    [[undoManager prepareWithInvocationTarget:self] setIndex:oldIndex ofHyperChild:aChild];
    [self moveChild:aChild toIndex:aIndex];
}

- (void)moveHyperChildFromIndex:(NSUInteger)aIndex toIndex:(NSUInteger)aIndex2
{
    [self hyperCount];
    if (aIndex == aIndex2)
        return;
    [self handleTemporaryOrderChanges];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:HSNodeUndoName(@"Change Order")];
    [[undoManager prepareWithInvocationTarget:self] moveHyperChildFromIndex:aIndex2 toIndex:aIndex];
    [self moveChildFromIndex:aIndex toIndex:aIndex2];
}

- (void)moveTemporarilyHyperChildFromIndex:(NSUInteger)aIndex toIndex:(NSUInteger)aIndex2
{
    [self hyperCount];
    if (aIndex != aIndex2)
        [self moveTemporarilyChildFromIndex:aIndex toIndex:aIndex2];
}

- (NSUInteger)indexOfHyperChild:(id)aChild
{
    return [[self children] indexOfObject:aChild];
}

- (void)insertHyperChild:(id)aChild atIndex:(NSUInteger)aIndex
{
    if ([[self children] indexOfObject:aChild] != NSNotFound)
        return;
    // A media object brings the comments and attributions of its media along.
    id comments = [aChild queryHyperInterface:@protocol(HSCommentsAttributes)];
    if (comments != nil) {
        id mediaUID = [[aChild queryHyperInterface:@protocol(HSMediaUIDAttribute)] mediaUID];
        if (mediaUID != nil) {
            NSString *attributions = [HSMediaCommentsAndAttributionsProvider commentsAndAttributionsForMediaUID:mediaUID];
            if (attributions != nil && [attributions length] != 0) {
                NSString *existing = [comments hyperComments];
                if (![existing hasHyperSubstring:attributions]) {
                    NSString *separator = [existing length] != 0 ? @"\n" : @"";
                    [comments setHyperComments:[NSString stringWithFormat:@"%@%@%@", existing, separator, attributions]];
                }
            }
        }
    }
    [self justInsertHyperChildren:[NSArray arrayWithObject:aChild] atIndexes:[NSIndexSet indexSetWithIndex:aIndex]];
}

- (void)justInsertHyperChildren:(id)aChildren atIndexes:(id)aIndexes
{
    if ([aChildren count] == 0 || [aChildren count] != [aIndexes count])
        return;
    NSUInteger count = [aChildren count];
    [self handleTemporaryOrderChanges];
    [[self undoManager] setActionName:HSNodeUndoName(count > 1 ? @"Add Items" : @"Add Item")];
    [[[self undoManager] prepareWithInvocationTarget:self] justRemoveHyperChildren:aChildren atIndexes:aIndexes];
    NSEnumerator *enumerator = [aChildren objectEnumerator];
    NSUInteger index = [aIndexes firstIndex];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        if (index != NSNotFound)
            [self insertChild:child atIndex:index];
        index = [aIndexes indexGreaterThanIndex:index];
    }
}

- (void)hyperRemoveChildrenEndGrouping
{
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:HSNodeUndoName([undoManager isUndoing] ? @"Add Items" : @"Remove Items")];
    [[undoManager prepareWithInvocationTarget:self] hyperAddChildrenBeginGrouping];
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(nodeContainerRemoveChildrenEndGrouping:)])
        [delegate nodeContainerRemoveChildrenEndGrouping:self];
}

- (void)hyperRemoveChildrenBeginGrouping
{
    NSUndoManager *undoManager = [self undoManager];
    [[undoManager prepareWithInvocationTarget:self] hyperAddChildrenEndGrouping];
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(nodeContainerRemoveChildrenBeginGrouping:)])
        [delegate nodeContainerRemoveChildrenBeginGrouping:self];
}

- (void)hyperAddChildrenEndGrouping
{
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:HSNodeUndoName([undoManager isUndoing] ? @"Remove Items" : @"Add Items")];
    [[undoManager prepareWithInvocationTarget:self] hyperRemoveChildrenBeginGrouping];
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(nodeContainerAddChildrenEndGrouping:)])
        [delegate nodeContainerAddChildrenEndGrouping:self];
}

- (void)hyperAddChildrenBeginGrouping
{
    NSUndoManager *undoManager = [self undoManager];
    [[undoManager prepareWithInvocationTarget:self] hyperRemoveChildrenEndGrouping];
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(nodeContainerAddChildrenBeginGrouping:)])
        [delegate nodeContainerAddChildrenBeginGrouping:self];
}

- (void)addHyperChild:(id)aChild
{
    [self insertHyperChild:aChild atIndex:[self hyperCount]];
}

- (id)hyperChildrenAtIndexes:(id)aIndexes
{
    return [[self children] objectsAtIndexes:aIndexes];
}

- (id)hyperChildAtIndex:(NSUInteger)aIndex
{
    return [[self children] objectAtIndex:aIndex];
}

- (NSUInteger)hyperCount
{
    return [[self children] count];
}

- (void)unlinkAttribute:(id)aAttribute fromAttribute:(id)aAttribute2
{
    if (_linkedAttributesMap == nil)
        return;
    NSHashTable *attributes = HSNodeProtocolTable(_linkedAttributesMap, aAttribute2);
    if (attributes == NULL || NSHashGet(attributes, aAttribute) == NULL)
        return;
    if (NSCountHashTable(attributes) == 1)
        NSMapRemove(_linkedAttributesMap, aAttribute2);
    else
        NSHashRemove(attributes, aAttribute);
}

// A change of the second attribute is also reported as a change of the first.
- (void)linkAttribute:(id)aAttribute toAttribute:(id)aAttribute2
{
    NSHashTable *attributes = NULL;
    if (_linkedAttributesMap == nil) {
        _linkedAttributesMap = NSCreateMapTable(HSProtocolMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
        if (_linkedAttributesMap == nil)
            return;
    } else
        attributes = HSNodeProtocolTable(_linkedAttributesMap, aAttribute2);
    if (attributes == NULL) {
        attributes = NSCreateHashTable(HSProtocolHashTableCallBacks, 0);
        if (attributes == NULL)
            return;
        id wrapper = [HSPointer wrapperForPointer:attributes withDisposer:NSFreeHashTable];
        if (wrapper == nil) {
            NSFreeHashTable(attributes);
            return;
        }
        NSMapInsert(_linkedAttributesMap, aAttribute2, wrapper);
    }
    NSHashInsert(attributes, aAttribute);
}

- (id)attributesChangedTemporary
{
    if (_attributesChangedTemporary != nil)
        return [[_attributesChangedTemporary copy] autorelease];
    return [NSEProtocolSet protocolSet];
}

- (id)attributesBeingChangedContinuously
{
    if (_attributesBeingChangedContinuously != nil)
        return [[_attributesBeingChangedContinuously copy] autorelease];
    return [NSEProtocolSet protocolSet];
}

- (void)endContinuousChangeOfAttributeSet:(id)aSet
{
    [self HSNode_sharedNotifyChange:0x80 ofAttributes:aSet andAttribute:nil];
}

- (void)beginContinuousChangeOfAttributeSet:(id)aSet
{
    [self HSNode_sharedNotifyChange:0x40 ofAttributes:aSet andAttribute:nil];
}

- (void)endContinuousChangeOfAttribute:(id)aAttribute
{
    [self HSNode_sharedNotifyChange:0x80 ofAttributes:nil andAttribute:aAttribute];
}

- (void)beginContinuousChangeOfAttribute:(id)aAttribute
{
    [self HSNode_sharedNotifyChange:0x40 ofAttributes:nil andAttribute:aAttribute];
}

// Continuous changes are also reported by the other nodes hosting the units
// that hold the attributes; this node then reports only what is left.
- (void)HSNode_sharedNotifyChange:(NSInteger)aChange ofAttributes:(id)aAttributes andAttribute:(id)aAttribute
{
    CFDictionaryRef nodes = [self HSNode_nodesWithSharedAttributes:aAttributes andAttribute:aAttribute];
    if (nodes != NULL) {
        CFDictionaryApplyFunction(nodes, HSNodeNotifySharingNode, (void *)aChange);
        if (_groupCardObjectsNotificationPatchForNodeDataDisablingCounter == 0) {
            id notified = (id)CFDictionaryGetValue(nodes, self);
            if (notified != nil) {
                if (aAttributes != nil) {
                    if ([notified isEqualToProtocolSet:aAttributes])
                        return;
                } else if ([notified count] == 1 && [notified containsProtocol:aAttribute])
                    return;
                id remaining = [[aAttributes mutableCopy] autorelease];
                if (remaining != nil) {
                    [remaining minusProtocolSet:notified];
                    aAttributes = remaining;
                }
            }
        }
    }
    if (aAttributes != nil)
        [self notifyChange:aChange ofAttributeSet:aAttributes withUserInfo:nil];
    else
        [self notifyChange:aChange ofAttribute:aAttribute withUserInfo:nil];
}

- (struct __CFDictionary *)HSNode_nodesWithSharedAttributes:(id)aAttributes andAttribute:(id)aAttribute
{
    if ([self HSNode_attributeToUnitMap] == NULL)
        return NULL;
    if (aAttribute == nil && [aAttributes count] == 0)
        return NULL;
    CFMutableDictionaryRef nodes = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    if ([(id)nodes autorelease] != nil) {
        [self HSNode_collectNodesWithSharedAttribute:aAttribute intoDictionary:nodes];
        for (id attribute in aAttributes)
            [self HSNode_collectNodesWithSharedAttribute:attribute intoDictionary:nodes];
    }
    return nodes;
}

- (void)HSNode_collectNodesWithSharedAttribute:(id)aAttribute intoDictionary:(struct __CFDictionary *)aDictionary
{
    id unit = (id)CFDictionaryGetValue(_attributeToUnitMap, aAttribute);
    if (unit == nil)
        return;
    for (id node in [unit hostNodes]) {
        if (node == self && _groupCardObjectsNotificationPatchForNodeDataDisablingCounter != 0)
            continue;
        id attributes = (id)CFDictionaryGetValue(aDictionary, node);
        if (attributes == nil) {
            attributes = [NSEMutableProtocolSet protocolSetWithProtocol:aAttribute];
            if (attributes == nil)
                return;
            CFDictionaryAddValue(aDictionary, node, attributes);
        } else
            [attributes addProtocol:aAttribute];
    }
}

- (struct __CFDictionary *)HSNode_attributeToUnitMap
{
    if (_attributeToUnitMap == NULL) {
        _attributeToUnitMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &HSProtocolCFDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (_attributeToUnitMap == NULL)
            return NULL;
        NSEnumerator *enumerator = [_units objectEnumerator];
        id unit;
        while ((unit = [enumerator nextObject]) != nil) {
            for (id attribute in [unit attributes])
                CFDictionaryAddValue(_attributeToUnitMap, attribute, unit);
        }
    }
    return _attributeToUnitMap;
}

- (void)removeAttributeObserver:(id)aObserver
{
    [[self HSNode_attributeNotificationCenter] removeObserver:aObserver selector:NULL ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector
{
    [[self HSNode_attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces
{
    [[self HSNode_attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface
{
    [[self HSNode_attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet
{
    [[self HSNode_attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes
{
    [[self HSNode_attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute
{
    [[self HSNode_attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority
{
    [[self HSNode_attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority
{
    [[self HSNode_attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority
{
    [[self HSNode_attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority
{
    [[self HSNode_attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority
{
    [[self HSNode_attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self withPriority:aPriority];
}

- (id)attributeObservingController
{
    return self;
}

- (void)injectUnit:(id)aUnit forRole:(id)aRole
{
    [self HSNode_injectUnit:aUnit forRole:aRole asUndoableOperation:YES];
}

- (id)unitEnumerator
{
    return [_units hyperProxiedObjectEnumerator];
}

- (id)unitRoleEnumerator
{
    return [_units keyEnumerator];
}

- (id)unitForRole:(id)aRole
{
    return [[_units objectForKey:aRole] object];
}

- (BOOL)isGroupCardObjectsNotificationPatchForNodeDataEnabled
{
    return _groupCardObjectsNotificationPatchForNodeDataDisablingCounter == 0;
}

- (void)enableGroupCardObjectsNotificationPatchForNodeData
{
    _groupCardObjectsNotificationPatchForNodeDataDisablingCounter--;
}

- (void)disableGroupCardObjectsNotificationPatchForNodeData
{
    _groupCardObjectsNotificationPatchForNodeDataDisablingCounter++;
}

- (id)notifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet withUserInfoInvocation:(id)aInvocation
{
    id attributes = [self HSNode_expandConcreteAttributeSetWithLinkedAttributes:aSet];
    if (attributes == nil)
        return nil;
    id notification = [HSAttributeNotification notificationWithChange:aChange attributeSet:attributes object:self userInfoInvocation:aInvocation];
    if (notification == nil)
        return nil;
    [self HSNode_postAttributeChangeNotification:notification];
    return [notification userInfoIfCreated];
}

- (id)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfoInvocation:(id)aInvocation
{
    id attributes = [self HSNode_attributeSetWithConcreteAttributeAndLinkedAttributes:aAttribute];
    if (attributes == nil)
        return nil;
    id notification = [HSAttributeNotification notificationWithChange:aChange attributeSet:attributes object:self userInfoInvocation:aInvocation];
    if (notification == nil)
        return nil;
    [self HSNode_postAttributeChangeNotification:notification];
    return [notification userInfoIfCreated];
}

- (void)renotifyFromSelf:(id)aSelf
{
    if ([[self support] isAttributesNotificationPostingDisabled])
        return;
    if ([aSelf object] != self)
        aSelf = [aSelf notificationWithObject:self];
    [[self HSNode_attributeNotificationCenter] postAttributeChangeNotification:aSelf];
}

- (void)notifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet withUserInfo:(id)aInfo
{
    id attributes = [self HSNode_expandConcreteAttributeSetWithLinkedAttributes:aSet];
    if (attributes == nil)
        return;
    id notification = [HSAttributeNotification notificationWithChange:aChange attributeSet:attributes object:self userInfo:aInfo];
    if (notification != nil)
        [self HSNode_postAttributeChangeNotification:notification];
}

- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo
{
    id attributes = [self HSNode_attributeSetWithConcreteAttributeAndLinkedAttributes:aAttribute];
    if (attributes == nil)
        return;
    id notification = [HSAttributeNotification notificationWithChange:aChange attributeSet:attributes object:self userInfo:aInfo];
    if (notification != nil)
        [self HSNode_postAttributeChangeNotification:notification];
}

- (id)HSNode_attributeSetWithConcreteAttributeAndLinkedAttributes:(id)aAttributes
{
    if (_linkedAttributesMap != nil) {
        NSEMutableProtocolSet *processed = [[NSEMutableProtocolSet alloc] initWithProtocolsAdoptedByProtocol:aAttributes];
        if (processed != nil) {
            id attributes = [self HSNode_attributeSetWithAttributesLinkedToAttributesFromHash:processed andWithConcreteAttribute:aAttributes orConcreteAttributeSet:nil];
            [processed release];
            if (attributes != nil)
                return attributes;
        }
    }
    return [NSEProtocolSet protocolSetWithProtocol:aAttributes];
}

- (id)HSNode_expandConcreteAttributeSetWithLinkedAttributes:(id)aAttributes
{
    id attributes = nil;
    if (_linkedAttributesMap != nil) {
        NSEMutableProtocolSet *processed = [aAttributes mutableCopy];
        if (processed != nil) {
            [processed addAdoptedProtocols];
            attributes = [self HSNode_attributeSetWithAttributesLinkedToAttributesFromHash:processed andWithConcreteAttribute:nil orConcreteAttributeSet:aAttributes];
            [processed release];
        }
    }
    return attributes != nil ? attributes : aAttributes;
}

// The concrete attribute (or set) plus every attribute linked to one of the
// processed attributes, followed transitively; nil when nothing is linked.
- (id)HSNode_attributeSetWithAttributesLinkedToAttributesFromHash:(id)aHash andWithConcreteAttribute:(id)aAttribute orConcreteAttributeSet:(id)aSet
{
    id attributes = nil;
    NSEMutableProtocolSet *linked = nil;
    for (id attribute in aHash) {
        NSHashTable *table = HSNodeProtocolTable(_linkedAttributesMap, attribute);
        if (table == NULL)
            continue;
        if (attributes == nil) {
            attributes = aAttribute != nil ? [NSEMutableProtocolSet protocolSetWithProtocol:aAttribute] : [[aSet mutableCopy] autorelease];
            if (attributes == nil)
                break;
            linked = [[NSEMutableProtocolSet alloc] init];
            if (linked == nil)
                break;
        }
        NSHashEnumerator enumerator = NSEnumerateHashTable(table);
        Protocol *linkedAttribute;
        while ((linkedAttribute = NSNextHashEnumeratorItem(&enumerator)) != NULL) {
            [attributes addProtocol:linkedAttribute];
            [linked addProtocolsAdoptedByProtocol:linkedAttribute];
        }
        NSEndHashTableEnumeration(&enumerator);
    }
    if (linked != nil) {
        [self HSNode_addAttributesLinkedToAttributesFromSet:linked intoAttributeSet:attributes withProcessedAttributes:aHash];
        [linked release];
    }
    return attributes;
}

- (void)HSNode_addAttributesLinkedToAttributesFromSet:(id)aSet intoAttributeSet:(id)aSet2 withProcessedAttributes:(id)aAttributes
{
    NSEMutableProtocolSet *linked = nil;
    for (id attribute in aSet) {
        if ([aAttributes containsProtocol:attribute])
            continue;
        [aAttributes addProtocol:attribute];
        NSHashTable *table = HSNodeProtocolTable(_linkedAttributesMap, attribute);
        if (table == NULL)
            continue;
        if (linked == nil) {
            linked = [[NSEMutableProtocolSet alloc] init];
            if (linked == nil)
                break;
        }
        NSHashEnumerator enumerator = NSEnumerateHashTable(table);
        Protocol *linkedAttribute;
        while ((linkedAttribute = NSNextHashEnumeratorItem(&enumerator)) != NULL) {
            [aSet2 addProtocol:linkedAttribute];
            [linked addProtocolsAdoptedByProtocol:linkedAttribute];
        }
        NSEndHashTableEnumeration(&enumerator);
    }
    if (linked != nil) {
        [self HSNode_addAttributesLinkedToAttributesFromSet:linked intoAttributeSet:aSet2 withProcessedAttributes:aAttributes];
        [linked release];
    }
}

- (void)HSNode_postAttributeChangeNotification:(id)aNotification
{
    if ([[self support] isAttributesNotificationPostingDisabled])
        return;
    NSInteger change = [aNotification attributeChange];
    id attributes = [aNotification attributeProtocolSet];
    [self HSNode_prenotifyChange:change ofAttributeSet:attributes];
    [[self HSNode_attributeNotificationCenter] postAttributeChangeNotification:aNotification];
    [self HSNode_postnotifyChange:change ofAttributeSet:attributes];
}

// Counts nested changes of an attribute: the set holds the attribute once, the
// map counts the extra levels.
static void HSNodeAddChangingAttributes(id aAttributes, NSEMutableProtocolSet *aSet, NSMapTable **aExtraMap)
{
    for (id attribute in aAttributes) {
        if (![aSet containsProtocol:attribute]) {
            [aSet addProtocol:attribute];
            continue;
        }
        if (*aExtraMap == nil) {
            *aExtraMap = NSCreateMapTable(HSProtocolMapKeyCallBacks, NSIntegerMapValueCallBacks, 0);
            if (*aExtraMap == nil)
                continue;
        }
        NSInteger extra = (NSInteger)NSMapGet(*aExtraMap, attribute);
        NSMapInsert(*aExtraMap, attribute, (void *)(extra + 1));
    }
}

static void HSNodeRemoveChangingAttributes(id aAttributes, NSEMutableProtocolSet *aSet, NSMapTable *aExtraMap)
{
    for (id attribute in aAttributes) {
        NSInteger extra = aExtraMap != nil ? (NSInteger)NSMapGet(aExtraMap, attribute) : 0;
        if (extra == 0)
            [aSet removeProtocol:attribute];
        else if (extra == 1)
            NSMapRemove(aExtraMap, attribute);
        else
            NSMapInsert(aExtraMap, attribute, (void *)(extra - 1));
    }
}

- (void)HSNode_postnotifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet
{
    if (aChange != 0x40)
        return;
    if (_attributesBeingChangedContinuously == nil) {
        _attributesBeingChangedContinuously = [[NSEMutableProtocolSet alloc] init];
        if (_attributesBeingChangedContinuously == nil)
            return;
    }
    HSNodeAddChangingAttributes(aSet, _attributesBeingChangedContinuously, &_attributesBeingChangedExtraContinuously);
}

- (void)HSNode_prenotifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet
{
    if (aChange == 8) {
        if (_attributesChangedTemporary == nil) {
            _attributesChangedTemporary = [[NSEMutableProtocolSet alloc] init];
            if (_attributesChangedTemporary == nil)
                return;
        }
        HSNodeAddChangingAttributes(aSet, _attributesChangedTemporary, &_attributesChangedExtraTemporary);
    } else if (aChange == 0x20) {
        if (_attributesChangedTemporary != nil)
            HSNodeRemoveChangingAttributes(aSet, _attributesChangedTemporary, _attributesChangedExtraTemporary);
    } else if (aChange == 0x80) {
        if (_attributesBeingChangedContinuously != nil)
            HSNodeRemoveChangingAttributes(aSet, _attributesBeingChangedContinuously, _attributesBeingChangedExtraContinuously);
    }
}

- (id)queryNewHyperInterface:(id)aInterface
{
    return [super queryHyperInterface:aInterface];
}

// Implementations come from the node itself or are created from the unit
// implementing the interface; weakly referencing ones are cached.
- (id)queryHyperInterface:(id)aInterface
{
    id implementation = [self implementationAssociatedWithInterface:aInterface];
    if (implementation != nil)
        return implementation;
    implementation = [self queryNewHyperInterface:aInterface];
    if (implementation == nil) {
        if (_interfaceToUnitMap == nil)
            return nil;
        id unit = (id)NSMapGet(_interfaceToUnitMap, aInterface);
        if (unit == nil)
            return nil;
        implementation = [[self createHyperImplementationForHyperInterface:aInterface withUnit:unit] autorelease];
        if (implementation == nil)
            return nil;
    }
    if ([implementation conformsToProtocol:@protocol(HSWeakReferencing)])
        [self associateImplementation:implementation withInterface:aInterface];
    return implementation;
}

- (id)createHyperImplementationForHyperInterface:(id)aInterface withUnit:(id)aUnit
{
    Class implementationClass = Nil;
    if (_interfaceToOverriddenUnitBasedHyperImplementationClassMap != nil)
        implementationClass = (Class)NSMapGet(_interfaceToOverriddenUnitBasedHyperImplementationClassMap, aInterface);
    if (implementationClass == Nil)
        implementationClass = [aUnit hyperImplementationClassForHyperInterface:aInterface];
    return [[implementationClass hyperImplementationWithNode:self unit:aUnit] retain];
}

- (void)overrideUnitBasedHyperImplementationClassWithClass:(Class)aClass forHyperInterface:(id)aInterface
{
    if (_interfaceToOverriddenUnitBasedHyperImplementationClassMap == nil) {
        _interfaceToOverriddenUnitBasedHyperImplementationClassMap = NSCreateMapTable(HSProtocolMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
        if (_interfaceToOverriddenUnitBasedHyperImplementationClassMap == nil)
            return;
    }
    NSMapInsert(_interfaceToOverriddenUnitBasedHyperImplementationClassMap, aInterface, aClass);
}

- (void)connectToChildren
{
    [[self children] makeObjectsPerformSelector:@selector(setParent:) withObject:self];
    if (_priorityToChildrenAttributeNotificationCentersMap != nil)
        [self HSNode_registerChildrenAttributeNotificationCenters];
    [self didConnectToChildren];
}

- (void)disconnectFromChildren
{
    [self willDisconnectFromChildren];
    if (_priorityToChildrenAttributeNotificationCentersMap != nil)
        [self HSNode_unregisterChildrenAttributeNotificationCenters];
    [_children makeObjectsPerformSelector:@selector(setParent:) withObject:nil];
}

- (void)setHyperOrderWeight:(id)aWeight
{
    [_hyperOrderWeight autorelease];
    _hyperOrderWeight = [aWeight retain];
}

- (id)hyperOrderWeight
{
    return _hyperOrderWeight;
}

- (id)description
{
    if ([self isLeaf])
        return [super description];
    return [NSString stringWithFormat:@"%@: %@", [super description], _children];
}

- (void)setFileWrapper:(id)aWrapper
{
    if (_fileWrapper == aWrapper)
        return;
    if ([aWrapper preferredFilename] == nil)
        [aWrapper setPreferredFilename:[self preferredFilename]];
    if ([aWrapper filename] == nil)
        [aWrapper setFilename:[self filename]];
    [_fileWrapper release];
    _fileWrapper = [aWrapper retain];
}

- (id)fileWrapper
{
    return _fileWrapper;
}

- (void)removeHyperAllChildren
{
    [self hyperRemoveChildrenBeginGrouping];
    NSArray *children = [[self hyperChildren] copy];
    [children makeObjectsPerformSelector:@selector(removeFromHyperParent)];
    [children release];
    [self hyperRemoveChildrenEndGrouping];
}

- (void)removeAllChildren
{
    [self disconnectFromChildren];
    [_children removeAllObjects];
}

- (void)removeChildren:(id)aChildren
{
    [aChildren retain];
    NSUInteger count = [[self children] count];
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    NSEnumerator *enumerator = [aChildren objectEnumerator];
    id child;
    // Quirk: indexing stops at the first child that is not ours.
    while ((child = [enumerator nextObject]) != nil) {
        NSUInteger index = [self indexOfHyperChild:child];
        if (index == NSNotFound)
            break;
        [indexes addIndex:index];
    }
    NSUInteger firstIndex = [indexes firstIndex];
    // Fix: with no index found the affected range was out of bounds.
    NSIndexSet *affected = firstIndex == NSNotFound ? [NSIndexSet indexSet] : [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstIndex, count - firstIndex)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:affected, @"HSAffectedNodeChildrenIndexes", [NSSet setWithArray:aChildren], @"HSNodeChildrenForRemoval", nil];
    NSMutableArray *descriptions = [[NSMutableArray alloc] init];
    BOOL visual = NO;
    enumerator = [aChildren objectEnumerator];
    while ((child = [enumerator nextObject]) != nil) {
        if ([child implementsHyperInterface:@protocol(HSVisualization)]) {
            [descriptions addObject:[NSDictionary dictionaryWithObject:child forKey:@"HSVisualSubobject"]];
            visual = YES;
        }
    }
    if ([descriptions count] != 0)
        [userInfo setObject:descriptions forKey:@"HSVisualSubobjectChangeDescriptions"];
    [descriptions release];
    id attributes = visual
        ? [NSEProtocolSet protocolSetWithProtocols:@protocol(HSNodeContainerChildrenAttribute), @protocol(HSVisualSubobjectsAttribute), nil]
        : [NSEProtocolSet protocolSetWithProtocol:@protocol(HSNodeContainerChildrenAttribute)];
    [self notifyChange:1 ofAttributeSet:attributes withUserInfo:userInfo];
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(nodeContainer:willRemoveChildren:)])
        [delegate nodeContainer:self willRemoveChildren:aChildren];
    enumerator = [aChildren objectEnumerator];
    while ((child = [enumerator nextObject]) != nil) {
        if (_priorityToChildrenAttributeNotificationCentersMap != nil)
            [self HSNode_unregisterChildrenAttributeNotificationCentersWithinChild:child];
        [child setHyperParent:nil];
        [_children removeObjectIdenticalTo:child];
    }
    affected = firstIndex == NSNotFound ? nil : [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(firstIndex, count - firstIndex - [aChildren count])];
    if (affected != nil)
        [userInfo setObject:affected forKey:@"HSAffectedNodeChildrenIndexes"];
    else
        [userInfo removeObjectForKey:@"HSAffectedNodeChildrenIndexes"];
    [self notifyChange:2 ofAttributeSet:attributes withUserInfo:userInfo];
    if ([delegate respondsToSelector:@selector(nodeContainer:didRemoveChildren:)])
        [delegate nodeContainer:self didRemoveChildren:aChildren];
    [indexes release];
    [aChildren release];
}

- (void)removeChild:(id)aChild
{
    [self removeChildren:[NSArray arrayWithObject:aChild]];
}

- (void)moveChild:(id)aChild toIndex:(NSUInteger)aIndex
{
    [self children];
    [self moveChildFromIndex:[self indexOfHyperChild:aChild] toIndex:aIndex];
}

- (void)moveChildFromIndex:(NSUInteger)aIndex toIndex:(NSUInteger)aIndex2
{
    [self moveChildFromIndex:aIndex toIndex:aIndex2 temporarily:NO];
}

- (void)moveTemporarilyChildFromIndex:(NSUInteger)aIndex toIndex:(NSUInteger)aIndex2
{
    [self moveChildFromIndex:aIndex toIndex:aIndex2 temporarily:YES];
    _areChildrenInTemporaryOrder = 1;
}

- (void)moveChildFromIndex:(NSUInteger)aIndex toIndex:(NSUInteger)aIndex2 temporarily:(BOOL)aTemporarily
{
    NSMutableArray *children = [self children];
    id child = [children objectAtIndex:aIndex];
    BOOL visual = [child implementsHyperInterface:@protocol(HSVisualization)];
    NSUInteger first = MIN(aIndex, aIndex2);
    NSUInteger last = MAX(aIndex, aIndex2);
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSNodeContainerChildrenAttribute), visual ? @protocol(HSVisualSubobjectsAttribute) : nil, nil];
    NSArray *descriptions = nil;
    if (visual)
        descriptions = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObject:child forKey:@"HSVisualSubobject"], nil];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(first, last - first + 1)], @"HSAffectedNodeChildrenIndexes", descriptions, @"HSVisualSubobjectChangeDescriptions", nil];
    [self notifyChange:1 ofAttributeSet:attributes withUserInfo:userInfo];
    [child retain];
    [children removeObjectAtIndex:aIndex];
    if (aTemporarily)
        [children insertObject:child atIndex:aIndex2];
    else
        [children insertWeighedHyperObject:child atIndex:aIndex2];
    [child release];
    [self notifyChange:2 ofAttributeSet:attributes withUserInfo:userInfo];
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(nodeContainer:didChangeOrderForChild:)])
        [delegate nodeContainer:self didChangeOrderForChild:child];
}

- (void)insertChild:(id)aChild atIndex:(NSUInteger)aIndex
{
    NSMutableArray *children = [self children];
    NSUInteger count = [children count];
    if (aIndex > count)
        aIndex = count;
    NSIndexSet *affected = aIndex == count ? [NSIndexSet indexSet] : [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(aIndex, count - aIndex)];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:affected, @"HSAffectedNodeChildrenIndexes", [NSSet setWithObject:aChild], @"HSNodeChildrenForAddition", nil];
    id attributes;
    if (![aChild implementsHyperInterface:@protocol(HSVisualization)])
        attributes = [NSEProtocolSet protocolSetWithProtocol:@protocol(HSNodeContainerChildrenAttribute)];
    else {
        attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSNodeContainerChildrenAttribute), @protocol(HSVisualSubobjectsAttribute), nil];
        id description = [NSDictionary dictionaryWithObject:aChild forKey:@"HSVisualSubobject"];
        id descriptions = description != nil ? [NSArray arrayWithObject:description] : nil;
        if (descriptions != nil)
            [userInfo setObject:descriptions forKey:@"HSVisualSubobjectChangeDescriptions"];
    }
    [self notifyChange:1 ofAttributeSet:attributes withUserInfo:userInfo];
    [children insertWeighedHyperObject:aChild atIndex:aIndex];
    [aChild setHyperParent:self];
    if (_priorityToChildrenAttributeNotificationCentersMap != nil)
        [self HSNode_registerChildrenAttributeNotificationCentersWithinChild:aChild];
    affected = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(aIndex, count + 1 - aIndex)];
    if (affected != nil)
        [userInfo setObject:affected forKey:@"HSAffectedNodeChildrenIndexes"];
    else
        [userInfo removeObjectForKey:@"HSAffectedNodeChildrenIndexes"];
    [self notifyChange:2 ofAttributeSet:attributes withUserInfo:userInfo];
    id delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(nodeContainer:didAddChild:)])
        [delegate nodeContainer:self didAddChild:aChild];
}

// A temporary order (from previews) becomes permanent with the next ordinary
// change, unless undoing or redoing, which restores the original order.
- (void)handleTemporaryOrderChanges
{
    if (!_areChildrenInTemporaryOrder)
        return;
    NSUndoManager *undoManager = [self undoManager];
    if ([undoManager isUndoing] || [undoManager isRedoing])
        [self restoreOriginalChildrenOrderWithUndo:NO];
    else
        [self makeTemporaryOrderOriginal];
}

- (void)makeTemporaryOrderOriginal
{
    NSMutableArray *children = [self children];
    [[[self undoManager] prepareWithInvocationTarget:self] restoreOriginalChildrenOrderWithUndo:YES];
    for (id child in children)
        [[[self undoManager] prepareWithInvocationTarget:child] setHyperOrderWeight:[child hyperOrderWeight]];
    [children normalizeHyperWeight];
    _areChildrenInTemporaryOrder = 0;
}

- (void)discardTemporaryChildrenOrder
{
    if (_areChildrenInTemporaryOrder)
        [self restoreOriginalChildrenOrderWithUndo:NO];
}

- (void)restoreOriginalChildrenOrderWithUndo:(BOOL)aUndo
{
    NSMutableArray *children = [self children];
    NSUndoManager *undoManager = [self undoManager];
    if (aUndo) {
        [[undoManager prepareWithInvocationTarget:self] makeTemporaryOrderOriginal];
        [[undoManager prepareWithInvocationTarget:children] setArray:[[children copy] autorelease]];
    }
    [self notifyChange:1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withUserInfo:nil];
    [children sortByHyperOrder];
    [self notifyChange:2 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withUserInfo:nil];
    _areChildrenInTemporaryOrder = 0;
}

- (void)setChildren:(id)aChildren
{
    [self disconnectFromChildren];
    if (aChildren == nil) {
        [_children release];
        _children = nil;
    } else {
        [[self children] setArray:aChildren];
        [[self children] sortByHyperOrder];
        [self connectToChildren];
    }
}

- (id)children
{
    if (_children == nil) {
        _children = [NSMutableArray new];
        if (_fileWrapper != nil)
            [self loadChildrenFromFileWrapper:_fileWrapper];
    }
    return _children;
}

- (id)HSNode_attributeNotificationCenter
{
    return [HSAttributeNotificationCenter defaultCenter];
}

- (void)dereferenceObject:(id)aObject
{
    [self rejectImplementation:aObject];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[(id)_parent attributeObservingController] removeAttributeObserver:self];
    if (_priorityToChildrenAttributeNotificationCentersMap != nil) {
        [self HSNode_unregisterChildrenAttributeNotificationCenters];
        NSFreeMapTable(_priorityToChildrenAttributeNotificationCentersMap);
    }
    [_attributesBeingChangedContinuously release];
    if (_attributesBeingChangedExtraContinuously != nil)
        NSFreeMapTable(_attributesBeingChangedExtraContinuously);
    [_attributesChangedTemporary release];
    if (_attributesChangedExtraTemporary != nil)
        NSFreeMapTable(_attributesChangedExtraTemporary);
    if (_linkedAttributesMap != nil)
        NSFreeMapTable(_linkedAttributesMap);
    [_children release];
    [_fileWrapper release];
    [_hyperOrderWeight release];
    [_filenameGenerator release];
    [_uniqueBasename release];
    [_explicitNodeDataProvider release];
    [_sharedNodeDataUID release];
    [_localNodeData setOwner:nil];
    [_localNodeData release];
    [_nodeData release];
    if (_interfaceToOverriddenUnitBasedHyperImplementationClassMap != nil)
        NSFreeMapTable(_interfaceToOverriddenUnitBasedHyperImplementationClassMap);
    if (_interfaceToUnitMap != nil)
        NSFreeMapTable(_interfaceToUnitMap);
    if (_attributeToUnitMap != NULL)
        CFRelease(_attributeToUnitMap);
    NSEnumerator *enumerator = [_units objectEnumerator];
    id unit;
    while ((unit = [enumerator nextObject]) != nil)
        [unit registerEjectionFromNode:self];
    [_units release];
    if (_interfaceToImplementationMap != nil)
        NSFreeMapTable(_interfaceToImplementationMap);
    if (_implementationToInterfacesMap != nil) {
        NSMapEnumerator mapEnumerator = NSEnumerateMapTable(_implementationToInterfacesMap);
        id implementation;
        void *interfaces;
        while (NSNextMapEnumeratorPair(&mapEnumerator, (void **)&implementation, &interfaces)) {
            if ([implementation conformsToProtocol:@protocol(HSWeakReferencing)])
                [implementation unregisterWeakReferencer:self];
        }
        NSEndMapTableEnumeration(&mapEnumerator);
        NSFreeMapTable(_implementationToInterfacesMap);
    }
    [super dealloc];
}

// The children hold this node as an unretained parent: they let go of it
// before the last reference goes.
- (void)release
{
    if ([self retainCount] == 1)
        [_children makeObjectsPerformSelector:@selector(setParent:) withObject:nil];
    [super release];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    if (_explicitNodeDataProvider == nil || _sharedNodeDataUID == nil) {
        _localNodeData = [[[self class] nodeDataClass] new];
        [_localNodeData setOwner:self];
        _nodeData = [_localNodeData retain];
        // Fix: a UID without a provider was leaked.
        [_sharedNodeDataUID release];
        _sharedNodeDataUID = nil;
    } else {
        _localNodeData = nil;
        _nodeData = [[_explicitNodeDataProvider nodeDataWithUID:_sharedNodeDataUID] retain];
    }
    _hyperOrderWeight = [@"1" retain];
    _filenameGenerator = [[HSUniqueNameGenerator alloc] initWithDataSource:self itemNameSelector:@selector(uniqueBasenameForGeneration)];
    NSDictionary *unitClassNames = [[self class] defaultUnitClassNames];
    NSEnumerator *enumerator = [unitClassNames keyEnumerator];
    id role;
    while ((role = [enumerator nextObject]) != nil) {
        id unit = [[[NSClassFromString([unitClassNames objectForKey:role]) alloc] init] autorelease];
        if (unit != nil)
            [self HSNode_injectUnit:unit forRole:role asUndoableOperation:NO];
    }
    return self;
}

- (id)initWithExplicitNodeDataProvider:(id)aProvider sharedNodeDataUID:(id)aUID
{
    _explicitNodeDataProvider = [aProvider retain];
    _sharedNodeDataUID = [aUID retain];
    return [self init];
}

- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    id provider = [[[aDictionary objectForKey:HSExplicitNodeDataProviderKey] retain] autorelease];
    if (provider != nil)
        _explicitNodeDataProvider = [provider retain];
    id UIDRepresentation = [[[aDictionary objectForKey:HSSharedNodeDataUIDKey] retain] autorelease];
    if (UIDRepresentation != nil)
        _sharedNodeDataUID = [[HSUID objectWithExtraDictionary:UIDRepresentation] retain];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:aDictionary];
    if (_explicitNodeDataProvider != nil)
        [dictionary removeObjectForKey:HSExplicitNodeDataProviderKey];
    return [super initWithExtraDictionary:dictionary codingContext:aContext];
}

- (void)HSNode_unregisterChildrenAttributeNotificationCenters
{
    NSEnumerator *enumerator = [_children objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        [self HSNode_unregisterChildrenAttributeNotificationCentersWithinChild:child];
}

- (void)HSNode_unregisterChildrenAttributeNotificationCentersWithinChild:(id)aChild
{
    NSMapEnumerator enumerator = NSEnumerateMapTable(_priorityToChildrenAttributeNotificationCentersMap);
    id center = nil;
    while (NSNextMapEnumeratorPair(&enumerator, NULL, (void **)&center))
        [[aChild attributeObservingController] removeObserver:center selector:@selector(postAttributeChangeNotification:) ofChanges:HSAllAttributeChanges ofAttribute:nil];
    NSEndMapTableEnumeration(&enumerator);
}

- (void)HSNode_registerChildrenAttributeNotificationCenters
{
    NSEnumerator *enumerator = [_children objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil)
        [self HSNode_registerChildrenAttributeNotificationCentersWithinChild:child];
}

- (void)HSNode_registerChildrenAttributeNotificationCentersWithinChild:(id)aChild
{
    NSMapEnumerator enumerator = NSEnumerateMapTable(_priorityToChildrenAttributeNotificationCentersMap);
    void *key = NULL;
    id center = nil;
    while (NSNextMapEnumeratorPair(&enumerator, &key, (void **)&center))
        [[aChild attributeObservingController] addObserver:center selector:@selector(postAttributeChangeNotification:) ofChanges:HSAllAttributeChanges ofAttribute:nil withPriority:(float)(NSInteger)key * 0.0001f];
    NSEndMapTableEnumeration(&enumerator);
}

// Units are kept behind proxies, so replacing the unit of a role leaves the
// interface lookups valid.
- (void)HSNode_injectUnit:(id)aUnit forRole:(id)aRole asUndoableOperation:(BOOL)aOperation
{
    id existing = nil;
    if (_units == nil) {
        _units = [[NSMutableDictionary alloc] init];
        if (_units == nil)
            return;
    } else
        existing = [_units objectForKey:aRole];

    id sizeAttributes = [self queryHyperInterface:@protocol(HSSizeAdditionalAttributes)];
    if (sizeAttributes != nil && [sizeAttributes isIntegralSize] && [aUnit conformsToProtocol:@protocol(HSSizeNodeStorage)]) {
        NSSize size = [(id <HSSizeAttributes>)aUnit size];
        NSSize roundedSize = NSMakeSize(roundf(size.width), roundf(size.height));
        if (!NSEqualSizes(size, roundedSize))
            [(id <HSSizeAttributes>)aUnit setSize:roundedSize];
    }

    id attributes = [aUnit attributes];
    if ([attributes count] == 0)
        attributes = nil;
    if (existing == nil) {
        id proxy = [HSObjectProxy proxyWithObject:aUnit];
        if (proxy == nil)
            return;
        if (attributes != nil)
            [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
        [_units setObject:proxy forKey:aRole];
        if (_interfaceToUnitMap == nil)
            _interfaceToUnitMap = NSCreateMapTable(HSProtocolMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
        if (_interfaceToUnitMap != nil) {
            NSEnumerator *enumerator = [[aUnit implementedHyperInterfaces] objectEnumerator];
            id interface;
            while ((interface = [enumerator nextObject]) != nil)
                NSMapInsertKnownAbsent(_interfaceToUnitMap, [(HSProtocolIdentifier *)interface protocol], proxy);
        }
        if (_attributeToUnitMap != NULL) {
            for (id attribute in attributes)
                CFDictionaryAddValue(_attributeToUnitMap, attribute, aUnit);
        }
    } else {
        id oldUnit = [existing object];
        if (aOperation)
            [[[self undoManager] prepareWithInvocationTarget:self] injectUnit:oldUnit forRole:aRole];
        if (attributes != nil)
            [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
        [oldUnit registerEjectionFromNode:self];
        [existing setObject:aUnit];
    }
    [aUnit registerInjectionIntoNode:self];
    if (attributes != nil)
        [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (id)loadedChildren
{
    if (_children == nil)
        return nil;
    return [NSArray arrayWithArray:[self children]];
}

@end
