#import "HSUserObject.h"
#import "HyperPlayerBaseData.h"

@protocol HSUserObjectHTML5ExportContext
- (id)documentType;
@end

@implementation HSUserObject

+ (id)defaultObject
{
    return [[[self alloc] init] autorelease];
}

+ (Class)nodeDataClass
{
    return [HSUserObjectData class];
}

// Shared properties come from the prototype object when there is one.
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [self setHyperUID:[HSUID UIDWithString:[[aRepresentation attributeForName:@"uid"] stringValue]]];
    id sharedRepresentation = nil;
    id prototypeRef = [[aRepresentation elementsForName:@"prototypeRef"] extraFirstObject];
    if (prototypeRef != nil)
        sharedRepresentation = [aContext prototypeObjectForUID:[HSUID UIDWithString:[[prototypeRef attributeForName:@"uid"] stringValue]]];
    if (sharedRepresentation == nil)
        sharedRepresentation = aRepresentation;
    [self importSharedPropertiesFromXMLElementRepresentation:sharedRepresentation inContext:aContext];
    [self importLocalPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [pool release];
}

- (void)importLocalPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
}

- (void)importSharedPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [self importGeometryFromXMLElementRepresentation:[[aRepresentation elementsForName:@"geometry"] extraFirstObject] inContext:aContext];
    if ([self implementsHyperInterface:@protocol(HSHypertextLinkContainerAttributes)])
        [self importHypertextLinksFromXMLElementRepresentation:[[aRepresentation elementsForName:@"hypertextLinks"] extraFirstObject] inContext:aContext];
    id actorElement = [[aRepresentation elementsForName:@"actor"] extraFirstObject];
    id actor = [self queryHyperInterface:@protocol(HSActor)];
    [self importAttributesFromXMLRepresentation:actorElement forActor:actor];
    for (id element in [actorElement children])
        [self importActionFromXMLElement:element forActor:actor inContext:aContext];
    [self importCursorFromXMLElementRepresentation:[[aRepresentation elementsForName:@"cursor"] extraFirstObject] inContext:aContext];
}

// A named system cursor, or one made from the referenced image media.
- (void)importCursorFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    if (aRepresentation == nil)
        return;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSPoint hotSpot = NSPointFromString([[aRepresentation attributeForName:@"hotSpot"] stringValue]);
    id mediaRef = [[aRepresentation elementsForName:@"mediaRef"] extraFirstObject];
    id UID = [HSUID UIDWithString:[[mediaRef attributeForName:HSXMLStoringRefIdString] stringValue]];
    id cursor = nil;
    if (UID == nil) {
        id name = [[aRepresentation attributeForName:@"name"] stringValue];
        if (name != nil)
            cursor = [HSCursor cursorNamed:name];
    } else {
        id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:UID];
        if (media != nil) {
            NSImage *image = [[NSImage alloc] initWithData:[media mediaData]];
            if (image != nil) {
                cursor = [[[HSCursor alloc] initWithImage:image hotSpot:hotSpot] autorelease];
                [cursor setImageMedia:media];
                // The original leaked the image.
                [image release];
            }
        }
    }
    if (cursor != nil)
        [self setHyperCursor:cursor];
    [pool release];
}

- (void)importHypertextLinksFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    id container = [self queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)];
    if (aRepresentation == nil || container == nil)
        return;
    for (id linkElement in [aRepresentation elementsForName:@"textLink"]) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        id title = [[linkElement attributeForName:@"title"] stringValue];
        if ([container linkWithTitle:title] == nil) {
            id link = [container addLinkWithTitle:title];
            // The original left the actor uninitialized when the link had
            // none.
            id actor = [link implementsHyperInterface:@protocol(HSActor)] ? [link queryHyperInterface:@protocol(HSActor)] : nil;
            id actorElement = [[linkElement elementsForName:@"actor"] extraFirstObject];
            if (actor != nil && actorElement != nil) {
                [self importAttributesFromXMLRepresentation:actorElement forActor:actor];
                for (id element in [actorElement children])
                    [self importActionFromXMLElement:element forActor:actor inContext:aContext];
            }
        }
        [pool release];
    }
}

- (void)importActionFromXMLElement:(id)aElement forActor:(id)aActor inContext:(id)aContext
{
    id className = [HSiPadImporterHelper actionClassNameForIPadActionName:[aElement name]];
    if (className == nil)
        return;
    Class actionClass = NSClassFromString(className);
    if (actionClass == Nil || ![actionClass isSubclassOfClass:[HSAction class]])
        return;
    id actor = [aActor queryHyperInterface:@protocol(HSActor)];
    if (actor == nil)
        return;
    id action = [actionClass new];
    [action importFromXMLElementRepresentation:aElement inContext:aContext];
    [actor addActions:[NSArray arrayWithObject:action]];
    [action release];
}

- (void)importGeometryFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
}

static void HSUserObjectImportTimer(id aElement, id aTimer)
{
    if (aTimer == nil || aElement == nil)
        return;
    [aTimer setRunActionsAutomatically:[[[aElement attributeForName:@"executeActionsAutomatically"] stringValue] hyperBoolValue]];
    BOOL looped = [[[aElement attributeForName:@"autoExecutionIsLooped"] stringValue] hyperBoolValue];
    float delay = [[[aElement attributeForName:@"autoExecutionDelay"] stringValue] floatValue];
    [aTimer setDelayBeforeRunActionsAutomatically:delay];
    if (looped)
        [aTimer setDelayBetweenRepeatingActions:delay];
}

- (void)importAttributesFromXMLRepresentation:(id)aRepresentation forActor:(id)aActor
{
    if (aRepresentation == nil || aActor == nil)
        return;
    HSUserObjectImportTimer([[aRepresentation elementsForName:@"defaultTimer"] extraFirstObject],
        [aActor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]]);
    HSUserObjectImportTimer([[aRepresentation elementsForName:@"arriveTimer"] extraFirstObject],
        [aActor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]]);
}

static long HSUserObjectPixels(CGFloat aLength)
{
    return aLength > 0.0 ? lroundf(ceilf((float)aLength)) : 0;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id cursor = [self hyperCursor];
    if (cursor == nil || [[(id<HSUserObjectHTML5ExportContext>)aContext documentType] isEqualToString:@"HSiBooksAuthorDocumentType"]) {
        [dictionary setObject:@"pointer" forKey:@"cursor"];
    } else {
        id media = [cursor imageMedia];
        [aContext addMedia:media];
        NSString *path = [@"Resources" stringByAppendingPathComponent:[HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media]];
        [dictionary setObject:[NSString stringWithFormat:@"url(%@), pointer", path] forKey:@"cursor"];
        NSPoint hotSpot = [cursor hotSpot];
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)(float)hotSpot.x] forKey:@"hotSpotX"];
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)(float)hotSpot.y] forKey:@"hotSpotY"];
    }
    if ([[self hyperComments] length] != 0) {
        NSMutableString *comments = [[self hyperComments] mutableCopy];
        [comments replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, [comments length])];
        [dictionary setObject:comments forKey:@"comments"];
        [comments release];
    }
    id actor = [self queryHyperInterface:@protocol(HSActor)];
    id timer = [actor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
    if ([timer runActionsAutomatically]) {
        [dictionary setObject:[NSString stringWithFormat:@"%.2f", (double)[timer delayBeforeRunActionsAutomatically]] forKey:@"timer"];
        double interval = [timer delayBetweenRepeatingActions];
        if (interval > 0.0)
            [dictionary setObject:[NSString stringWithFormat:@"%.2f", interval] forKey:@"interval"];
    }
    NSMutableDictionary *actions = [NSMutableDictionary dictionary];
    id clickActions = [actor actionsHTML5RepresentationForEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] inContext:aContext];
    if ([clickActions count] != 0)
        [actions setObject:clickActions forKey:@"click"];
    if ([self implementsHyperInterface:@protocol(HSCardAttributes)] || [self implementsHyperInterface:@protocol(HSStackAttributes)]) {
        id arriveActions = [actor actionsHTML5RepresentationForEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType] inContext:aContext];
        if ([arriveActions count] != 0) {
            id arriveTimer = [actor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]];
            [dictionary setObject:[NSString stringWithFormat:@"%.2f", (double)[arriveTimer delayBeforeRunActionsAutomatically]] forKey:@"arrive-timer"];
            double interval = [arriveTimer delayBetweenRepeatingActions];
            if (interval > 0.0)
                [dictionary setObject:[NSString stringWithFormat:@"%.2f", interval] forKey:@"interval"];
            [actions setObject:arriveActions forKey:@"arrive"];
        }
        id leaveActions = [actor actionsHTML5RepresentationForEvent:[HSActionEvent actionEventOfType:kHSLeaveActionEventType] inContext:aContext];
        if ([leaveActions count] != 0)
            [actions setObject:leaveActions forKey:@"leave"];
    }
    if ([actions count] != 0)
        [dictionary setObject:actions forKey:@"actions"];
    // Exported as an image (shared by objects of a group), with a shape
    // image for hit testing when clicks have actions.
    if (![self shouldBeExportedAsImage])
        goto done;
    id groupUID = [self sharedNodeDataUID];
    id imageName = nil;
    id shapeName = nil;
    id image = nil;
    if (groupUID != nil) {
        imageName = [aContext mediaNameForGroupUID:groupUID];
        shapeName = [aContext shapeNameForGroupUID:groupUID];
    }
    if (imageName == nil) {
        image = [self imageForHTML5Export];
        if (image == nil)
            goto done;
        NSSize size = [(NSImage *)image size];
        id data = [image hyperPNGRepresentationWithWide:HSUserObjectPixels(size.width) high:HSUserObjectPixels(size.height)];
        if (data == nil)
            goto done;
        id media = [HSNewMedia mediaWithData:data name:@"image" type:@"png"];
        [aContext addMedia:media];
        id filename = [HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media];
        if (filename == nil)
            goto done;
        imageName = [@"Resources" stringByAppendingPathComponent:filename];
        if (imageName == nil)
            goto done;
        if (groupUID != nil)
            [aContext addGroupUID:groupUID withMediaName:imageName];
    }
    [dictionary setObject:@"image" forKey:@"type"];
    [dictionary setObject:[[self queryHyperInterface:@protocol(HSHighlightSupportAttribute)] canBeHighlighted] ? @"1" : @"0" forKey:@"isHighlight"];
    [dictionary setObject:imageName forKey:@"src"];
    if ([clickActions count] == 0)
        goto done;
    if (shapeName == nil) {
        // With a group's image, the image wasn't loaded and the shape is
        // made at a zero size, as in the original.
        id shape = [self shapeImageWithSize:[(NSImage *)image size]];
        if (shape == nil)
            goto done;
        NSSize size = [(NSImage *)shape size];
        id data = [shape hyperPNGRepresentationWithWide:HSUserObjectPixels(size.width) high:HSUserObjectPixels(size.height)];
        if (data == nil)
            goto done;
        id media = [HSNewMedia mediaWithData:data name:@"shape" type:@"png"];
        [aContext addMedia:media];
        id filename = [HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media];
        if (filename == nil)
            goto done;
        shapeName = [@"Resources" stringByAppendingPathComponent:filename];
        // The original checked the image name here instead.
        if (shapeName == nil)
            goto done;
        if (groupUID != nil)
            [aContext addGroupUID:groupUID withShapeName:shapeName];
    }
    [dictionary setObject:shapeName forKey:@"shapeFile"];
done:
    [pool release];
    return [dictionary autorelease];
}

// Custom cursors other than the hand aren't supported by iBooks Author.
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    if ([self hasUnsupportedHTML5FeaturesForDocumentType:aType])
        return [NSSet setWithObject:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSiPadUnsupportedFeatureCustomCursors" value:@"" table:@"Export"]];
    return [NSSet set];
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    if (![aType isEqualToString:@"HSiBooksAuthorDocumentType"])
        return NO;
    id cursor = [self hyperCursor];
    if (cursor == nil)
        return NO;
    return ![[[[cursor cursor] image] name] isEqualToString:@"Hand_Up"];
}

- (id)XMLHypertextLinksElementForContext:(id)aContext
{
    NSXMLElement *element = [NSXMLElement elementWithName:@"hypertextLinks"];
    id container = [self queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)];
    for (id link in [container allLinks]) {
        if ([aContext shouldTerminateExport])
            break;
        NSXMLElement *linkElement = [NSXMLElement elementWithName:@"textLink"];
        [linkElement addAttribute:[NSXMLNode attributeWithName:@"title" stringValue:[link title]]];
        NSXMLElement *actorElement = [self XMLActorElementForActor:link inContext:aContext];
        if ([[actorElement attributes] count] != 0 || [actorElement childCount] != 0)
            [linkElement addChild:actorElement];
        if ([[linkElement attributes] count] != 0 || [linkElement childCount] != 0)
            [element addChild:linkElement];
    }
    return element;
}

// The arrive timer's looping is stored from its delay before running, as in
// the original.
- (id)XMLActorElementForActor:(id)aActor inContext:(id)aContext
{
    id actor = [aActor queryHyperInterface:@protocol(HSActor)];
    if (actor == nil)
        return nil;
    NSXMLElement *element = [NSXMLElement elementWithName:@"actor"];
    id timer = [actor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
    if (timer != nil) {
        NSXMLElement *timerElement = [NSXMLElement elementWithName:@"defaultTimer"];
        [timerElement addAttribute:[NSXMLNode attributeWithName:@"executeActionsAutomatically" stringValue:[timer runActionsAutomatically] ? HSXMLStoring1String : HSXMLStoring0String]];
        [timerElement addAttribute:[NSXMLNode attributeWithName:@"autoExecutionIsLooped" stringValue:[timer delayBetweenRepeatingActions] > 0.0 ? HSXMLStoring1String : HSXMLStoring0String]];
        [timerElement addAttribute:[NSXMLNode attributeWithName:@"autoExecutionDelay" stringValue:[NSString stringWithFormat:@"%.1f", (double)[timer delayBeforeRunActionsAutomatically]]]];
        [element addChild:timerElement];
    }
    if ([aActor implementsHyperInterface:@protocol(HSCardAttributes)] || [aActor implementsHyperInterface:@protocol(HSStackAttributes)]) {
        timer = [actor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSArriveActionEventType]];
        if (timer != nil) {
            NSXMLElement *timerElement = [NSXMLElement elementWithName:@"arriveTimer"];
            [timerElement addAttribute:[NSXMLNode attributeWithName:@"executeActionsAutomatically" stringValue:[timer runActionsAutomatically] ? HSXMLStoring1String : HSXMLStoring0String]];
            [timerElement addAttribute:[NSXMLNode attributeWithName:@"autoExecutionIsLooped" stringValue:[timer delayBeforeRunActionsAutomatically] > 0.0 ? HSXMLStoring1String : HSXMLStoring0String]];
            [timerElement addAttribute:[NSXMLNode attributeWithName:@"autoExecutionDelay" stringValue:[NSString stringWithFormat:@"%.1f", (double)[timer delayBeforeRunActionsAutomatically]]]];
            [element addChild:timerElement];
        }
    }
    for (id action in [actor hyperActions]) {
        if ([aContext shouldTerminateExport])
            break;
        if ([action supportedInIPad] && [action canBeStoredAsXMLElement])
            [element addChild:[action XMLElementRepresentationInContext:aContext]];
    }
    return element;
}

- (id)XMLGeometryElementRepresentationInContext:(id)aContext
{
    return nil;
}

- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
}

- (void)storeSharedPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    id element = [self XMLActorElementForActor:self inContext:aContext];
    if (element != nil)
        [aRepresentation addChild:element];
    element = [self XMLGeometryElementRepresentationInContext:aContext];
    if (element != nil)
        [aRepresentation addChild:element];
    if ([self implementsHyperInterface:@protocol(HSHypertextLinkContainerAttributes)]) {
        element = [self XMLHypertextLinksElementForContext:aContext];
        if ([element childCount] != 0)
            [aRepresentation addChild:element];
    }
    element = [self XMLCursorElementRepresentationInContext:aContext];
    if (element != nil)
        [aRepresentation addChild:element];
}

// The cursor's image is stored as media.
- (id)XMLCursorElementRepresentationInContext:(id)aContext
{
    id cursor = [self cursor];
    if (cursor == nil)
        return nil;
    NSXMLElement *element = [NSXMLElement elementWithName:@"cursor"];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id name = [cursor name];
    [element addAttribute:[NSXMLNode attributeWithName:@"name" stringValue:name]];
    [element addAttribute:[NSXMLNode attributeWithName:@"hotSpot" stringValue:NSStringFromPoint([cursor hotSpot])]];
    id media = [cursor imageMedia];
    if (media == nil) {
        id image = [cursor image];
        if (image != nil)
            media = [HSNewMedia mediaWithData:[image hyperPNGRepresentation] name:name type:@"png"];
    }
    if (media != nil) {
        [aContext addMedia:media];
        NSXMLElement *mediaRef = [NSXMLElement elementWithName:@"mediaRef"];
        [mediaRef addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[media mediaUID] stringValue]]];
        [element addChild:mediaRef];
    }
    [pool release];
    return element;
}

- (id)groupUIDForXMLStoring
{
    return [self sharedNodeDataUID];
}

// The first object of a group stores the shared properties; the others
// refer to it.
- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [NSXMLElement elementWithName:[self XMLElementName]];
    BOOL storesShared = YES;
    id groupUID = [self groupUIDForXMLStoring];
    if (groupUID != nil) {
        id prototypeUID = [aContext prototypeObjectUIDForGroupUID:groupUID];
        if (prototypeUID != nil) {
            NSXMLElement *prototypeRef = [NSXMLElement elementWithName:@"prototypeRef"];
            [prototypeRef addAttribute:[NSXMLNode attributeWithName:@"uid" stringValue:[prototypeUID stringValue]]];
            [element addChild:prototypeRef];
            storesShared = NO;
        } else {
            [aContext setPrototypeObjectUID:[self hyperUID] forGroupUID:groupUID];
        }
    }
    [element addAttribute:[NSXMLNode attributeWithName:@"uid" stringValue:[[self hyperUID] stringValue]]];
    if (storesShared)
        [self storeSharedPropertiesInXMLElementRepresentation:element context:aContext];
    [self storeLocalPropertiesInXMLElementRepresentation:element context:aContext];
    return element;
}

- (id)XMLElementName
{
    return @"node";
}

- (BOOL)canBeStoredAsXMLElement
{
    return NO;
}

// A custom cursor, or actions playing live video.
- (BOOL)hasiPadUnsupportedFunctionality
{
    if ([self cursor] != nil && [self cursor] != [HSCursor defaultCursor])
        return YES;
    if (![self implementsHyperInterface:@protocol(HSActor)])
        return NO;
    BOOL unsupported = NO;
    for (id action in [[self queryHyperInterface:@protocol(HSActor)] hyperActions]) {
        if ([action implementsHyperInterface:@protocol(HSPlayMovieActionAttributes)]
            && [[[action queryHyperInterface:@protocol(HSPlayMovieActionAttributes)] liveVideos] count] != 0)
            unsupported = YES;
    }
    return unsupported;
}

- (id)iPadUnsupportedFunctionalityDescription
{
    NSMutableArray *descriptions = [NSMutableArray array];
    if ([self cursor] != nil && [self cursor] != [HSCursor defaultCursor])
        [descriptions addObject:[NSString stringWithString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSiPadUnsupportedFeatureCustomCursors" value:@"" table:@"Export"]]];
    if ([self implementsHyperInterface:@protocol(HSActor)]) {
        for (id action in [[self queryHyperInterface:@protocol(HSActor)] hyperActions]) {
            if ([action implementsHyperInterface:@protocol(HSPlayMovieActionAttributes)]
                && [[[action queryHyperInterface:@protocol(HSPlayMovieActionAttributes)] liveVideos] count] != 0)
                [descriptions addObject:[NSString stringWithString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSiPadUnsupportedFeatureLiveVideo" value:@"" table:@"Export"]]];
        }
    }
    return [descriptions count] != 0 ? [NSArray arrayWithArray:descriptions] : nil;
}

// The text content is the name and media names; the media types are listed
// too.
- (id)valuesForMDAttribute:(id)aAttribute
{
    NSMutableArray *values = [NSMutableArray array];
    if ([aAttribute isEqualToString:(NSString *)kMDItemTextContent]) {
        id name = [self hyperName];
        if (name != nil)
            [values addObject:name];
        for (id UID in [self mediaUIDs]) {
            id mediaName = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:UID] mediaName];
            if (mediaName != nil && ![values containsObject:mediaName])
                [values addObject:mediaName];
        }
    } else if ([aAttribute isEqualToString:(NSString *)kMDItemMediaTypes]) {
        for (id UID in [self mediaUIDs]) {
            id mediaType = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:UID] mediaType];
            if (mediaType != nil && ![values containsObject:mediaType])
                [values addObject:mediaType];
        }
    }
    return values;
}

- (id)supportedMDAttributes
{
    if ([[self mediaUIDs] count] != 0)
        return [NSArray arrayWithObjects:(NSString *)kMDItemTextContent, (NSString *)kMDItemMediaTypes, nil];
    return [NSArray arrayWithObject:(NSString *)kMDItemTextContent];
}

- (void)setUsingTemplateName:(BOOL)aName
{
    [[self nodeData] setUsingTemplateName:aName];
}

- (BOOL)usingTemplateName
{
    return [[self nodeData] usingTemplateName];
}

- (void)setName:(id)aName
{
    [[self nodeData] setName:aName];
}

- (id)name
{
    return [[self nodeData] name];
}

// Arrive and leave actions belong to cards; drop-off ones only to card
// objects that send them.
- (BOOL)supportsActionType:(id)aType forEvent:(id)aEvent
{
    id arrive = [HSActionEvent actionEventOfType:kHSArriveActionEventType];
    id leave = [HSActionEvent actionEventOfType:kHSLeaveActionEventType];
    id dropOff = [HSActionEvent actionEventOfType:kHSDeprecatedDropOffActionEventType];
    if ([aEvent isEqual:arrive] || [aEvent isEqual:leave])
        return NO;
    if (![aEvent isEqual:dropOff])
        return YES;
    return [[self queryHyperInterface:@protocol(HSCardObjectAttributes)] canSendActionsOnDrop];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    NSDictionary *map = [self attributeToNotificationMapForCodingOperation:[aContext codingOperation]];
    for (id key in [aRepresentation keyEnumerator]) {
        id attribute = [map objectForKey:key];
        if (attribute != nil)
            [self notifyChange:2 ofAttribute:[attribute protocol] withUserInfo:nil];
    }
}

- (id)attributeToNotificationMapForCodingOperation:(id)aOperation
{
    if ([[self nodeData] attributeToNotificationMap] == nil)
        [[self nodeData] setAttributeToNotificationMap:[[NSDictionary new] autorelease]];
    return [[self nodeData] attributeToNotificationMap];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"UID"];
    [keys addObject:@"actor"];
    [keys addObject:@"cursor"];
    [keys addObject:HSUserObjectNameSerializationKey];
    [keys addObject:@"usingTemplateName"];
    [keys addObject:@"comments"];
    return keys;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        return [NSArray array];
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"userInfo"];
}

- (id)unrefreshingUIDs
{
    NSMutableSet *UIDs = [NSMutableSet setWithSet:[[self queryHyperInterface:@protocol(HSActor)] unrefreshingUIDs]];
    NSEnumerator *children = [self hyperEnumerator];
    id child;
    while ((child = [children nextObject]) != nil) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        id childUIDs = [[child queryHyperInterface:@protocol(HSActor)] unrefreshingUIDs];
        if (childUIDs != nil)
            [UIDs unionSet:childUIDs];
        [pool release];
    }
    return [NSSet setWithSet:UIDs];
}

- (id)mediaUIDs
{
    NSMutableSet *UIDs = [NSMutableSet setWithSet:[self ownedMediaUIDs]];
    NSEnumerator *children = [self hyperEnumerator];
    id child;
    while ((child = [children nextObject]) != nil) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        id childUIDs = [[child queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs];
        if (childUIDs != nil)
            [UIDs unionSet:childUIDs];
        [pool release];
    }
    return UIDs;
}

- (id)ownedMediaUIDs
{
    NSCountedSet *UIDs = [NSCountedSet new];
    id UID = [[self queryHyperInterface:@protocol(HSMediaUIDAttribute)] mediaUID];
    if (UID != nil)
        [UIDs addObject:UID];
    id backgroundUIDs = [[[[self queryHyperInterface:@protocol(HSBackgroundAttributes)] backgroundGraphics] queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs];
    if (backgroundUIDs != nil)
        [UIDs unionSet:backgroundUIDs];
    NSEnumerator *units = [self unitEnumerator];
    id unit;
    while ((unit = [units nextObject]) != nil) {
        id unitUIDs = [unit mediaUIDs];
        if (unitUIDs != nil)
            [UIDs unionSet:unitUIDs];
    }
    [UIDs unionSet:[[self queryHyperInterface:@protocol(HSActor)] mediaUIDs]];
    return [UIDs autorelease];
}

- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(aInterface, @protocol(HSActor)) || HSProtocolsAreEqual(aInterface, @protocol(HSRunScriptActionValidation)))
        return [[self actor] queryHyperInterface:aInterface];
    return [super queryNewHyperInterface:aInterface];
}

- (void)loadObjectStyleDictionaryRepresentation:(id)aRepresentation
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Paste Style" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] loadObjectStyleDictionaryRepresentation:[self objectStyleDictionaryRepresentation]];
    [self loadExtraDictionaryRepresentation:aRepresentation withCodingContext:[EXCodingContext codingContextWithOperation:@"HSObjectStyleCodingOperation" shouldZeroMissingValuesOnLoading:NO]];
}

- (id)objectStyleDictionaryRepresentation
{
    return [self extraDictionaryRepresentationWithCodingContext:[EXCodingContext codingContextWithOperation:HSCopyingCodingOperation shouldZeroMissingValuesOnLoading:NO]];
}

- (BOOL)canLoadStyleFromDictionary:(id)aDictionary
{
    id keys = [self keysForExtraLoadingWithCodingContext:[EXCodingContext codingContextWithOperation:@"HSObjectStyleCodingOperation" shouldZeroMissingValuesOnLoading:NO]];
    return [keys firstObjectCommonWithArray:[aDictionary allKeys]] != nil;
}

- (void)appendHyperCommentsFromObjects:(id)aObjects
{
    for (id object in aObjects) {
        id comments = [object queryHyperInterface:@protocol(HSCommentsAttributes)];
        if (comments != nil)
            [self appendHyperComments:[comments hyperComments]];
    }
}

- (void)appendHyperComments:(id)aComments
{
    NSMutableString *comments = [NSMutableString string];
    if ([[self comments] length] != 0)
        [comments appendFormat:@"%@\n", [self comments]];
    if ([aComments length] != 0)
        [comments appendFormat:@"%@", aComments];
    [self setHyperComments:comments];
}

- (void)setHyperComments:(id)aComments
{
    if ([[self comments] isEqual:aComments])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Comments" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperComments:[self hyperComments]];
    [self notifyChange:1 ofAttribute:@protocol(HSCommentsAttribute) withUserInfo:nil];
    [self setComments:aComments];
    [self notifyChange:2 ofAttribute:@protocol(HSCommentsAttribute) withUserInfo:nil];
}

- (id)childrenComments
{
    return nil;
}

- (id)deepComments
{
    return [self hyperComments];
}

- (id)hyperComments
{
    return [self comments];
}

- (void)setComments:(id)aComments
{
    [[self nodeData] setComments:aComments];
}

- (id)comments
{
    return [[self nodeData] comments];
}

- (void)setHyperCursor:(id)aCursor
{
    if ([[self nodeData] cursor] == aCursor)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Cursor" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperCursor:[self hyperCursor]];
    [self notifyChange:1 ofAttribute:@protocol(HSCursorAttribute) withUserInfo:nil];
    [self setCursor:aCursor];
    [self notifyChange:2 ofAttribute:@protocol(HSCursorAttribute) withUserInfo:nil];
}

- (id)hyperCursor
{
    return [self cursor];
}

- (void)setCursor:(id)aCursor
{
    [[self nodeData] setCursor:aCursor];
}

- (id)cursor
{
    return [[self nodeData] cursor];
}

- (id)parentHyperScriptableEntity
{
    return [[self hyperParent] queryHyperInterface:@protocol(HSScriptableEntity)];
}

- (id)objectInHyperScriptableEntitiesAtIndex:(NSUInteger)aIndex
{
    NSUInteger remaining = aIndex + 1;
    NSEnumerator *children = [self hyperEnumerator];
    id child;
    while ((child = [children nextObject]) != nil) {
        id entity = [child queryHyperInterface:@protocol(HSScriptableEntity)];
        if (entity != nil && --remaining == 0)
            return entity;
    }
    return nil;
}

- (NSUInteger)countOfHyperScriptableEntities
{
    NSUInteger count = 0;
    NSEnumerator *children = [self hyperEnumerator];
    id child;
    while ((child = [children nextObject]) != nil) {
        if ([child queryHyperInterface:@protocol(HSScriptableEntity)] != nil)
            count++;
    }
    return count;
}

- (void)actorDidChange:(id)aChange
{
    [self notifyChange:2 ofAttribute:@protocol(HSActionsAttribute) withUserInfo:[NSDictionary dictionaryWithObject:aChange forKey:@"actor"]];
}

- (id)stackForAction:(id)aAction
{
    return [[[self cardForAction:aAction] queryHyperInterface:@protocol(HSUserObjectSupport)] stack];
}

// The card the object is on, or the support's card for the action (or its
// current card).
- (id)cardForAction:(id)aAction
{
    id card = [self card];
    if (card != nil)
        return card;
    id support = [self support];
    if ([support respondsToSelector:@selector(cardForAction:ofObject:)])
        return [support cardForAction:aAction ofObject:self];
    if ([support respondsToSelector:@selector(currentCard)])
        return [[support currentCard] queryHyperInterface:@protocol(HSCardAttributes)];
    return nil;
}

- (id)stack
{
    return [[[[self card] queryHyperInterface:@protocol(HSNodeChild)] hyperParent] queryHyperInterface:@protocol(HSStackAttributes)];
}

- (id)card
{
    return [[[self hyperParent] queryHyperInterface:@protocol(HSUserObjectSupport)] card];
}

- (BOOL)isUsingTemplateName
{
    return [[self nodeData] usingTemplateName];
}

- (id)uniqueName:(id)aName
{
    if ([self uniqueNameGenerator] != nil)
        return [[self uniqueNameGenerator] uniqueName:aName omittingItemIdenticalTo:self];
    return aName;
}

- (id)uniqueNameGenerator
{
    return nil;
}

- (BOOL)needsOwnUniqueNameGenerator
{
    if ([self hyperParent] == nil)
        return YES;
    return ![[self hyperParent] respondsToSelector:@selector(uniqueNameGenerator)];
}

- (void)resetHyperName
{
    id name = [[self nodeData] name];
    if ([[self nodeData] usingTemplateName]) {
        [[self nodeData] setPreferredNameTemplate:nil];
        name = nil;
    }
    [self setHyperName:name];
}

- (void)validateUniqueNames
{
    [self resetHyperName];
    NSUInteger count = [self hyperCount];
    for (NSUInteger index = 0; index < count; index++)
        [[self hyperChildAtIndex:index] validateUniqueNames];
}

// An empty, unacceptable or template name becomes the preferred template;
// the name is then made unique.
- (void)validateSetName:(id *)aName usingTemplateName:(BOOL *)aName2
{
    id name = *aName;
    BOOL usingTemplate;
    if (name != nil && [[[self nodeData] name] isEqualToString:name] && [[self nodeData] usingTemplateName]) {
        usingTemplate = YES;
    } else {
        usingTemplate = YES;
        if ([name length] != 0) {
            name = [[HSUserObjectNamingStrategy defaultNamingStrategy] acceptableObjectName:name];
            if ([name length] != 0 && ![[self preferredNameTemplate] isEqualToString:name])
                usingTemplate = NO;
        }
    }
    if (usingTemplate)
        name = [self preferredNameTemplate];
    *aName = [self uniqueName:name];
    *aName2 = usingTemplate;
}

- (void)setHyperName:(id)aName usingTemplateName:(BOOL)aName2
{
    if ([[[self nodeData] name] isEqualToString:aName] && [self isUsingTemplateName] == aName2)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Name" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperName:[[self nodeData] name] usingTemplateName:[self isUsingTemplateName]];
    [self notifyChange:1 ofAttribute:@protocol(HSObjectNameAttribute) withUserInfo:nil];
    [[self nodeData] setName:[[aName copy] autorelease]];
    [[self nodeData] setUsingTemplateName:aName2];
    [self notifyChange:2 ofAttribute:@protocol(HSObjectNameAttribute) withUserInfo:nil];
}

- (void)userObjectNameBaseTemplateDidChange
{
    [[self nodeData] setPreferredNameTemplate:nil];
    if ([self isUsingTemplateName])
        [self setHyperName:nil];
}

- (id)nameBaseTemplates
{
    return [NSArray array];
}

// The first acceptable name base template, or the default identifier
// template.
- (id)preferredNameTemplate
{
    if ([[self nodeData] preferredNameTemplate] == nil) {
        id template = nil;
        for (id base in [self nameBaseTemplates]) {
            id name = [[HSUserObjectNamingStrategy defaultNamingStrategy] acceptableObjectName:base];
            if ([name length] != 0) {
                template = name;
                break;
            }
        }
        if (template == nil)
            template = [self defaultIdentifierTemplate];
        [[self nodeData] setPreferredNameTemplate:[[template copy] autorelease]];
    }
    return [[self nodeData] preferredNameTemplate];
}

- (BOOL)isHyperValid
{
    return [[self actor] isHyperValid];
}

- (BOOL)hasHyperWarnings
{
    return [[self actor] hasHyperWarnings];
}

- (void)willDisconnectFromDocument
{
    [[self actor] willDisconnectFromDocument];
}

- (void)didConnectToDocument
{
    [[self actor] didConnectToDocument];
}

- (void)willDisconnectFromSupport
{
    [self willDisconnectFromDocument];
    [super willDisconnectFromSupport];
}

- (void)didConnectToSupport
{
    [super didConnectToSupport];
    [self didConnectToDocument];
}

- (void)willRemoveFromDocument
{
    [[self children] makeObjectsPerformSelector:_cmd];
    [[[self unitEnumerator] allObjects] makeObjectsPerformSelector:@selector(nodeWillRemoveFromDocument:) withObject:self];
    [[self nodeData] willRemoveOwningObjectFromDocument:self];
    [[self actor] willRemoveFromDocument];
    [[[self queryHyperInterface:@protocol(HSBackgroundAttributes)] backgroundGraphics] willRemoveFromDocument];
}

- (void)didAddToDocument
{
    [[[self queryHyperInterface:@protocol(HSBackgroundAttributes)] backgroundGraphics] didAddToDocument];
    [[self actor] didAddToDocument];
    [[self nodeData] didAddOwningObjectToDocument:self];
    [[[self unitEnumerator] allObjects] makeObjectsPerformSelector:@selector(nodeDidAddToDocument:) withObject:self];
    [[self children] makeObjectsPerformSelector:_cmd];
}

- (void)willRemoveFromParent
{
    [super willRemoveFromParent];
    if ([self isInDocument])
        [self willRemoveFromDocument];
}

- (void)didAddToParent
{
    [super didAddToParent];
    if ([self isInDocument])
        [self didAddToDocument];
}

- (BOOL)isInDocument
{
    return [self support] != nil;
}

// The actions of the object and its hypertext links implementing the
// interface.
- (id)allActionsOfType:(id)aType
{
    if (aType == nil)
        return nil;
    NSMutableSet *actions = [NSMutableSet set];
    id links = [[self queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks];
    NSMutableArray *actors = [NSMutableArray arrayWithObject:self];
    if ([links count] != 0)
        [actors addObjectsFromArray:links];
    for (id actor in actors) {
        for (id action in [[actor queryHyperInterface:@protocol(HSActor)] hyperActions]) {
            id typed = [action queryHyperInterface:aType];
            if (typed != nil)
                [actions addObject:typed];
        }
    }
    return actions;
}

- (void)setActor:(id)aActor
{
    [[self nodeData] setActor:aActor];
}

- (id)actor
{
    return [[self nodeData] actor];
}

- (void)objectWillRemoveFromCardView
{
}

- (void)objectDidAddToCardView
{
}

- (id)document
{
    if (![[self support] isKindOfClass:[HSDocument class]])
        return nil;
    return [self support];
}

- (id)childInTreeWithUID:(id)aUID
{
    NSEnumerator *children = [self hyperEnumerator];
    if ([[self hyperUID] isEqual:aUID])
        return self;
    id child;
    while ((child = [children nextObject]) != nil) {
        id found = [child childInTreeWithUID:aUID];
        if (found != nil)
            return found;
    }
    return nil;
}

- (id)childWithUID:(id)aUID
{
    NSEnumerator *children = [self hyperEnumerator];
    id child;
    while ((child = [children nextObject]) != nil) {
        if ([[child hyperUID] isEqual:aUID])
            return child;
    }
    return nil;
}

- (id)hyperScriptName
{
    return [[self hyperUID] scriptValue];
}

- (id)hyperScriptKind
{
    return [super hyperScriptKind];
}

- (id)hyperScriptDisplayName
{
    return [[HSJavaScriptNamingStrategy defaultNamingStrategy] mechanicNameForObjectName:[self hyperName]];
}

- (void)cleanupUserInfo
{
    [self setUserInfo:nil];
    NSEnumerator *children = [self hyperEnumerator];
    id child;
    while ((child = [children nextObject]) != nil) {
        if ([child respondsToSelector:_cmd])
            [child performSelector:_cmd];
    }
}

- (id)userInfoForKey:(id)aKey
{
    return [_userInfo objectForKey:aKey];
}

- (void)setUserInfo:(id)aInfo forKey:(id)aKey
{
    if (_userInfo == nil)
        _userInfo = [NSMutableDictionary new];
    [_userInfo setValue:aInfo forKey:aKey];
}

- (void)setUserInfo:(id)aInfo
{
    if (_userInfo != aInfo) {
        [_userInfo release];
        _userInfo = [aInfo mutableCopy];
    }
}

- (void)setHyperName:(id)aName
{
    if ([aName isEqualToString:[self hyperName]])
        return;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id name = aName;
    BOOL usingTemplate = YES;
    [self validateSetName:&name usingTemplateName:&usingTemplate];
    [self setHyperName:name usingTemplateName:usingTemplate];
    [pool release];
}

- (id)hyperName
{
    return [self name];
}

- (id)nonLocalizedObjectKindKey
{
    return nil;
}

- (id)defaultIdentifierTemplate
{
    return [[HSUserObjectDefaultAttributesProvider sharedInstance] defaultIdentifierTemplateForUserObjectClass:[self class] key:[self nonLocalizedObjectKindKey]];
}

- (id)hyperKindDisplayName
{
    return [[HSUserObjectDefaultAttributesProvider sharedInstance] localizedKindNameForUserObjectClass:[self class] key:[self nonLocalizedObjectKindKey]];
}

- (id)nonLocalizedKindName
{
    return NSStringFromClass([self class]);
}

- (id)enumeratorForGenerator:(id)aGenerator
{
    if ([[self nodeData] nameGenerator] == aGenerator)
        return [self hyperDeepEnumerator];
    return [super enumeratorForGenerator:aGenerator];
}

- (void)setHyperUID:(id)aUID
{
    [self setUID:aUID];
}

- (id)hyperUID
{
    return [self UID];
}

- (void)setUID:(id)aUID
{
    [[self nodeData] setUID:aUID];
}

- (id)UID
{
    return [[self nodeData] UID];
}

- (id)debugDescription
{
    return [NSString stringWithFormat:@"%@ (%@)", [super description], [[self nodeData] UID]];
}

- (void)dealloc
{
    [_userInfo release];
    [super dealloc];
}

- (NSUInteger)hash
{
    return [self hyperIdentifier] >> 2;
}

- (BOOL)canHaveExtraInitializer
{
    return NO;
}

// Unless the node data is shared, the class's default attributes are
// loaded; failing that, the object is released.
- (id)init
{
    self = [self initUserObject];
    if (self == nil)
        return nil;
    if ([self sharedNodeDataUID] != nil)
        return self;
    id attributes = [[HSUserObjectDefaultAttributesProvider sharedInstance] defaultAttributesForUserObjectClass:[self class]];
    @try {
        if ([attributes count] != 0)
            [self loadExtraDictionaryRepresentation:attributes];
    } @catch (NSException *exception) {
        [self release];
        self = nil;
    }
    return self;
}

- (id)initUserObject
{
    return [super init];
}

- (void)verifyUnsupportedFeatures
{
}

@end

@implementation NSObject (ScriptKind)

// From the ClassToScriptKind dictionary, for the nearest class listed.
- (id)hyperScriptKind
{
    Class aClass = [self class];
    do {
        id kind = [[HSPlayerBaseID extraDictionaryNamed:@"ClassToScriptKind"] objectForKey:NSStringFromClass(aClass)];
        if ([kind length] != 0)
            return kind;
        aClass = [aClass superclass];
    } while (aClass != Nil);
    return nil;
}

@end
