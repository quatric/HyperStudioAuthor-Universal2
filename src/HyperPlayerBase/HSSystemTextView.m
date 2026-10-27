#import "HSSystemTextView.h"
#import "HyperPlayerBaseData.h"

// The XML text coding category on NSAttributedString is provided by the
// HyperStudio editor, which is the only host that stores or imports XML.
@interface NSAttributedString (HSSystemTextViewXMLText)
+ (id)hyperLoadFromXMLRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)hyperXMLRepresentationInContext:(id)aContext UID:(id)aUID;
@end

@interface NSObject (HSSystemTextViewGeometry)
- (void)resizeFrameTo:(NSSize)aTo aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)rotateBy:(CGFloat)aBy aboutRelativePoint:(NSPoint)aPoint withLayoutGuidingContext:(id)aContext;
- (void)setFlippedVertically:(BOOL)aVertically withLayoutGuidingContext:(id)aContext;
- (void)setAffineTransform:(CGAffineTransform)aTransform;
@end

/* Set while text objects are processed without a window (exports, previews):
   no Cocoa views are created then. */
BOOL HSTextIsViewCreationDisabled = NO;

#define HSSTVData ((HSSystemTextViewData *)[self nodeData])

static NSString *HSSystemTextViewUndoName(NSString *aKey)
{
    return [[NSBundle mainBundle] localizedStringForKey:aKey value:@"" table:@"UndoManager"];
}

/* An alpha is treated as zero within the usual relative tolerance. */
static BOOL HSSystemTextViewAlphaIsZero(CGFloat aAlpha)
{
    float alpha = fabsf((float)aAlpha);
    float magnitude = alpha != 0 ? alpha : 1;
    float tolerance = magnitude >= 1 ? magnitude * 0.0005f : 0.0005f;
    return alpha <= tolerance;
}

static NSSet *sLinkPrefixes;
static NSDictionary *sSchemaByLinkPrefix;
static NSArray *sLinkPrefixesByLength;
static NSCharacterSet *sStartUrlDelimiters;
static NSCharacterSet *sUrlAllowedCharacters;
static NSSet *sTextImplementationInterfaces;

@implementation HSSystemTextView

+ (id)schemaByLowercaseLinkPrefix
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"http://", @"www.", @"ftp://", @"ftp.", nil];
}

+ (id)lowercaseLinkPrefixes
{
    return [NSArray arrayWithObjects:@"www.", @"http://", @"ftp.", @"ftp://", @"file://", @"mailto:", nil];
}

+ (NSUInteger)minimumDetectableLinkLength
{
    return 7;
}

+ (id)textImplementationInterfaces
{
    if (sTextImplementationInterfaces == nil) {
        sTextImplementationInterfaces = [[NSSet alloc] initWithObjects:
                                         [HSProtocolIdentifier identifierForProtocol:@protocol(HSSystemTextViewAttributes)],
                                         [HSProtocolIdentifier identifierForProtocol:@protocol(HSSystemTextViewFontTraitsAttributes)],
                                         [HSProtocolIdentifier identifierForProtocol:@protocol(HSGenericSolidColorAttributes)], nil];
    }
    return sTextImplementationInterfaces;
}

+ (Class)nodeDataClass
{
    return [HSSystemTextViewData class];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"HSSizeNodeUnit", @"Size Unit",
            @"HSGeometryNodeUnit", @"Geometry Unit",
            @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit",
            @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit",
            @"HSShowHideTransitionNodeUnit", @"Transition Unit",
            @"HSHypertextLinksContainerNodeUnit", @"HypertextLinks Container Unit",
            @"HSMutableSnapOptionsNodeUnit", @"Snap Options Unit", nil];
}

+ (id)defaultObject
{
    HSSystemTextView *object = [super defaultObject];
    HSSystemTextViewAttributesSharedProvider *provider = [HSSystemTextViewAttributesSharedProvider systemTextViewAttributesSharedProvider];
    [object setShouldRememberTextStyleAttributes:NO];
    [object setHyperPlainText:@""];
    [object setHyperAlignment:NSTextAlignmentLeft];
    [object setHyperName:[HSUserObjectDefaultAttributesProvider defaultNameForNewlyCreatedTextView]];
    [object setRotatableText:YES];
    // New text objects start with the attributes the user applied last.
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [HSUserObjectDefaultAttributesProvider defaultFontForNewlyCreatedRotatableTextObjects], NSFontAttributeName, nil];
    NSDictionary *shared = [provider sharedSystemTextViewAttributes];
    if (shared != nil) {
        id value;
        if ((value = [shared objectForKey:NSFontAttributeName]) != nil)
            [attributes setObject:value forKey:NSFontAttributeName];
        if ((value = [shared objectForKey:NSUnderlineStyleAttributeName]) != nil)
            [attributes setObject:value forKey:NSUnderlineStyleAttributeName];
        if ((value = [shared objectForKey:NSParagraphStyleAttributeName]) != nil)
            [attributes setObject:value forKey:NSParagraphStyleAttributeName];
        if ((value = [shared objectForKey:NSForegroundColorAttributeName]) != nil)
            [attributes setObject:value forKey:NSForegroundColorAttributeName];
        if ((value = [shared objectForKey:NSShadowAttributeName]) != nil)
            [attributes setObject:value forKey:NSShadowAttributeName];
        else
            [attributes removeObjectForKey:NSShadowAttributeName];
    }
    [object applyHyperTextAttributesDictionary:attributes];
    [attributes release];
    [object setHyperSpaceBetweenCharacters:[provider spaceBetweenCharacters]];
    [object setShouldRememberTextStyleAttributes:YES];
    return object;
}

- (void)rememberTextStyleAttributes
{
    if (!_shouldRememberTextStyleAttributes)
        return;
    HSSystemTextViewAttributesSharedProvider *provider = [HSSystemTextViewAttributesSharedProvider systemTextViewAttributesSharedProvider];
    [provider setSharedSystemTextViewAttributes:[self hyperTextAttributes]];
    [provider setSpaceBetweenCharacters:[self hyperSpaceBetweenCharacters]];
}

- (void)setShouldRememberTextStyleAttributes:(BOOL)aAttributes
{
    _shouldRememberTextStyleAttributes = aAttributes;
}

- (void)importLocalPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importLocalPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    id element = [[aRepresentation elementsForName:@"richText"] extraFirstObject];
    [self setHyperText:[NSAttributedString hyperLoadFromXMLRepresentation:element inContext:aContext]];
}

- (void)importSharedPropertiesFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importSharedPropertiesFromXMLElementRepresentation:aRepresentation inContext:aContext];
    NSXMLElement *behavior = [[aRepresentation elementsForName:@"textBehavior"] extraFirstObject];
    [self setBorderType:[[[behavior attributeForName:@"bordered"] stringValue] hyperBoolValue] ? 1 : 0];
    [self setEditable:[[[behavior attributeForName:@"editable"] stringValue] hyperBoolValue]];
    [self setTransparent:![[[behavior attributeForName:@"drawBackground"] stringValue] hyperBoolValue]];
    [self setScrollable:[[[behavior attributeForName:@"scrollable"] stringValue] hyperBoolValue]];
    [self setRotatableText:[[[behavior attributeForName:@"rotatable"] stringValue] hyperBoolValue]];
    NSArray *components = [[[behavior attributeForName:@"backgroundColor"] stringValue] componentsSeparatedByString:@","];
    if ([components count] > 2) {
        float red = [[components objectAtIndex:0] floatValue];
        float green = [[components objectAtIndex:1] floatValue];
        float blue = [[components objectAtIndex:2] floatValue];
        float alpha = [components count] == 4 ? [[components objectAtIndex:3] floatValue] : 1.0f;
        [self setBackgroundColor:[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha]];
    }
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (void)storeSharedPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeSharedPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    [aRepresentation addChild:[self XMLTextBehaviorElementInContext:aContext]];
}

- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext
{
    [super storeLocalPropertiesInXMLElementRepresentation:aRepresentation context:aContext];
    [aRepresentation addChild:[[self hyperAttributedStringValue] hyperXMLRepresentationInContext:aContext UID:[self hyperUID]]];
}

- (id)XMLTextBehaviorElementInContext:(id)aContext
{
    NSXMLElement *element = [NSXMLElement elementWithName:@"textBehavior"];
    [element addAttribute:[NSXMLNode attributeWithName:@"bordered" stringValue:[self borderType] != 0 ? HSXMLStoring1String : HSXMLStoring0String]];
    [element addAttribute:[NSXMLNode attributeWithName:@"editable" stringValue:[self isEditable] ? HSXMLStoring1String : HSXMLStoring0String]];
    [element addAttribute:[NSXMLNode attributeWithName:@"scrollable" stringValue:[self isScrollable] ? HSXMLStoring1String : HSXMLStoring0String]];
    [element addAttribute:[NSXMLNode attributeWithName:@"rotatable" stringValue:[self isRotatableText] ? HSXMLStoring1String : HSXMLStoring0String]];
    [element addAttribute:[NSXMLNode attributeWithName:@"drawBackground" stringValue:[self isTransparent] ? HSXMLStoring0String : HSXMLStoring1String]];
    NSColor *color = [self backgroundColor];
    if ([[color colorSpaceName] isEqualToString:NSPatternColorSpace]) {
        NSData *data = [[color patternImage] hyperPNGRepresentation];
        HSNewMedia *media = [HSNewMedia mediaWithData:data name:[[HSUID UID] stringValue] type:@"png"];
        [element addAttribute:[NSXMLNode attributeWithName:@"backgroundColorUID" stringValue:[[media mediaUID] stringValue]]];
        [aContext addMedia:media];
    } else {
        NSColor *rgb = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
        double red = 0, green = 0, blue = 0, alpha = 1;
        if (rgb != nil) {
            red = [rgb redComponent];
            green = [rgb greenComponent];
            blue = [rgb blueComponent];
            alpha = [rgb alphaComponent];
        }
        NSString *string = [NSString stringWithFormat:@"%.8f,%.8f,%.8f,%.8f", red, green, blue, alpha];
        [element addAttribute:[NSXMLNode attributeWithName:@"backgroundColor" stringValue:string]];
    }
    return element;
}

- (id)XMLElementName
{
    return @"objText";
}

- (id)imageForHTML5Export
{
    // The image is taken with the text scrolled to its origin.
    CGFloat vertical = [self verticalScrollPosition];
    CGFloat horizontal = [self horizontalScrollPosition];
    [self setVerticalScrollPosition:0];
    [self setHorizontalScrollPosition:0];
    id image = [super imageForHTML5Export];
    [self setVerticalScrollPosition:vertical];
    [self setHorizontalScrollPosition:horizontal];
    return image;
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    NSMutableSet *features = [NSMutableSet setWithSet:[super HTML5UnsupportedFeaturesForDocumentType:aType]];
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    if ([self hasUnsupportedAttribute:NSStrokeWidthAttributeName])
        [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeatureTextObjectOutline" value:@"" table:@"Export"]];
    if ([self isScrollable] && ![self hasNotSolidColorComponentsInString:[self hyperText]])
        [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeatureTextObjectColor" value:@"" table:@"Export"]];
    return features;
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    if ([super hasUnsupportedHTML5FeaturesForDocumentType:aType])
        return YES;
    if ([self hasUnsupportedAttribute:NSStrokeWidthAttributeName])
        return YES;
    if ([self isScrollable])
        return ![self hasNotSolidColorComponentsInString:[self hyperText]];
    return NO;
}

- (BOOL)hasUnsupportedAttribute:(id)aAttribute
{
    NSAttributedString *text = [self hyperText];
    NSUInteger index = 0;
    NSUInteger length = [text length];
    while (length != 0) {
        NSRange range = NSMakeRange(0, 0);
        NSDictionary *attributes = [text attributesAtIndex:index longestEffectiveRange:&range inRange:NSMakeRange(index, length)];
        if ([attributes objectForKey:aAttribute] != nil)
            return YES;
        length -= NSMaxRange(range) - index;
        index = NSMaxRange(range);
    }
    return NO;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [dictionary setObject:@"text" forKey:@"type"];
    if ([self isEmpty]) {
        NSMutableString *css = [NSMutableString stringWithFormat:@"font-family:%@;font-size:%.2fpx;", [self hyperFontFamily], (double)[self hyperFontSize]];
        if ([self isHyperItalic])
            [css appendString:@"font-style:italic;"];
        if ([self isHyperBold])
            [css appendString:@"font-weight:bold;"];
        if ([self isHyperUnderlined])
            [css appendString:@"text-decoration:underline;"];
        NSColor *color = [[self textColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
        if (color != nil)
            [css appendFormat:@"color:%@;opacity:%.2f;", [HSHTML5ExporterHelper HTMLStringWithColor:color], (double)[color alphaComponent]];
        [dictionary setObject:css forKey:@"cssString"];
    }
    NSString *text = [HSHTML5ExporterHelper HTML5StringWithAttributedString:[self hyperTextExtendedWithMandatoryHTMLAttributes]];
    if ([text length] != 0)
        [dictionary setObject:text forKey:@"text"];
    [dictionary setObject:@"0" forKey:@"hasShadow"];
    BOOL asImage = [self willBeExportedAsImage];
    if ([self isRotatableText] && ![self isRotationAngleZero]) {
        [dictionary setObject:@"rotatable" forKey:@"textType"];
        [dictionary setObject:@"0" forKey:@"rotationAngle"];
    } else {
        if ([self isEmpty] && [self isHyperShadowEnabled] && !asImage) {
            [dictionary setObject:@"1" forKey:@"hasShadow"];
            NSSize offset = [self hyperShadowOffset];
            NSDictionary *shadow = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%.1f", (double)offset.width], @"xOffset",
                                    [NSString stringWithFormat:@"%.1f", (double)-offset.height], @"yOffset",
                                    [NSString stringWithFormat:@"%.1f", (double)[self hyperShadowBlurRadius]], @"blur", nil];
            [dictionary setObject:shadow forKey:@"shadow"];
            [shadow release];
        } else {
            [dictionary setObject:@"0" forKey:@"hasShadow"];
        }
        [dictionary setObject:@"scrollable" forKey:@"textType"];
        [dictionary setObject:[self hasVerticalScroller] ? @"1" : @"0" forKey:@"drawScrollBar"];
        [dictionary setObject:[self borderType] != 0 ? @"1" : @"0" forKey:@"drawFrame"];
        [dictionary setObject:[self isScrollable] ? @"1" : @"0" forKey:@"isScrollable"];
        [dictionary setObject:[self isEditable] ? @"0" : @"1" forKey:@"isReadOnly"];
        NSColor *background = [self backgroundColor];
        if ([[background colorSpaceName] isEqualToString:NSPatternColorSpace] && ![self isRotatableText]) {
            HSNewMedia *media = [[HSNewMedia alloc] initWithData:[[background patternImage] hyperPNGRepresentation] name:@"background" type:@"png"];
            [aContext addMedia:media];
            NSString *path = [@"Resources" stringByAppendingPathComponent:[HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media]];
            [dictionary setObject:path forKey:@"background"];
            [media release];
        } else {
            NSString *value = nil;
            if ([background alphaComponent] == 0 || [self isRotatableText])
                value = @"transparent";
            else
                value = [HSHTML5ExporterHelper HTMLStringWithRGBAColor:background];
            if (value != nil)
                [dictionary setObject:value forKey:@"backgroundColor"];
        }
    }
    if (asImage) {
        NSImage *image = [self imageForHTML5Export];
        if (image != nil) {
            NSString *name = [[[self hyperUID] stringValue] stringByAppendingPathExtension:@"png"];
            HSNewMedia *media = [[HSNewMedia alloc] initWithData:[image hyperPNGRepresentation] name:name type:@"png"];
            [aContext addMedia:media];
            NSString *path = [@"Resources" stringByAppendingPathComponent:[HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media]];
            [dictionary setObject:path forKey:@"textImage"];
            [media release];
            NSRect frame = [self affineFrameBoundingRectIncludingShadow];
            [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)frame.origin.x] forKey:@"xCoord"];
            [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)frame.origin.y] forKey:@"yCoord"];
            NSSize size = [image size];
            [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)size.width] forKey:@"xSize"];
            [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)size.height] forKey:@"ySize"];
        }
    } else if ([self isRotatableText]) {
        float width = [[dictionary objectForKey:@"xSize"] floatValue];
        [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)(width + 5)] forKey:@"xSize"];
    }
    [pool release];
    return dictionary;
}

- (id)hyperTextExtendedWithMandatoryHTMLAttributes
{
    return [[self hyperText] hyperAttributedStringByAddingDefaultParagraphLineHeightAttribute];
}

/* Despite its name, this answers YES when every text color is a plain solid
   RGB color. */
- (BOOL)hasNotSolidColorComponentsInString:(id)aString
{
    NSUInteger index = 0;
    NSUInteger length = [aString length];
    while (length != 0) {
        NSRange range = NSMakeRange(0, 0);
        NSDictionary *attributes = [aString attributesAtIndex:index longestEffectiveRange:&range inRange:NSMakeRange(index, length)];
        NSColor *color = [attributes valueForKey:NSForegroundColorAttributeName];
        if (color != nil) {
            if ([color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] == nil)
                return NO;
            if ([NSStringFromClass([color class]) isEqualToString:@"HSGradientColor"])
                return NO;
        }
        length -= NSMaxRange(range) - index;
        index = NSMaxRange(range);
    }
    return YES;
}

- (id)htmlStringFromAttributedString:(id)aString areColorsSolid:(BOOL *)aSolid
{
    NSMutableString *html = [NSMutableString string];
    NSUInteger length = [aString length];
    NSString *string = [aString string];
    if (aSolid != NULL)
        *aSolid = YES;
    NSUInteger index = 0;
    while (length != 0) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        NSMutableString *style = [NSMutableString stringWithString:@"<span style=\""];
        NSRange range = NSMakeRange(0, 0);
        NSDictionary *attributes = [aString attributesAtIndex:index longestEffectiveRange:&range inRange:NSMakeRange(index, length)];
        NSFont *font = [attributes valueForKey:NSFontAttributeName];
        if (font != nil) {
            [style appendFormat:@"font-size:%3.2fpx;", (double)[font pointSize]];
            NSLayoutManager *layoutManager = [NSLayoutManager new];
            CGFloat lineHeight = [layoutManager defaultLineHeightForFont:font];
            [layoutManager release];
            [style appendFormat:@"line-height:%3.2fpx;", (double)lineHeight];
            [style appendFormat:@"font-family:%@, default;", [font familyName]];
            NSFontSymbolicTraits traits = [[font fontDescriptor] symbolicTraits];
            if (traits & NSFontItalicTrait)
                [style appendString:@"font-style:italic;"];
            if (traits & NSFontBoldTrait)
                [style appendString:@"font-weight:bold;"];
            int strikethrough = [[attributes valueForKey:NSStrikethroughStyleAttributeName] intValue];
            int underline = [[attributes valueForKey:NSUnderlineStyleAttributeName] intValue];
            if (underline != 0) {
                [style appendString:@"text-decoration:underline"];
                if (strikethrough != 0)
                    [style appendString:@" line-through"];
                [style appendString:@";"];
            } else if (strikethrough != 0) {
                [style appendString:@"text-decoration:line-through;"];
            }
        }
        NSColor *color = [attributes valueForKey:NSForegroundColorAttributeName];
        if (color != nil) {
            NSColor *rgb = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
            if (rgb == nil) {
                if (aSolid != NULL)
                    *aSolid = NO;
            } else {
                [style appendFormat:@"color:%@;opacity:%.2f;", [HSHTML5ExporterHelper HTMLStringWithColor:rgb], (double)[rgb alphaComponent]];
            }
        }
        NSParagraphStyle *paragraph = [attributes valueForKey:NSParagraphStyleAttributeName];
        if (paragraph != nil) {
            NSString *alignment;
            switch ([paragraph alignment]) {
                case NSTextAlignmentJustified:
                    alignment = @"justify;display: inline-block; width:inherit;";
                    break;
                case NSTextAlignmentCenter:
                    alignment = @"center;display: inline-block; width:inherit;";
                    break;
                case NSTextAlignmentRight:
                    alignment = @"right;display: inline-block; width:inherit;";
                    break;
                default:
                    alignment = @"left;";
                    break;
            }
            [style appendFormat:@"text-align:%@;", alignment];
        }
        NSShadow *shadow = [attributes valueForKey:NSShadowAttributeName];
        if (shadow != nil) {
            NSSize offset = [shadow shadowOffset];
            [style appendFormat:@"text-shadow: %fpx %fpx %fpx %@;", (double)offset.width, (double)-offset.height,
                                (double)[shadow shadowBlurRadius], [HSHTML5ExporterHelper HTMLStringWithRGBAColor:[shadow shadowColor]]];
        }
        id kern = [attributes objectForKey:NSKernAttributeName];
        if (kern != nil)
            [style appendFormat:@"letter-spacing: %fpx;", (double)[kern floatValue]];
        [style appendString:@"\">"];
        NSMutableString *part = [[[string substringWithRange:range] mutableCopy] autorelease];
        [part replaceOccurrencesOfString:@"\n" withString:@"<br>" options:0 range:NSMakeRange(0, [part length])];
        [html appendFormat:@"%@%@</span>", style, part];
        length -= NSMaxRange(range) - index;
        index = NSMaxRange(range);
        [pool release];
    }
    return html;
}

- (BOOL)shouldBeExportedAsImage
{
    return NO;
}

- (BOOL)willBeExportedAsImage
{
    BOOL solid = [self isRotationAngleZero] ? [self hasNotSolidColorComponentsInString:[self hyperText]] : YES;
    if ([self isRotatableText] && ![self isRotationAngleZero])
        return [[self hyperText] length] != 0 || !solid;
    return !solid;
}

- (void)performPrimarySetupOnCard:(id)aCard
{
    [self setVerticalScrollPosition:0];
}

- (void)textView:(id)aView willInsertText:(id)aText
{
    NSString *inserted = aText;
    if (![aText isKindOfClass:[NSString class]])
        inserted = [aText string];
    // Links are only looked for once a delimiter is typed.
    if ([inserted length] < 2 && ![[self startUrlDelimiters] characterIsMember:[inserted characterAtIndex:0]])
        return;
    NSRange selection = [[[aView selectedRanges] objectAtIndex:0] rangeValue];
    NSString *string = [aView string];
    NSUInteger start = selection.location;
    if ([string length] != 0) {
        NSUInteger steps = 0;
        while (steps != selection.location) {
            start--;
            steps++;
            if (![[self urlAllowedCharacters] characterIsMember:[string characterAtIndex:start]])
                break;
        }
    }
    NSUInteger end = NSMaxRange(selection);
    while (end < [string length]) {
        unichar character = [string characterAtIndex:end];
        end++;
        if (![[self urlAllowedCharacters] characterIsMember:character])
            break;
    }
    NSMutableString *result = [NSMutableString stringWithString:string];
    [result replaceCharactersInRange:selection withString:inserted];
    [self checkForHyperLinksInString:result limitRange:NSMakeRange(start, [inserted length] + end - (selection.length + start))];
}

- (void)checkForHyperLinksInString:(id)aString limitRange:(NSRange)aRange
{
    NSRange linkRange = NSMakeRange(NSNotFound, 0);
    NSString *link = [self firstHyperLinkInString:aString range:aRange effectiveRange:&linkRange];
    if ([link length] == 0)
        return;
    NSURL *url = [NSURL URLWithString:link];
    if (url == nil)
        return;
    id container = [[self rootNode] queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)];
    NSString *title = [aString substringWithRange:linkRange];
    if ([container linkWithTitle:title] != nil)
        return;
    id hyperLink = [container addLinkWithTitle:title];
    HSGoToURLAction *action = [HSGoToURLAction new];
    [[action currentAction] setURL:url];
    id event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
    [[hyperLink queryHyperInterface:@protocol(HSActor)] addHyperAction:action forEvent:event];
    [action release];
}

- (id)firstHyperLinkInString:(id)aString range:(NSRange)aRange effectiveRange:(NSRange *)aRange2
{
    NSScanner *scanner = [[[NSScanner alloc] initWithString:aString] autorelease];
    [scanner setCharactersToBeSkipped:nil];
    NSCharacterSet *delimiters = [self startUrlDelimiters];
    NSUInteger location = aRange.location;
    [scanner setScanLocation:location];
    NSUInteger end = NSMaxRange(aRange);
    if (location != 0 && ![delimiters characterIsMember:[aString characterAtIndex:location - 1]]
        && ![delimiters characterIsMember:[aString characterAtIndex:location]]) {
        // Start inside a word: skip to its end.
        [scanner scanUpToCharactersFromSet:delimiters intoString:NULL];
        location = [scanner scanLocation];
    }
    if (location < end && [delimiters characterIsMember:[aString characterAtIndex:location]]) {
        [scanner scanCharactersFromSet:delimiters intoString:NULL];
        location = [scanner scanLocation];
    }
    NSRange linkRange = NSMakeRange(NSNotFound, 0);
    id link = nil;
    while (end - location > 6) {
        linkRange = NSMakeRange(NSNotFound, 0);
        link = [self scanLinkWithScanner:scanner maxRange:end effectiveRange:&linkRange];
        if (link != nil)
            break;
        location = [scanner scanLocation];
        if (end - location > 6) {
            if (![scanner scanUpToCharactersFromSet:delimiters intoString:NULL])
                break;
            location = [scanner scanLocation];
            if (location < end) {
                if (![scanner scanUpToCharactersFromSet:delimiters intoString:NULL])
                    break;
                location = [scanner scanLocation];
            }
        }
    }
    if (link == nil)
        linkRange = NSMakeRange(NSNotFound, 0);
    if (aRange2 != NULL)
        *aRange2 = linkRange;
    return link;
}

- (id)scanLinkWithScanner:(id)aScanner maxRange:(NSUInteger)aRange effectiveRange:(NSRange *)aRange2
{
    NSUInteger location = [aScanner scanLocation];
    NSString *string = [aScanner string];
    NSRange prefix = [self rangeOfLinkPrefixAtIndex:location inString:string maxRange:aRange];
    if (prefix.location == NSNotFound)
        prefix = NSMakeRange(NSNotFound, 0);
    [aScanner setScanLocation:prefix.location + prefix.length];
    [aScanner scanCharactersFromSet:[self urlAllowedCharacters] intoString:NULL];
    NSRange linkRange = NSMakeRange(NSNotFound, 0);
    id link = nil;
    if (prefix.location < [aScanner scanLocation]) {
        NSUInteger linkEnd = [aScanner scanLocation];
        // A link must end the string or be followed by a delimiter, and be
        // longer than the shortest prefix.
        if (linkEnd >= 7
            && (linkEnd == [string length] || [[self startUrlDelimiters] characterIsMember:[string characterAtIndex:linkEnd]])
            && linkEnd - prefix.location >= 7) {
            linkRange = NSMakeRange(prefix.location, linkEnd - prefix.location);
            NSString *text = [string substringWithRange:linkRange];
            NSString *schema = [[self schemaByLinkPrefix] objectForKey:[string substringWithRange:prefix]];
            link = [schema length] != 0 ? [schema stringByAppendingString:text] : text;
        }
    }
    [aScanner scanCharactersFromSet:[self startUrlDelimiters] intoString:NULL];
    if (aRange2 != NULL)
        *aRange2 = linkRange;
    return link;
}

- (NSRange)rangeOfLinkPrefixAtIndex:(NSUInteger)aIndex inString:(id)aString maxRange:(NSUInteger)aRange
{
    NSArray *prefixesByLength = [self linkPrefixesByLength];
    NSUInteger count = [prefixesByLength count];
    for (NSUInteger index = 0; index < count; index++) {
        NSSet *prefixes = [prefixesByLength objectAtIndex:index];
        NSUInteger length = [[prefixes anyObject] length];
        if (aIndex + length >= aRange)
            break;
        if ([prefixes containsObject:[aString substringWithRange:NSMakeRange(aIndex, length)]])
            return NSMakeRange(aIndex, length);
    }
    return NSMakeRange(NSNotFound, 0);
}

- (id)urlAllowedCharacters
{
    if (sUrlAllowedCharacters == nil) {
        NSMutableCharacterSet *set = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
        [set addCharactersInString:@"$-_.+!*'(),;/?:@@=&"];
        sUrlAllowedCharacters = [set copy];
    }
    return sUrlAllowedCharacters;
}

- (id)startUrlDelimiters
{
    if (sStartUrlDelimiters == nil) {
        NSMutableCharacterSet *set = [[[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy] autorelease];
        [set addCharactersInString:@",!`'\"?;:()<>{}[]"];
        sStartUrlDelimiters = [set copy];
    }
    return sStartUrlDelimiters;
}

- (id)linkPrefixesByLength
{
    if (sLinkPrefixesByLength == nil) {
        // Group the prefixes by length, shortest first.
        NSMutableSet *byLength[256];
        memset(byLength, 0, sizeof(byLength));
        NSUInteger longest = 0;
        NSEnumerator *prefixes = [[self linkPrefixes] objectEnumerator];
        NSString *prefix;
        while ((prefix = [prefixes nextObject]) != nil) {
            NSUInteger length = [prefix length];
            if (length > 0xff)
                continue;
            if (byLength[length] == nil)
                byLength[length] = [NSMutableSet set];
            if (length > longest)
                longest = length;
            [byLength[length] addObject:prefix];
        }
        NSMutableArray *groups = [NSMutableArray array];
        for (NSUInteger length = 0; length <= longest; length++) {
            if ([byLength[length] count] != 0)
                [groups addObject:[NSSet setWithSet:byLength[length]]];
        }
        sLinkPrefixesByLength = [[NSArray alloc] initWithArray:groups];
    }
    return sLinkPrefixesByLength;
}

- (id)schemaByLinkPrefix
{
    [self linkPrefixes];
    return sSchemaByLinkPrefix;
}

- (id)linkPrefixes
{
    if (sLinkPrefixes == nil) {
        NSArray *lowercase = [[self class] lowercaseLinkPrefixes];
        NSMutableSet *prefixes = [NSMutableSet set];
        NSMutableDictionary *schemas = [NSMutableDictionary dictionary];
        NSDictionary *lowercaseSchemas = [[self class] schemaByLowercaseLinkPrefix];
        NSUInteger count = [lowercase count];
        for (NSUInteger index = 0; index < count; index++) {
            NSString *prefix = [lowercase objectAtIndex:index];
            if ([prefix length] == 0)
                continue;
            NSString *uppercase = [prefix uppercaseString];
            [prefixes addObject:prefix];
            [prefixes addObject:uppercase];
            id schema = [lowercaseSchemas objectForKey:prefix];
            if (schema != nil) {
                [schemas setObject:schema forKey:prefix];
                [schemas setObject:schema forKey:uppercase];
            }
        }
        sLinkPrefixes = [[NSSet alloc] initWithSet:prefixes];
        sSchemaByLinkPrefix = [[NSDictionary alloc] initWithDictionary:schemas];
    }
    return sLinkPrefixes;
}

- (void)setHyperHeightSetByUser:(BOOL)aUser
{
}

- (BOOL)hyperHeightSetByUser
{
    return YES;
}

- (void)setHyperWidthSetByUser:(BOOL)aUser
{
}

- (BOOL)hyperWidthSetByUser
{
    return YES;
}

- (NSInteger)stickyHorizontalSideForAutoresizing
{
    NSInteger alignment = [_textObject hyperAlignment];
    if (alignment == NSTextAlignmentRight)
        return 2;
    return alignment == NSTextAlignmentCenter ? 4 : 0;
}

- (struct HSTextObjectAutoresizingOptions)hyperAutoresizingOptions
{
    NSSize size = [(id <HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
    struct HSTextObjectAutoresizingOptions options;
    options.f0 = ceilf(size.width);
    options.f1 = size.height;
    options.f2 = NO;
    options.f3 = NO;
    return options;
}

- (void)hyperAutoSizeToFitText
{
}

- (NSInteger)hyperAutoresizingMode
{
    return 3;
}

- (BOOL)canRotate
{
    return [self isRotatableText];
}

- (BOOL)canFlipVertically
{
    return [self isRotatableText];
}

- (BOOL)canFlipHorizontally
{
    return [self isRotatableText];
}

- (BOOL)isRotationAngleZero
{
    id applier = [[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    float angle = [[applier mutableGeometryAttributes] rotationAngle];
    if (angle < -0.0001f || angle > 0.0001f)
        return angle >= 6.2830853f && angle <= 6.2832856f;
    return YES;
}

- (void)setRotatableText:(BOOL)aText autoresizing:(BOOL)aAutoresizing
{
    BOOL rotatable = [self isRotatableText];
    if (rotatable == aText)
        return;
    [[self undoManager] setActionName:HSSystemTextViewUndoName(@"Change Text Object Type")];
    [[[self undoManager] prepareWithInvocationTarget:self] setRotatableText:rotatable autoresizing:aAutoresizing];
    [[self undoManager] disableUndoRegistration];
    [self HSSystemTextView_setRotatableText:aText];
    id applier = [[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (!aText) {
        // Remember the angle so turning rotation back on restores it.
        _rotationAngle = [[applier mutableGeometryAttributes] rotationAngle];
        _enableTemporaryRotating = YES;
        [applier rotateBy:-_rotationAngle aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
        _enableTemporaryRotating = NO;
    } else {
        [applier rotateBy:_rotationAngle aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
    }
    if (aAutoresizing) {
        NSSize size = [(id <HSSizeAttributes>)[applier mutableGeometryAttributes] size];
        NSAttributedString *text = [[self textObject] hyperText];
        if ([text length] == 0) {
            // As in the original, the default text is chosen inversely to the
            // placeholder's.
            NSString *defaultText = [self isRotatableText] ? [HSUserObjectDefaultAttributesProvider defaultTextForNewlyCreatedTextView]
                                                           : [HSUserObjectDefaultAttributesProvider defaultTextForNewlyCreatedRotatableTextObject];
            text = [[[NSTextStorage alloc] initWithString:defaultText attributes:[self hyperTextAttributes]] autorelease];
        }
        if ([text length] != 0) {
            NSSize textSize = [NSTextStorage hyperSizeForTextStorage:text withWidth:size.width fixedWidth:NO];
            NSPoint point = NSZeroPoint;
            NSInteger side = [self stickyHorizontalSideForAutoresizing];
            if (side == 4)
                point.x = 0.5;
            else if (side == 2)
                point.x = 1.0;
            CGFloat scrollerWidth;
            if ([self isScrollable]) {
                scrollerWidth = [NSScroller scrollerWidthForControlSize:[self scrollBarSize]];
                CGFloat width = textSize.width + (scrollerWidth + 2);
                if (width > size.width) {
                    [applier resizeFrameTo:NSMakeSize(width, size.height) aboutRelativePoint:point withLayoutGuidingContext:nil];
                    _isResizedFrame = YES;
                }
            } else if (_isResizedFrame) {
                scrollerWidth = [NSScroller scrollerWidthForControlSize:[self scrollBarSize]];
                [applier resizeFrameTo:NSMakeSize(size.width - (scrollerWidth + 2), size.height) aboutRelativePoint:point withLayoutGuidingContext:nil];
                _isResizedFrame = NO;
            }
        }
    }
    [[self undoManager] enableUndoRegistration];
}

- (void)HSSystemTextView_setRotatableText:(BOOL)aText
{
    [[self undoManager] setActionName:HSSystemTextViewUndoName(@"Change Text Object Type")];
    [[[self undoManager] prepareWithInvocationTarget:self] HSSystemTextView_setRotatableText:[self isRotatableText]];
    NSEMutableProtocolSet *changes = [[NSEMutableProtocolSet alloc] initWithProtocol:@protocol(HSSystemTextViewTypeAttribute)];
    BOOL scrollable = [HSSTVData isScrollable];
    BOOL verticalScroller = [HSSTVData hasVerticalScroller];
    NSUInteger borderType = [HSSTVData borderType];
    BOOL editable = [HSSTVData isEditable];
    BOOL selectable = [HSSTVData isSelectable];
    // Rotatable text hides all of these, so each one that is set changes.
    if (borderType != 0)
        [changes addProtocol:@protocol(HSSystemTextViewBorderTypeAttribute)];
    if (verticalScroller)
        [changes addProtocol:@protocol(HSSystemTextViewVerticalScrollerVisibilityAttribute)];
    if (scrollable)
        [changes addProtocol:@protocol(HSSystemTextViewScrollableAttribute)];
    if (editable)
        [changes addProtocol:@protocol(HSSystemEditableAttribute)];
    if (selectable)
        [changes addProtocol:@protocol(HSSystemTextViewSelectableAttribute)];
    if (!HSSystemTextViewAlphaIsZero([[self backgroundColor] alphaComponent]))
        [changes addProtocol:@protocol(HSBackgroundColorAttribute)];
    [self notifyChange:1 ofAttributeSet:changes withUserInfo:nil];

    BOOL draggable = [self canBeDraggable];
    BOOL resizable = [self canBeResizable];
    BOOL canRotate = [self canBeRotatable];
    NSColor *background = [self backgroundColor];
    [HSSTVData setRotatable:aText];
    if (aText) {
        scrollable = NO;
        editable = NO;
        selectable = NO;
        verticalScroller = NO;
        borderType = 0;
    }
    for (HSSystemTextView *object in [self allGroupTextViewObjects]) {
        id scrollView = [object enclosingScrollViewForSetAccessor];
        id placeholder = [object HSSystemTextView_placeholderSystemView];
        id textView = [object systemTextViewForSetAccessor];
        [textView setRotatableText:aText];
        [scrollView setScrollable:scrollable];
        [scrollView setHasVerticalScroller:verticalScroller];
        [placeholder setHasVerticalScroller:verticalScroller];
        [scrollView setBorderType:borderType];
        [placeholder setBorderType:borderType];
        [textView setEditable:editable];
        [textView setSelectable:selectable];
        [textView setBackgroundColor:aText ? [NSColor clearColor] : background];
    }
    [_placeholderScrollView setScrollable:scrollable];
    [[_placeholderScrollView documentView] setEditable:editable];
    [[_placeholderScrollView documentView] setSelectable:selectable];
    [[self textObject] setBackgroundColor:aText ? [NSColor clearColor] : background];
    [[_placeholderScrollView documentView] setBackgroundColor:aText ? [NSColor clearColor] : background];

    if (draggable != [self canBeDraggable])
        [changes addProtocol:@protocol(HSCardObjectDraggableAttribute)];
    if (resizable != [self canBeResizable])
        [changes addProtocol:@protocol(HSCardObjectResizableAttribute)];
    if (canRotate != [self canBeRotatable])
        [changes addProtocol:@protocol(HSCardObjectRotatableAttribute)];
    if ([self hasVerticalScroller]) {
        id applier = [[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        NSSize size = [(id <HSSizeAttributes>)[applier mutableGeometryAttributes] size];
        NSSize minimum = NSSizeFromString([self hyperSizeMinValue]);
        if (size.height <= minimum.height)
            [applier resizeFrameTo:NSMakeSize(size.width, minimum.height) aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
    }
    [self setVerticalScrollPosition:0];
    id applier = [[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (!aText) {
        _enableTemporaryRotating = YES;
        [applier setFlippedHorizontally:NO withLayoutGuidingContext:nil];
        [applier setFlippedVertically:NO withLayoutGuidingContext:nil];
        _enableTemporaryRotating = NO;
    }
    [self textDidChange:_textObject];
    [self notifyChange:2 ofAttributeSet:changes withUserInfo:nil];
    [changes release];
}

- (void)setRotatableText:(BOOL)aText
{
    [self setRotatableText:aText autoresizing:NO];
}

- (BOOL)isRotatableText
{
    if ([HSSTVData isRotatable])
        return YES;
    return _enableTemporaryRotating;
}

- (void)setScrollsHorizontally:(BOOL)aHorizontally
{
    if ([self scrollsHorizontally] != aHorizontally)
        [[[self systemTextViewArrayForSetAccessor] extraFirstObject] setScrollsHorizontally:aHorizontally];
}

- (BOOL)scrollsHorizontally
{
    return [[[self systemTextViewArrayForSetAccessor] extraFirstObject] scrollsHorizontally];
}

- (void)setScrollable:(BOOL)aScrollable
{
    if ([self isScrollable] == aScrollable)
        return;
    [[self undoManager] setActionName:HSSystemTextViewUndoName(@"Change Scrollable")];
    [[[self undoManager] prepareWithInvocationTarget:self] setScrollable:[self isScrollable]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextViewScrollableAttribute) withUserInfo:nil];
    [HSSTVData setScrollable:aScrollable];
    for (id scrollView in [self enclosingScrollViewArrayForSetAccessor])
        [scrollView setScrollable:aScrollable];
    [_placeholderScrollView setScrollable:aScrollable];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextViewScrollableAttribute) withUserInfo:nil];
}

- (BOOL)isScrollable
{
    if ([self isRotatableText])
        return NO;
    return [HSSTVData isScrollable];
}

- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters
{
    [[self textObject] setHyperSpaceBetweenCharacters:aCharacters];
    [self rememberTextStyleAttributes];
}

- (CGFloat)hyperSpaceBetweenCharacters
{
    return [[self textObject] hyperSpaceBetweenCharacters];
}

- (void)setHyperShadowBlurRadius:(CGFloat)aRadius
{
    [[self textObject] setHyperShadowBlurRadius:aRadius];
    [self rememberTextStyleAttributes];
}

- (CGFloat)hyperShadowBlurRadius
{
    return [[self textObject] hyperShadowBlurRadius];
}

- (void)setHyperShadowOffset:(NSSize)aOffset
{
    [[self textObject] setHyperShadowOffset:aOffset];
    [self rememberTextStyleAttributes];
}

- (NSSize)hyperShadowOffset
{
    return [[self textObject] hyperShadowOffset];
}

- (void)setHyperShadowDistance:(CGFloat)aDistance
{
    [[self textObject] setHyperShadowDistance:aDistance];
    [self rememberTextStyleAttributes];
}

- (CGFloat)hyperShadowDistance
{
    return [[self textObject] hyperShadowDistance];
}

- (void)setHyperShadowAngle:(CGFloat)aAngle
{
    [[self textObject] setHyperShadowAngle:aAngle];
    [self rememberTextStyleAttributes];
}

- (CGFloat)hyperShadowAngle
{
    return [[self textObject] hyperShadowAngle];
}

- (void)setHyperShadowEnabled:(BOOL)aEnabled
{
    [[self textObject] setHyperShadowEnabled:aEnabled];
    [self rememberTextStyleAttributes];
}

- (BOOL)isHyperShadowEnabled
{
    return [[self textObject] isHyperShadowEnabled];
}

- (BOOL)hasMultipleShadowStyles
{
    return [[self textObject] hasMultipleShadowStyles];
}

- (void)setHyperAlignment:(NSInteger)aAlignment
{
    [[self textObject] setHyperAlignment:aAlignment];
    [self rememberTextStyleAttributes];
}

- (NSInteger)hyperAlignment
{
    return [[self textObject] hyperAlignment];
}

- (void)finishOutlineMutating:(BOOL)aMutating
{
    [[self textObject] finishOutlineMutating:aMutating];
}

- (void)startOutlineMutating
{
    [[self textObject] startOutlineMutating];
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth
{
    [[self textObject] setHyperOutlineWidth:aWidth];
}

- (CGFloat)hyperOutlineWidth
{
    return [[self textObject] hyperOutlineWidth];
}

- (void)setHyperOutlineColor:(id)aColor
{
    [[self textObject] setHyperOutlineColor:aColor];
}

- (id)hyperOutlineColor
{
    return [[self textObject] hyperOutlineColor];
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled
{
    [[self textObject] setHyperOutlineEnabled:aEnabled];
}

- (BOOL)isHyperOutlineEnabled
{
    return [[self textObject] isHyperOutlineEnabled];
}

- (void)setHyperItalic:(BOOL)aItalic
{
    [[self textObject] setHyperItalic:aItalic];
    [self rememberTextStyleAttributes];
}

- (BOOL)isHyperItalic
{
    return [[self textObject] isHyperItalic];
}

- (void)setHyperExpanded:(BOOL)aExpanded
{
    [[self textObject] setHyperExpanded:aExpanded];
}

- (BOOL)isHyperExpanded
{
    return [[self textObject] isHyperExpanded];
}

- (void)setHyperCondensed:(BOOL)aCondensed
{
    [[self textObject] setHyperCondensed:aCondensed];
}

- (BOOL)isHyperCondensed
{
    return [[self textObject] isHyperCondensed];
}

- (void)setHyperBold:(BOOL)aBold
{
    [[self textObject] setHyperBold:aBold];
    [self rememberTextStyleAttributes];
}

- (BOOL)isHyperBold
{
    return [[self textObject] isHyperBold];
}

- (void)setHyperUnderlined:(BOOL)aUnderlined
{
    [[self textObject] setHyperUnderlined:aUnderlined];
    [self rememberTextStyleAttributes];
}

- (BOOL)isHyperUnderlined
{
    return [[self textObject] isHyperUnderlined];
}

- (void)setHyperFontSize:(CGFloat)aSize
{
    [[self textObject] setHyperFontSize:aSize];
    [self rememberTextStyleAttributes];
}

- (CGFloat)hyperFontSize
{
    return [[self textObject] hyperFontSize];
}

- (void)setHyperFontFamily:(id)aFamily
{
    [[self textObject] setHyperFontFamily:aFamily];
    [self rememberTextStyleAttributes];
}

- (id)hyperFontFamily
{
    return [[self textObject] hyperFontFamily];
}

- (id)valuesForMDAttribute:(id)aAttribute
{
    if ([aAttribute isEqualToString:(NSString *)kMDItemTextContent]) {
        id string = [self objectString];
        if (string != nil)
            return [[super valuesForMDAttribute:aAttribute] arrayByAddingObject:string];
    }
    return [super valuesForMDAttribute:aAttribute];
}

- (id)supportedMDAttributes
{
    NSMutableArray *attributes = [NSMutableArray arrayWithArray:[super supportedMDAttributes]];
    if (![attributes containsObject:(NSString *)kMDItemTextContent])
        [attributes addObject:(NSString *)kMDItemTextContent];
    return attributes;
}

- (void)replaceObjectString:(id)aString inRanges:(id)aRanges
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:[_textObject hyperText]];
    int count = (int)[aRanges count];
    for (int index = 0; index < count; index++)
        [text replaceCharactersInRange:[[aRanges objectAtIndex:index] rangeValue] withString:aString];
    [_textObject setHyperText:text];
    [text release];
}

- (void)setObjectString:(id)aString
{
    [self setHyperStringValue:aString];
}

- (id)objectString
{
    return [self hyperStringValue];
}

- (id)hyperSizeMinValue
{
    NSString *key = [self hasVerticalScroller] ? @"HSSystemTextViewWithVerticalScrollerSizeMinValue" : @"HSSystemTextViewSizeMinValue";
    return [[HSValueConstraints sharedConstraints] constraintForKey:key];
}

- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter
{
    [[self textObject] applyCharacterAttributesWithAttributesConverter:aConverter];
    [self rememberTextStyleAttributes];
}

- (void)applyFontWithFontConverter:(id)aConverter
{
    [[self textObject] applyFontWithFontConverter:aConverter];
    [self rememberTextStyleAttributes];
}

- (id)fontForSystemFontPanelIsMultiple:(BOOL *)aMultiple
{
    return [[self textObject] fontForSystemFontPanelIsMultiple:aMultiple];
}

- (void)applySystemFontPanelDocumentBackgroundColor:(id)aColor
{
    [self setBackgroundColor:aColor];
}

- (id)hyperTextAttributes
{
    return [[self textObject] hyperTextAttributes];
}

- (void)setHyperFont:(id)aFont
{
    [[self textObject] setHyperFont:aFont];
    [self rememberTextStyleAttributes];
}

- (id)hyperFont
{
    return [[self textObject] hyperFont];
}

- (void)setHyperPlainStringValue:(id)aValue
{
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:aValue];
    [self setHyperText:text];
    [text release];
}

- (void)setHyperAttributedStringValue:(id)aValue
{
    [self setHyperText:aValue];
}

- (id)hyperAttributedStringValue
{
    return [self hyperText];
}

- (void)setHyperStringValue:(id)aValue
{
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:aValue];
    [self setHyperText:text];
    [text release];
}

- (id)hyperStringValue
{
    return [[self textObject] hyperString];
}

- (NSSize)defaultSize
{
    return NSMakeSize(89, 97);
}

- (CGFloat)totalScrollAmountInPixels
{
    BOOL horizontal = [self scrollsHorizontally];
    NSTextView *textView = [self systemTextViewForGetAccessor];
    if (horizontal)
        return [textView bounds].size.width;
    CGFloat height = [textView bounds].size.height;
    return height - [[[[self systemTextViewForGetAccessor] enclosingScrollView] contentView] bounds].size.height;
}

- (CGFloat)heightOfFirstLineFragments:(NSUInteger)aFragments
{
    NSLayoutManager *layoutManager = [[[self systemTextViewArrayForSetAccessor] extraFirstObject] layoutManager];
    NSRange range = NSMakeRange(0, 0);
    NSUInteger glyphCount = [layoutManager numberOfGlyphs];
    NSRect rect = NSZeroRect;
    NSUInteger glyph = 0;
    for (NSUInteger fragment = 0; fragment < aFragments; fragment++) {
        rect = [layoutManager lineFragmentUsedRectForGlyphAtIndex:glyph effectiveRange:&range];
        // As in the original, the next fragment starts one glyph past the
        // end of this one.
        glyph = NSMaxRange(range) + 1;
        if (glyph >= glyphCount)
            break;
    }
    return rect.origin.y + rect.size.height;
}

- (void)setHorizontalScrollPosition:(CGFloat)aPosition
{
    if ([[[self systemTextViewArrayForSetAccessor] extraFirstObject] hyperHorizontalScrollPosition] == aPosition)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextViewHorizontalScrollPostionAttribute) withUserInfo:nil];
    for (id textView in [self systemTextViewArrayForSetAccessor])
        [textView setHorizontalScrollPosition:aPosition];
    [[_placeholderScrollView documentView] setHorizontalScrollPosition:aPosition];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextViewHorizontalScrollPostionAttribute) withUserInfo:nil];
}

- (CGFloat)horizontalScrollPosition
{
    return [[self systemTextViewForGetAccessor] hyperHorizontalScrollPosition];
}

- (void)setSelectedRange:(NSRange)aRange
{
    if (NSEqualRanges([self selectedRange], aRange))
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextViewSelectedRangeAttribute) withUserInfo:nil];
    [[self systemTextViewForSetAccessor] hyperSafeSetSelectedRange:aRange];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextViewSelectedRangeAttribute) withUserInfo:nil];
}

- (NSRange)selectedRange
{
    return [[self systemTextViewForGetAccessor] selectedRange];
}

- (void)setVerticalScrollPosition:(CGFloat)aPosition
{
    float position = 0;
    if (aPosition >= 0)
        position = aPosition > 1 ? 1 : aPosition;
    if (position == (float)[self verticalScrollPosition])
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute) withUserInfo:nil];
    for (id textView in [self systemTextViewArrayForSetAccessor])
        [textView hyperSafeSetScrollPosition:position];
    [[_placeholderScrollView documentView] hyperSafeSetScrollPosition:position];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute) withUserInfo:nil];
}

- (CGFloat)verticalScrollPosition
{
    return [[self systemTextViewForGetAccessor] hyperScrollPosition];
}

- (void)setHyperSpaceBetweenLines:(CGFloat)aLines
{
    [[self textObject] setHyperSpaceBetweenLines:aLines];
}

- (CGFloat)hyperSpaceBetweenLines
{
    return [[self textObject] hyperSpaceBetweenLines];
}

- (void)setHasVerticalScroller:(BOOL)aScroller
{
    if ([self hasVerticalScroller] == aScroller)
        return;
    [[self undoManager] setActionName:HSSystemTextViewUndoName(@"Change Has Vertical Scroller")];
    [[[self undoManager] prepareWithInvocationTarget:self] setHasVerticalScroller:[self hasVerticalScroller]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextViewVerticalScrollerVisibilityAttribute) withUserInfo:nil];
    [HSSTVData setHasVerticalScroller:aScroller];
    for (HSSystemTextView *object in [self allGroupTextViewObjects]) {
        [[object enclosingScrollViewForSetAccessor] setHasVerticalScroller:aScroller];
        [[object HSSystemTextView_placeholderSystemView] setHasVerticalScroller:aScroller];
    }
    if (aScroller) {
        id applier = [[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        NSSize size = [(id <HSSizeAttributes>)[applier mutableGeometryAttributes] size];
        NSSize minimum = NSSizeFromString([self hyperSizeMinValue]);
        if (size.height <= minimum.height)
            [applier resizeFrameTo:NSMakeSize(size.width, minimum.height) aboutRelativePoint:NSZeroPoint withLayoutGuidingContext:nil];
    }
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextViewVerticalScrollerVisibilityAttribute) withUserInfo:nil];
}

- (BOOL)hasVerticalScroller
{
    if ([self isRotatableText])
        return NO;
    return [HSSTVData hasVerticalScroller];
}

- (void)setEditable:(BOOL)aEditable setByUser:(BOOL)aUser
{
    [self setEditableAndSelectable:aEditable];
}

- (void)setEditable:(BOOL)aEditable
{
    if ([self isEditable] != aEditable)
        [self setEditable:aEditable setByUser:NO];
}

- (BOOL)isEditable
{
    if ([self isRotatableText])
        return NO;
    return [HSSTVData isEditable];
}

- (void)setSelectable:(BOOL)aSelectable
{
    // As in the original, asking for a selectable but not editable text
    // turns both off: the two always change together.
    if (aSelectable && ![self isEditable])
        [self setEditableAndSelectable:NO];
    else
        [self setEditableAndSelectable:aSelectable];
}

- (BOOL)isSelectable
{
    if ([self isRotatableText])
        return NO;
    return [HSSTVData isSelectable];
}

- (void)setEditableAndSelectable:(BOOL)aSelectable
{
    BOOL editable = [self isEditable];
    BOOL selectable = [self isSelectable];
    if (editable == aSelectable && selectable == aSelectable)
        return;
    BOOL draggable = [self canBeDraggable];
    BOOL resizable = [self canBeResizable];
    BOOL rotatable = [self canBeRotatable];
    [[self undoManager] setActionName:HSSystemTextViewUndoName(@"Change Editabling")];
    [[[self undoManager] prepareWithInvocationTarget:self] setEditableAndSelectable:editable];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemEditableAttribute) withUserInfo:nil];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextViewSelectableAttribute) withUserInfo:nil];
    [HSSTVData setSelectable:aSelectable];
    [HSSTVData setEditable:aSelectable];
    for (id textView in [self systemTextViewArrayForSetAccessor]) {
        [textView setEditable:aSelectable];
        [textView setSelectable:aSelectable];
    }
    id placeholder = [_placeholderScrollView documentView];
    [placeholder setEditable:aSelectable];
    [placeholder setSelectable:aSelectable];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextViewSelectableAttribute) withUserInfo:nil];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemEditableAttribute) withUserInfo:nil];
    if (draggable != [self canBeDraggable])
        [self notifyChange:2 ofAttribute:@protocol(HSCardObjectDraggableAttribute) withUserInfo:nil];
    if (resizable != [self canBeResizable])
        [self notifyChange:2 ofAttribute:@protocol(HSCardObjectResizableAttribute) withUserInfo:nil];
    if (rotatable != [self canBeRotatable])
        [self notifyChange:2 ofAttribute:@protocol(HSCardObjectRotatableAttribute) withUserInfo:nil];
}

/* Text that can be edited or selected takes the mouse, so it cannot be
   dragged, resized or rotated. */
- (BOOL)canBeDraggable
{
    if ([super canBeDraggable] && ![self isEditable])
        return ![self isSelectable];
    return NO;
}

- (BOOL)canBeResizable
{
    if ([super canBeResizable] && ![self isEditable])
        return ![self isSelectable];
    return NO;
}

- (BOOL)canBeRotatable
{
    if ([super canBeRotatable] && ![self isEditable])
        return ![self isSelectable];
    return NO;
}

- (void)setIsEmpty:(BOOL)aEmpty
{
    _isEmpty = aEmpty;
}

- (BOOL)isEmpty
{
    return _isEmpty;
}

- (void)setHyperTextAttributes:(id)aAttributes
{
    if ([[self hyperText] length] != 0 && ![self isEmpty])
        return;
    [self applyHyperTextAttributesDictionary:aAttributes];
}

- (void)applyHyperTextAttributesDictionary:(id)aDictionary
{
    [self notifyChange:1 ofAttribute:@protocol(HSBaseTextAttribute) withUserInfo:nil];
    [[self textObject] applyHyperTextAttributesDictionary:aDictionary];
    [self notifyChange:2 ofAttribute:@protocol(HSBaseTextAttribute) withUserInfo:nil];
}

- (void)setHyperTextFilePath:(id)aPath
{
    if (_path == aPath)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
    [self setTextFilePath:aPath];
    [self notifyChange:2 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
}

- (void)setTextFilePath:(id)aPath
{
    [_path autorelease];
    _path = [aPath retain];
    NSAttributedString *text = nil;
    if (_path != nil && [[NSFileManager defaultManager] fileExistsAtPath:_path]
        && [[NSFileManager defaultManager] hyperIsReadableFileAtPath:_path showAlert:YES error:NULL])
        text = [[[NSAttributedString alloc] initWithPath:_path documentAttributes:NULL] autorelease];
    if (text == nil)
        text = [[[NSAttributedString alloc] initWithString:@""] autorelease];
    // Recolor the text and pass it through RTF to normalize its attributes.
    text = [text hyperAttributedStringByApplyingColor:[self textColor]];
    NSData *rtf = [text RTFFromRange:NSMakeRange(0, [text length]) documentAttributes:@{}];
    text = [[[NSAttributedString alloc] initWithRTF:rtf documentAttributes:NULL] autorelease];
    if (text != nil)
        [self setHyperText:text];
}

- (id)hyperTextFilePath
{
    return _path;
}

- (void)setHyperScrollBarControlSize:(NSUInteger)aSize
{
    if ([self scrollBarSize] == aSize)
        return;
    [[self undoManager] setActionName:HSSystemTextViewUndoName(@"Change Scrollbar Size")];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperScrollBarControlSize:[self scrollBarSize]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextViewScrollBarControlSizeAttribute) withUserInfo:nil];
    [self setScrollBarSize:aSize];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextViewScrollBarControlSizeAttribute) withUserInfo:nil];
}

- (NSUInteger)hyperScrollBarControlSize
{
    return [self scrollBarSize];
}

- (void)setBorderType:(NSUInteger)aType
{
    if ([self borderType] == aType)
        return;
    [[self undoManager] setActionName:HSSystemTextViewUndoName(@"Change Border Type")];
    [[[self undoManager] prepareWithInvocationTarget:self] setBorderType:[self borderType]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTextViewBorderTypeAttribute) withUserInfo:nil];
    [HSSTVData setBorderType:aType];
    for (HSSystemTextView *object in [self allGroupTextViewObjects]) {
        [[object enclosingScrollViewForSetAccessor] setBorderType:aType];
        [[object HSSystemTextView_placeholderSystemView] setBorderType:aType];
    }
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTextViewBorderTypeAttribute) withUserInfo:nil];
}

- (NSUInteger)borderType
{
    if ([self isRotatableText])
        return 0;
    return [HSSTVData borderType];
}

- (id)placeholderSystemTextView
{
    return [[self HSSystemTextView_placeholderSystemView] documentView];
}

- (id)systemTextView
{
    return [self systemTextViewForGetAccessor];
}

- (void)setHyperPlainText:(id)aText
{
    [[self textObject] setHyperPlainText:aText];
    [self userObjectNameBaseTemplateDidChange];
    if (aText != nil)
        [self checkForHyperLinksInString:aText limitRange:NSMakeRange(0, [aText length])];
}

- (id)hyperPlainText
{
    return [[self textObject] hyperPlainText];
}

- (void)replaceTextInRange:(NSRange)aRange withAttributedString:(id)aString
{
    [[self textObject] replaceTextInRange:aRange withAttributedString:aString];
}

- (void)setHyperText:(id)aText
{
    NSDictionary *attributes = [[self hyperTextAttributes] copy];
    if ([aText isHyperEmpty] && ![attributes isEqual:[NSAttributedString hyperNullAttributes]]) {
        // Empty text keeps the current typing attributes.
        [[self textObject] setHyperText:aText];
        [self applyHyperTextAttributesDictionary:attributes];
    } else {
        id text = [[aText mutableCopy] autorelease];
        if ([[self delegate] respondsToSelector:@selector(stringOfPermittedLengthFromString:)])
            text = [[self delegate] stringOfPermittedLengthFromString:text];
        if (text != nil)
            [[self textObject] setHyperText:text];
    }
    [attributes release];
    [self setIsEmpty:[aText length] == 0];
    if (aText != nil)
        [self checkForHyperLinksInString:[aText string] limitRange:NSMakeRange(0, [aText length])];
}

- (id)hyperText
{
    return [[self textObject] hyperText];
}

- (void)setBackgroundColor:(id)aColor
{
    if ([[self backgroundColor] isEqual:aColor])
        return;
    [[[self undoManager] prepareWithInvocationTarget:self] setBackgroundColor:[self backgroundColor]];
    if (aColor == nil)
        aColor = [[NSColor whiteColor] colorWithAlphaComponent:0.57];
    [self notifyChange:1 ofAttribute:@protocol(HSBackgroundColorAttribute) withUserInfoInvocation:nil];
    [HSSTVData setBackgroundColor:aColor];
    [[self textObject] setBackgroundColor:aColor];
    for (id textView in [self systemTextViewArrayForSetAccessor])
        [textView setBackgroundColor:aColor];
    [[_placeholderScrollView documentView] setBackgroundColor:aColor];
    [self notifyChange:2 ofAttribute:@protocol(HSBackgroundColorAttribute) withUserInfoInvocation:nil];
}

- (id)backgroundColor
{
    return [HSSTVData backgroundColor];
}

- (void)setTransparent:(BOOL)aTransparent
{
    if ([self isTransparent] == aTransparent)
        return;
    [[self undoManager] setActionName:HSSystemTextViewUndoName(@"Setting Background Color")];
    [[[self undoManager] prepareWithInvocationTarget:self] setTransparent:[self isTransparent]];
    [self notifyChange:1 ofAttribute:@protocol(HSSystemTransparencyAttribute) withUserInfo:nil];
    // The opaque color is kept so turning transparency off brings it back.
    NSColor *color = _backgroundColor;
    if (aTransparent) {
        if (_backgroundColor != [self backgroundColor]) {
            [_backgroundColor release];
            _backgroundColor = [[self backgroundColor] retain];
        }
        color = [NSColor clearColor];
    }
    [self setBackgroundColor:color];
    [self notifyChange:2 ofAttribute:@protocol(HSSystemTransparencyAttribute) withUserInfo:nil];
}

- (BOOL)isTransparent
{
    if ([self isRotatableText])
        return YES;
    return HSSystemTextViewAlphaIsZero([[self backgroundColor] alphaComponent]);
}

- (void)setHyperDroppedSolidColor:(id)aColor
{
    [self setBackgroundColor:aColor];
}

- (void)setHyperSolidColor:(id)aColor
{
    [self setTextColor:aColor];
}

- (id)hyperSolidColor
{
    return [self textColor];
}

- (void)setTextColor:(id)aColor
{
    [self notifyChange:1 ofAttribute:@protocol(HSTextColorAttribute) withUserInfo:nil];
    [[self textObject] setTextColor:aColor];
    [self notifyChange:2 ofAttribute:@protocol(HSTextColorAttribute) withUserInfo:nil];
    [self rememberTextStyleAttributes];
}

- (id)textColor
{
    return [[self textObject] textColor];
}

- (id)queryNewHyperInterface:(id)aInterface
{
    BOOL drawPlaceholder;
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface))
        drawPlaceholder = NO;
    else if (HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface) || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface))
        drawPlaceholder = YES;
    else
        return [super queryNewHyperInterface:aInterface];
    return [[[HSSystemTextViewVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface drawPlaceholderView:drawPlaceholder] autorelease];
}

- (void)setScrollBarSize:(NSUInteger)aSize
{
    [HSSTVData setScrollBarSize:aSize];
    for (id scrollView in [self enclosingScrollViewArrayForSetAccessor])
        [[scrollView verticalScroller] setControlSize:aSize];
    [[_placeholderScrollView verticalScroller] setControlSize:aSize];
}

- (NSUInteger)scrollBarSize
{
    return [HSSTVData scrollBarSize];
}

- (id)nameBaseTemplates
{
    return [NSArray arrayWithObjects:[self hyperName], nil];
}

- (void)setFont:(id)aFont
{
    [[self textObject] setHyperFont:aFont];
    [self rememberTextStyleAttributes];
}

- (id)font
{
    return [[self textObject] font];
}

- (id)queryTextViewObjectHitTester
{
    return [self queryDefaultHitTester];
}

- (id)queryInteractivePlayerItem
{
    return [[[HSInteractiveTextViewObject alloc] initWithNode:self] autorelease];
}

- (id)systemTextViewArrayForSetAccessor
{
    NSMutableArray *textViews = nil;
    for (id scrollView in [self enclosingScrollViewArrayForSetAccessor]) {
        id textView = [scrollView documentView];
        if (textView == nil)
            continue;
        if (textViews == nil)
            textViews = [NSMutableArray arrayWithCapacity:1];
        [textViews addObject:textView];
    }
    return textViews;
}

- (id)systemTextViewForSetAccessor
{
    return [[[self viewManager] systemViewForSetAccessor] documentView];
}

- (id)systemTextViewForGetAccessor
{
    return [[self enclosingScrollViewForGetAccessor] documentView];
}

- (id)enclosingScrollViewArrayForSetAccessor
{
    NSMutableArray *scrollViews = nil;
    for (HSSystemTextView *object in [self allGroupTextViewObjects]) {
        id scrollView = [[object viewManager] systemViewForSetAccessor];
        if (scrollView == nil)
            continue;
        if (scrollViews == nil)
            scrollViews = [NSMutableArray arrayWithCapacity:1];
        [scrollViews addObject:scrollView];
    }
    return scrollViews;
}

- (id)enclosingScrollViewForSetAccessor
{
    return [[self viewManager] systemViewForSetAccessor];
}

- (id)enclosingScrollViewForGetAccessor
{
    return [[self viewManager] systemViewForGetAccessor];
}

- (id)allGroupTextViewObjects
{
    // Every text object sharing this one's node data shows the same text.
    NSArray *objects = [[HSSTVData owner] objectsWithNodeDataUID:[HSSTVData nodeDataUID]];
    if (![objects containsObject:self])
        objects = [objects arrayByAddingObject:self];
    return objects;
}

- (void)removeDuplicateHyperSystemView:(id)aView
{
    [[self viewManager] removeDuplicateHyperSystemView:aView];
}

- (id)addDuplicateHyperSystemView
{
    return [[self viewManager] addDuplicateHyperSystemView];
}

- (id)placeholderSystemView
{
    return [self HSSystemTextView_placeholderSystemView];
}

- (id)hyperSystemView
{
    return [[self viewManager] hyperSystemView];
}

- (id)duplicatedViewForSystemManager:(id)aManager
{
    NSScrollView *scrollView = [self HSSystemTextView_systemViewCreatingIfNeeded:YES];
    NSScrollView *duplicate = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:scrollView]];
    id textView = [scrollView documentView];
    id duplicateTextView = [duplicate documentView];
    [duplicateTextView setFrame:[textView frame]];
    [duplicateTextView setBounds:[textView bounds]];
    [duplicateTextView setScrollsHorizontally:[textView scrollsHorizontally]];
    [duplicateTextView setHorizontalScrollPosition:[textView hyperHorizontalScrollPosition]];
    return duplicate;
}

- (id)systemViewManager:(id)aManager viewCreateIfNeeded:(BOOL)aNeeded
{
    return [self HSSystemTextView_systemViewCreatingIfNeeded:aNeeded];
}

- (id)viewManager
{
    if (_viewManager == nil) {
        _viewManager = [HSSystemViewManager new];
        [_viewManager setDelegate:self];
    }
    return _viewManager;
}

- (void)textDidChange:(id)aChange
{
    NSAttributedString *text = [_textObject hyperText];
    if (text != nil) {
        id textView = [self systemTextViewForSetAccessor];
        if ([textView isHyperProxy]) {
            for (id view in [textView allHyperInterfaces])
                [self HSSystemTextView_synchonizeTextOfSystemTextView:view withText:text];
        } else {
            [self HSSystemTextView_synchonizeTextOfSystemTextView:textView withText:text];
        }
    }
    // The placeholder shows only while the text is empty.
    if (_placeholderScrollView != nil) {
        if ([text length] == 0) {
            [self HSSystemTextView_synchonizeTextOfSystemPlaceholderTextView];
        } else {
            [_placeholderScrollView release];
            _placeholderScrollView = nil;
        }
    }
}

- (id)HSSystemTextView_systemViewCreatingIfNeeded:(BOOL)aNeeded
{
    if (!HSTextIsViewCreationDisabled && _scrollView == nil && aNeeded) {
        NSAttributedString *text = [[self textObject] hyperText];
        _scrollView = [self HSSystemTextView_createEnclosingScrollView];
        [_scrollView setPostsFrameChangedNotifications:YES];
        [self HSSystemTextView_systemViewSynchronize];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(systemViewFrameDidChange:) name:NSViewFrameDidChangeNotification object:_scrollView];
        [center addObserver:self selector:@selector(systemViewDidScroll:) name:NSViewBoundsDidChangeNotification object:[_scrollView contentView]];
        [center addObserver:self selector:@selector(textViewDidStartScrolling:) name:@"HSScrollWheelDidStartScrollingNotification" object:_scrollView];
        [center addObserver:self selector:@selector(textViewDidEndScrolling:) name:@"HSScrollWheelDidEndScrollingNotification" object:_scrollView];
        if (_scrollView != nil && text != nil)
            [self HSSystemTextView_synchonizeTextOfSystemTextView:[_scrollView documentView] withText:text];
        _oldBounds = NSZeroRect;
    }
    return _scrollView;
}

- (void)textViewDidEndScrolling:(id)aScrolling
{
    [[[self hyperObject] attributeObservingController] endContinuousChangeOfAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute)];
}

- (void)textViewDidStartScrolling:(id)aScrolling
{
    [[[self hyperObject] attributeObservingController] beginContinuousChangeOfAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute)];
}

- (void)systemViewDidScroll:(id)aScroll
{
    NSRect bounds = [[aScroll object] bounds];
    if (!NSEqualRects(bounds, _oldBounds)) {
        [self notifyChange:1 ofAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute) withUserInfo:nil];
        [self notifyChange:2 ofAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute) withUserInfo:nil];
        _oldBounds = bounds;
    }
}

- (void)systemViewFrameDidChange:(id)aChange
{
    // Asking for the last glyph's location lays the text out for the new
    // frame.
    NSLayoutManager *layoutManager = [[_scrollView documentView] layoutManager];
    NSUInteger count = [layoutManager numberOfGlyphs];
    if (count != 0)
        [layoutManager locationForGlyphAtIndex:count - 1];
}

- (id)HSSystemTextView_placeholderSystemView
{
    if (HSTextIsViewCreationDisabled || _placeholderScrollView != nil)
        return _placeholderScrollView;
    if ([[[self textObject] hyperText] length] != 0)
        return _placeholderScrollView;
    _placeholderScrollView = [self HSSystemTextView_createEnclosingScrollView];
    if (_placeholderScrollView != nil) {
        // The placeholder mirrors the look of the real text view.
        NSScrollView *scrollView = [self enclosingScrollViewForGetAccessor];
        id textView = [scrollView documentView];
        [[_placeholderScrollView verticalScroller] setControlSize:[[scrollView verticalScroller] controlSize]];
        [_placeholderScrollView setBorderType:[scrollView borderType]];
        [_placeholderScrollView setHasVerticalScroller:[scrollView hasVerticalScroller]];
        [_placeholderScrollView setScrollable:[(HSScrollView *)scrollView isScrollable]];
        id placeholder = [_placeholderScrollView documentView];
        [placeholder setBackgroundColor:[textView backgroundColor]];
        [placeholder setEditable:[textView isEditable]];
        [placeholder setSelectable:[textView isSelectable]];
        [placeholder hyperSafeSetScrollPosition:[textView hyperScrollPosition]];
        [placeholder setHorizontalScrollPosition:[textView hyperHorizontalScrollPosition]];
        [self HSSystemTextView_synchonizeTextOfSystemPlaceholderTextView];
    }
    return _placeholderScrollView;
}

- (void)HSSystemTextView_synchonizeTextOfSystemPlaceholderTextView
{
    NSString *string = [self isRotatableText] ? [HSUserObjectDefaultAttributesProvider defaultTextForNewlyCreatedRotatableTextObject]
                                              : [HSUserObjectDefaultAttributesProvider defaultTextForNewlyCreatedTextView];
    NSDictionary *attributes = [[self textObject] hyperTextAttributes];
    if (string == nil)
        string = @" ";
    NSAttributedString *text = [[[NSAttributedString alloc] initWithString:string attributes:attributes] autorelease];
    if (text == nil)
        text = [[[NSAttributedString alloc] initWithString:@" "] autorelease];
    [self HSSystemTextView_synchonizeTextOfSystemTextView:[_placeholderScrollView documentView] withText:text];
}

- (void)HSSystemTextView_synchonizeTextOfSystemTextView:(id)aView withText:(id)aText
{
    NSTextStorage *storage = [aView textStorage];
    if (![storage isEqualToAttributedString:aText])
        [storage setAttributedString:aText];
    // Laying out the last line keeps the view's size current.
    NSLayoutManager *layoutManager = [aView layoutManager];
    NSUInteger count = [layoutManager numberOfGlyphs];
    if (count != 0)
        [layoutManager lineFragmentRectForGlyphAtIndex:count - 1 effectiveRange:NULL];
    // Empty text, or the single space standing for it, types with the
    // object's attributes.
    if ([aText length] == 0 || [[aText string] isEqualToString:@" "])
        [aView setTypingAttributes:[self hyperTextAttributes]];
}

- (id)HSSystemTextView_createEnclosingScrollView
{
    NSScrollView *scrollView = [HSVisualSystemViewLoader cocoaViewWithNibName:@"VisualSystemTextView"];
    if (scrollView == nil)
        return nil;
    [scrollView setDrawsBackground:NO];
    [scrollView setScrollerStyle:NSScrollerStyleLegacy];
    NSDictionary *classes = [NSDictionary dictionaryWithObjectsAndKeys:
                             [HSClipView class], [NSClipView class],
                             [HSScroller class], [NSScroller class],
                             [HSLayoutManager class], [NSLayoutManager class], nil];
    return [[HSSystemViewManager duplicateObject:scrollView withSubstituteClasses:classes] retain];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    NSDictionary *representation = aRepresentation;
    id rotatable = [aRepresentation objectForKey:@"rotatable"];
    if (rotatable != nil) {
        [self setRotatableText:[rotatable boolValue]];
        NSMutableDictionary *copy = [aRepresentation mutableCopy];
        [copy removeObjectForKey:@"rotatable"];
        representation = [copy autorelease];
    }
    [super loadExtraDictionaryRepresentation:representation withCodingContext:aContext];
    [self removeJustifyAlignmentFromAppleChanceryFont];
    if ([representation objectForKey:HSLocalNodeDataKey] == nil) {
        // Old documents keep the shared values at the top level.
        NSMutableDictionary *shared = [NSMutableDictionary dictionary];
        for (NSString *key in [self oldFormatKeysForExtraLoading]) {
            id value = [representation objectForKey:key];
            if (value != nil)
                [shared setObject:value forKey:key];
        }
        [[self nodeData] loadExtraDictionaryRepresentation:shared withCodingContext:[EXCodingContext defaultCodingContext]];
    }
    [self HSSystemTextView_systemViewSynchronize];
}

- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    HSSystemTextView *object = [super initWithExtraDictionary:aDictionary codingContext:aContext];
    [object setShouldRememberTextStyleAttributes:NO];
    // Snap the stored translation to whole points.
    id applier = [[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    CGAffineTransform transform = [[applier mutableGeometryAttributes] affineTransform];
    transform.tx = roundf(transform.tx);
    transform.ty = roundf(transform.ty);
    [[applier mutableGeometryAttributes] setAffineTransform:transform];
    if ([aDictionary objectForKey:@"isEmpty"] == nil && [[object hyperText] length] != 0)
        [object setIsEmpty:YES];
    [object setShouldRememberTextStyleAttributes:YES];
    return object;
}

- (void)HSSystemTextView_systemViewSynchronize
{
    if (_scrollView == nil)
        return;
    [_scrollView setBorderType:[self borderType]];
    [_scrollView setHasVerticalScroller:[self hasVerticalScroller]];
    [[_scrollView documentView] setSelectable:[self isSelectable]];
    [[_scrollView documentView] setEditable:[self isEditable]];
    [[_scrollView verticalScroller] setControlSize:[self scrollBarSize]];
    [_scrollView setScrollable:[self isScrollable]];
    [[_scrollView documentView] setBackgroundColor:[self backgroundColor]];
    [[_scrollView documentView] setRotatableText:[self isRotatableText]];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"textColor"];
    [keys addObject:@"rotatable"];
    [keys addObject:@"borderType"];
    [keys addObject:@"hasVerticalScroller"];
    [keys addObject:@"scrollable"];
    [keys addObject:@"editable"];
    [keys addObject:@"backgroundColor"];
    return keys;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"hyperText"];
    [keys addObject:@"isEmpty"];
    [keys addObject:[@"hyperTextAttributes" extraKeyForCollection]];
    return keys;
}

- (id)oldFormatKeysForExtraLoading
{
    return [NSArray arrayWithObjects:@"selectable", @"scrollBarSize", nil];
}

- (void)removeJustifyAlignmentFromAppleChanceryFont
{
    if ([[self hyperFontFamily] isEqualToString:@"Apple Chancery"] && [self hyperAlignment] == NSTextAlignmentJustified)
        [self setHyperAlignment:NSTextAlignmentLeft];
}

- (void)postProcessAfterCreationFromGroupObject:(id)aObject
{
    // Give the copy its own text storage.
    NSAttributedString *text = [[[[aObject textObject] hyperText] copy] autorelease];
    [[self textObject] setHyperText:text];
}

- (void)dealloc
{
    [_path release];
    [_textObject setOwner:nil];
    [_textObject release];
    [_placeholderScrollView release];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NSViewFrameDidChangeNotification object:_scrollView];
    [center removeObserver:self name:NSViewBoundsDidChangeNotification object:[_scrollView contentView]];
    [center removeObserver:self name:@"HSScrollWheelDidStartScrollingNotification" object:_scrollView];
    [center removeObserver:self name:@"HSScrollWheelDidEndScrollingNotification" object:_scrollView];
    [_scrollView release];
    [_viewManager setDelegate:nil];
    [_viewManager release];
    [_backgroundColor release];
    [super dealloc];
}

- (BOOL)isHyperEqual:(id)aEqual
{
    BOOL equal = [super isHyperEqual:aEqual];
    if ([self isEmpty])
        return equal && [aEqual isEmpty];
    if (!equal || ![[self hyperText] isEqualToAttributedString:[aEqual hyperText]])
        return NO;
    return [[self hyperTextAttributes] isEqualToDictionary:[aEqual hyperTextAttributes]];
}

- (id)extraInit
{
    // A copy made from a peer is set up from the peer's dictionary instead.
    if (_tempPeer == nil)
        [self init];
    return self;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _isEmpty = YES;
        [self setShouldRememberTextStyleAttributes:NO];
        [super linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute)];
        [super linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextViewHorizontalScrollPostionAttribute)];
        [super linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSBaseTextAttribute)];
        [super linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextViewBorderTypeAttribute)];
        [super linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextViewScrollBarControlSizeAttribute)];
        [super linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextViewSelectableAttribute)];
        [super linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextViewVerticalScrollerVisibilityAttribute)];
        [super linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextViewBorderTypeAttribute)];
        [super linkAttribute:@protocol(HSSystemViewAttribute) toAttribute:@protocol(HSSystemTextViewSelectedRangeAttribute)];
        [super linkAttribute:@protocol(HSSelectionKnobsProviderAttribute) toAttribute:@protocol(HSSystemTextViewTypeAttribute)];
        [self setShouldRememberTextStyleAttributes:YES];
    }
    return self;
}

- (id)initWithExplicitNodeDataProvider:(id)aProvider sharedNodeDataUID:(id)aUID
{
    HSSystemTextView *object = [super initWithExplicitNodeDataProvider:aProvider sharedNodeDataUID:aUID];
    [object setShouldRememberTextStyleAttributes:NO];
    // Take the extra values from another object sharing the node data.
    NSEnumerator *peers = [[aProvider objectsWithNodeDataUID:aUID] objectEnumerator];
    _tempPeer = nil;
    while ((_tempPeer = [peers nextObject]) == self)
        ;
    if (_tempPeer != nil) {
        [self initWithExtraDictionary:[_tempPeer extraDictionaryRepresentation]];
        _tempPeer = nil;
    }
    [object setShouldRememberTextStyleAttributes:YES];
    return object;
}

- (id)textObject
{
    if (_textObject == nil)
        _textObject = [[HSText alloc] initWithOwner:self];
    return _textObject;
}

@end
