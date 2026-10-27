#import "HSConcreteCardObject.h"

// The HTML5 export context (application side).
@protocol HSConcreteCardObjectHTML5ExportContext
- (NSString *)documentType;
@end

static NSString *HSConcreteCardObjectLocalizedUndoName(NSString *aKey)
{
    return [[NSBundle mainBundle] localizedStringForKey:aKey value:@"" table:@"UndoManager"];
}

static NSString *HSConcreteCardObjectUnsupportedFeature(NSString *aKey)
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:aKey value:@"" table:@"Export"];
}

// Card object with the common player behaviors (drag, resize, rotate, hide, lock, drop off),
// a per-object effect, autoplay and group (background) object support.
@implementation HSConcreteCardObject
+ (Class)nodeDataClass
{
    return [HSConcreteCardObjectData class];
}
// XML geometry is top-left based: the transform is flipped against the card height.
- (void)importGeometryFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    if (!aRepresentation)
        return;
    NSArray *components = [[[aRepresentation attributeForName:@"size"] stringValue] componentsSeparatedByString:@","];
    float width = 0.0f, height = 0.0f;
    if ([components count] > 1) {
        height = [[components objectAtIndex:1] floatValue];
        width = [[components objectAtIndex:0] floatValue];
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    components = [[[aRepresentation attributeForName:@"affineTransform"] stringValue] componentsSeparatedByString:@","];
    if ([components count] == 6) {
        transform.a = [[components objectAtIndex:0] floatValue];
        transform.b = [[components objectAtIndex:1] floatValue];
        transform.c = [[components objectAtIndex:2] floatValue];
        transform.d = [[components objectAtIndex:3] floatValue];
        transform.tx = [[components objectAtIndex:4] floatValue];
        transform.ty = [[components objectAtIndex:5] floatValue];
    }
    id geometry = [self queryHyperInterface:@protocol(HSMutableGeometryAttributes)];
    id owner = [self stack] ? (id)self : [[NSDocumentController sharedDocumentController] currentDocument];
    NSSize cardSize = [[owner stack] hyperCardSize];
    float span = (float)(CGPointZero.y + CGPointZero.y + height);
    CGAffineTransform flipped = CGAffineTransformMake(transform.a, -transform.b, -transform.c, transform.d,
                                                      transform.c * span + transform.tx, -transform.d * span + ((float)cardSize.height - transform.ty));
    [geometry setSize:NSMakeSize(width, height) affineTransform:flipped flippedHorizontally:NO];
}
- (void)importSharedPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importSharedPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [self setHyperName:[[[aRepresentation elementsForName:HSXMLStoringNameString] extraFirstObject] stringValue]];
    [self setHyperComments:[[[aRepresentation elementsForName:HSXMLStoringCommentString] extraFirstObject] stringValue]];
    id behavior = [[aRepresentation elementsForName:@"behavior"] extraFirstObject];
    [self setDraggable:[[[behavior attributeForName:@"draggable"] stringValue] hyperBoolValue]];
    if ([self respondsToSelector:@selector(setEnabled:)])
        [(id)self setEnabled:[[[behavior attributeForName:@"enabled"] stringValue] hyperBoolValue]];
    [self setHidden:![[[behavior attributeForName:@"visible"] stringValue] hyperBoolValue]];
    [self setLocked:[[[behavior attributeForName:@"locked"] stringValue] hyperBoolValue]];
    [self setDropOffOnly:[[[behavior attributeForName:@"dropoffonly"] stringValue] hyperBoolValue]];
    [self setNoClick:[[[behavior attributeForName:@"mouseover"] stringValue] hyperBoolValue]];
    if ([[[behavior attributeForName:@"wantsgroup"] stringValue] hyperBoolValue]) {
        // The first object of a group registers its element as the prototype.
        if (![aContext prototypeObjectForUID:[self hyperUID]])
            [aContext setPrototypeObject:aRepresentation forUID:[self hyperUID]];
        [self makeGroupObject];
    }
    [(HSConcreteCardObjectData *)[self nodeData] setOpacity:[[[behavior attributeForName:@"opacity"] stringValue] floatValue]];
}
- (void)importLocalPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importLocalPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    id title = [self queryHyperInterface:@protocol(HSTitleMutableAttributes)];
    if (title)
        [title setTitle:[[[aRepresentation elementsForName:HSXMLStoringTitleString] extraFirstObject] stringValue]];
}
- (BOOL)canBeStoredAsXMLElement
{
    return [self isGenericCardObjectForXMLStoring];
}
- (void)storeSharedPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeSharedPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    [aRepresentation addChild:[NSXMLElement elementWithName:HSXMLStoringNameString stringValue:[self name]]];
    [aRepresentation addChild:[NSXMLElement elementWithName:HSXMLStoringCommentString stringValue:[self hyperComments]]];
    NSXMLElement *behavior = [NSXMLElement elementWithName:@"behavior"];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"draggable" stringValue:[self isDraggable] ? HSXMLStoring1String : HSXMLStoring0String]];
    id enabled = [self queryHyperInterface:@protocol(HSSystemEnabledAttribute)];
    if (enabled)
        [behavior addAttribute:[NSXMLNode attributeWithName:@"enabled" stringValue:[enabled isEnabled] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"visible" stringValue:[self isHidden] ? HSXMLStoring0String : HSXMLStoring1String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"locked" stringValue:[self isLocked] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"dropoffonly" stringValue:[self isDropOffOnly] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"mouseover" stringValue:[self isNoClick] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"wantsgroup" stringValue:[self isGroupObject] ? HSXMLStoring1String : HSXMLStoring0String]];
    NSString *opacity = [NSString stringWithFormat:@"%.3f", [(HSConcreteCardObjectData *)[self nodeData] opacity]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"opacity" stringValue:opacity]];
    [aRepresentation addChild:behavior];
}
// Generic objects are stored as an image: their own media, or a rendered PNG.
- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeLocalPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    id title = [self queryHyperInterface:@protocol(HSTitleAttributes)];
    NSString *string = title ? [title title] : [self hyperName];
    [aRepresentation addChild:[NSXMLElement elementWithName:HSXMLStoringTitleString stringValue:string]];
    if (![self isGenericCardObjectForXMLStoring])
        return;
    id media = nil;
    NSSet *uids = [[self queryHyperInterface:@protocol(HSMediaCopySupport)] ownedMediaUIDs];
    if (!uids || [uids count] == 0) {
        NSString *name = [[[self hyperUID] stringValue] stringByAppendingPathExtension:@"png"];
        media = [HSNewMedia mediaWithImage:[self imageForIPadExport] name:name];
        [aContext addMedia:media];
    } else {
        // Every owned media is added; the reference names the last one.
        NSEnumerator *enumerator = [uids objectEnumerator];
        id uid;
        while ((uid = [enumerator nextObject])) {
            media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid];
            [aContext addMedia:media];
        }
    }
    NSXMLElement *reference = [NSXMLElement elementWithName:@"mediaRef"];
    [reference addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[media mediaUID] stringValue]]];
    [aRepresentation addChild:reference];
}
- (id)XMLElementName
{
    return @"objImage";
}
- (id)XMLGeometryElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [NSXMLElement elementWithName:@"geometry"];
    NSRect bounds = [self boundsForXMLStoring];
    CGAffineTransform t = [[self queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
    float span = (float)(bounds.origin.y + bounds.origin.y + bounds.size.height);
    float tx = (float)(t.c * span + t.tx + (t.a * bounds.origin.x - t.c * bounds.origin.y));
    float ty = (float)(t.d * span + t.ty + (t.b * bounds.origin.x - t.d * bounds.origin.y));
    NSSize cardSize = [[[aContext document] stack] hyperCardSize];
    ty = (float)cardSize.height - ty;
    NSSize size = [(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
    [element addAttribute:[NSXMLNode attributeWithName:@"size" stringValue:[NSString stringWithFormat:@"%.1f,%.1f", size.width, size.height]]];
    NSString *transform = [NSString stringWithFormat:@"%.8f,%.8f,%.8f,%.8f,%.8f,%.8f", (double)(float)t.a, (double)-(float)t.b, (double)-(float)t.c, (double)(float)t.d, (double)tx, (double)ty];
    [element addAttribute:[NSXMLNode attributeWithName:@"affineTransform" stringValue:transform]];
    return element;
}
- (NSRect)boundsForXMLStoring
{
    return [[self queryHyperInterface:@protocol(HSGeometryAttributes)] boundingRect];
}
- (BOOL)isGenericCardObjectForXMLStoring
{
    return [[self XMLElementName] isEqualToString:@"objImage"];
}
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    NSMutableSet *features = [NSMutableSet setWithSet:[super HTML5UnsupportedFeaturesForDocumentType:aType]];
    if ([self isRotatable])
        [features addObject:HSConcreteCardObjectUnsupportedFeature(@"HSHTML5UnsupportedFeatureRotatable")];
    if ([self isResizable])
        [features addObject:HSConcreteCardObjectUnsupportedFeature(@"HSHTML5UnsupportedFeatureResizable")];
    if ([self isNoClick] && [aType isEqualToString:@"HSiBooksAuthorDocumentType"])
        [features addObject:HSConcreteCardObjectUnsupportedFeature(@"HSHTML5UnsupportedFeatureNoClick")];
    return features;
}
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    if ([super hasUnsupportedHTML5FeaturesForDocumentType:aType] || [self isRotatable] || [self isResizable])
        return YES;
    return [self isNoClick] && [aType isEqualToString:@"HSiBooksAuthorDocumentType"];
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [dictionary setObject:[self isDraggable] ? @"1" : @"0" forKey:@"isDraggable"];
    [dictionary setObject:[self isResizable] ? @"1" : @"0" forKey:@"isResizable"];
    [dictionary setObject:[self isRotatable] ? @"1" : @"0" forKey:@"isRotatable"];
    [dictionary setObject:[self isHidden] ? @"0" : @"1" forKey:@"isVisible"];
    [dictionary setObject:[self isDropOffOnly] ? @"1" : @"0" forKey:@"isDropOffOnly"];
    // iBooks Author has no mouse over: no-click objects stay clickable there.
    BOOL noClick = [self isNoClick] && ![[(id<HSConcreteCardObjectHTML5ExportContext>)aContext documentType] isEqualToString:@"HSiBooksAuthorDocumentType"];
    [dictionary setObject:noClick ? @"1" : @"0" forKey:@"isNoClick"];
    [dictionary setObject:[self isGroupObject] ? @"1" : @"0" forKey:@"isGroupObject"];
    if ([self isDraggable]) {
        HSCursor *cursor = [self hyperCursor];
        if (!cursor)
            cursor = [HSCursor draggableCursor];
        id media = [HSNewMedia mediaWithImage:[cursor image]];
        [aContext addMedia:media];
        NSString *path = [@"Resources" stringByAppendingPathComponent:[HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media]];
        [dictionary setObject:[NSString stringWithFormat:@"url(%@), pointer", path] forKey:@"cursor"];
        NSPoint hotSpot = [cursor hotSpot];
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", hotSpot.x] forKey:@"hotSpotX"];
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", hotSpot.y] forKey:@"hotSpotY"];
        id targetIdentification = [self queryHyperInterface:@protocol(HSMutableSnappingTargetUIDIdentification)];
        if ([targetIdentification dropOffTargetUID]) {
            id targetUID = [targetIdentification dropOffTargetUID];
            id target = [[[self card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:targetUID];
            id snapOptions = [[target queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)];
            NSInteger range = [snapOptions isDropOffSnappingEnabled] ? [snapOptions dropOffSnappingRange] : 0;
            NSMutableDictionary *snapping = [NSMutableDictionary dictionary];
            [snapping setObject:[NSString stringWithFormat:@"%d", (int)range] forKey:@"delta"];
            [snapping setObject:[targetUID stringValue] forKey:@"target"];
            if ([snapOptions playDropOffRewardSound]) {
                id sound = [snapOptions dropOffRewardSoundMedia];
                [aContext addMedia:sound];
                [snapping setObject:[@"Resources" stringByAppendingPathComponent:[HSHTML5ExporterHelper JSonCorrectFilenameForMedia:sound]] forKey:@"rewardSound"];
            }
            [dictionary setObject:snapping forKey:@"snapping"];
        }
    }
    if (![self implementsHyperInterface:@protocol(HSMovieObjectAttribute)]) {
        BOOL target = [[self queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)] isDropOffTarget];
        [dictionary setObject:target ? @"1" : @"0" forKey:@"isDropOffTarget"];
    }
    [dictionary setObject:@"1" forKey:@"opacity"];
    [dictionary setObject:[[self hyperUID] stringValue] forKey:@"id"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[self hyperIndex]] forKey:@"order"];
    id<HSGeometryAttributes> geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    // Objects exported as images carry their frame (including the shadow) and no rotation.
    if ([self shouldBeExportedAsImage] && ![[self queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)] isDropOffTarget]) {
        NSRect frame = [self affineFrameBoundingRectIncludingShadow];
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)(float)frame.origin.x] forKey:@"xCoord"];
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)(float)frame.origin.y] forKey:@"yCoord"];
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)(float)frame.size.width] forKey:@"xSize"];
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)(float)frame.size.height] forKey:@"ySize"];
        [dictionary setObject:@"0" forKey:@"rotationAngle"];
        [pool release];
        return dictionary;
    }
    CGAffineTransform t = [geometry affineTransform];
    BOOL flipped = [geometry isFlippedHorizontally];
    float angle;
    if (t.a != 0.0 || t.b != 0.0) {
        angle = flipped ? atan2f(-(float)t.b, -(float)t.a) : atan2f((float)t.b, (float)t.a);
    } else {
        angle = flipped ? atan2f(-(float)t.d, -(float)t.c) : atan2f((float)t.d, (float)t.c);
        angle = (float)(angle - M_PI_2);
    }
    if (angle < 0.0f)
        angle += 6.2831855f;
    // The position is the untransformed frame placed around the transformed center.
    float halfHeight = (float)[geometry height] * 0.5f;
    float halfWidth = (float)[geometry width] * 0.5f;
    float x = (float)(t.a * halfWidth + t.c * halfHeight + t.tx) - halfWidth;
    float y = (float)(t.b * halfWidth + t.d * halfHeight + t.ty) - halfHeight;
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)x] forKey:@"xCoord"];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)y] forKey:@"yCoord"];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)[geometry width]] forKey:@"xSize"];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)[geometry height]] forKey:@"ySize"];
    float scale = angle != 0.0f ? fabsf(angle) : 1.0f;
    double degrees = fabsf(angle) > MAX(scale, 1.0f) * 0.0005f ? (double)((angle * 180.0f) / 3.1415927f) : 0.0;
    [dictionary setObject:[NSString stringWithFormat:@"%f", degrees] forKey:@"rotationAngle"];
    [pool release];
    return dictionary;
}
- (BOOL)shouldSetStoredAttributes
{
    return ![[self document] isInPlayerMode];
}
- (void)postProcessAfterCreationFromGroupObject:(id)aObject
{
}
// The drop off target is copied along and the copy retargeted to it.
// Quirk: both copies ignore aUnits (node units are never included).
- (id)localCopyIncludingNodeUnits:(BOOL)aUnits copiedLinkedObjects:(id *)aObjects
{
    NSMutableArray *linkedObjects = aObjects ? [NSMutableArray arrayWithCapacity:0] : nil;
    id copy = [super localCopyIncludingNodeUnits:NO copiedLinkedObjects:&linkedObjects];
    id targetIdentification = [copy queryHyperInterface:@protocol(HSMutableSnappingTargetUIDIdentification)];
    NSArray *targetLinkedObjects = nil;
    id access = [[self card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)];
    id target = [[access childInTreeWithUID:[targetIdentification dropOffTargetUID]] localCopyIncludingNodeUnits:NO copiedLinkedObjects:&targetLinkedObjects];
    [targetIdentification setDropOffTargetUID:[target hyperUID]];
    if (targetLinkedObjects)
        [linkedObjects addObjectsFromArray:targetLinkedObjects];
    if (target)
        [linkedObjects addObject:target];
    if (aObjects)
        *aObjects = linkedObjects;
    return copy;
}
- (id)linkedObjects
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:0];
    id targetIdentification = [self queryHyperInterface:@protocol(HSMutableSnappingTargetUIDIdentification)];
    id access = [[self card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)];
    id target = [access childInTreeWithUID:[targetIdentification dropOffTargetUID]];
    if (target)
        [objects addObject:target];
    return objects;
}
- (BOOL)hasLinkedObjects
{
    return [[self queryHyperInterface:@protocol(HSMutableSnappingTargetUIDIdentification)] dropOffTargetUID] != nil;
}
// A local copy keeps the UID and gets its own node data (group objects lose the shared one).
- (id)localCopyIncludingNodeUnits:(BOOL)aUnits
{
    id copy = [super localCopyIncludingNodeUnits:aUnits];
    id uid = [[copy hyperUID] retain];
    if ([self isGroupObject])
        [copy setSharedNodeDataUID:nil];
    [copy setLocalNodeData:[[[self nodeData] localCopy] autorelease]];
    [copy setHyperUID:uid];
    [uid release];
    return copy;
}
- (void)setInteractiveInAnimation:(BOOL)aAnimation
{
    if (_interactiveInAnimation == aAnimation)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSInteractiveInAnimationAttribute) withUserInfo:nil];
    _interactiveInAnimation = aAnimation;
    [self notifyChange:2 ofAttribute:@protocol(HSInteractiveInAnimationAttribute) withUserInfo:nil];
}
- (BOOL)isInteractiveInAnimation
{
    return _interactiveInAnimation;
}
- (void)setAnimatedObject:(BOOL)aObject
{
    if (_animatedObject == aObject)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSAnimatedObjectAttribute) withUserInfo:nil];
    _animatedObject = aObject;
    [self notifyChange:2 ofAttribute:@protocol(HSAnimatedObjectAttribute) withUserInfo:nil];
}
- (BOOL)isAnimatedObject
{
    return _animatedObject;
}
- (id)quickTimeEffectAdjustedToSize:(NSSize)aSize
{
    if (![self quickTimeEffect])
        return nil;
    return [self effectPerObjectAdjustedToSize:aSize];
}
- (id)coreImageEffectAdjustedToSize:(NSSize)aSize
{
    if (![self coreImageEffect])
        return nil;
    return [self effectPerObjectAdjustedToSize:aSize];
}
- (id)quickTimeEffect
{
    if (![[self effectPerObject] isKindOfClass:[HSQTEffect class]])
        return nil;
    return [self effectPerObject];
}
- (id)coreImageEffect
{
    if (![[self effectPerObject] isKindOfClass:[HSCIEffect class]])
        return nil;
    return [self effectPerObject];
}
- (void)setHyperValue:(id)aValue forKey:(id)aKey
{
    [[self effectPerObject] setValue:aValue forKey:aKey];
}
- (void)setHyperEffectName:(id)aName settings:(id)aSettings
{
    [[self undoManager] setActionName:HSConcreteCardObjectLocalizedUndoName(@"Change Object Effect")];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperEffectName:[self hyperEffectName] settings:[[self nodeData] effectSettings]];
    [self notifyChange:1 ofAttribute:@protocol(HSGeometryAttribute) withUserInfo:nil];
    [self notifyChange:1 ofAttribute:@protocol(HSEffectVisualAttribute) withUserInfo:nil];
    [self notifyChange:1 ofAttribute:@protocol(HSEffectNameAttribute) withUserInfo:nil];
    [[self nodeData] setEffectName:aName settings:aSettings];
    [self notifyChange:2 ofAttribute:@protocol(HSEffectVisualAttribute) withUserInfo:nil];
    [self notifyChange:2 ofAttribute:@protocol(HSEffectNameAttribute) withUserInfo:nil];
    [self notifyChange:2 ofAttribute:@protocol(HSGeometryAttribute) withUserInfo:nil];
}
// Empty in the original; names change with their settings.
- (void)setHyperEffectName:(id)aName
{
}
- (id)hyperValueForKey:(id)aKey
{
    return [[self effectPerObject] valueForKey:aKey];
}
- (id)hyperInputKeys
{
    return [[self effectPerObject] inputKeys];
}
- (id)effectSettings
{
    return [[self nodeData] effectSettings];
}
- (id)hyperAttributes
{
    return [[self effectPerObject] attributes];
}
- (struct CGPath *)effectSourceAreaBoundingPath
{
    return NULL;
}
- (id)hyperEffectName
{
    return [(HSEffect *)[self effectPerObject] name];
}
- (id)effectPerObjectAdjustedToSize:(NSSize)aSize
{
    HSEffect *effect = [self effectPerObject];
    id settings = [[HSEffectSettings sharedSettings] adjustedSettings:[[self nodeData] effectSettings] forName:[effect name] category:[effect category] frameSize:aSize];
    [effect setAttributes:settings];
    return effect;
}
- (id)effectPerObject
{
    return [[self nodeData] effectPerObject];
}
- (BOOL)hasEffectPerObject
{
    return [self effectPerObject] != nil;
}
- (BOOL)supportsEffectPerObject
{
    return [self implementsHyperInterface:@protocol(HSEffectPerObjectAttributes)];
}
// Group objects share node data: the other objects of the group get the notification too,
// without the HSNode* attributes, which stay per object.
- (void)HSNode_postAttributeChangeNotification:(id)aNotification
{
    if ([self isGroupCardObjectsNotificationPatchForNodeDataEnabled] && [self sharedNodeDataUID]) {
        NSEProtocolSet *attributes = [aNotification attributeProtocolSet];
        NSEMutableProtocolSet *filtered = nil;
        for (Protocol *attribute in attributes) {
            const char *name = protocol_getName(attribute);
            if (strstr(name, "HSNode") == name) {
                if (!filtered)
                    filtered = [[attributes mutableCopy] autorelease];
                [filtered removeProtocol:attribute];
            }
        }
        if (filtered) {
            if ([filtered count] == 0) {
                [super HSNode_postAttributeChangeNotification:aNotification];
                return;
            }
            attributes = filtered;
        }
        NSInteger change = [aNotification attributeChange];
        NSEnumerator *enumerator = [[[[self support] cardGroupController] objectsWithNodeDataUID:[self sharedNodeDataUID]] objectEnumerator];
        HSConcreteCardObject *object;
        while ((object = [enumerator nextObject])) {
            if (object != self)
                [object HSNode_justPostAttributeChangeNotification:[aNotification notificationWithChange:change attributeSet:attributes object:object]];
        }
    }
    [super HSNode_postAttributeChangeNotification:aNotification];
}
- (void)HSNode_justPostAttributeChangeNotification:(id)aNotification
{
    [super HSNode_postAttributeChangeNotification:aNotification];
}
// The drop off target goes with the object; group objects are removed through the group controller.
- (void)removeFromHyperParent
{
    [[self dropOffObject] removeFromHyperParent];
    if ([self isGroupObject] && [[self card] cardGroupUID]) {
        [[[self support] cardGroupController] removeGroupObject:self];
        return;
    }
    [super removeFromHyperParent];
}
- (void)notifyDidChangeCardObjectGroupAttribute
{
    [[[self undoManager] prepareWithInvocationTarget:self] notifyWillChangeCardObjectGroupAttribute];
    [self notifyChange:2 ofAttribute:@protocol(HSCardObjectGroupAttribute) withUserInfo:nil];
}
- (void)notifyWillChangeCardObjectGroupAttribute
{
    [[[self undoManager] prepareWithInvocationTarget:self] notifyDidChangeCardObjectGroupAttribute];
    [self notifyChange:1 ofAttribute:@protocol(HSCardObjectGroupAttribute) withUserInfo:nil];
}
- (void)makeGroupObjectIgnoringGroupObjectFlag
{
    [[self nodeData] setGroupObjectFlag:NO];
    [self makeGroupObject];
}
- (void)makeNonGroupObject
{
    id dropOffObject = [self dropOffObject];
    if ([dropOffObject isGroupObject])
        [dropOffObject makeNonGroupObject];
    [self notifyWillChangeCardObjectGroupAttribute];
    [[[self support] cardGroupController] makeNonGroupObject:self];
    [self notifyDidChangeCardObjectGroupAttribute];
}
- (void)makeGroupObject
{
    id dropOffObject = [self dropOffObject];
    if (![dropOffObject isGroupObject])
        [dropOffObject makeGroupObject];
    [self notifyWillChangeCardObjectGroupAttribute];
    [[[self support] cardGroupController] makeGroupObject:self];
    [self notifyDidChangeCardObjectGroupAttribute];
}
- (BOOL)isGroupObject
{
    return [[self nodeData] groupObjectFlag];
}
- (void)setHyperIgnoredInLayoutGuiding:(BOOL)aGuiding
{
    [[self nodeData] setHyperIgnoredInLayoutGuiding:aGuiding];
}
- (BOOL)isHyperIgnoredInLayoutGuiding
{
    return [[self nodeData] isHyperIgnoredInLayoutGuiding];
}
- (NSRect)hyperLayoutInfluencingBoundingRect
{
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (!geometry)
        return NSZeroRect;
    return [geometry boundingRect];
}
- (CGAffineTransform)hyperLayoutInfluencingTransform
{
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (!geometry)
        return CGAffineTransformIdentity;
    return [geometry affineTransform];
}
- (BOOL)isHyperInfluencingLayout
{
    return ![[self nodeData] isHyperIgnoredInLayoutGuiding];
}
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    [self postprocessDeprecatedActionEvents];
}
// Old drop off and mouse over events became click events.
- (void)postprocessDeprecatedActionEvents
{
    id click = [HSActionEvent actionEventOfType:kHSClickActionEventType];
    id dropOff = [HSActionEvent actionEventOfType:kHSDeprecatedDropOffActionEventType];
    id mouseOver = [HSActionEvent actionEventOfType:kHSDeprecatedMouseOverActionEventType];
    NSEnumerator *enumerator = [[[self queryHyperInterface:@protocol(HSActor)] hyperActions] objectEnumerator];
    id action;
    while ((action = [enumerator nextObject])) {
        BOOL runsOnMouseOver = [action runsWithActionEvent:mouseOver];
        BOOL runsOnDropOff = [action runsWithActionEvent:dropOff];
        if (runsOnMouseOver)
            [action removeActionEvent:mouseOver];
        if (runsOnDropOff)
            [action removeActionEvent:dropOff];
        if ((runsOnDropOff || runsOnMouseOver) && ![action runsWithActionEvent:click])
            [action addActionEvent:click];
    }
}
- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys;
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        keys = [NSMutableArray arrayWithCapacity:4];
        [keys addObject:@"hidden"];
        [keys addObject:@"draggable"];
        [keys addObject:@"resizable"];
        [keys addObject:[@"rotatable" extraKeyForCollection]];
    } else {
        keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
        [keys addObject:@"draggable"];
        [keys addObject:@"locked"];
        [keys addObject:@"hyperIgnoredInLayoutGuiding"];
        [keys addObject:@"dropOffOnly"];
        [keys addObject:@"noClick"];
        [keys addObject:@"groupObjectFlag"];
        [keys addObject:@"hidden"];
        [keys addObject:@"effectName"];
        [keys addObject:@"effectSettings"];
    }
    return keys;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        [keys addObject:@"hidden"];
        [keys addObject:@"draggable"];
        [keys addObject:@"resizable"];
        [keys addObject:@"rotatable"];
    }
    [keys addObject:@"animatedObject"];
    [keys addObject:@"interactiveInAnimation"];
    return keys;
}
- (id)playSelfActionType
{
    return nil;
}
- (void)willRemoveFromParent
{
    [super willRemoveFromParent];
    if (![self isTemporary])
        [[self queryHyperInterface:@protocol(HSAutoplayAttributes)] setAutoplayed:NO];
}
- (void)didAddToParent
{
    [super didAddToParent];
    if (![self isTemporary])
        [[self queryHyperInterface:@protocol(HSAutoplayAttributes)] setAutoplayed:YES];
}
- (id)autoPlayActionEvent
{
    if (!_autoPlayActionEvent)
        _autoPlayActionEvent = [[HSActionEvent actionEventOfType:kHSArriveActionEventType] retain];
    return _autoPlayActionEvent;
}
- (void)setAutoPlayActionEvent:(id)aEvent
{
    if ([_autoPlayActionEvent isEqual:aEvent])
        return;
    [_autoPlayActionEvent release];
    _autoPlayActionEvent = [aEvent retain];
}
- (void)setAutoplayed:(BOOL)aAutoplayed
{
    [self setDefaultHyperPlayed:aAutoplayed onActionEvent:[self autoPlayActionEvent]];
}
- (BOOL)isAutoplayed
{
    return [self isDefaultHyperPlayedOnActionEvent:[self autoPlayActionEvent]];
}
- (id)queryVectorBrushHitTester
{
    return nil;
}
- (id)queryGroupBoxObjectHitTester
{
    return nil;
}
- (id)queryImageWellObjectHitTester
{
    return nil;
}
- (id)queryWebObjectHitTester
{
    return nil;
}
- (id)queryCameraObjectHitTester
{
    return nil;
}
- (id)queryTextViewObjectHitTester
{
    return nil;
}
- (id)queryImageObjectHitTester
{
    return nil;
}
- (id)queryMovieObjectHitTester
{
    return nil;
}
- (id)queryEffectObjectHitTester
{
    return nil;
}
- (id)queryButtonObjectHitTester
{
    return nil;
}
- (id)queryTextObjectHitTester
{
    return nil;
}
- (id)queryVectorGraphicObjectHitTester
{
    return nil;
}
- (id)queryInteractivePlayerItem
{
    return [[[HSInteractiveCanvasItem alloc] initWithNode:self] autorelease];
}
- (id)queryEditorHitTester
{
    return [[[HSVisualBoundsHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSEditorVisualization)] autorelease];
}
- (id)queryInteractiveHitTester
{
    return [self queryDefaultHitTester];
}
- (id)queryDefaultHitTester
{
    return [[[HSVisualBoundsHitTester alloc] initWithHyperObject:self] autorelease];
}
- (void)notifyDidChangeUserObjectHitTesterAttribute
{
    [self notifyChange:2 ofAttribute:@protocol(HSUserObjectHitTesterAttribute) withUserInfo:nil];
}
- (void)setNoClick:(BOOL)aClick
{
    if ([[self nodeData] isNoClick] == aClick)
        return;
    [[self undoManager] setActionName:HSConcreteCardObjectLocalizedUndoName(@"No Click Option")];
    [[[self undoManager] prepareWithInvocationTarget:self] setNoClick:[[self nodeData] isNoClick]];
    [self notifyChange:1 ofAttribute:@protocol(HSCardObjectNoClickAttribute) withUserInfo:nil];
    [[self nodeData] setNoClick:aClick];
    [self notifyChange:2 ofAttribute:@protocol(HSCardObjectNoClickAttribute) withUserInfo:nil];
}
- (BOOL)isNoClick
{
    return [[self nodeData] isNoClick];
}
// Drop off only excludes no click.
- (void)setDropOffOnly:(BOOL)aOnly
{
    if ([[self nodeData] isDropOffOnly] == aOnly)
        return;
    [[self undoManager] setActionName:HSConcreteCardObjectLocalizedUndoName(@"Sends Actions on Drop Off Only in Player Change")];
    [[[self undoManager] prepareWithInvocationTarget:self] setDropOffOnly:[[self nodeData] isDropOffOnly]];
    [self notifyChange:1 ofAttribute:@protocol(HSCardObjectDropOffOnlyAttribute) withUserInfo:nil];
    if (aOnly)
        [self setNoClick:NO];
    [[self nodeData] setDropOffOnly:aOnly];
    [self notifyChange:2 ofAttribute:@protocol(HSCardObjectDropOffOnlyAttribute) withUserInfo:nil];
}
- (BOOL)isDropOffOnly
{
    return [[self nodeData] isDropOffOnly];
}
- (BOOL)canSendActionsOnDrop
{
    return YES;
}
- (BOOL)canBeGrouped
{
    return YES;
}
- (BOOL)canBeFlatten
{
    return YES;
}
- (void)setLocked:(BOOL)aLocked
{
    if ([self isLocked] == aLocked)
        return;
    [[self undoManager] setActionName:HSConcreteCardObjectLocalizedUndoName(aLocked ? @"Lock" : @"Unlock")];
    [[[self undoManager] prepareWithInvocationTarget:self] setLocked:[self isLocked]];
    [self notifyChange:1 ofAttribute:@protocol(HSCardObjectLockedAttribute) withUserInfo:nil];
    [[self nodeData] setLocked:aLocked];
    [self notifyChange:2 ofAttribute:@protocol(HSCardObjectLockedAttribute) withUserInfo:nil];
}
- (BOOL)isLocked
{
    return [[self nodeData] isLocked];
}
- (BOOL)isVisibleInEditor
{
    return [[self nodeData] isVisibleInEditor];
}
- (void)setIsVisibleInEditor:(BOOL)aEditor
{
    [[self nodeData] setIsVisibleInEditor:aEditor];
}
- (BOOL)isHiddenInPlayer
{
    return [[self nodeData] isHiddenInPlayer];
}
// Not undoable; the stack keeps track of objects hidden in the player.
- (void)setHiddenInPlayer:(BOOL)aPlayer
{
    if ([self isHiddenInPlayer] == aPlayer)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSCardObjectHiddenAttribute) withUserInfo:nil];
    [[self nodeData] setHiddenInPlayer:aPlayer];
    [self notifyChange:2 ofAttribute:@protocol(HSCardObjectHiddenAttribute) withUserInfo:nil];
    [[[self stack] queryHyperInterface:@protocol(HSMutableStackAttributes)] addHiddenInPlayerObject:self];
}
// The undo is registered in its own group.
- (void)setHidden:(BOOL)aHidden
{
    if ([self isHidden] == aHidden)
        return;
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:HSConcreteCardObjectLocalizedUndoName(@"Toggle Object In Player Visibility")];
    BOOL groupsByEvent = [undoManager groupsByEvent];
    [undoManager setGroupsByEvent:NO];
    [undoManager beginUndoGrouping];
    [[undoManager prepareWithInvocationTarget:self] setHidden:[self isHidden]];
    [undoManager endUndoGrouping];
    [undoManager setGroupsByEvent:groupsByEvent];
    [self notifyChange:1 ofAttribute:@protocol(HSCardObjectHiddenAttribute) withUserInfo:nil];
    [[self nodeData] setHidden:aHidden];
    [self notifyChange:2 ofAttribute:@protocol(HSCardObjectHiddenAttribute) withUserInfo:nil];
}
- (BOOL)canBeHidden
{
    return YES;
}
- (BOOL)isHidden
{
    return [[self nodeData] isHidden];
}
- (BOOL)isDraggable
{
    if (![self canBeDraggable])
        return NO;
    return [[self nodeData] isDraggable];
}
- (void)setDraggable:(BOOL)aDraggable
{
    if ([[self nodeData] isDraggable] == aDraggable)
        return;
    [[self undoManager] setActionName:HSConcreteCardObjectLocalizedUndoName(@"Drag in Player Change")];
    [[[self undoManager] prepareWithInvocationTarget:self] setDraggable:[[self nodeData] isDraggable]];
    [self notifyChange:1 ofAttribute:@protocol(HSCardObjectDraggableAttribute) withUserInfo:nil];
    [[self nodeData] setDraggable:aDraggable];
    [self notifyChange:2 ofAttribute:@protocol(HSCardObjectDraggableAttribute) withUserInfo:nil];
}
- (BOOL)canBeDraggable
{
    return YES;
}
- (id)dropOffObject
{
    id uid = [[self queryHyperInterface:@protocol(HSMutableSnappingTargetUIDIdentification)] dropOffTargetUID];
    id target = [[[self card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:uid];
    return [target queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
}
- (void)setRotatable:(BOOL)aRotatable
{
    BOOL rotatable = [[self nodeData] isRotatableInPlayer];
    if (rotatable == aRotatable)
        return;
    [[self undoManager] setActionName:HSConcreteCardObjectLocalizedUndoName(@"Rotate in Player Change")];
    [[[self undoManager] prepareWithInvocationTarget:self] setRotatable:rotatable];
    [self notifyChange:1 ofAttribute:@protocol(HSCardObjectRotatableAttribute) withUserInfo:nil];
    [[self nodeData] setRotatableInPlayer:aRotatable];
    [self notifyChange:2 ofAttribute:@protocol(HSCardObjectRotatableAttribute) withUserInfo:nil];
}
- (BOOL)isRotatable
{
    if (![self canBeRotatable])
        return NO;
    return [[self nodeData] isRotatableInPlayer];
}
- (BOOL)canBeRotatable
{
    return YES;
}
- (void)setResizable:(BOOL)aResizable
{
    BOOL resizable = [[self nodeData] isResizable];
    if (resizable == aResizable)
        return;
    [[self undoManager] setActionName:HSConcreteCardObjectLocalizedUndoName(@"Resize in Player Change")];
    [[[self undoManager] prepareWithInvocationTarget:self] setResizable:resizable];
    [self notifyChange:1 ofAttribute:@protocol(HSCardObjectResizableAttribute) withUserInfo:nil];
    [[self nodeData] setResizable:aResizable];
    [self notifyChange:2 ofAttribute:@protocol(HSCardObjectResizableAttribute) withUserInfo:nil];
}
- (BOOL)isResizable
{
    if (![self canBeResizable])
        return NO;
    return [[self nodeData] isResizable];
}
- (BOOL)canBeResizable
{
    return YES;
}
- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(aInterface, @protocol(HSAutoplayAttributes)))
        return [self conformsToProtocol:@protocol(HSPlayableObjectAttributes)] ? self : nil;
    if (HSProtocolsAreEqual(aInterface, @protocol(HSUserObjectInteractiveHitTesting)))
        return [self queryInteractiveHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSUserObjectEditorHitTesting)))
        return [self queryEditorHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSVectorGraphicObjectHitTesting)))
        return [self queryVectorGraphicObjectHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSTextObjectHitTesting)))
        return [self queryTextObjectHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSButtonObjectHitTesting)))
        return [self queryButtonObjectHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSEffectObjectHitTesting)))
        return [self queryEffectObjectHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSMovieObjectHitTesting)))
        return [self queryMovieObjectHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSImageObjectHitTesting)))
        return [self queryImageObjectHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSTextViewObjectHitTesting)))
        return [self queryTextViewObjectHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSCameraObjectHitTesting)))
        return [self queryCameraObjectHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSWebObjectHitTesting)))
        return [self queryWebObjectHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSImageWellObjectHitTesting)))
        return [self queryImageWellObjectHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSGroupBoxObjectHitTesting)))
        return [self queryGroupBoxObjectHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSVectorBrushHitTesting)))
        return [self queryVectorBrushHitTester];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSInteractivePlayerItem)))
        return [self queryInteractivePlayerItem];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSCoreImageEffectAccessing)))
        return [self coreImageEffect] ? self : nil;
    if (HSProtocolsAreEqual(aInterface, @protocol(HSQuickTimeEffectAccessing)))
        return [self quickTimeEffect] ? self : nil;
    if ([self respondsToSelector:@selector(queryNewEditorInterface:)]) {
        id interface = [(id)self queryNewEditorInterface:aInterface];
        if (interface)
            return interface;
    }
    return [super queryNewHyperInterface:aInterface];
}
- (BOOL)isHyperEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    BOOL equal = [super isHyperEqual:aEqual];
    if (_autoPlayActionEvent || [aEqual autoPlayActionEvent]) {
        if (!equal)
            return NO;
        equal = [[self autoPlayActionEvent] isEqual:[aEqual autoPlayActionEvent]];
    }
    if (!equal || _animatedObject != [aEqual isAnimatedObject])
        return NO;
    return _interactiveInAnimation == [aEqual isInteractiveInAnimation];
}
- (id)initUserObject
{
    self = [super initUserObject];
    if (self)
        [self linkAttribute:@protocol(HSSelectionKnobsProviderAttribute) toAttribute:@protocol(HSCardObjectLockedAttribute)];
    return self;
}
- (void)dealloc
{
    [_autoPlayActionEvent release];
    [super dealloc];
}
@end

@implementation HSConcreteCardObject (HSPlayableObjectAttributesPrivate)
// Autoplay is a "play self" action of the parent run on the event. Movies on a card
// (not QTVR, panoramas or opaque non-GIF movies) are added as playback items instead.
- (void)setDefaultHyperPlayed:(BOOL)aPlayed onActionEvent:(id)aEvent
{
    id playable = [self queryHyperInterface:@protocol(HSAutoplayAttributes)];
    if (!playable || [playable isAutoplayed] == aPlayed)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSAutoplayAttribute) withUserInfo:nil];
    id actor = [[self hyperParent] queryHyperInterface:@protocol(HSActor)];
    id action = [actor hyperActionOfType:[playable playSelfActionType] forEvent:aEvent];
    if (!action)
        action = [actor addHyperActionOfType:[playable playSelfActionType] forEvent:aEvent];
    if (!aPlayed) {
        [action removePlayableObject:playable];
        if ([[action hyperSelectedUIDs] count] == 0)
            [actor removeHyperAction:action forEvent:aEvent];
    } else {
        id movie = [self queryHyperInterface:@protocol(HSMovieObjectAttributes)];
        id playMovie = [action queryHyperInterface:@protocol(HSPlayMovieActionAttributes)];
        BOOL usePlaybackItem = NO;
        if (movie && playMovie && [[self hyperParent] queryHyperInterface:@protocol(HSCardAttributes)]
            && ![movie isHyperQTVR] && ![movie isHyperPanoramaObject])
            usePlaybackItem = ![[movie hyperMovie] isOpaque] || [[movie hyperMovie] isGifMovie];
        if (usePlaybackItem) {
            [movie setHyperStartingOnClick:NO];
            id support = [action queryHyperInterface:@protocol(HSPlaybackItemSupport)];
            HSMoviePlaybackItem *item = [[HSMoviePlaybackItem alloc] initWithMovieObject:movie playMovieAction:support];
            [item setEnabled:YES];
            [item setPlayCount:0];
            [playMovie addMovie:item];
            [item release];
        } else {
            [action addPlayableObject:playable];
        }
    }
    [self notifyChange:2 ofAttribute:@protocol(HSAutoplayAttribute) withUserInfo:nil];
}
- (BOOL)isDefaultHyperPlayedOnActionEvent:(id)aEvent
{
    id playable = [self queryHyperInterface:@protocol(HSAutoplayAttributes)];
    if (!playable)
        return NO;
    id actor = [[self hyperParent] queryHyperInterface:@protocol(HSActor)];
    NSEnumerator *enumerator = [[actor hyperActionsOfType:[playable playSelfActionType]] objectEnumerator];
    id action;
    while ((action = [enumerator nextObject])) {
        if ([action runsWithActionEvent:aEvent])
            return [[action hyperSelectedUIDs] containsObject:[playable hyperPlayableObjectUID]];
    }
    return NO;
}
@end
