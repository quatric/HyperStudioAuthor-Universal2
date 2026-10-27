#import "HSButtonObject.h"
#import "HyperPlayerBaseData.h"
#import "HSButtonObjectVisualization.h"
#import "HSButtonObjectEditorVisualization.h"
#import "HSButtonObjectPlayerVisualization.h"
#import "HSButtonObjectShapeHitTester.h"
#import "HSMutableSizeAttributesImplementation.h"

// The XML text coding category on NSAttributedString is provided by the
// HyperStudio editor, which is the only host that stores or imports XML.
@interface NSAttributedString (HSButtonObjectXMLText)
+ (id)hyperLoadFromXMLRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)hyperXMLRepresentationInContext:(id)aContext UID:(id)aUID;
@end

#define HSBOData ((HSButtonObjectData *)[self nodeData])

static NSString *HSButtonObjectUndoName(NSString *aKey)
{
    return [[NSBundle mainBundle] localizedStringForKey:aKey value:@"" table:@"UndoManager"];
}

static BOOL HSButtonObjectFloatsDiffer(float a, float b)
{
    float ma = a != 0 ? fabsf(a) : 1;
    float mb = b != 0 ? fabsf(b) : 1;
    return fabsf(a - b) > MAX(ma, mb) * 0.0005f;
}

@implementation HSButtonObject

+ (id)supportedTitleAttributes
{
    return [NSSet setWithObjects:NSForegroundColorAttributeName, NSFontAttributeName, NSUnderlineStyleAttributeName, NSStrokeWidthAttributeName, NSStrokeColorAttributeName, NSShadowAttributeName, NSKernAttributeName, nil];
}

+ (Class)nodeDataClass
{
    return [HSButtonObjectData class];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"HSGeometryNodeUnit", @"Geometry Unit",
            @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit",
            @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit",
            @"HSShowHideTransitionNodeUnit", @"Transition Unit",
            @"HSMutableSnapOptionsNodeUnit", @"Snap Options Unit", nil];
}

- (void)importSharedPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    id iconElement = [[aRepresentation elementsForName:@"icon"] extraFirstObject];
    id uid = [HSUID UIDWithString:[[iconElement attributeForName:HSXMLStoringRefIdString] stringValue]];
    id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid];
    if (media != nil)
        [self setMedia:media];

    id iconStyle = [[aRepresentation elementsForName:@"iconStyle"] extraFirstObject];
    [self setIconVisible:[[[iconStyle attributeForName:@"visible"] stringValue] hyperBoolValue]];
    [self setIconPosition:[[[iconStyle attributeForName:@"position"] stringValue] intValue]];

    id richText = [[aRepresentation elementsForName:@"richText"] extraFirstObject];
    NSAttributedString *text = [NSAttributedString hyperLoadFromXMLRepresentation:richText inContext:aContext];
    [self setTitle:[text string]];
    // Every attribute is read at index 0 over the whole string.
    NSRange effectiveRange = NSMakeRange(0, 0);
    NSRange whole = NSMakeRange(0, [text length]);
    [self setTitleFont:[text attribute:NSFontAttributeName atIndex:0 longestEffectiveRange:&effectiveRange inRange:whole]];
    [self setTitleColor:[text attribute:NSForegroundColorAttributeName atIndex:0 longestEffectiveRange:&effectiveRange inRange:whole]];
    // The original applies the stroke color twice here.
    [self setHyperOutlineColor:[text attribute:NSStrokeColorAttributeName atIndex:0 longestEffectiveRange:&effectiveRange inRange:whole]];
    [self setHyperOutlineColor:[text attribute:NSStrokeColorAttributeName atIndex:0 longestEffectiveRange:&effectiveRange inRange:whole]];
    NSShadow *shadow = [text attribute:NSShadowAttributeName atIndex:0 longestEffectiveRange:&effectiveRange inRange:whole];
    if (shadow != nil)
    {
        [self setHyperShadowEnabled:YES];
        [self setTitleShadowOffset:[shadow shadowOffset]];
        [self setTitleShadowBlurRadius:[shadow shadowBlurRadius]];
    }
    id strokeColor = [text attribute:NSStrokeColorAttributeName atIndex:0 longestEffectiveRange:&effectiveRange inRange:whole];
    if (strokeColor != nil)
    {
        [self setHyperOutlineEnabled:YES];
        [self setHyperOutlineColor:strokeColor];
    }
    id strokeWidth = [text attribute:NSStrokeWidthAttributeName atIndex:0 longestEffectiveRange:&effectiveRange inRange:whole];
    if (strokeWidth != nil)
    {
        [self setHyperOutlineEnabled:YES];
        [self setHyperOutlineWidth:[strokeWidth floatValue]];
    }
    id kern = [text attribute:NSKernAttributeName atIndex:0 longestEffectiveRange:&effectiveRange inRange:whole];
    if (kern != nil)
        [self setHyperSpaceBetweenCharacters:[kern floatValue]];
    id underline = [text attribute:NSUnderlineStyleAttributeName atIndex:0 longestEffectiveRange:&effectiveRange inRange:whole];
    if (underline != nil)
        [self setHyperUnderlined:[underline intValue] > 0];
    [self setTitleVisible:[[[richText attributeForName:@"visible"] stringValue] hyperBoolValue]];

    id buttonStyle = [[aRepresentation elementsForName:@"buttonStyle"] extraFirstObject];
    id systemBackground = [self queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
    id shapeBackground = [self queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)];
    NSString *type = [[buttonStyle attributeForName:@"type"] stringValue];
    if ([type isEqualToString:@"HSRegularSystemButtonType"]
        || [type isEqualToString:@"HSDefaultSystemButtonType"]
        || [type isEqualToString:@"HSRectangleSystemButtonType"]
        || [type isEqualToString:@"HSDropShadowRectangleSystemButtonType"]
        || [type isEqualToString:@"HSTexturedBackgroundSystemButtonType"])
    {
        [self setBackgroundStyle:@"HSButtonObjectSystemBackgroundStyle"];
        [systemBackground setSystemButtonType:type];
        [shapeBackground setShapeButtonType:nil];
        [shapeBackground setBorderPath:nil];
    }
    else if ([type isEqualToString:@"HSInvisibleShapeButtonType"]
             || [type isEqualToString:@"HSFreehandAreaShapeButtonType"]
             || [type isEqualToString:@"HSExpandingAreaShapeButtonType"]
             || [type isEqualToString:@"HSLassoAreaShapeButtonType"])
    {
        [self setBackgroundStyle:@"HSButtonObjectShapeBackgroundStyle" needsResetRotationAngle:NO];
        [shapeBackground setShapeButtonType:type];
        [systemBackground setSystemButtonType:nil];
        [shapeBackground setBorderPath:[NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, 1, 1)]];
    }
    [self setTitleVisible:[self isTitleVisibleForButtonType:type]];
    [self setHasHighlight:[self hasHighlightForButtonType:type]];

    id tint = [[aRepresentation elementsForName:@"tint"] extraFirstObject];
    NSArray *components = [[[tint attributeForName:@"color"] stringValue] componentsSeparatedByString:@","];
    if ([components count] > 3)
    {
        NSColor *color = [NSColor colorWithCalibratedRed:[[components objectAtIndex:0] floatValue]
                                                   green:[[components objectAtIndex:1] floatValue]
                                                    blue:[[components objectAtIndex:2] floatValue]
                                                   alpha:[[components objectAtIndex:3] floatValue]];
        [systemBackground setTintColor:color];
    }
    [systemBackground setIgnoreTintColor:[[[tint attributeForName:@"ignore"] stringValue] hyperBoolValue]];

    [super importSharedPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    [pool release];
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (void)storeSharedPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeSharedPropertiesInXMLElementRepresentation:aRepresentation context:aContext];

    id media = [self media];
    if (media != nil)
    {
        NSXMLElement *icon = [NSXMLElement elementWithName:@"icon"];
        [icon addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[media mediaUID] stringValue]]];
        [aRepresentation addChild:icon];
        [aContext addMedia:media];
    }

    NSXMLElement *iconStyle = [NSXMLElement elementWithName:@"iconStyle"];
    [iconStyle addAttribute:[NSXMLNode attributeWithName:@"visible" stringValue:[self isIconVisible] ? HSXMLStoring1String : HSXMLStoring0String]];
    [iconStyle addAttribute:[NSXMLNode attributeWithName:@"position" stringValue:[NSString stringWithFormat:@"%d", (int)[self iconPosition]]]];
    [aRepresentation addChild:iconStyle];

    id richText = [[self hyperText] hyperXMLRepresentationInContext:aContext UID:[self hyperUID]];
    [richText addAttribute:[NSXMLNode attributeWithName:@"visible" stringValue:[self isTitleVisible] ? HSXMLStoring1String : HSXMLStoring0String]];
    [aRepresentation addChild:richText];

    NSXMLElement *buttonStyle = [NSXMLElement elementWithName:@"buttonStyle"];
    NSString *type = [[self background] buttonType];
    if (![[self backgroundStyle] isEqualToString:@"HSButtonObjectShapeBackgroundStyle"])
        type = @"HSRectangleSystemButtonType";
    else if (![type isEqualToString:@"HSLassoAreaShapeButtonType"])
        type = @"HSInvisibleShapeButtonType";
    [buttonStyle addAttribute:[NSXMLNode attributeWithName:@"type" stringValue:type]];
    [buttonStyle addAttribute:[NSXMLNode attributeWithName:@"hasHighlight" stringValue:[self hasHighlight] ? HSXMLStoring1String : HSXMLStoring0String]];
    [aRepresentation addChild:buttonStyle];

    NSXMLElement *tint = [NSXMLElement elementWithName:@"tint"];
    id systemBackground = [self queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
    NSColor *tintColor = [[systemBackground tintColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    double red = 0, green = 0, blue = 0, alpha = 1;
    if (tintColor != nil)
    {
        red = [tintColor redComponent];
        green = [tintColor greenComponent];
        blue = [tintColor blueComponent];
        alpha = [tintColor alphaComponent];
    }
    [tint addAttribute:[NSXMLNode attributeWithName:@"color" stringValue:[NSString stringWithFormat:@"%.8f,%.8f,%.8f,%.8f", red, green, blue, alpha]]];
    [tint addAttribute:[NSXMLNode attributeWithName:@"ignore" stringValue:[systemBackground ignoreTintColor] ? HSXMLStoring1String : HSXMLStoring0String]];
    [aRepresentation addChild:tint];

    // The exported images must show the button even when it is hidden in the player.
    BOOL wasHiddenInPlayer = [HSBOData isHiddenInPlayer];
    [HSBOData setHiddenInPlayer:NO];
    NSString *uidString = nil;
    if (![type isEqualToString:@"HSLassoAreaShapeButtonType"])
    {
        uidString = [[self hyperUID] stringValue];
        NSString *name = [[uidString stringByAppendingString:@"_highlighted_button"] stringByAppendingPathExtension:@"png"];
        id highlighted = [aContext convertedMediaForKey:name];
        if (highlighted == nil)
        {
            BOOL wasHighlightActive = [self isSpecialAccessHighlightActive];
            [self setSpecialAccessHighlightActive:YES];
            highlighted = [HSNewMedia mediaWithImage:[self imageForExport] name:name];
            [self setSpecialAccessHighlightActive:wasHighlightActive];
            if (highlighted != nil)
                [aContext setConvertedMedia:highlighted forKey:name];
        }
        if (highlighted != nil)
        {
            [aContext addMedia:highlighted];
            NSXMLElement *element = [NSXMLElement elementWithName:@"highlightedImageMediaRef"];
            [element addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[highlighted mediaUID] stringValue]]];
            [aRepresentation addChild:element];
        }
    }
    [HSBOData setHiddenInPlayer:wasHiddenInPlayer];

    id image;
    if ([self isTitleVisible])
    {
        NSString *name = [[uidString stringByAppendingString:@"_button"] stringByAppendingPathExtension:@"png"];
        image = [aContext convertedMediaForKey:name];
        if (image == nil)
        {
            image = [HSNewMedia mediaWithImage:[self imageForExport] name:name];
            if (image != nil)
                [aContext setConvertedMedia:image forKey:name];
        }
    }
    else
        image = [self media];
    if (image != nil)
    {
        [aContext addMedia:image];
        NSXMLElement *element = [NSXMLElement elementWithName:@"imageMediaRef"];
        [element addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[image mediaUID] stringValue]]];
        [aRepresentation addChild:element];
    }

    if ([type isEqualToString:@"HSLassoAreaShapeButtonType"])
    {
        id borderPath = [[[self background] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] borderPath];
        NSData *data = borderPath != nil ? [borderPath hyperDataForBinaryStoring] : nil;
        if (data != nil)
        {
            id pathMedia = [aContext mediaForPathData:data];
            if (pathMedia == nil)
            {
                NSString *name = [[NSString stringWithFormat:@"%@_vg_borderPath", [[self hyperUID] stringValue]] stringByAppendingPathExtension:@"path"];
                pathMedia = [HSNewMedia mediaWithData:data name:name type:@"path"];
                if (pathMedia != nil)
                    [aContext setPathMedia:pathMedia forData:data];
            }
            if (pathMedia != nil)
            {
                [aContext addMedia:pathMedia];
                NSXMLElement *element = [NSXMLElement elementWithName:@"borderPath"];
                [element addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[pathMedia mediaUID] stringValue]]];
                [aRepresentation addChild:element];
            }
        }
    }
}

- (id)XMLElementName
{
    return @"objButton";
}

- (BOOL)shouldBeExportedAsImage
{
    return YES;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:@"button" forKey:@"type"];
    [dictionary setObject:[self backgroundStyle] forKey:@"style"];
    [dictionary setObject:[[self background] buttonType] forKey:@"buttonType"];
    [dictionary setObject:[self hasHighlight] ? @"1" : @"0" forKey:@"isHighlight"];
    return dictionary;
}

- (BOOL)hasHyperTitle
{
    return [self isTitleVisible];
}

- (NSRect)untransformedTitleRect
{
    NSRect bounds;
    bounds.origin = NSZeroPoint;
    bounds.size = [self size];
    // An empty title has no title rect, so measure a single space instead.
    id title = [[HSBOData title] retain];
    if ([title isEqualToString:@""])
        [HSBOData setTitle:@" "];
    NSButtonCell *cell = [[[[HSBOData systemButtonForGetAccessor] cell] copy] autorelease];
    [cell setImagePosition:[self visualIconPosition]];
    NSRect rect = [cell titleRectForBounds:bounds];
    [HSBOData setTitle:title];
    // Retained across the swap so the original title outlives setTitle:.
    [title release];
    return rect;
}

- (id)queryEditorHitTester
{
    if (![[self backgroundStyle] isEqualToString:@"HSButtonObjectShapeBackgroundStyle"])
        return [super queryEditorHitTester];
    return [[[HSButtonObjectShapeHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSEditorHitTestingVisualization)] autorelease];
}

- (id)queryInteractiveHitTester
{
    if (![[self backgroundStyle] isEqualToString:@"HSButtonObjectShapeBackgroundStyle"])
        return [super queryInteractiveHitTester];
    return [[[HSButtonObjectShapeHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSPlayerHitTestingVisualization)] autorelease];
}

- (id)queryDefaultHitTester
{
    if (![[self backgroundStyle] isEqualToString:@"HSButtonObjectShapeBackgroundStyle"])
        return [super queryDefaultHitTester];
    return [[[HSButtonObjectShapeHitTester alloc] initWithHyperObject:self] autorelease];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:[@"titleColor" extraKeyForMultiRepresentations]];
    [keys addObject:@"hyperUnderlined"];
    [keys addObject:@"hyperOutlineEnabled"];
    [keys addObject:@"hyperOutlineColor"];
    [keys addObject:@"hyperOutlineWidth"];
    [keys addObject:@"opacity"];
    [keys addObject:@"titleVisible"];
    [keys addObject:@"iconVisible"];
    [keys addObject:@"hasHighlight"];
    [keys addObject:[@"backgroundStyleToBackroundDictionary" extraKeyForCollection]];
    [keys addObject:@"backgroundStyle"];
    [keys addObject:@"hyperSpaceBetweenCharacters"];
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
    {
        [keys addObject:@"hyperShadowEnabled"];
        [keys addObject:@"hyperShadowOffsetAsString"];
        [keys addObject:@"hyperShadowBlurRadius"];
    }
    else
    {
        [keys addObject:@"titleShadowEnabled"];
        [keys addObject:@"titleShadowOffsetAsString"];
        [keys addObject:@"titleShadowBlurRadius"];
    }
    return keys;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    if ([[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"])
    {
        [keys addObject:[@"titleColor" extraKeyForMultiRepresentations]];
        [keys addObject:@"hyperUnderlined"];
        [keys addObject:@"hyperOutlineEnabled"];
        [keys addObject:@"hyperOutlineColor"];
        [keys addObject:@"hyperOutlineWidth"];
        [keys addObject:@"hyperShadowEnabled"];
        [keys addObject:@"hyperShadowOffsetAsString"];
        [keys addObject:@"hyperShadowBlurRadius"];
        [keys addObject:@"hyperSpaceBetweenCharacters"];
        [keys addObject:@"opacity"];
    }
    return keys;
}

- (id)queryNewHyperInterface:(id)aInterface
{
    Class visualizationClass = Nil;
    Protocol *visualizationProtocol = aInterface;
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface))
        visualizationClass = [HSButtonObjectVisualization class];
    else if (HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        visualizationClass = [HSButtonObjectEditorVisualization class];
    else if (HSProtocolsAreEqual(@protocol(HSHitTestingVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSPlayerHitTestingVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSEditorHitTestingVisualization), aInterface))
    {
        visualizationClass = [HSButtonObjectEditorVisualization class];
        visualizationProtocol = @protocol(HSEditorVisualization);
    }
    else if (HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface))
        visualizationClass = [HSButtonObjectPlayerVisualization class];
    if (visualizationClass != Nil)
        return [[[visualizationClass alloc] initWithHyperObject:self visualizationProtocol:visualizationProtocol] autorelease];

    // The square and push button attributes of the superclass are hidden.
    if (HSProtocolsAreEqual(@protocol(HSSystemPushButtonAttributes), aInterface) || HSProtocolsAreEqual(@protocol(HSSystemSquareButtonAttributes), aInterface))
        return nil;
    if (HSProtocolsAreEqual(@protocol(HSAttributes), aInterface))
        return [super queryNewHyperInterface:aInterface];
    if (protocol_conformsToProtocol(@protocol(HSButtonObjectSystemStyleBackgroundAttributes), aInterface))
        return [[[self backgroundStyleToBackroundDictionary] objectForKey:@"HSButtonObjectSystemBackgroundStyle"] queryHyperInterface:aInterface];
    if (protocol_conformsToProtocol(@protocol(HSStandaloneMutableSizeAttributes), aInterface))
        return [[[HSMutableSizeAttributesImplementation alloc] initWithNodeStorage:self node:self] autorelease];
    if (protocol_conformsToProtocol(@protocol(HSButtonObjectShapeBackgroundAttributes), aInterface))
        return [[[self backgroundStyleToBackroundDictionary] objectForKey:@"HSButtonObjectShapeBackgroundStyle"] queryHyperInterface:aInterface];
    return [super queryNewHyperInterface:aInterface];
}

- (void)applyHyperTextAttributesDictionary:(id)aDictionary
{
    [HSBOData setCachedAttributedTitle:[[[NSAttributedString alloc] initWithString:[self title] attributes:aDictionary] autorelease]];
}

- (id)hyperTextAttributes
{
    return [[self hyperText] hyperTextAttributesDictionary];
}

- (void)setHyperPlainText:(id)aText
{
    [self setTitle:aText];
}

- (id)hyperPlainText
{
    return [self title];
}

- (void)replaceTextInRange:(NSRange)aRange withAttributedString:(id)aString
{
}

- (void)setHyperText:(id)aText
{
}

- (id)hyperText
{
    if ([HSBOData cachedAttributedTitle] == nil)
        [HSBOData setCachedAttributedTitle:[[[NSAttributedString alloc] initWithString:[self title] attributes:[self titleAttributes]] autorelease]];
    return [HSBOData cachedAttributedTitle];
}

- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter
{
    id attributes = [self titleAttributes];
    id converted = [aConverter convertAttributes:attributes];
    if (attributes == converted)
        return;
    id values = [NSAttributedString hyperAttributeValuesForChangingAttributes:attributes intoAttributes:converted];
    if (values == nil || [values isEmpty])
        return;
    NSEnumerator *names = [values attributeNamesEnumerator];
    id name;
    while ((name = [names nextObject]) != nil)
        [self applyTitleAttributesReplacementValue:[values replacementValueForAttributeName:name] forAttributeName:name];
}

- (void)applyTitleAttributesReplacementValue:(id)aValue forAttributeName:(id)aName
{
    NSDictionary *selectors = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"setTitleColor:", NSForegroundColorAttributeName,
                               @"setTitleFont:", NSFontAttributeName,
                               @"applyUnderlineValue:", NSUnderlineStyleAttributeName,
                               @"applyOutlineWidthAttributeValue:", NSStrokeWidthAttributeName,
                               @"setHyperOutlineColor:", NSStrokeColorAttributeName,
                               @"applyShadowValue:", NSShadowAttributeName, nil];
    NSString *selectorName = [selectors objectForKey:aName];
    if (selectorName != nil)
        [self performSelector:NSSelectorFromString(selectorName) withObject:aValue];
}

- (void)applyUnderlineValue:(id)aValue
{
    [self setHyperUnderlined:[aValue intValue] != 0];
}

- (void)applyShadowValue:(id)aValue
{
    if (aValue == nil)
    {
        [self setHyperShadowEnabled:NO];
        return;
    }
    [self setHyperShadowEnabled:YES];
    [self setHyperShadowOffset:[aValue shadowOffset]];
    [self setHyperShadowBlurRadius:[aValue shadowBlurRadius]];
}

- (id)titleAttributes
{
    // A nil title color truncates the dictionary, as in the original.
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [self titleColor], NSForegroundColorAttributeName,
                                       [self titleFont], NSFontAttributeName,
                                       [NSNumber numberWithBool:[self isHyperUnderlined]], NSUnderlineStyleAttributeName,
                                       [NSNumber numberWithFloat:[self hyperSpaceBetweenCharacters]], NSKernAttributeName, nil];
    if ([self isHyperOutlineEnabled])
        [attributes setObject:[NSNumber numberWithFloat:[self hyperOutlineWidth]] forKey:NSStrokeWidthAttributeName];
    else if ([attributes objectForKey:NSStrokeWidthAttributeName] != nil)
        [attributes removeObjectForKey:NSStrokeWidthAttributeName];
    if ([self hyperOutlineColor] != nil)
        [attributes setObject:[self hyperOutlineColor] forKey:NSStrokeColorAttributeName];
    if ([self isHyperShadowEnabled])
    {
        // The original leaked this shadow.
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        [shadow setShadowOffset:[self hyperShadowOffset]];
        [shadow setShadowBlurRadius:[self hyperShadowBlurRadius]];
        [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0 alpha:0.75f]];
        [attributes setObject:shadow forKey:NSShadowAttributeName];
    }
    else if ([attributes objectForKey:NSShadowAttributeName] != nil)
        [attributes removeObjectForKey:NSShadowAttributeName];
    return attributes;
}

- (void)setBackgroundColor:(id)aColor
{
    [[self queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] setTintColor:aColor];
}

- (id)backgroundColor
{
    return [[self queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] tintColor];
}

- (void)setTextColor:(id)aColor
{
    [self setTitleColor:aColor];
}

- (id)textColor
{
    return [self titleColor];
}

- (void)setHyperSpaceBetweenLines:(CGFloat)aLines
{
}

- (CGFloat)hyperSpaceBetweenLines
{
    return 0;
}

- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters
{
    if (!HSButtonObjectFloatsDiffer([HSBOData hyperSpaceBetweenCharacters], aCharacters))
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Space Between Characters")];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperSpaceBetweenCharacters:[self hyperSpaceBetweenCharacters]];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
    [HSBOData setHyperSpaceBetweenCharacters:aCharacters];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
}

- (CGFloat)hyperSpaceBetweenCharacters
{
    return [HSBOData hyperSpaceBetweenCharacters];
}

- (void)setHyperShadowBlurRadius:(CGFloat)aRadius
{
    [self setTitleShadowBlurRadius:aRadius];
}

- (CGFloat)hyperShadowBlurRadius
{
    return [self titleShadowBlurRadius];
}

- (void)setHyperShadowOffset:(NSSize)aOffset
{
    [self setTitleShadowOffset:aOffset];
}

- (NSSize)hyperShadowOffset
{
    return [self titleShadowOffset];
}

- (void)setHyperShadowDistance:(CGFloat)aDistance
{
    [self setTitleShadowOffset:[NSShadow hyperShadowOffsetWithShadowDistance:aDistance currentOffset:[self titleShadowOffset]]];
}

- (CGFloat)hyperShadowDistance
{
    return [NSShadow hyperShadowDistanceWithShadowOffset:[self titleShadowOffset]];
}

- (void)setHyperShadowAngle:(CGFloat)aAngle
{
    [self setTitleShadowOffset:[NSShadow hyperShadowOffsetWithShadowAngle:aAngle currentOffset:[self titleShadowOffset]]];
}

- (CGFloat)hyperShadowAngle
{
    return [NSShadow hyperNormalizedShadowAngleWithShadowOffset:[self titleShadowOffset]];
}

- (void)setHyperShadowOffsetAsString:(id)aString
{
    [self setTitleShadowOffsetAsString:aString];
}

- (id)hyperShadowOffsetAsString
{
    return [self titleShadowOffsetAsString];
}

- (void)setHyperShadowEnabled:(BOOL)aEnabled
{
    [self setTitleShadowEnabled:aEnabled];
}

- (BOOL)isHyperShadowEnabled
{
    return [self isTitleShadowEnabled];
}

- (BOOL)hasMultipleShadowStyles
{
    return NO;
}

- (void)setHyperAlignment:(NSInteger)aAlignment
{
    if ((NSInteger)[self iconPosition] == aAlignment)
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Icon Position")];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperAlignment:[self iconPosition]];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
    [self setIconPosition:aAlignment];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
}

- (NSInteger)hyperAlignment
{
    return [self iconPosition];
}

- (id)titleStrokeWidth
{
    return [NSNumber numberWithFloat:[self isHyperOutlineEnabled] ? 3.0f : 1.0f];
}

- (void)finishOutlineMutating:(BOOL)aMutating
{
    BOOL enabled = [self isHyperOutlineEnabled];
    CGFloat width = [self hyperOutlineWidth];
    id color = [[[self hyperOutlineColor] copy] autorelease];
    [[self undoManager] disableUndoRegistration];
    [self setHyperOutlineEnabled:_oldIsOutlineEnabled];
    [self setHyperOutlineWidth:_oldOutlineWidth];
    [self setHyperOutlineColor:_oldOutlineColor];
    [[self undoManager] enableUndoRegistration];
    if (!aMutating)
        return;
    [[self undoManager] setMultipleActionsName:HSButtonObjectUndoName(@"Outline Change")];
    [self setHyperOutlineEnabled:enabled];
    [self setHyperOutlineWidth:width];
    [self setHyperOutlineColor:color];
}

- (void)startOutlineMutating
{
    _oldIsOutlineEnabled = [self isHyperOutlineEnabled];
    _oldOutlineWidth = [self hyperOutlineWidth];
    if (_oldOutlineColor != [self hyperOutlineColor])
    {
        [_oldOutlineColor release];
        _oldOutlineColor = [[self hyperOutlineColor] copy];
    }
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth
{
    if (!HSButtonObjectFloatsDiffer([HSBOData hyperOutlineWidth], aWidth))
        return;
    [self setTitleOutlineValue:[NSNumber numberWithFloat:aWidth] undoActionName:HSButtonObjectUndoName(@"Change Title outline width")];
}

- (CGFloat)hyperOutlineWidth
{
    return [HSBOData hyperOutlineWidth];
}

- (void)setHyperOutlineColor:(id)aColor
{
    if ([HSBOData hyperOutlineColor] == aColor)
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Title outline color")];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOutlineColor:[HSBOData hyperOutlineColor]];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
    [HSBOData setHyperOutlineColor:aColor];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
}

- (id)hyperOutlineColor
{
    return [HSBOData hyperOutlineColor];
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled
{
    if ([HSBOData isHyperOutlineEnabled] == aEnabled)
        return;
    NSString *name = HSButtonObjectUndoName(@"Change Title outline");
    [self setTitleOutlineValue:aEnabled ? [NSAttributedString hyperDefaultOutlineValueForEnablingOutline] : nil undoActionName:name];
}

- (void)setTitleOutlineValue:(id)aValue undoActionName:(id)aName
{
    [[self undoManager] setActionName:aName];
    id attributes = [self titleAttributes];
    id cachedWidth = [HSBOData cachedUnusedOutlineWidthValue];
    if (cachedWidth != nil)
    {
        attributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        [attributes setObject:cachedWidth forKey:HSStoredStrokeWidthAttributeName];
    }
    id values = [NSAttributedString hyperAttributeValuesAffectedByApplyingOutlineValue:aValue inDictionary:attributes];
    if (values == nil || [values isEmpty])
    {
        [self applyOutlineWidthAttributeValue:aValue];
        return;
    }
    NSEnumerator *names = [values attributeNamesEnumerator];
    id name;
    while ((name = [names nextObject]) != nil)
        [self applyOutlineAttributesReplacementValue:[values replacementValueForAttributeName:name] forAttributeName:name];
}

- (void)applyOutlineAttributesReplacementValue:(id)aValue forAttributeName:(id)aName
{
    NSDictionary *selectors = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"applyOutlineWidthAttributeValue:", NSStrokeWidthAttributeName,
                               @"setHyperOutlineColor:", NSStrokeColorAttributeName,
                               @"setCachedUnusedOutlineWidthValue:", HSStoredStrokeWidthAttributeName, nil];
    NSString *selectorName = [selectors objectForKey:aName];
    // The original performed a NULL selector for unknown attribute names.
    if (selectorName != nil)
        [self performSelector:NSSelectorFromString(selectorName) withObject:aValue];
}

- (void)applyOutlineWidthAttributeValue:(id)aValue
{
    [self setPrimitiveOutlineEnabled:aValue != nil];
    [self setPrimitiveOutlineWidth:aValue != nil ? [aValue floatValue] : 0];
}

- (void)setCachedUnusedOutlineWidthValue:(id)aValue
{
    if ([HSBOData cachedUnusedOutlineWidthValue] == aValue)
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setCachedUnusedOutlineWidthValue:[HSBOData cachedUnusedOutlineWidthValue]];
    [HSBOData setCachedUnusedOutlineWidthValue:aValue];
}

- (void)setPrimitiveOutlineWidth:(CGFloat)aWidth
{
    if (!HSButtonObjectFloatsDiffer([HSBOData hyperOutlineWidth], aWidth))
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setPrimitiveOutlineWidth:[HSBOData hyperOutlineWidth]];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
    [HSBOData setHyperOutlineWidth:aWidth];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
}

- (void)setPrimitiveOutlineEnabled:(BOOL)aEnabled
{
    if ([HSBOData isHyperOutlineEnabled] == aEnabled)
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setPrimitiveOutlineEnabled:[HSBOData isHyperOutlineEnabled]];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
    [HSBOData setHyperOutlineEnabled:aEnabled];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
}

- (BOOL)isHyperOutlineEnabled
{
    return [HSBOData isHyperOutlineEnabled];
}

- (void)setHyperItalic:(BOOL)aItalic
{
    if ([self isHyperItalic] == aItalic)
        return;
    NSFontManager *manager = [NSFontManager sharedFontManager];
    [self setTitleFont:[manager convertFont:[self titleFont] toHaveTrait:aItalic ? NSItalicFontMask : NSUnitalicFontMask]];
}

- (BOOL)isHyperItalic
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self titleFont]] & NSItalicFontMask) != 0;
}

- (void)setHyperExpanded:(BOOL)aExpanded
{
    if ([self isHyperExpanded] == aExpanded)
        return;
    NSFontManager *manager = [NSFontManager sharedFontManager];
    [self setTitleFont:[manager convertFont:[self titleFont] toHaveTrait:aExpanded ? NSExpandedFontMask : NSCondensedFontMask]];
}

- (BOOL)isHyperExpanded
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self titleFont]] & NSExpandedFontMask) != 0;
}

- (void)setHyperCondensed:(BOOL)aCondensed
{
    if ([self isHyperCondensed] == aCondensed)
        return;
    NSFontManager *manager = [NSFontManager sharedFontManager];
    [self setTitleFont:[manager convertFont:[self titleFont] toHaveTrait:aCondensed ? NSCondensedFontMask : NSExpandedFontMask]];
}

- (BOOL)isHyperCondensed
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self titleFont]] & NSCondensedFontMask) != 0;
}

- (void)setHyperBold:(BOOL)aBold
{
    if ([self isHyperBold] == aBold)
        return;
    NSFontManager *manager = [NSFontManager sharedFontManager];
    [self setTitleFont:[manager convertFont:[self titleFont] toHaveTrait:aBold ? NSBoldFontMask : NSUnboldFontMask]];
}

- (BOOL)isHyperBold
{
    return ([[NSFontManager sharedFontManager] traitsOfFont:[self titleFont]] & NSBoldFontMask) != 0;
}

- (void)setHyperUnderlined:(BOOL)aUnderlined
{
    if ([HSBOData isHyperUnderlined] == aUnderlined)
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Title underline")];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperUnderlined:[HSBOData isHyperUnderlined]];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
    [HSBOData setHyperUnderlined:aUnderlined];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
}

- (BOOL)isHyperUnderlined
{
    return [HSBOData isHyperUnderlined];
}

- (void)setHiddenInEditor:(BOOL)aEditor
{
    if ([self isHiddenInEditor] == aEditor)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectHiddenInEditorAttribute) withUserInfo:nil];
    [HSBOData setHiddenIEditor:aEditor];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectHiddenInEditorAttribute) withUserInfo:nil];
}

- (BOOL)isHiddenInEditor
{
    return [HSBOData isHiddenInEditor];
}

- (void)setHyperOpacity:(CGFloat)aOpacity
{
    [self setOpacity:aOpacity];
}

- (CGFloat)hyperOpacity
{
    return [self opacity];
}

- (BOOL)isButtonNaturallyInvisible
{
    return ![[self background] isVisible];
}

- (BOOL)isButtonInvisible
{
    if ([self isTitleVisible] || [self isIconVisible])
        return NO;
    return ![[self background] isVisible];
}

- (BOOL)isTitleVisibleForButtonType:(id)aType
{
    return [HSBOData isTitleVisibleForButtonType:aType];
}

- (BOOL)hasHighlightForButtonType:(id)aType
{
    return [HSBOData hasHighlightForButtonType:aType];
}

- (void)setHyperBackgroundStyle:(id)aStyle
{
    if ([[self backgroundStyle] isEqualToString:aStyle])
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Button background")];
    [(HSButtonObject *)[[self undoManager] prepareWithInvocationTarget:self] setBackgroundStyle:[HSBOData backgroundStyle]];
    // The visibility changes only when the background is all that shows.
    Protocol *visibility = nil;
    if (![self isTitleVisible] && ![self isIconVisible])
    {
        BOOL wasVisible = [[self background] isVisible];
        BOOL willBeVisible = [[[self backgroundStyleToBackroundDictionary] objectForKey:aStyle] isVisible];
        if (wasVisible != willBeVisible)
            visibility = @protocol(HSButtonObjectVisibilityAttribute);
    }
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSButtonObjectBackgroundStyleAttribute), @protocol(HSSizeAttribute), visibility, nil];
    [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    [HSBOData setBackgroundStyle:aStyle];
    [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
    // Only the did-change half is posted for the hit tester, as in the original.
    [self notifyChange:2 ofAttribute:@protocol(HSUserObjectHitTesterAttribute) withUserInfo:nil];
}

- (void)setBackgroundStyle:(id)aStyle needsResetRotationAngle:(BOOL)aAngle
{
    [self setHyperBackgroundStyle:aStyle];
    if (aAngle)
        [[[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] rotateTo:0 aboutRelativePoint:NSMakePoint(0.5f, 0.5f) withLayoutGuidingContext:nil];
}

- (void)setBackgroundStyle:(id)aStyle
{
    [self setBackgroundStyle:aStyle needsResetRotationAngle:[aStyle isEqualToString:@"HSButtonObjectShapeBackgroundStyle"]];
}

- (id)backgroundStyle
{
    return [HSBOData backgroundStyle];
}

- (id)background
{
    return [HSBOData background];
}

- (void)setBackgroundStyleToBackroundDictionary:(id)aDictionary
{
    if ([[HSBOData backgroundStyleToBackroundDictionary] isHyperIdenticalToDictionary:aDictionary])
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Button background")];
    [[[self undoManager] prepareWithInvocationTarget:self] setBackgroundStyleToBackroundDictionary:[HSBOData backgroundStyleToBackroundDictionary]];
    Protocol *visibility = nil;
    if (![self isTitleVisible] && ![self isIconVisible])
    {
        BOOL wasVisible = [[self background] isVisible];
        BOOL willBeVisible = [[aDictionary objectForKey:[self backgroundStyle]] isVisible];
        if (wasVisible != willBeVisible)
            visibility = @protocol(HSButtonObjectVisibilityAttribute);
    }
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSButtonObjectBackgroundStyleAttribute), @protocol(HSSizeAttribute), visibility, nil];
    [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    [HSBOData setBackgroundStyleToBackroundDictionary:[[[NSMutableDictionary dictionaryWithDictionary:aDictionary] retain] autorelease]];
    [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (id)backgroundStyleToBackroundDictionary
{
    return [HSBOData backgroundStyleToBackroundDictionary];
}

- (void)setHasHighlight:(BOOL)aHighlight
{
    if ([HSBOData hasHighlight] == aHighlight)
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Button highlight")];
    [[[self undoManager] prepareWithInvocationTarget:self] setHasHighlight:[self hasHighlight]];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectHighlightAttribute) withUserInfo:nil];
    [HSBOData setHasHighlight:aHighlight];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectHighlightAttribute) withUserInfo:nil];
}

- (BOOL)hasHighlight
{
    return [HSBOData hasHighlight];
}

- (void)setIconPosition:(NSUInteger)aPosition
{
    [self setImagePosition:aPosition];
}

- (void)setContentOverlapsBackground:(BOOL)aBackground
{
    if ([self contentOverlapsBackground] == aBackground)
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Button content overlaping background")];
    [[[self undoManager] prepareWithInvocationTarget:self] setContentOverlapsBackground:[self contentOverlapsBackground]];
    [self notifyChange:1 ofAttribute:@protocol(HSButonObjectContentOverlapsBackgroundAtrribute) withUserInfo:nil];
    [HSBOData setContentOverlapsBackground:aBackground];
    // The original posts the will-change notification a second time here.
    [self notifyChange:1 ofAttribute:@protocol(HSButonObjectContentOverlapsBackgroundAtrribute) withUserInfo:nil];
}

- (BOOL)contentOverlapsBackground
{
    return [HSBOData contentOverlapsBackground];
}

- (NSUInteger)iconPosition
{
    return [self imagePosition];
}

- (NSUInteger)visualIconPosition
{
    return [HSBOData visualIconPosition];
}

- (void)setIconFromPath:(id)aPath
{
    [self setImageFromPath:aPath];
}

- (void)setIcon:(id)aIcon
{
    [self setImage:aIcon];
}

- (id)icon
{
    return [self image];
}

- (void)setMedia:(id)aMedia
{
    [super setMedia:aMedia];
    [self setIconVisible:YES];
    [self sizeToFitContentWithBounds];
}

- (void)setIconVisible:(BOOL)aVisible
{
    if ([HSBOData isIconVisible] == aVisible)
        return;
    if (aVisible)
    {
        [self linkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) toAttribute:@protocol(HSTitleStringAttribute)];
        [self linkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) toAttribute:@protocol(HSTitleFontAttribute)];
    }
    else
    {
        [self unlinkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) fromAttribute:@protocol(HSTitleStringAttribute)];
        [self unlinkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) fromAttribute:@protocol(HSTitleFontAttribute)];
    }
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Icon visibility")];
    [[[self undoManager] prepareWithInvocationTarget:self] setIconVisible:[self isIconVisible]];
    Protocol *visibility = nil;
    if (![self isTitleVisible] && ![[self background] isVisible])
        visibility = @protocol(HSButtonObjectVisibilityAttribute);
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSButtonObjectIconVisibilityAttribute), visibility, nil];
    [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    [HSBOData setIconVisible:aVisible];
    [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
    if (aVisible)
        [self sizeToFitContentWithBounds];
}

- (BOOL)isIconVisible
{
    return [HSBOData isIconVisible];
}

- (void)setTitleColor:(id)aColor
{
    if ([[HSBOData titleColor] isEqual:aColor])
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Title color")];
    [[[self undoManager] prepareWithInvocationTarget:self] setTitleColor:[self titleColor]];
    [self notifyChange:1 ofAttribute:@protocol(HButtonObjectTitleColorAttribute) withUserInfo:nil];
    [HSBOData setTitleColor:aColor];
    [self notifyChange:2 ofAttribute:@protocol(HButtonObjectTitleColorAttribute) withUserInfo:nil];
}

- (id)titleColor
{
    return [HSBOData titleColor];
}

- (void)setTitleVisible:(BOOL)aVisible
{
    if ([HSBOData isTitleVisible] == aVisible)
        return;
    if (aVisible)
    {
        [self linkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) toAttribute:@protocol(HSTitleStringAttribute)];
        [self linkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) toAttribute:@protocol(HSTitleFontAttribute)];
    }
    else
    {
        [self unlinkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) fromAttribute:@protocol(HSTitleStringAttribute)];
        [self unlinkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) fromAttribute:@protocol(HSTitleFontAttribute)];
    }
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Title visibility")];
    [[[self undoManager] prepareWithInvocationTarget:self] setTitleVisible:[self isTitleVisible]];
    Protocol *visibility = nil;
    if (![self isIconVisible] && ![[self background] isVisible])
        visibility = @protocol(HSButtonObjectVisibilityAttribute);
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSButtonObjectTitleVisibilityAttribute), visibility, nil];
    [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    [HSBOData setTitleVisible:aVisible];
    if ([self media] != nil && ![HSBOData isImageValid])
    {
        [[HSBOData systemButtonForSetAccessor] setImage:[[self media] image]];
        [HSBOData setImageValid:YES];
    }
    [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (BOOL)isTitleVisible
{
    return [HSBOData isTitleVisible];
}

- (void)setTitleShadowBlurRadius:(CGFloat)aRadius
{
    if ([HSBOData titleShadowBlurRadius] == aRadius)
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Title shadow blur radius")];
    [[[self undoManager] prepareWithInvocationTarget:self] setTitleShadowBlurRadius:[self titleShadowBlurRadius]];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
    [HSBOData setTitleShadowBlurRadius:aRadius];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
}

- (CGFloat)titleShadowBlurRadius
{
    return [HSBOData titleShadowBlurRadius];
}

- (void)setTitleShadowOffsetAsString:(id)aString
{
    [self setTitleShadowOffset:NSSizeFromString(aString)];
}

- (id)titleShadowOffsetAsString
{
    return NSStringFromSize([self titleShadowOffset]);
}

- (void)setTitleShadowOffset:(NSSize)aOffset
{
    if (NSEqualSizes([HSBOData titleShadowOffset], aOffset))
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Title shadow offset")];
    [[[self undoManager] prepareWithInvocationTarget:self] setTitleShadowOffset:[self titleShadowOffset]];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
    [HSBOData setTitleShadowOffset:aOffset];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
}

- (NSSize)titleShadowOffset
{
    return [HSBOData titleShadowOffset];
}

- (void)setTitleShadowEnabled:(BOOL)aEnabled
{
    if ([HSBOData isTitleShadowEnabled] == aEnabled)
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Title shadow")];
    [[[self undoManager] prepareWithInvocationTarget:self] setTitleShadowEnabled:[self isTitleShadowEnabled]];
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
    [HSBOData setTitleShadowEnabled:aEnabled];
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectTitleStyleAttribute) withUserInfo:nil];
}

- (BOOL)isTitleShadowEnabled
{
    return [HSBOData isTitleShadowEnabled];
}

- (void)setTitleFont:(id)aFont
{
    if ([[self titleFont] isEqual:aFont])
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Title Font")];
    [[[self undoManager] prepareWithInvocationTarget:self] setTitleFont:[self titleFont]];
    [self notifyChange:1 ofAttribute:@protocol(HSTitleFontAttribute) withUserInfo:nil];
    [HSBOData setCachedAttributedTitle:nil];
    [HSBOData setFont:aFont];
    [self notifyChange:2 ofAttribute:@protocol(HSTitleFontAttribute) withUserInfo:nil];
}

- (void)setTitle:(id)aTitle
{
    if ([[self title] isEqual:aTitle])
        return;
    [HSBOData setCachedAttributedTitle:nil];
    [super setTitle:aTitle];
    if (![self isButtonInvisible])
        [self sizeToFitContentWithBounds];
}

- (void)controlSizeDidChange
{
}

- (void)controlSizeWillChange
{
}

- (CGFloat)additionalHorizontalTitleSpace
{
    id systemBackground = [[self background] queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
    if (![[systemBackground systemButtonType] isEqualTo:@"HSTexturedBackgroundSystemButtonType"])
        return 12.0f;
    return [systemBackground additionalHorizontalTitleSpace];
}

- (void)hyperAutoSizeToFitTitle
{
    [self sizeToFitContentWithBounds];
}

- (void)sizeToFitContentWithBounds
{
    NSSize size = [self size];
    NSSize contentSize = [self contentSize];
    if (size.width < contentSize.width + [self additionalHorizontalTitleSpace] && [self canResizeHorizontally])
        [self hyperSizeToFitContentHorizontally:[self canResizeHorizontally] vertically:NO];
    if (size.height < contentSize.height && [self canResizeVertically])
        [self hyperSizeToFitContentHorizontally:NO vertically:[self canResizeVertically]];
}

- (void)hyperSizeToFitContentHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically
{
    id geometry = [self queryHyperInterface:@protocol(HSMutableGeometryAttributes)];
    if (geometry == nil)
        return;
    NSSize size = [(HSButtonObject *)geometry size];
    NSSize contentSize = [self contentSize];
    if (aHorizontally)
        size.width = contentSize.width + [self additionalHorizontalTitleSpace];
    if (aVertically)
        size.height = contentSize.height;
    [geometry setSize:size aboutRelativePoint:NSMakePoint(0.5f, 0.5f)];
}

- (NSSize)contentSize
{
    return [HSBOData contentSize];
}

- (BOOL)canMoveVertically
{
    return YES;
}

- (BOOL)canMoveHorizontally
{
    return YES;
}

- (BOOL)canRotate
{
    return YES;
}

- (BOOL)canSkew
{
    return NO;
}

- (BOOL)canFlipVertically
{
    return YES;
}

- (BOOL)canFlipHorizontally
{
    return YES;
}

- (BOOL)canScaleVertically
{
    return NO;
}

- (BOOL)canScaleHorizontally
{
    return NO;
}

- (BOOL)canBreakSizeScaleAspectRatio
{
    return NO;
}

- (BOOL)prefersResizingToScaling
{
    return YES;
}

- (BOOL)canResizeVertically
{
    if ([[HSBOData backgroundStyle] isEqualToString:@"HSButtonObjectShapeBackgroundStyle"])
        return [[[[self background] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] shapeButtonType] isEqualTo:@"HSInvisibleShapeButtonType"];
    id systemBackground = [[self background] queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
    if (![[systemBackground systemButtonType] isEqualTo:@"HSTexturedBackgroundSystemButtonType"])
        return YES;
    return [systemBackground canResizeVertically];
}

- (BOOL)canResizeHorizontally
{
    if (![[HSBOData backgroundStyle] isEqualToString:@"HSButtonObjectShapeBackgroundStyle"])
        return YES;
    return [[[[self background] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] shapeButtonType] isEqualTo:@"HSInvisibleShapeButtonType"];
}

- (BOOL)canBreakSizeAspectRatio
{
    return YES;
}

- (void)setOpacity:(CGFloat)aOpacity
{
    if (!HSButtonObjectFloatsDiffer([self hyperOpacity], aOpacity))
        return;
    [[self undoManager] setActionName:HSButtonObjectUndoName(@"Change Button opacity")];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOpacity:[self hyperOpacity]];
    [self notifyChange:1 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
    [HSBOData setOpacity:aOpacity];
    [self notifyChange:2 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
}

- (CGFloat)opacity
{
    return [HSBOData opacity];
}

- (void)setSize:(NSSize)aSize
{
    NSSize size = [self size];
    float widthTolerance = size.width != 0 ? (float)size.width * 0.0001f : FLT_MIN;
    BOOL widthChanged = aSize.width < size.width - widthTolerance || widthTolerance + size.width < aSize.width;
    float heightTolerance = size.height != 0 ? (float)size.height * 0.0001f : FLT_MIN;
    BOOL heightChanged = aSize.height < size.height - heightTolerance || heightTolerance + size.height < aSize.height;
    if (widthChanged)
        [self notifyChange:1 ofAttribute:@protocol(HSWidthAttribute) withUserInfo:nil];
    if (heightChanged)
        [self notifyChange:1 ofAttribute:@protocol(HSHeightAttribute) withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:HSButtonObjectUndoName(@"Change Size")];
    [(HSButtonObject *)[undoManager prepareWithInvocationTarget:self] setSize:size];
    [HSBOData setSize:aSize];
    if (widthChanged)
        [self notifyChange:2 ofAttribute:@protocol(HSWidthAttribute) withUserInfo:nil];
    if (heightChanged)
        [self notifyChange:2 ofAttribute:@protocol(HSHeightAttribute) withUserInfo:nil];
}

- (NSSize)size
{
    return [HSBOData size];
}

- (void)didCreateSystemView
{
    [self linkAttribute:@protocol(HSButtonObjectIconAttribute) toAttribute:@protocol(HSSystemSquareButtonImageAttribute)];
    [self linkAttribute:@protocol(HSButtonObjectIconPositionAttribute) toAttribute:@protocol(HSSystemSquareButtonImagePositionAttribute)];
    [self linkAttribute:@protocol(HSSelectionKnobsProviderAttribute) toAttribute:@protocol(HSButtonObjectBackgroundStyleAttribute)];
    [self linkAttribute:@protocol(HSSelectionKnobsProviderAttribute) toAttribute:@protocol(HSButtonObjectSystemButtonTypeAttribute)];
    [self linkAttribute:@protocol(HSSelectionKnobsProviderAttribute) toAttribute:@protocol(HSButtonObjectShapeButtonTypeAttribute)];
    [self linkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) toAttribute:@protocol(HSTitleStringAttribute)];
    [self linkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) toAttribute:@protocol(HSTitleFontAttribute)];
    [self linkAttribute:@protocol(HSSystemSquareButtonImageRectAttribute) toAttribute:@protocol(HSButtonObjectTitleVisibilityAttribute)];
}

- (void)dealloc
{
    [_oldOutlineColor release];
    [super dealloc];
}

// A borderless cell laying out the icon and the centered title the way the
// button draws them.
- (id)createContentButtonCell
{
    NSButtonCell *cell = [[[NSButtonCell alloc] init] autorelease];
    [cell setBordered:NO];
    [cell setButtonType:NSMomentaryChangeButton];
    if ([self isIconVisible]) {
        [cell setImage:[self image]];
        [cell setImagePosition:[self visualIconPosition]];
    }
    if ([self isTitleVisible]) {
        NSMutableAttributedString *title = [[[self hyperText] mutableCopy] autorelease];
        NSUInteger length = [title length];
        NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [style setAlignment:NSTextAlignmentCenter];
        [title addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, length)];
        [cell setAttributedTitle:title];
    }
    return cell;
}

- (id)XMLIconStyleElementWithButtonCell:(id)aCell
{
    if (![[self backgroundStyle] isEqualToString:@"HSButtonObjectShapeBackgroundStyle"] || aCell == nil)
        return nil;
    NSXMLElement *element = [NSXMLElement elementWithName:@"iconStyle"];
    [element addAttribute:[NSXMLNode attributeWithName:@"visible" stringValue:[self isIconVisible] ? HSXMLStoring1String : HSXMLStoring0String]];
    [element addAttribute:[NSXMLNode attributeWithName:@"position" stringValue:[NSString stringWithFormat:@"%d", (int)[self iconPosition]]]];
    if ([self media] != nil && [self isIconVisible]) {
        NSXMLElement *geometry = [NSXMLElement elementWithName:@"geometry"];
        NSSize size = [self size];
        NSSize cellSize = [aCell cellSize];
        NSRect rect = [aCell imageRectForBounds:NSMakeRect(0, 0, cellSize.width, cellSize.height)];
        CGFloat x = (size.width - cellSize.width) * 0.5 + rect.origin.x;
        CGFloat y = (size.height - cellSize.height) * 0.5 + rect.origin.y;
        [geometry addAttribute:[NSXMLNode attributeWithName:@"origin" stringValue:[NSString stringWithFormat:@"%.0f,%.0f", x, y]]];
        [geometry addAttribute:[NSXMLNode attributeWithName:@"size" stringValue:[NSString stringWithFormat:@"%.0f,%.0f", rect.size.width, rect.size.height]]];
        [element addChild:geometry];
    }
    return element;
}

- (id)XMLTitleStyleElementWithButtonCell:(id)aCell
{
    if (aCell == nil)
        return nil;
    NSXMLElement *element = [NSXMLElement elementWithName:@"titleStyle"];
    [element addAttribute:[NSXMLNode attributeWithName:@"visible" stringValue:[self isTitleVisible] ? HSXMLStoring1String : HSXMLStoring0String]];
    if ([self isTitleVisible]) {
        NSXMLElement *geometry = [NSXMLElement elementWithName:@"geometry"];
        NSSize size = [self size];
        NSSize cellSize = [aCell cellSize];
        NSRect rect = [aCell titleRectForBounds:NSMakeRect(0, 0, cellSize.width, cellSize.height)];
        CGFloat x = (size.width - cellSize.width) * 0.5 + rect.origin.x;
        CGFloat y = (size.height - cellSize.height) * 0.5 + rect.origin.y;
        [geometry addAttribute:[NSXMLNode attributeWithName:@"origin" stringValue:[NSString stringWithFormat:@"%.0f,%.0f", x, y]]];
        [geometry addAttribute:[NSXMLNode attributeWithName:@"size" stringValue:[NSString stringWithFormat:@"%.0f,%.0f", rect.size.width, rect.size.height]]];
        [element addChild:geometry];
    }
    return element;
}

@end
