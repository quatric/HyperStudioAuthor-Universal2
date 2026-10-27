#import "HSShapeObject.h"
#import "HSColor.h"
#import "HSGradientColor.h"
#import "HSMediaFileWrapper.h"
#import "HSNewMediaAccessor.h"
#import "HSProtocolIdentifier.h"
#import "HSUID.h"
#import "HSVectorGraphics.h"
#import "HSVectorGraphicsObjectData.h"
#import "HSVectorGraphicsObjectVisualization.h"
#import "HSHitTestingVectorGraphicsObjectVisualization.h"
#import "HSMutableSizeAttributesImplementation.h"
#import "HSVisualHitTester.h"
#import "HSiPadExportContext.h"
#import "NSAffineTransform+HSKeyValueCoding.h"
#import "NSBezierPath+HSBinarySerialization.h"

// A vector graphics object (line, curve or shape): the vector graphics with
// its stroke lives in the node data's vg, the fill is the background
// graphics (shapes only).

@implementation HSVectorGraphicsObject

+ (Class)concreteClassForBezierPath:(id)aPath
{
    return self;
}

+ (id)backgroundAttributesSerializationKey
{
    return @"backgroundGraphics";
}

+ (Class)nodeDataClass
{
    return [HSVectorGraphicsObjectData class];
}

+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        @"HSGeometryNodeUnit", @"Geometry Unit",
        @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit",
        @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit",
        @"HSShowHideTransitionNodeUnit", @"Transition Unit",
        @"HSMutableSnapOptionsNodeUnit", @"Snap Options Unit",
        nil];
}

// The vectorGrpahicsSettings element (sic): line width, outline color
// (gradient, texture media or "r,g,b[,a]"), fill color and border path media.
// Quirk kept: super's import isn't called.
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id settings = [[aRepresentation elementsForName:@"vectorGrpahicsSettings"] extraFirstObject];
    if (settings != nil) {
        [[self vg] setHyperLineWidth:[[[settings attributeForName:@"lineWidth"] stringValue] floatValue]];
        id outline = [[settings elementsForName:@"outlineColor"] extraFirstObject];
        if (outline != nil) {
            id color = nil;
            id gradient = [[outline elementsForName:@"gradientColor"] extraFirstObject];
            if (gradient != nil) {
                HSColor *hsColor = [[HSColor alloc] init];
                [hsColor importFromXMLElementRepresentation:gradient inContext:aContext];
                color = [HSGradientColor gradientColorWithHSColor:hsColor];
                [hsColor release];
            } else {
                id texture = [[outline elementsForName:@"textureMediaRef"] extraFirstObject];
                if (texture != nil) {
                    id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[HSUID UIDWithString:[[texture attributeForName:HSXMLStoringRefIdString] stringValue]]];
                    NSImage *image = [[NSImage alloc] initWithData:[media mediaData]];
                    if (image != nil)
                        color = [NSColor colorWithPatternImage:image];
                    [image release];
                } else {
                    NSArray *components = [[[outline attributeForName:@"color"] stringValue] componentsSeparatedByString:@","];
                    if ([components count] > 2) {
                        CGFloat red = [[components objectAtIndex:0] floatValue];
                        CGFloat green = [[components objectAtIndex:1] floatValue];
                        CGFloat blue = [[components objectAtIndex:2] floatValue];
                        CGFloat alpha = ([components count] == 4) ? [[components objectAtIndex:3] floatValue] : 1.0;
                        color = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
                    }
                }
            }
            [[self vg] setHyperStrokeColor:color];
        }
        id fill = [[settings elementsForName:@"fillColor"] extraFirstObject];
        if (fill != nil) {
            HSColor *hsColor = [HSColor new];
            [hsColor importFromXMLElementRepresentation:[[fill elementsForName:[hsColor XMLElementName]] extraFirstObject] inContext:aContext];
            [self setBackgroundGraphics:[hsColor queryHyperInterface:@protocol(HSGraphics)]];
            [hsColor release];
        }
        id border = [[settings elementsForName:@"borderPath"] extraFirstObject];
        if (border != nil) {
            HSUID *uid = [HSUID UIDWithString:[[border attributeForName:HSXMLStoringRefIdString] stringValue]];
            if (uid != nil) {
                NSData *data = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid] mediaData];
                if (data != nil)
                    [self setBezierPath:[NSBezierPath hyperBezierPathWithBinaryStoredData:data]];
            }
        }
    }
    [pool release];
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSXMLElement *settings = [NSXMLElement elementWithName:@"vectorGrpahicsSettings"];
    id strokeColor = [[self vg] hyperStrokeColor];
    if (strokeColor != nil) {
        NSXMLElement *outline = [NSXMLElement elementWithName:@"outlineColor"];
        if ([strokeColor isKindOfClass:[HSGradientColor class]]) {
            id hsColor = [strokeColor hyperHSColor];
            if ([hsColor canBeStoredAsXMLElement]) {
                id colorElement = [hsColor XMLElementRepresentationInContext:aContext];
                if ([[colorElement attributes] count] != 0)
                    [outline addChild:colorElement];
            }
        } else if ([[strokeColor colorSpaceName] isEqualToString:NSPatternColorSpace]) {
            NSImage *image = [[strokeColor colorUsingColorSpaceName:NSPatternColorSpace] patternImage];
            if (image != nil) {
                NSString *key = [[[[self hyperUID] stringValue] stringByAppendingString:@"_textureImage"] stringByAppendingPathExtension:@"png"];
                id media = [aContext convertedMediaForKey:key];
                if (media == nil) {
                    media = [HSNewMedia mediaWithData:[image hyperPNGRepresentation] name:key type:@"png"];
                    if (media != nil)
                        [aContext setConvertedMedia:media forKey:key];
                }
                if (media != nil) {
                    [aContext addMedia:media];
                    NSXMLElement *texture = [NSXMLElement elementWithName:@"textureMediaRef"];
                    [texture addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[media mediaUID] stringValue]]];
                    [outline addChild:texture];
                }
            }
        } else {
            NSColor *rgbColor = [strokeColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
            CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 1.0;
            if (rgbColor != nil) {
                red = [rgbColor redComponent];
                green = [rgbColor greenComponent];
                blue = [rgbColor blueComponent];
                alpha = [rgbColor alphaComponent];
            }
            [outline addAttribute:[NSXMLNode attributeWithName:@"color" stringValue:[NSString stringWithFormat:@"%.8f,%.8f,%.8f,%.8f", red, green, blue, alpha]]];
        }
        if ([outline childCount] != 0 || [[outline attributes] count] != 0)
            [settings addChild:outline];
    }
    [settings addAttribute:[NSXMLNode attributeWithName:@"lineWidth" stringValue:[NSString stringWithFormat:@"%.1f", (double)[[self vg] hyperLineWidth]]]];
    id background = [self backgroundGraphics];
    if ([background isKindOfClass:[HSColor class]] && background != nil && [background canBeStoredAsXMLElement]) {
        NSXMLElement *fill = [NSXMLElement elementWithName:@"fillColor"];
        id colorElement = [background XMLElementRepresentationInContext:aContext];
        if ([[colorElement attributes] count] != 0) {
            [fill addChild:colorElement];
            [settings addChild:fill];
        }
    }
    if ([self bezierPath] != nil) {
        NSData *data = [[self bezierPath] hyperDataForBinaryStoring];
        if (data != nil) {
            id media = [aContext mediaForPathData:data];
            if (media == nil) {
                NSString *name = [[NSString stringWithFormat:@"%@_vg_borderPath", [[self hyperUID] stringValue]] stringByAppendingPathExtension:@"path"];
                media = [HSNewMedia mediaWithData:data name:name type:@"path"];
                if (media != nil)
                    [aContext setPathMedia:media forData:data];
            }
            if (media != nil) {
                [aContext addMedia:media];
                NSXMLElement *border = [NSXMLElement elementWithName:@"borderPath"];
                [border addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[[media mediaUID] stringValue]]];
                [settings addChild:border];
            }
        }
    }
    [element addChild:settings];
    [pool release];
    return element;
}

- (NSRect)boundsForXMLStoring
{
    return [self boundsForIPadExport];
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)shouldBeExportedAsImage
{
    return YES;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (id)queryVectorGraphicObjectHitTester
{
    return [self queryDefaultHitTester];
}

- (id)queryEditorHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSEditorHitTestingVisualization)] autorelease];
}

- (id)queryInteractiveHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self visualizationProtocol:@protocol(HSPlayerHitTestingVisualization)] autorelease];
}

- (id)queryDefaultHitTester
{
    return [[[HSVisualHitTester alloc] initWithHyperObject:self] autorelease];
}

- (NSRect)backgroundBounds
{
    NSRect bounds;
    bounds.origin = NSZeroPoint;
    bounds.size = [(HSVectorGraphics *)[self vg] size];
    return bounds;
}

// The background drawn into the path's bounds scaled to fit the size and
// clipped by the path; cached in the node data until the size changes.
- (id)hyperBackgroundThumbnailForSize:(NSSize)aSize
{
    NSImage *thumbnail = [[self nodeData] backgroundThumbnail];
    if (thumbnail == nil || !NSEqualSizes([thumbnail size], aSize)) {
        NSBezierPath *path = [[self queryHyperInterface:@protocol(HSVectorGraphicsAttributes)] hyperBezierPath];
        NSRect bounds = [path bounds];
        CGFloat scaleY = aSize.height / bounds.size.height;
        CGFloat scaleX = aSize.width / bounds.size.width;
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:-((bounds.size.width - aSize.width) * 0.5 + bounds.origin.x) yBy:-((bounds.size.height - aSize.height) * 0.5 + bounds.origin.y)];
        CGFloat scale = MIN(scaleX, scaleY);
        [transform hyperPostscaleBy:NSMakeSize(scale, scale) aboutPoint:NSMakePoint(NSZeroPoint.x + aSize.width * 0.5, NSZeroPoint.y + aSize.height * 0.5)];
        [[self nodeData] setBackgroundThumbnail:[[[NSImage alloc] initWithSize:aSize] autorelease]];
        [[[self nodeData] backgroundThumbnail] lockFocus];
        [transform concat];
        [path addClip];
        [self hyperDrawBackgroundInROI:bounds ofBounds:bounds];
        [[[self nodeData] backgroundThumbnail] unlockFocus];
    }
    return [[self nodeData] backgroundThumbnail];
}

- (void)setHyperBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject
{
    [self setBackgroundGraphics:aGraphics copyObject:aObject];
}

- (void)setBackgroundThumbnail:(id)aThumbnail
{
    if ([[self nodeData] backgroundThumbnail] != aThumbnail)
        [[self nodeData] setBackgroundThumbnail:aThumbnail];
}

- (id)backgroundThumbnail
{
    return [[self nodeData] backgroundThumbnail];
}

- (void)_setBackgroundGraphics:(id)aGraphics
{
    if ([[self nodeData] backgroundGraphics] != aGraphics)
        [self setBackgroundThumbnail:nil];
    if ([self isInDocument])
        [[[self nodeData] backgroundGraphics] willRemoveFromDocument];
    [[self nodeData] setBackgroundGraphics:aGraphics];
    if ([self isInDocument])
        [[[self nodeData] backgroundGraphics] didAddToDocument];
}

- (id)backgroundGraphics
{
    return [[self nodeData] backgroundGraphics];
}

- (void)setHyperDroppedSolidColor:(id)aColor
{
    [self setHyperSolidColor:aColor];
}

// A shape also takes the color as its fill (a gradient's settings are copied
// into the fill color); the color always becomes the stroke color.
- (void)setHyperSolidColor:(id)aColor
{
    if ([[self vg] isHyperShape]) {
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Stroke and Fill Color" value:@"" table:@"UndoManager"]];
        id fill = [self queryBackgroundGraphicsInterface:@protocol(HSMutableColor)];
        id color = [aColor queryHyperInterface:@protocol(HSMutableColor)];
        if (color == nil)
            [fill setHyperSolidColor:aColor];
        else {
            [fill setHyperClear:[color isHyperClear]];
            [fill setHyperKind:[color hyperKind]];
            [fill setHyperCacheEnabled:[color isHyperCacheEnabled]];
            [fill setHyperStartColor:[color hyperStartColor]];
            [fill setHyperEndColor:[color hyperEndColor]];
            [fill setHyperAngle:[color hyperAngle]];
            // Quirk kept: the original passes the center x for both coordinates.
            [fill setHyperCenterX:[color hyperCenterX] andY:[color hyperCenterX]];
        }
    }
    [[self vg] setHyperStrokeColor:aColor];
}

- (void)setHyperOpacity:(CGFloat)aOpacity
{
    float opacity = [self hyperOpacity];
    float newOpacity = aOpacity;
    float magnitude = (opacity != 0.0f) ? fabsf(opacity) : 1.0f;
    float newMagnitude = (newOpacity != 0.0f) ? fabsf(newOpacity) : 1.0f;
    if (newMagnitude <= magnitude)
        newMagnitude = magnitude;
    if (newMagnitude * 0.0005f < fabsf(opacity - newOpacity)) {
        [self notifyChange:1 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Opacity" value:@"" table:@"UndoManager"]];
        [[[self undoManager] prepareWithInvocationTarget:self] setHyperOpacity:[self hyperOpacity]];
        [self setOpacity:aOpacity];
        [self notifyChange:2 ofAttribute:@protocol(HSOpacityAttribute) withUserInfo:nil];
    }
}

// A shape filled with a solid color shows that color, others their stroke
// color.
- (id)hyperSolidColor
{
    if ([[self vg] isHyperShape]) {
        id fill = [[self backgroundGraphics] queryHyperInterface:@protocol(HSMutableColor)];
        if (fill != nil && [fill isHyperSolid]) {
            id color = [fill hyperSolidColor];
            if (color != nil)
                return color;
        }
    }
    return [[self vg] hyperStrokeColor];
}

- (CGFloat)hyperOpacity
{
    return [(HSVectorGraphicsObjectData *)[self nodeData] opacity];
}

- (id)hyperTailEnding
{
    return [self tailEnding];
}

- (id)hyperHeadEnding
{
    return [self headEnding];
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

- (void)setVg:(id)aVg
{
    if ([self vg] != aVg)
        [[self nodeData] setVg:aVg];
}

- (id)vg
{
    return [[self nodeData] vg];
}

- (id)tailEnding
{
    return [[self nodeData] tailEnding];
}

- (id)headEnding
{
    return [[self nodeData] headEnding];
}

- (void)appendVectorGraphicsObject:(id)aObject
{
}

- (void)setTailEnding:(id)aEnding
{
    if ([[self nodeData] tailEnding] != aEnding)
        [[self nodeData] setTailEnding:aEnding];
}

- (void)setHeadEnding:(id)aEnding
{
    if ([[self nodeData] headEnding] != aEnding)
        [[self nodeData] setHeadEnding:aEnding];
}

- (void)setSizeAsString:(id)aString
{
    [self setSize:NSSizeFromString(aString)];
}

- (id)sizeAsString
{
    return NSStringFromSize([self size]);
}

// Undoable; a dimension changes when it moves by more than 1/10000 of itself.
- (void)setSize:(NSSize)aSize
{
    HSVectorGraphics *vg = [self vg];
    NSSize size = [vg size];
    float width = size.width, height = size.height;
    float tolerance = (width != 0.0f) ? width * 0.0001f : FLT_MIN;
    BOOL widthChanged = aSize.width < width - tolerance || width + tolerance < aSize.width;
    tolerance = (height != 0.0f) ? height * 0.0001f : FLT_MIN;
    BOOL heightChanged = aSize.height < height - tolerance || height + tolerance < aSize.height;
    if (!widthChanged && !heightChanged)
        return;
    if (widthChanged)
        [self notifyChange:1 ofAttribute:@protocol(HSWidthAttribute) withUserInfo:nil];
    if (heightChanged)
        [self notifyChange:1 ofAttribute:@protocol(HSHeightAttribute) withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Size" value:@"" table:@"UndoManager"]];
    [(HSVectorGraphicsObject *)[undoManager prepareWithInvocationTarget:self] setSize:size];
    [vg setSize:aSize];
    if (widthChanged)
        [self notifyChange:2 ofAttribute:@protocol(HSWidthAttribute) withUserInfo:nil];
    if (heightChanged)
        [self notifyChange:2 ofAttribute:@protocol(HSHeightAttribute) withUserInfo:nil];
}

- (NSSize)size
{
    return [(HSVectorGraphics *)[self vg] size];
}

- (void)setObjectKindName:(id)aName
{
    if (![[[self nodeData] objectKindName] isEqualToString:aName]) {
        [[self nodeData] setObjectKindName:[[aName copy] autorelease]];
        [self userObjectNameBaseTemplateDidChange];
    }
}

- (id)objectKindName
{
    return [[self nodeData] objectKindName];
}

- (id)nonLocalizedObjectKindKey
{
    return [[self nodeData] objectKindName];
}

- (void)loadObjectStyleDictionaryRepresentation:(id)aRepresentation
{
    [self notifyChange:1 ofAttribute:@protocol(HSSelectionKnobsProviderAttribute) withUserInfo:nil];
    [super loadObjectStyleDictionaryRepresentation:aRepresentation];
    [self notifyChange:2 ofAttribute:@protocol(HSSelectionKnobsProviderAttribute) withUserInfo:nil];
}

- (void)setStrokeColor:(id)aColor
{
    [[self vg] setStrokeColor:aColor];
}

- (id)strokeColor
{
    return [[self vg] valueForKey:@"strokeColor"];
}

- (void)setExtraBezierPath:(id)aPath
{
    [[self vg] setBezierPath:aPath];
}

- (void)setBezierPath:(id)aPath
{
    [[self vg] setBezierPath:aPath];
}

- (id)extraBezierPath
{
    return [[self vg] bezierPath];
}

- (id)bezierPath
{
    return [[self vg] bezierPath];
}

- (void)setLineDashInfoKey:(id)aKey
{
    [[self vg] setLineDashInfoKey:aKey];
}

- (void)setLineDashInfo:(id)aInfo
{
    [[self vg] setLineDashInfo:aInfo];
}

- (id)lineDashInfoKey
{
    return [[self vg] lineDashInfoKey];
}

- (id)lineDashInfo
{
    return [[self vg] valueForKey:@"lineDashInfo"];
}

- (id)attributeToNotificationMapForCodingOperation:(id)aOperation
{
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithDictionary:[super attributeToNotificationMapForCodingOperation:aOperation]];
    [map setValue:[HSProtocolIdentifier identifierForProtocol:@protocol(HSOpacityAttribute)] forKey:@"opacity"];
    return map;
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"objectKindName"];
    [keys addObject:@"vg"];
    [keys addObject:@"opacity"];
    [keys addObject:@"headEnding"];
    [keys addObject:@"tailEnding"];
    [keys addObject:@"lineDashInfo"];
    [keys addObject:@"lineDashInfoKey"];
    [keys addObject:[@"bezierPath" extraKeyForMultiRepresentations]];
    [keys addObject:@"sizeAsString"];
    [keys addObject:@"extraBezierPath"];
    [keys addObject:[@"strokeColor" extraKeyForMultiRepresentations]];
    [keys addObject:[HSVectorGraphicsObject backgroundAttributesSerializationKey]];
    return keys;
}

- (void)setOpacity:(CGFloat)aOpacity
{
    [(HSVectorGraphicsObjectData *)[self nodeData] setOpacity:aOpacity];
}

- (CGFloat)opacity
{
    return [(HSVectorGraphicsObjectData *)[self nodeData] opacity];
}

// Vector graphics attributes come from the vg; the background interfaces
// exist for shapes only, line endings for lines and curves only.
- (id)queryNewHyperInterface:(id)aInterface
{
    if (protocol_conformsToProtocol(aInterface, @protocol(HSVectorGraphicsAttributes)))
        return [[self vg] queryHyperInterface:aInterface];
    if (protocol_conformsToProtocol(aInterface, @protocol(HSBackgroundRenderer))
        || HSProtocolsAreEqual(aInterface, @protocol(HSBackgroundAttributes))
        || HSProtocolsAreEqual(aInterface, @protocol(HSMutableBackgroundAttributes))
        || HSProtocolsAreEqual(aInterface, @protocol(HSBackgroundAttributesContainerPrimitives)))
        return [[self vg] isHyperShape] ? self : nil;
    if (protocol_conformsToProtocol(aInterface, @protocol(HSLineEndingContainer)) && [[self vg] isHyperShape])
        return nil;
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        return [[[HSVectorGraphicsObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    if (!HSProtocolsAreEqual(@protocol(HSAttributes), aInterface) && protocol_conformsToProtocol(@protocol(HSStandaloneMutableSizeAttributes), aInterface))
        return [[[HSMutableSizeAttributesImplementation alloc] initWithNodeStorage:self node:self] autorelease];
    if (HSProtocolsAreEqual(@protocol(HSHitTestingVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerHitTestingVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorHitTestingVisualization), aInterface))
        return [[[HSHitTestingVectorGraphicsObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    return [super queryNewHyperInterface:aInterface];
}

// Returns a new object of the concrete class for the path instead of self.
- (id)initWithBezierPath:(id)aPath originAtPoint:(NSPoint)aPoint
{
    self = [super init];
    id object = [[[[self class] concreteClassForBezierPath:aPath] allocWithZone:[self zone]] init];
    [[[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveFrameBoundingRectOriginTo:aPoint withLayoutGuidingContext:nil];
    [[object vg] setBezierPath:aPath];
    [self release];
    return object;
}

@end

@implementation HSCurveObject

+ (id)extraClassNameForStoring
{
    return @"HSVectorGraphicsObject";
}

@end

@implementation HSShapeObject
@end
