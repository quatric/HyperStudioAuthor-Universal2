#import "HSCard.h"
#import "HyperPlayerBaseData.h"

@protocol HSCardHTML5ExportContext
- (id)documentType;
@end

static BOOL HSCardFloatsAreEqual(float a, float b)
{
    float ma = a != 0.0f ? fabsf(a) : 1.0f;
    float mb = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(ma, mb) * 0.0005f;
}

// Actions of the flattened objects are merged in name order.
static NSInteger HSCardCompareObjectNames(id aObject1, id aObject2, void *aContext)
{
    return [[[aObject1 queryHyperInterface:@protocol(HSObjectAttributes)] hyperName] caseInsensitiveCompare:[[aObject2 queryHyperInterface:@protocol(HSObjectAttributes)] hyperName]];
}

@implementation HSCard

+ (id)cardWithData:(id)aData pasteboard:(id)aPasteboard
{
    id wrapper = [[[NSFileWrapper alloc] initWithSerializedRepresentation:aData] autorelease];
    return [HSCard nodeWithFileWrapper:wrapper explicitNodeDataProvider:nil];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"HSEditableImageNodeUnit", HSEditableBackgroundUnitRole, @"HSSizeNodeUnit", @"Size Unit", nil];
}

- (void)importGeometryFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    if (aRepresentation == nil)
        return;
    NSArray *components = [[[aRepresentation attributeForName:@"size"] stringValue] componentsSeparatedByString:@","];
    NSSize size = NSZeroSize;
    if ([components count] >= 2)
        size = NSMakeSize([[components objectAtIndex:0] floatValue], [[components objectAtIndex:1] floatValue]);
    [(id<HSMutableSizeAttributes>)[self queryHyperInterface:@protocol(HSMutableSizeAttributes)] setSize:size];
}

// Cards that want a group register their element as the group prototype.
- (void)importSharedPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importSharedPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    id behavior = [[aRepresentation elementsForName:@"behavior"] extraFirstObject];
    if ([[[behavior attributeForName:@"wantsgroup"] stringValue] hyperBoolValue]) {
        if ([aContext prototypeObjectForUID:[self hyperUID]] == nil)
            [aContext setPrototypeObject:aRepresentation forUID:[self hyperUID]];
    }
    id background = [[aRepresentation elementsForName:@"background"] extraFirstObject];
    id UID = [HSUID UIDWithString:[[background attributeForName:HSXMLStoringRefIdString] stringValue]];
    id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:UID];
    id imageMedia = [self queryHyperInterface:@protocol(HSEditableImageMediaAttributes)];
    if (media != nil && imageMedia != nil)
        [imageMedia setEditableImageMedia:media];
}

- (void)importLocalPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importLocalPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    id cardState = [[aRepresentation elementsForName:@"cardState"] extraFirstObject];
    [self setMarkedCard:[[[cardState attributeForName:@"isMarked"] stringValue] hyperBoolValue]];
    [self setHyperName:[[[aRepresentation elementsForName:HSXMLStoringNameString] extraFirstObject] stringValue]];
    [self setHyperComments:[[[aRepresentation elementsForName:HSXMLStoringCommentString] extraFirstObject] stringValue]];
    [self setHyperTitle:[[[aRepresentation elementsForName:HSXMLStoringTitleString] extraFirstObject] stringValue]];
    for (id element in [aRepresentation children]) {
        NSString *className = [HSiPadImporterHelper cardObjectClassNameForIPadObjectName:[(NSXMLNode *)element name]];
        if ([className length] == 0)
            continue;
        Class objectClass = NSClassFromString(className);
        if (objectClass == Nil || ![objectClass isSubclassOfClass:[HSUserObject class]])
            continue;
        id object = [objectClass defaultObject];
        [self addHyperChild:object];
        [object importFromXMLElementRepresentation:element inContext:aContext];
    }
}

- (id)XMLGeometryElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [NSXMLElement elementWithName:@"geometry"];
    NSSize size = [(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
    [element addAttribute:[NSXMLNode attributeWithName:@"size" stringValue:[NSString stringWithFormat:@"%.0f,%.0f", size.width, size.height]]];
    return element;
}

- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeLocalPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    NSXMLElement *cardState = [NSXMLElement elementWithName:@"cardState"];
    [cardState addAttribute:[NSXMLNode attributeWithName:@"isMarked" stringValue:[self isMarkedCard] ? HSXMLStoring1String : HSXMLStoring0String]];
    [aRepresentation addChild:cardState];
    [aRepresentation addChild:[NSXMLElement elementWithName:HSXMLStoringNameString stringValue:[self name]]];
    [aRepresentation addChild:[NSXMLElement elementWithName:HSXMLStoringCommentString stringValue:[self hyperComments]]];
    [aRepresentation addChild:[NSXMLElement elementWithName:HSXMLStoringTitleString stringValue:[self hyperTitle]]];
    for (id child in [self hyperChildren]) {
        if ([aContext shouldTerminateExport])
            return;
        id node = [child queryHyperInterface:@protocol(HSNodeChild)];
        id storing = [child queryHyperInterface:@protocol(HSXMLStoringSupport)];
        if ([storing canBeStoredAsXMLElement] && ![node isTemporary])
            [aRepresentation addChild:[storing XMLElementRepresentationInContext:aContext]];
    }
}

- (void)storeSharedPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeSharedPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    NSXMLElement *behavior = [NSXMLElement elementWithName:@"behavior"];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"wantsgroup" stringValue:[self cardGroupUID] != nil ? HSXMLStoring1String : HSXMLStoring0String]];
    [aRepresentation addChild:behavior];
    id media = [[self queryHyperInterface:@protocol(HSEditableImageMediaAttributes)] editableImageMedia];
    if (media != nil) {
        [aContext addMedia:media];
        NSXMLElement *background = [NSXMLElement elementWithName:@"background"];
        [background addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[media mediaUID] stringValue]]];
        [aRepresentation addChild:background];
    }
}

- (id)groupUIDForXMLStoring
{
    return [self cardGroupUID];
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (id)XMLElementName
{
    return @"card";
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

// Card objects come first, then the non-card representations of the card
// and of its objects.
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setValue:[self hyperTitle] forKey:@"name"];
    [dictionary setValue:[NSString stringWithFormat:@"%i", (int)[self hyperIndex]] forKey:@"id"];
    [dictionary setValue:[self isMarkedCard] ? @"1" : @"0" forKey:@"isMarkedCard"];
    [dictionary setValue:[self isGroupCard] ? @"1" : @"0" forKey:@"isGroupCard"];
    id backgroundUID = [self hyperUID];
    id imageMedia = [self queryHyperInterface:@protocol(HSEditableImageMediaAttributes)];
    if (imageMedia != nil) {
        id media = [imageMedia editableImageMedia];
        if (media != nil)
            backgroundUID = [media mediaUID];
    }
    NSString *backgroundName = [NSString stringWithFormat:@"%@%@.png", @"background_", [backgroundUID stringValue]];
    NSString *previewName = [NSString stringWithFormat:@"%@%@.png", @"preview_", [[self hyperUID] stringValue]];
    NSDictionary *images = [[NSDictionary alloc] initWithObjectsAndKeys:backgroundName, @"background", previewName, @"preview", nil];
    [dictionary setValue:images forKey:@"images"];
    [images release];
    NSMutableArray *nonCardReps = [[NSMutableArray alloc] initWithArray:[[self queryHyperInterface:@protocol(HSActor)] nonCardObjectRepsInContext:aContext]];
    NSMutableArray *objects = [NSMutableArray new];
    for (id child in [self hyperChildren]) {
        if ([aContext shouldTerminateExport])
            break;
        if (![child canBeExportedToHTML5DocumentType:[(id<HSCardHTML5ExportContext>)aContext documentType]] || [child isTemporary])
            continue;
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        id representation = [child HTML5DictionaryRepresentationInContext:aContext];
        if (representation != nil)
            [objects addObject:representation];
        [nonCardReps addObjectsFromArray:[[child queryHyperInterface:@protocol(HSActor)] nonCardObjectRepsInContext:aContext]];
        [pool release];
    }
    [objects addObjectsFromArray:nonCardReps];
    [nonCardReps release];
    [dictionary setValue:objects forKey:@"objects"];
    [objects release];
    return dictionary;
}

- (BOOL)isIntegralSize
{
    return YES;
}

- (id)deepComments
{
    NSMutableString *result = [NSMutableString string];
    NSMutableString *comments = [NSMutableString string];
    [comments appendString:[self hyperComments]];
    if ([comments length] != 0) {
        while (![comments hasSuffix:@"\n\n"])
            [comments appendString:@"\n"];
    }
    [comments appendString:[self childrenComments]];
    if ([comments length] != 0) {
        NSUInteger index = [[self queryHyperInterface:@protocol(HSNodeChild)] hyperIndex];
        NSString *format = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"HSCardCommentsFormat" value:@"" table:@"HyperPlayerBase"];
        [result appendFormat:format, (int)index + 1, comments];
    }
    return result;
}

- (id)childrenComments
{
    NSMutableString *result = [NSMutableString string];
    NSEnumerator *enumerator = [[self queryHyperInterface:@protocol(HSNodeContainer)] hyperEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        NSString *comments = [[child queryHyperInterface:@protocol(HSCommentsAttributes)] hyperComments];
        if ([comments length] == 0)
            continue;
        if ([result length] != 0) {
            while (![result hasSuffix:@"\n\n"])
                [result appendString:@"\n"];
        }
        [result appendString:comments];
    }
    return result;
}

- (void)eraseBackgroundWithColor:(id)aColor
{
    if (aColor == nil)
        aColor = [NSColor whiteColor];
    [self fillBackgroundWithColor:aColor];
}

- (void)importBackgroundFromImage:(id)aImage toPoint:(NSPoint)aPoint eraseBackground:(BOOL)aBackground
{
    [self HSCard_importBackgroundFromImage:aImage toPoint:aPoint imageScalingOption:-1 eraseBackground:aBackground];
}

- (void)importBackgroundFromImage:(id)aImage imageScalingOption:(NSInteger)aOption eraseBackground:(BOOL)aBackground
{
    [self HSCard_importBackgroundFromImage:aImage toPoint:NSMakePoint(NAN, NAN) imageScalingOption:aOption eraseBackground:aBackground];
}

// A point that is not NaN places the image unscaled there. Otherwise the
// option picks the placement: 0 fit, 1 fit at 1/sqrt(3) of the size, 2
// fill, 3 stretch, 4 centered, 5 tiled, 6 shrunk to fit only when larger;
// all but stretch are centered. Other options draw nothing.
- (void)HSCard_importBackgroundFromImage:(id)aImage toPoint:(NSPoint)aPoint imageScalingOption:(NSInteger)aOption eraseBackground:(BOOL)aBackground
{
    if (aImage == nil)
        return;
    id editableImage = [self queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (editableImage == nil)
        return;
    Protocol *required[] = { @protocol(BTCocoaMutableImage), NULL };
    id backgroundImage = [editableImage queryImageWithRequiredProtocols:required optionalProtocols:NULL];
    if (backgroundImage == nil)
        return;
    NSSize cardSize = [backgroundImage imageSize];
    NSSize imageSize = [(NSImage *)aImage size];
    NSRect editRect = NSMakeRect(0.0, 0.0, cardSize.width, cardSize.height);
    float x = aPoint.x;
    float y = NSZeroRect.origin.y;
    float width = NSZeroRect.size.width;
    float height = NSZeroRect.size.height;
    float cardWidth = cardSize.width;
    float cardHeight = cardSize.height;
    float imageRatio = imageSize.width / imageSize.height;
    float cardRatio = cardWidth / cardHeight;
    if (!isnan(aPoint.x)) {
        y = aPoint.y;
        width = imageSize.width;
        height = imageSize.height;
    } else {
        switch (aOption) {
        case 0:
        case 1:
            if (imageRatio > cardRatio) {
                width = cardWidth;
                height = cardWidth / imageRatio;
            } else {
                width = imageRatio * cardHeight;
                height = cardHeight;
            }
            if (aOption == 1) {
                width *= 0.57735026f;
                height *= 0.57735026f;
            }
            x = (cardWidth - width) * 0.5f;
            y = (cardHeight - height) * 0.5f;
            break;
        case 2:
            if (cardRatio > imageRatio) {
                width = cardWidth;
                height = cardWidth / imageRatio;
            } else {
                width = imageRatio * cardHeight;
                height = cardHeight;
            }
            x = (cardWidth - width) * 0.5f;
            y = (cardHeight - height) * 0.5f;
            break;
        case 3:
            x = 0.0f;
            y = 0.0f;
            width = cardWidth;
            height = cardHeight;
            break;
        case 4:
            width = imageSize.width;
            height = imageSize.height;
            x = (cardWidth - width) * 0.5f;
            y = (cardHeight - height) * 0.5f;
            break;
        case 6:
            width = imageSize.width;
            height = imageSize.height;
            if (width > cardWidth || height > cardHeight) {
                if (imageRatio > cardRatio) {
                    width = cardWidth;
                    height = cardWidth / imageRatio;
                } else {
                    width = imageRatio * cardHeight;
                    height = cardHeight;
                }
            }
            x = NSZeroPoint.x + (cardWidth - width) * 0.5f;
            y = NSZeroPoint.y + (cardHeight - height) * 0.5f;
            break;
        default:
            x = NSZeroRect.origin.x;
            break;
        }
    }
    NSRect drawRect = NSMakeRect(roundf(x), roundf(y), width, height);
    NSRect fromRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, imageSize.width, imageSize.height);
    [editableImage beginEditImage:backgroundImage inRect:editRect];
    [backgroundImage beginCocoaEditing];
    if (aBackground) {
        id data = [[NSUserDefaults standardUserDefaults] objectForKey:HSToolEraserColorPreferencesKey];
        NSColor *eraserColor = data != nil ? [NSUnarchiver unarchiveObjectWithData:data] : [NSColor whiteColor];
        if (eraserColor != nil) {
            [eraserColor set];
            [NSBezierPath fillRect:editRect];
        }
    }
    if (aOption == 5) {
        CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
        CGContextBeginPath(context);
        CGContextAddRect(context, NSRectToCGRect(editRect));
        CGEContextFillPathWithColor(context, NULL, NSRectToCGRect(editRect), [[NSColor colorWithPatternImage:aImage] BT_coreGraphicsExtendedColor]);
    } else {
        NSImageCacheMode cacheMode = [aImage cacheMode];
        [aImage setCacheMode:NSImageCacheNever];
        [aImage drawInRect:drawRect fromRect:fromRect operation:NSCompositingOperationSourceOver fraction:1.0];
        [aImage setCacheMode:cacheMode];
    }
    [backgroundImage endCocoaEditing];
    [editableImage endEditImage];
    [self mediaUIDs];
}

- (void)currentCardInCardViewDidChange:(id)aChange
{
    if ([[aChange object] card] == self)
        [[self queryHyperInterface:@protocol(HSWebPageObjectRegistry)] startLoadingWebPageObjects];
}

- (void)currentCardInCardViewWillChange:(id)aChange
{
    [[self queryHyperInterface:@protocol(HSWebPageObjectRegistry)] stopLoadingWebPageObjects];
}

- (id)valuesForMDAttribute:(id)aAttribute
{
    id values = [super valuesForMDAttribute:aAttribute];
    if ([aAttribute isEqualToString:(NSString *)kMDItemTextContent])
        values = [values arrayByAddingObject:[self hyperTitle]];
    return values;
}

- (void)cardPresentationWillStart
{
    [[self animationController] presentationIsStarting];
}

// Cards take no mouse over or drop off actions, and no go to actions on
// leave.
- (BOOL)supportsActionType:(id)aType forEvent:(id)aEvent
{
    id mouseOver = [HSActionEvent actionEventOfType:kHSDeprecatedMouseOverActionEventType];
    id dropOff = [HSActionEvent actionEventOfType:kHSDeprecatedDropOffActionEventType];
    BOOL supports = ![aEvent isEqual:mouseOver] && ![aEvent isEqual:dropOff];
    if ([aEvent isEqual:[HSActionEvent actionEventOfType:kHSLeaveActionEventType]]) {
        if ([NSClassFromString(aType) isSubclassOfClass:[HSToGoAction class]])
            supports = NO;
    }
    return supports;
}

- (id)hyperObjectForActor:(id)aActor
{
    return self;
}

// Shared children are copied so that every child stores its node units.
- (id)fullDictionaryRepresentationWithAllNodeUnits:(BOOL)aUnits
{
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"HSCodingOptionSaveNodeUnitsLocally"];
    id context = [EXCodingContext codingContextWithOperation:EXDefaultCodingOperation shouldZeroMissingValuesOnLoading:NO options:options];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[self extraDictionaryRepresentationWithCodingContext:context]];
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:[self hyperCount]];
    NSEnumerator *enumerator = [self hyperEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        if ([child isTemporary])
            continue;
        if ([child localNodeData] == nil)
            child = [[child localCopyIncludingNodeUnits:aUnits] autorelease];
        [children addObject:[child extraDictionaryRepresentationWithCodingContext:context]];
    }
    [dictionary setObject:children forKey:[HSNodeChildrenKey extraKeyForCollection]];
    return dictionary;
}

- (void)removeFromHyperParent
{
    if ([self cardGroupUID] == nil)
        [super removeFromHyperParent];
    else
        [[self cardGroupController] removeGroupCard:self];
}

- (void)notifyDidChangeCardGroupAttribute
{
    [[[self undoManager] prepareWithInvocationTarget:self] notifyWillChangeCardGroupAttribute];
    [self notifyChange:2 ofAttribute:@protocol(HSCardGroupAttribute) withUserInfo:nil];
}

- (void)notifyWillChangeCardGroupAttribute
{
    [[[self undoManager] prepareWithInvocationTarget:self] notifyDidChangeCardGroupAttribute];
    [self notifyChange:1 ofAttribute:@protocol(HSCardGroupAttribute) withUserInfo:nil];
}

- (void)setCursor:(id)aCursor
{
    [[self nodeData] setCursor:aCursor];
    if ([self isGroupCard])
        [[self cardGroupController] setCardGroupCursor:aCursor forCard:self];
}

- (id)cursor
{
    if ([self isGroupCard]) {
        id cursor = [[self cardGroupController] cardGroupCursorForCard:self];
        if (cursor != nil)
            return cursor;
    }
    return [[self nodeData] cursor];
}

- (void)makeNonGroupCard
{
    [[self cardGroupController] makeNonGroupCard:self];
}

- (void)makeGroupCardWithGroupUID:(id)aUID
{
    [[self cardGroupController] makeGroupCard:self groupUID:aUID];
}

- (void)makeNewGroupCard
{
    [[self cardGroupController] makeNewGroupCard:self];
}

- (id)otherActorsFromGroup:(id)aGroup
{
    NSMutableArray *actors = nil;
    if (_cardGroupUID != nil)
        // The original returned the copy without autoreleasing it.
        actors = [[[[self cardGroupController] allActorsForGroupUID:_cardGroupUID] mutableCopy] autorelease];
    [actors removeObject:aGroup];
    return actors;
}

- (BOOL)isGroupCard
{
    return _cardGroupUID != nil;
}

- (void)setCardGroupUID:(id)aUID
{
    if (![aUID isEqual:_cardGroupUID]) {
        [_cardGroupUID release];
        _cardGroupUID = [aUID retain];
    }
}

- (id)cardGroupUID
{
    return _cardGroupUID;
}

- (id)cardGroupController
{
    if ([self support] != nil)
        return [[self support] cardGroupController];
    return [self nodeDataProvider];
}

- (id)animationController
{
    return _animationController;
}

// The layout grid holder is the editor grid. Influencing geometry holders
// are the card itself (unless ignored) followed by its children.
- (id)objectInHyperGeometryHoldersForInterface:(id)aInterface atIndex:(NSUInteger)aIndex
{
    if (HSProtocolsAreEqual(aInterface, @protocol(HSLayoutGridGeometry)))
        return [self editorLayoutGrid];
    if (!HSProtocolsAreEqual(aInterface, @protocol(HSLayoutInfluencingObjectGeometry)))
        return nil;
    if (_isHyperCardIgnoredInLayoutGuiding)
        return [self hyperChildAtIndex:aIndex];
    if (aIndex == 0)
        return self;
    return [self hyperChildAtIndex:aIndex - 1];
}

- (NSUInteger)countOfHyperGeometryHoldersForInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(aInterface, @protocol(HSLayoutGridGeometry)))
        return 1;
    if (HSProtocolsAreEqual(aInterface, @protocol(HSLayoutInfluencingObjectGeometry)))
        return [self hyperCount] + (_isHyperCardIgnoredInLayoutGuiding ? 0 : 1);
    return 0;
}

- (void)setHyperCardIgnoredInLayoutGuiding:(BOOL)aGuiding
{
    _isHyperCardIgnoredInLayoutGuiding = aGuiding;
}

- (BOOL)isHyperCardIgnoredInLayoutGuiding
{
    return _isHyperCardIgnoredInLayoutGuiding;
}

- (NSRect)hyperLayoutInfluencingBoundingRect
{
    id stack = [self stack];
    NSSize size = stack != nil ? [stack hyperCardSize] : NSZeroRect.size;
    return NSMakeRect(NSZeroRect.origin.x, NSZeroRect.origin.y, size.width, size.height);
}

- (CGAffineTransform)hyperLayoutInfluencingTransform
{
    return CGAffineTransformIdentity;
}

- (BOOL)isHyperInfluencingLayout
{
    return YES;
}

- (void)setMarkedCard:(BOOL)aCard
{
    if (_markedCard == aCard)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Marked Card" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setMarkedCard:_markedCard];
    [self notifyChange:1 ofAttribute:@protocol(HSCardMarkedAttribute) withUserInfo:nil];
    _markedCard = aCard;
    [self notifyChange:2 ofAttribute:@protocol(HSCardMarkedAttribute) withUserInfo:nil];
}

- (BOOL)isMarkedCard
{
    return _markedCard;
}

- (id)basename
{
    return @"Card";
}

- (id)wrapperExtension
{
    return @"hscard";
}

- (void)setHyperDroppedSolidColor:(id)aColor
{
    [[self queryBackgroundGraphicsInterface:@protocol(HSMutableColor)] setHyperSolidColor:aColor];
}

- (void)setHyperSolidColor:(id)aColor
{
}

- (id)hyperSolidColor
{
    id color = [[self backgroundGraphics] queryHyperInterface:@protocol(HSMutableColor)];
    if (color != nil && [color isHyperSolid])
        return [color hyperSolidColor];
    return nil;
}

// Printing renders through an offscreen cache window.
- (id)makeImageRepresentationForContext:(id)aContext
{
    NSSize size = [[self stack] hyperCardSize];
    HSPlayerCardView *view = [[[HSPlayerCardView alloc] initWithFrame:NSMakeRect(0.0, 0.0, size.width, size.height)] autorelease];
    [view setPresentationContext:aContext];
    [view setCard:self];
    if (![[aContext contextIdentifier] isEqual:[[HSPrintingContext presentationContext] contextIdentifier]])
        return [NSImage hyperImageWithView:view];
    NSWindow *window = [NSWindow hyperCacheWindowWithContentRect:NSMakeRect(0.0, 0.0, size.width, size.height)];
    [window setContentView:view];
    [view displayIfNeeded];
    [view lockFocus];
    NSBitmapImageRep *representation = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:[view bounds]] autorelease];
    [view unlockFocus];
    NSImage *image = [[[NSImage allocWithZone:[self zone]] initWithSize:size] autorelease];
    [image addRepresentation:representation];
    return image;
}

- (void)setMenuBarVisible:(BOOL)aVisible
{
    _isMenuBarVisible = aVisible;
}

- (BOOL)isMenuBarVisible
{
    return _isMenuBarVisible;
}

// White needs no fill, the default background already is white.
- (void)fillBackgroundWithEraserColorIfNeeded
{
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:HSToolEraserColorPreferencesKey];
    NSColor *color = data != nil ? [NSUnarchiver unarchiveObjectWithData:data] : nil;
    CGFloat red = 0.0, green = 0.0, blue = 0.0;
    [[color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&red green:&green blue:&blue alpha:NULL];
    if (color == nil)
        return;
    if (HSCardFloatsAreEqual(red, 1.0f) && HSCardFloatsAreEqual(green, 1.0f) && HSCardFloatsAreEqual(blue, 1.0f))
        return;
    [self fillBackgroundWithColor:color];
}

- (void)fillBackgroundWithColor:(id)aColor
{
    id editableImage = [self queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (editableImage == nil)
        return;
    Protocol *required[] = { @protocol(BTCocoaMutableImage), NULL };
    id image = [editableImage queryImageWithRequiredProtocols:required optionalProtocols:NULL];
    if (image == nil)
        return;
    NSSize size = [image imageSize];
    NSRect rect = NSMakeRect(0.0, 0.0, size.width, size.height);
    [editableImage beginEditImage:image inRect:rect];
    [image beginCocoaEditing];
    [(NSColor *)aColor set];
    [NSBezierPath fillRect:rect];
    [image endCocoaEditing];
    [editableImage endEditImage];
}

// The image keeps the name, actions, cursor, comments and grouping of the
// object.
- (void)convertObjectToImage:(id)aImage
{
    NSString *actionName = [[NSBundle mainBundle] localizedStringForKey:@"Convert to Image" value:@"" table:@"UndoManager"];
    [[self undoManager] setMultipleActionsName:actionName];
    id actor = [[[aImage actor] copy] autorelease];
    id imageObject = [self flatObjectsToImageObject:[NSArray arrayWithObject:aImage] addToCard:NO];
    if (imageObject != nil) {
        id objectAttributes = [imageObject queryHyperInterface:@protocol(HSMutableObjectAttributes)];
        if (objectAttributes != nil)
            [objectAttributes setHyperName:[[aImage queryHyperInterface:@protocol(HSObjectAttributes)] hyperName]];
        [self addHyperChild:imageObject];
        [imageObject setActor:actor];
        [imageObject setCursor:[aImage cursor]];
        [imageObject setComments:[aImage comments]];
        id cardObject = [imageObject queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
        if ([[aImage queryHyperInterface:@protocol(HSCardObjectAttributes)] isGroupObject])
            [cardObject makeGroupObject];
    }
    [[self undoManager] setMultipleActionsName:actionName];
}

// Flags shared by all objects carry over to the image; the shadow is kept
// only when every flattened child has one.
- (id)flatObjectsToImageObject:(id)aObjects addToCard:(BOOL)aCard
{
    NSUInteger count = [aObjects count];
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:count];
    BOOL allHidden = YES, allDraggable = YES, allResizable = YES, allRotatable = YES;
    BOOL allNoClick = YES, allGroup = YES, allDropOffOnly = YES, allShadowed = YES;
    NSUInteger i;
    for (i = 0; i < count; i++) {
        id object = [aObjects objectAtIndex:i];
        if ([[object queryHyperInterface:@protocol(HSButtonObjectAttributes)] isButtonNaturallyInvisible]) {
            id shape = [object queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)];
            if ([[shape shapeButtonType] isEqualToString:@"HSInvisibleShapeButtonType"])
                [shape setIsBorderless:YES];
        }
        id child = [object queryHyperInterface:@protocol(HSNodeChild)];
        if ([child hyperParent] == self) {
            [children addObject:child];
            if (allShadowed && ![[object queryHyperInterface:@protocol(HSShadowEnabledAttribute)] isHyperShadowEnabled])
                allShadowed = NO;
        }
        id attributes = [object queryHyperInterface:@protocol(HSCardObjectAttributes)];
        allHidden = allHidden && [attributes isHidden];
        allDraggable = allDraggable && [attributes isDraggable];
        allResizable = allResizable && [attributes isResizable];
        allRotatable = allRotatable && [attributes isRotatable];
        allNoClick = allNoClick && [attributes isNoClick];
        allGroup = allGroup && [attributes isGroupObject];
        allDropOffOnly = allDropOffOnly && [attributes isDropOffOnly];
    }
    [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Flat to Image" value:@"" table:@"UndoManager"]];
    // Hidden objects are shown while rendering.
    if (allHidden) {
        for (i = 0; i < count; i++)
            [[[aObjects objectAtIndex:i] queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] setHidden:NO];
    }
    NSPoint origin = NSZeroPoint;
    NSImage *image = [HSUserObjectInPlayerPreviewView previewImageForObjects:children renderingOrigin:&origin];
    id imageObject = nil;
    if (image != nil) {
        NSSize size = [image size];
        if (!HSCardFloatsAreEqual(size.width, NSZeroSize.width) || !HSCardFloatsAreEqual(size.height, NSZeroSize.height))
            imageObject = [HSDocument userObjectWithMedia:[HSNewMedia mediaWithImage:image]];
    }
    if (imageObject == nil) {
        // The original showed the objects again here and left them visible.
        if (allHidden) {
            for (i = 0; i < count; i++)
                [[[aObjects objectAtIndex:i] queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] setHidden:YES];
        }
        return nil;
    }
    [[[imageObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveFrameBoundingRectOriginTo:origin withLayoutGuidingContext:nil];
    if (!allShadowed)
        [[imageObject queryHyperInterface:@protocol(HSMutableShadowAttributes)] setHyperShadowEnabled:NO];
    [[imageObject queryHyperInterface:@protocol(HSCommentsAttributes)] appendHyperCommentsFromObjects:children];
    id firstName = nil;
    [self HSCard_mergeActionsFromObjects:aObjects toObject:imageObject firstName:&firstName];
    [self hyperRemoveChildrenBeginGrouping];
    [children makeObjectsPerformSelector:@selector(removeFromHyperParent)];
    [self hyperRemoveChildrenEndGrouping];
    HSImageCropApplier *cropApplier = [[HSImageCropApplier alloc] initWithImageObject:imageObject];
    [cropApplier updateCurrentBorderPath];
    [cropApplier adjustObjectSizeToBorderSize];
    [cropApplier release];
    id cardObject = [imageObject queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
    if (allHidden)
        [cardObject setHidden:YES];
    if (allDraggable)
        [cardObject setDraggable:YES];
    if (allResizable)
        [cardObject setResizable:YES];
    if (allRotatable)
        [cardObject setRotatable:YES];
    if (allNoClick)
        [cardObject setNoClick:YES];
    if (allDropOffOnly)
        [cardObject setDropOffOnly:YES];
    if (aCard) {
        [[imageObject queryHyperInterface:@protocol(HSMutableObjectAttributes)] setHyperName:firstName];
        [self addHyperChild:imageObject];
        if (allGroup)
            [cardObject makeGroupObject];
    }
    return imageObject;
}

- (void)flatObjectsToImage:(id)aImage
{
    [self flatObjectsToImageObject:aImage addToCard:YES];
}

- (void)flatObjectsToBackground:(id)aBackground
{
    [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Flat To Background" value:@"" table:@"UndoManager"]];
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:[aBackground count]];
    for (id object in aBackground) {
        if ([[object queryHyperInterface:@protocol(HSNodeChild)] hyperParent] == self)
            [children addObject:object];
    }
    [children sortByHyperOrder];
    [[self queryHyperInterface:@protocol(HSCommentsAttributes)] appendHyperCommentsFromObjects:children];
    [self hyperRemoveChildrenBeginGrouping];
    [children makeObjectsPerformSelector:@selector(removeFromHyperParent)];
    [self hyperRemoveChildrenEndGrouping];
    NSPoint origin = NSZeroPoint;
    NSImage *image = [HSUserObjectInPlayerPreviewView previewImageForObjects:children renderingOrigin:&origin];
    NSSize size = [image size];
    [self HSCard_setBackgroundImage:image inRect:[NSValue valueWithRect:NSMakeRect(origin.x, origin.y, size.width, size.height)] draw:[NSNumber numberWithBool:YES]];
}

// Undo registers the opposite draw flag, so undo itself draws nothing.
// The first go to and the first NBA style action are copied (re-targeted
// to the image object), as is the first action of every other class;
// later actions of the mergeable types are merged into the copied ones.
- (void)HSCard_mergeActionsFromObjects:(id)aObjects toObject:(id)aObject firstName:(id *)aName
{
    id actor = [aObject queryHyperInterface:@protocol(HSActor)];
    id defaultEvent = [HSActionEvent actionEventOfType:kHSDefaultActionEventType];
    id timer = [actor automaticTimerForActionEvent:defaultEvent];
    id imageUID = [[aObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    NSArray *sorted = [aObjects sortedArrayUsingFunction:HSCardCompareObjectNames context:NULL];
    NSMutableArray *UIDs = [NSMutableArray new];
    for (id object in sorted)
        [UIDs addObject:[[object queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID]];
    NSSet *UIDSet = [NSSet setWithArray:UIDs];
    NSMutableArray *actions = [NSMutableArray new];
    NSMutableSet *copiedClassNames = [NSMutableSet new];
    BOOL copiedToGo = NO;
    BOOL copiedNBA = NO;
    id playSound = nil, playMovie = nil, showHide = nil, arduinoWatcher = nil, keyMapper = nil;
    id speechRecognition = nil, buttonLister = nil, buttonStepper = nil, ghostWriter = nil, sequencer = nil;
    NSUInteger i;
    for (i = 0; i < [sorted count]; i++) {
        id objectActor = [[sorted objectAtIndex:i] queryHyperInterface:@protocol(HSActor)];
        if (![timer runActionsAutomatically]) {
            id objectTimer = [objectActor automaticTimerForActionEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]];
            if ([objectTimer runActionsAutomatically]) {
                [timer setRunActionsAutomatically:YES];
                [timer setDelayBetweenRepeatingActions:[objectTimer delayBetweenRepeatingActions]];
                [timer setDelayBeforeRunActionsAutomatically:[objectTimer delayBeforeRunActionsAutomatically]];
            }
        }
        for (id action in [objectActor hyperActions]) {
            NSString *className = NSStringFromClass([action class]);
            BOOL copy;
            if ([action isKindOfType:[HSToGoAction actionType]]) {
                copy = !copiedToGo;
                copiedToGo = YES;
            } else if ([action isKindOfType:[HSNBAAction actionType]]) {
                copy = !copiedNBA;
            } else {
                copy = ![copiedClassNames containsObject:className];
            }
            if (copy) {
                id copied = [action copyReplacingObjectUIDs:UIDSet sortedByPriority:UIDs withImageObjectUID:imageUID];
                if ([action isKindOfType:[HSPlaySoundAction actionType]])
                    playSound = copied;
                else if ([action isKindOfType:[HSPlayMovieAction actionType]])
                    playMovie = copied;
                else if ([action isKindOfType:[HSShowHideObjectAction actionType]])
                    showHide = copied;
                else if ([action isKindOfType:[HSArduinoWatcherAction actionType]]) {
                    copiedNBA = copied != nil;
                    arduinoWatcher = copied;
                } else if ([action isKindOfType:[HSKeyMapperAction actionType]]) {
                    copiedNBA = copied != nil;
                    keyMapper = copied;
                } else if ([action isKindOfType:[HSSpeechRecognitionAction actionType]]) {
                    copiedNBA = copied != nil;
                    speechRecognition = copied;
                } else if ([action isKindOfType:[HSButtonListerAction actionType]]) {
                    copiedNBA = copied != nil;
                    buttonLister = copied;
                } else if ([action isKindOfType:[HSButtonStepperAction actionType]]) {
                    copiedNBA = copied != nil;
                    buttonStepper = copied;
                } else if ([action isKindOfType:[HSGhostWriterAction actionType]]) {
                    copiedNBA = copied != nil;
                    ghostWriter = copied;
                } else if ([action isKindOfType:[HSSequencerAction actionType]]) {
                    copiedNBA = copied != nil;
                    sequencer = copied;
                }
                if (copied != nil) {
                    [actions addObject:copied];
                    [copiedClassNames addObject:className];
                    [copied release];
                }
            } else if ([action isKindOfType:[HSPlaySoundAction actionType]]) {
                [playSound mergeInPlaySoundAction:action replacingObjectUIDs:nil sortedByPriority:UIDs withImageObjectUID:nil];
            } else if ([action isKindOfType:[HSPlayMovieAction actionType]]) {
                [playMovie mergeInPlayMovieAction:action replacingObjectUIDs:UIDSet sortedByPriority:UIDs withImageObjectUID:nil];
            } else if ([action isKindOfType:[HSShowHideObjectAction actionType]]) {
                [showHide mergeInShowHideObjectAction:action replacingObjectUIDs:UIDSet sortedByPriority:UIDs withImageObjectUID:imageUID];
            } else if ([action isKindOfType:[HSArduinoWatcherAction actionType]]) {
                [arduinoWatcher mergeInArduinoWatcherAction:action replacingObjectUIDs:UIDSet sortedByPriority:UIDs withImageObjectUID:nil];
            } else if ([action isKindOfType:[HSKeyMapperAction actionType]]) {
                [keyMapper mergeInKeyMapperAction:action replacingObjectUIDs:UIDSet sortedByPriority:UIDs withImageObjectUID:imageUID];
            } else if ([action isKindOfType:[HSSpeechRecognitionAction actionType]]) {
                [speechRecognition mergeInSpeechRecognitionAction:action replacingObjectUIDs:UIDSet sortedByPriority:UIDs withImageObjectUID:imageUID];
            } else if ([action isKindOfType:[HSButtonListerAction actionType]]) {
                [buttonLister mergeInButtonListerAction:action replacingObjectUIDs:UIDSet sortedByPriority:UIDs withImageObjectUID:nil];
            } else if ([action isKindOfType:[HSButtonStepperAction actionType]]) {
                [buttonStepper mergeInButtonStepperAction:action replacingObjectUIDs:UIDSet sortedByPriority:UIDs withImageObjectUID:nil];
            } else if ([action isKindOfType:[HSGhostWriterAction actionType]]) {
                [ghostWriter mergeInGhostWriterAction:action replacingObjectUIDs:UIDSet sortedByPriority:UIDs withImageObjectUID:nil];
            } else if ([action isKindOfType:[HSSequencerAction actionType]]) {
                [sequencer mergeInSequencerAction:action replacingObjectUIDs:UIDSet sortedByPriority:UIDs withImageObjectUID:nil];
            }
        }
    }
    [actor setHyperActions:actions];
    [copiedClassNames release];
    [actions release];
    [UIDs release];
    if (aName != NULL)
        *aName = [[sorted objectAtIndex:0] hyperName];
}

// The objects' renderers draw into the background bitmap within the part of
// the background their bounding regions cover.
- (void)drawObjectsOnBackground:(id)aBackground
{
    id editableImage = [self queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (editableImage == nil)
        return;
    Protocol *required[] = { @protocol(BTCGMutableImage), NULL };
    id image = [editableImage queryImageWithRequiredProtocols:required optionalProtocols:NULL];
    if (image == nil)
        return;
    HSMutableRegion *region = [HSMutableRegion region];
    NSUInteger count = [aBackground count];
    NSMutableArray *renderers = [NSMutableArray arrayWithCapacity:count];
    NSMutableData *transformsData = [NSMutableData dataWithLength:count * sizeof(CGAffineTransform)];
    CGAffineTransform *transforms = [transformsData mutableBytes];
    CGAffineTransform *transform = transforms;
    for (id object in aBackground) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        *transform = [(id<HSGeometryAttributes>)[object queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
        id renderer = [[object queryHyperInterface:@protocol(HSEditorVisualization)] queryRenderer];
        HSMutableRegion *bounds = [HSMutableRegion region];
        [renderer unionBoundingRegionWithRegion:bounds];
        [renderers addObject:renderer];
        [region addRegion:[bounds applyAffineTransform:*transform]];
        [pool release];
        transform++;
    }
    NSSize imageSize = [image imageSize];
    NSRect imageRect = [editableImage imageRect];
    float scaleX = imageSize.width != 0.0 ? imageRect.size.width / imageSize.width : 1.0f;
    float scaleY = imageSize.height != 0.0 ? imageRect.size.height / imageSize.height : 1.0f;
    CGAffineTransform imageToCard = CGAffineTransformMake(scaleX, 0.0, 0.0, -scaleY, imageRect.origin.x - CGPointZero.x * scaleX, imageRect.origin.y + imageRect.size.height + CGPointZero.y * scaleY);
    [region applyAffineTransform:CGAffineTransformInvert(imageToCard)];
    NSRect editRect = NSIntersectionRect(NSRectFromCGRect(CGRectIntegral(NSRectToCGRect([region boundingRect]))), imageRect);
    if (NSIsEmptyRect(editRect))
        return;
    [editableImage beginEditImage:image inRect:editRect];
    [image beginCGEditing];
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithCGContext:[image imageCGContext] flipped:YES];
    [NSGraphicsContext setCurrentContext:context];
    [context saveGraphicsState];
    [[NSAffineTransform transformWithHyperCGAffineTransform:CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, imageSize.height)] concat];
    NSSize cardSize = [[self stack] hyperCardSize];
    HSRegion *cardRegion = [HSRegion regionWithRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, cardSize.width, cardSize.height)];
    id delegate = [HSGenericRenderDelegate delegateWithDrawable:nil];
    transform = transforms;
    for (id renderer in renderers) {
        [context saveGraphicsState];
        [[NSAffineTransform transformWithHyperCGAffineTransform:*transform] concat];
        HSMutableRegion *drawRegion = [[cardRegion mutableCopy] autorelease];
        [drawRegion applyAffineTransform:CGAffineTransformInvert(*transform)];
        [renderer drawRegion:drawRegion withDelegate:delegate];
        [context restoreGraphicsState];
        transform++;
    }
    [context restoreGraphicsState];
    [NSGraphicsContext restoreGraphicsState];
    [image endCGEditing];
    [editableImage endEditImage];
}

- (void)_setBackgroundGraphics:(id)aGraphics
{
    if (_backgroundGraphics == aGraphics)
        return;
    if ([self isInDocument])
        [_backgroundGraphics willRemoveFromDocument];
    [_backgroundGraphics setHyperOwner:nil];
    [_backgroundGraphics autorelease];
    _backgroundGraphics = [aGraphics retain];
    [_backgroundGraphics setHyperOwner:self];
    if ([self isInDocument])
        [_backgroundGraphics didAddToDocument];
    [self setBackgroundThumbnail:nil];
}

- (NSRect)backgroundBounds
{
    id stack = [self stack];
    NSSize size = stack != nil ? [stack hyperCardSize] : NSZeroRect.size;
    return NSMakeRect(NSZeroRect.origin.x, NSZeroRect.origin.y, size.width, size.height);
}

- (id)backgroundGraphics
{
    return _backgroundGraphics;
}

- (void)setHyperBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject
{
    [self setBackgroundGraphics:aGraphics copyObject:aObject];
}

- (void)setBackgroundThumbnail:(id)aThumbnail
{
    if (_backgroundThumbnail != aThumbnail) {
        [_backgroundThumbnail autorelease];
        _backgroundThumbnail = [aThumbnail retain];
    }
}

- (id)backgroundThumbnail
{
    return _backgroundThumbnail;
}

- (NSRect)imageRect
{
    id sizeAttributes = [self queryHyperInterface:@protocol(HSSizeAttributes)];
    if (sizeAttributes == nil)
        return NSZeroRect;
    NSSize size = [(id<HSSizeAttributes>)sizeAttributes size];
    return NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height);
}

- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface))
        return [[[HSCardVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSInteractivePlayerItem)))
        return [[[HSInteractiveFlatObject alloc] initWithNode:self] autorelease];
    return [super queryNewHyperInterface:aInterface];
}

// Repeated pastes of the same pasteboard contents are counted.
- (NSInteger)incrementPasteCount
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    if (_pasteboardChangeCount == [pasteboard changeCount])
        return ++_pasteCount;
    _pasteboardChangeCount = (int)[pasteboard changeCount];
    _pasteCount = 0;
    return 0;
}

- (void)resetPasteCount
{
    _pasteboardChangeCount = -1;
}

- (void)hyperDrawBackgroundInROI:(NSRect)aROI ofBounds:(NSRect)aBounds
{
    [super hyperDrawBackgroundInROI:aROI ofBounds:aBounds];
}

- (void)postTitleDidChange
{
    [self notifyChange:2 ofAttribute:@protocol(HSCardTitleAttribute) withUserInfo:nil];
}

- (BOOL)isEmpty
{
    NSUInteger childCount = [[self hyperChildren] count];
    id image = [[self queryHyperInterface:@protocol(HSEditableImageAttributes)] queryImageWithRequiredProtocols:NULL optionalProtocols:NULL];
    BOOL placeholder = [image conformsToProtocol:@protocol(HSPlaceholderImage)];
    NSUInteger actionCount = [[[[self actor] queryHyperInterface:@protocol(HSActionsAttribute)] hyperActions] count];
    return actionCount == 0 && placeholder && childCount == 0;
}

- (void)setCardIdOldFileFormatAsString:(id)aString
{
    _cardIdOldFileFormat = [aString intValue];
}

- (id)cardIdOldFileFormatAsString
{
    return [NSString stringWithFormat:@"%d", _cardIdOldFileFormat];
}

- (void)setCardIdOldFileFormat:(NSInteger)aFormat
{
    _cardIdOldFileFormat = (int)aFormat;
}

- (NSInteger)cardIdOldFileFormat
{
    return _cardIdOldFileFormat;
}

- (void)setHyperTitle:(id)aTitle
{
    if ([_title isEqual:aTitle])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Title" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperTitle:[self hyperTitle]];
    [self setTitle:aTitle];
    [self postTitleDidChange];
}

- (id)hyperTitle
{
    return [self title] != nil ? [self title] : @"";
}

// Titles are made unique among the cards of the stack.
- (void)hyperRefreshTitle
{
    NSString *title = [self hyperTitle];
    _cardTitleGenerator = [[HSUniqueNameGenerator alloc] initWithDataSource:self itemNameSelector:@selector(hyperTitle) separator:@" "];
    NSString *uniqueTitle = [_cardTitleGenerator uniqueName:title omittingItemIdenticalTo:self];
    [_cardTitleGenerator release];
    _cardTitleGenerator = nil;
    if (![uniqueTitle isEqualToString:title])
        [self setHyperTitle:uniqueTitle];
}

- (id)enumeratorForGenerator:(id)aGenerator
{
    if (_cardTitleGenerator == aGenerator)
        return [[self hyperParent] hyperEnumerator];
    return [super enumeratorForGenerator:aGenerator];
}

- (id)nameBaseTemplates
{
    return [NSArray arrayWithObjects:[self title], nil];
}

- (void)setTitle:(id)aTitle
{
    if (_title != aTitle) {
        [_title release];
        _title = [aTitle copy];
        [self userObjectNameBaseTemplateDidChange];
    }
}

- (id)title
{
    return _title;
}

// Image objects whose media lost its image are dropped.
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    [self HSCard_setDefaultBackgroundIfNeeded];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSArray *keys = [super keysForExtraLoadingWithCodingContext:aContext];
    return [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"_isGridVisible", @"_layoutGrid", @"gridOffsetAsString", @"_isSnapToGridEnabled", @"_isSnapToGuidesEnabled", @"_isSnapToObjectsEnabled", nil]];
}

// Object styles store only the background and the title.
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [super keysForExtraStoringWithCodingContext:aContext];
    NSArray *cardKeys;
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
        cardKeys = [NSArray arrayWithObjects:@"backgroundGraphics", @"_title", nil];
    else
        cardKeys = [NSArray arrayWithObjects:@"backgroundGraphics", @"_title", @"cardIdOldFileFormatAsString", @"cardGroupUID", @"markedCard", @"_isMenuBarVisible", nil];
    return [keys arrayByAddingObjectsFromArray:cardKeys];
}

- (BOOL)isItemProxy
{
    return NO;
}

- (id)childWrapperExtension
{
    return @"hsobject";
}

- (id)stack
{
    return [[[[self card] queryHyperInterface:@protocol(HSNodeChild)] hyperParent] queryHyperInterface:@protocol(HSStackAttributes)];
}

- (id)card
{
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_title release];
    [super removeObserver:self selector:@selector(HSCard_cardSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSSizeAttribute)];
    [_backgroundGraphics setHyperOwner:nil];
    [_backgroundGraphics release];
    [_backgroundThumbnail release];
    [_cardTitleGenerator release];
    [_animationController setOwner:nil];
    [_animationController release];
    [_cardGroupUID release];
    [_webPageObjects release];
    [super dealloc];
}

- (void)willDisconnectFromParent
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super willDisconnectFromParent];
}

- (void)didConnectToParent
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentCardInCardViewDidChange:) name:HSCurrentCardInCardViewDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentCardInCardViewWillChange:) name:HSCurrentCardInCardViewWillChange object:nil];
    [super didConnectToParent];
}

// The default background only takes the new size; any other background is
// redrawn into a bitmap of the new size.
- (void)HSCard_cardSizeDidChange:(id)aChange
{
    id sizeAttributes = [self queryHyperInterface:@protocol(HSSizeAttributes)];
    if (sizeAttributes == nil)
        return;
    NSSize size = [(id<HSSizeAttributes>)sizeAttributes size];
    if (NSEqualSizes(size, NSZeroSize))
        return;
    id editableImage = [self queryHyperInterface:@protocol(HSEditableImageAttributes)];
    if (editableImage == nil)
        return;
    Protocol *required[] = { @protocol(BTCGImage), NULL };
    id image = [editableImage queryImageWithRequiredProtocols:required optionalProtocols:NULL];
    if (image == nil || NSEqualSizes(size, [image imageSize]))
        return;
    if ([image isKindOfClass:[HSCard_HSDefaultBackgroundImage class]]) {
        [image setImageSize:size];
        return;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
        return;
    size_t width = size.width > 0.0 ? lroundf(ceilf(size.width)) : 0;
    size_t height = size.height > 0.0 ? lroundf(ceilf(size.height)) : 0;
    CGContextRef context = CGEBitmapContextCreate(NULL, width, height, 8, (width * 4 + 15) & ~(size_t)15, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL)
        return;
    [image drawInCGContext:context inRect:CGRectMake(CGPointZero.x, CGPointZero.y, size.width, size.height)];
    [editableImage beginEditImage:[BTCGBitmapLayer bitmapLayerWithCGContext:context decode:NULL format:-1 colorProfile:NULL]];
    [editableImage endEditImage];
    CGContextRelease(context);
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _animationController = [HSAnimationController new];
    [_animationController setOwner:self];
    _isMenuBarVisible = YES;
    [self HSCard_setDefaultBackgroundIfNeeded];
    [super linkAttribute:@protocol(HSImageRectAttribute) toAttribute:@protocol(HSSizeAttribute)];
    [super addObserver:self selector:@selector(HSCard_cardSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSSizeAttribute) withPriority:0.75f];
    return self;
}

// A card without a background image gets a white placeholder of its size.
- (void)HSCard_setDefaultBackgroundIfNeeded
{
    id unit = [super unitForRole:HSEditableBackgroundUnitRole];
    if (![unit isKindOfClass:[HSEditableImageNodeUnit class]] || [unit hasImage])
        return;
    id sizeUnit = [super unitForRole:@"Size Unit"];
    if (![sizeUnit isKindOfClass:[HSSizeNodeUnit class]])
        return;
    [unit beginEditImage:[[[HSCard_HSDefaultBackgroundImage alloc] initWithImageSize:[(HSSizeNodeUnit *)sizeUnit size]] autorelease]];
    [unit endEditImage];
}

- (void)removeHyperChild:(id)aChild
{
    if ([aChild isTemporary])
        [[self stack] unregisterTemporaryObject:aChild];
    [super removeHyperChild:aChild];
}

- (void)insertTemporaryHyperChild:(id)aChild atIndex:(NSUInteger)aIndex
{
    [aChild setTemporary:YES];
    [self insertHyperChild:aChild atIndex:aIndex];
    [[self stack] registerTemporaryObject:aChild];
}

- (void)addTemporaryHyperChild:(id)aChild
{
    [self insertTemporaryHyperChild:aChild atIndex:[self hyperCount]];
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    return [[[self queryHyperInterface:@protocol(HSCursorAttributes)] cursor] imageMedia] != nil;
}

- (void)verifyUnsupportedFeatures
{
    id attributes = [self queryHyperInterface:@protocol(HSCursorAttributes)];
    if ([[attributes hyperCursor] imageMedia] != nil)
        [attributes setHyperCursor:nil];
    [super verifyUnsupportedFeatures];
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    id cursor = [[self queryHyperInterface:@protocol(HSCursorAttributes)] cursor];
    NSMutableSet *features = [NSMutableSet setWithSet:[super HTML5UnsupportedFeaturesForDocumentType:aType]];
    if ([cursor imageMedia] != nil)
        [features addObject:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureCursor" value:@"" table:@"Export"]];
    return features;
}

@end

// White placeholder background of a given size.
@implementation HSCard_HSDefaultBackgroundImage

- (struct CGColor *)colorAtPoint:(CGPoint)aPoint
{
    if (aPoint.x < 0.0 || aPoint.y < 0.0 || aPoint.x >= _size.width || aPoint.y >= _size.height)
        return NULL;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
        return NULL;
    CGFloat components[] = { 1.0, 1.0, 1.0, 1.0 };
    CGColorRef color = CGColorCreate(colorSpace, components);
    CGColorSpaceRelease(colorSpace);
    return (CGColorRef)[(id)color autorelease];
}

- (void)drawInCurrentNSGraphicsContextAtPoint:(NSPoint)aPoint
{
    [self drawInCGContext:[[NSGraphicsContext currentContext] CGContext] atPoint:NSPointToCGPoint(aPoint)];
}

- (void)drawInCurrentNSGraphicsContextInRect:(NSRect)aRect
{
    [self drawInCGContext:[[NSGraphicsContext currentContext] CGContext] inRect:NSRectToCGRect(aRect)];
}

- (void)drawInCGContext:(struct CGContext *)aContext atPoint:(CGPoint)aPoint
{
    [self drawInCGContext:aContext inRect:CGRectMake(aPoint.x, aPoint.y, _size.width, _size.height)];
}

- (void)drawInCGContext:(struct CGContext *)aContext inRect:(CGRect)aRect
{
    CGContextSaveGState(aContext);
    CGContextSetRGBFillColor(aContext, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(aContext, aRect);
    CGContextRestoreGState(aContext);
}

- (struct CGImage *)coreGraphicsImage
{
    return NULL;
}

- (struct CGColorSpace *)coreGraphicsColorSpace
{
    return (CGColorSpaceRef)[(id)CGColorSpaceCreateDeviceRGB() autorelease];
}

- (struct CGPDFDocument *)coreGraphicsPDFDocument
{
    return NULL;
}

- (void)setImageSize:(NSSize)aSize
{
    _size = NSSizeToCGSize(aSize);
}

- (CGSize)imageSize
{
    return _size;
}

- (id)initWithImageSize:(NSSize)aSize
{
    self = [super init];
    if (self != nil)
        _size = NSSizeToCGSize(aSize);
    return self;
}

- (id)init
{
    return [self initWithImageSize:NSZeroSize];
}

@end
