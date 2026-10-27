#import "HSColor.h"
#import <OpenGL/gl.h>

// Start and end RGBA plus the length the shading input is divided by.
typedef struct {
    float startColor[4];
    float endColor[4];
    float length;
} HSColorGradientInfo;

static void HSColorGradientEvaluate(void *aInfo, const CGFloat *aIn, CGFloat *aOut)
{
    HSColorGradientInfo *info = aInfo;
    float t = 1.0f;
    if ((float)aIn[0] / info->length <= 1.0f)
        t = (float)aIn[0] / info->length;
    for (int i = 0; i < 4; i++)
        aOut[i] = (info->endColor[i] - info->startColor[i]) * t + info->startColor[i];
}

// Relative comparison used by the undoable setters.
static BOOL HSColorFloatsAreClose(float aValue1, float aValue2)
{
    float scale1 = aValue1 != 0.0f ? fabsf(aValue1) : 1.0f;
    float scale2 = aValue2 != 0.0f ? fabsf(aValue2) : 1.0f;
    return fabsf(aValue1 - aValue2) <= MAX(scale1, scale2) * 0.0005f;
}

static NSColor *HSColorFromXMLComponents(NSArray *aComponents)
{
    float alpha = [aComponents count] == 4 ? [[aComponents objectAtIndex:3] floatValue] : 1.0f;
    return [NSColor colorWithCalibratedRed:[[aComponents objectAtIndex:0] floatValue]
                                     green:[[aComponents objectAtIndex:1] floatValue]
                                      blue:[[aComponents objectAtIndex:2] floatValue]
                                     alpha:alpha];
}

static NSString *HSColorChangeFillingActionName(void)
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Change Filling" value:@"" table:@"UndoManager"];
}

// A solid color or a two-color gradient (axial, radial or rectangular).
@implementation HSColor
+ (id)defaultColor
{
    return [NSColor whiteColor];
}
- (NSUInteger)hash
{
    NSUInteger hash = [_startColor hash];
    if (!_isSolid)
        hash += [_endColor hash];
    return hash + [super hash];
}
- (BOOL)isEqual:(id)aEqual
{
    if (![super isEqual:aEqual] || [aEqual isHyperClear] != _isClear)
        return NO;
    if ([aEqual isHyperSolid] == _isSolid && [[aEqual hyperStartColor] isEqual:_startColor] && _isSolid)
        return YES;
    if (![[aEqual hyperStartColor] isEqual:_startColor] || ![[aEqual hyperEndColor] isEqual:_endColor])
        return NO;
    if ((float)[aEqual hyperAngle] != _angle || (float)[aEqual hyperCenterX] != _centerX || (float)[aEqual hyperCenterY] != _centerY)
        return NO;
    return [aEqual hyperKind] == _kind;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    if (!aRepresentation)
        return;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSString *string = [[aRepresentation attributeForName:@"startColor"] stringValue];
    NSColor *color = nil;
    if ([string isEqualToString:@"pattern"]) {
        id reference = [[aRepresentation elementsForName:@"textureMediaRef"] extraFirstObject];
        if (reference) {
            NSString *uid = [[reference attributeForName:@"refId"] stringValue];
            id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[HSUID UIDWithString:uid]];
            NSImage *image = [[NSImage alloc] initWithData:[media mediaData]];
            if (image)
                color = [NSColor colorWithPatternImage:image];
            [image release];
        }
    } else {
        NSArray *components = [string componentsSeparatedByString:@","];
        if ([components count] > 2)
            color = HSColorFromXMLComponents(components);
    }
    if (color)
        [self setStartColor:color];
    NSXMLNode *endColor = [aRepresentation attributeForName:@"endColor"];
    if (endColor) {
        [self setSolid:NO];
        NSArray *components = [[endColor stringValue] componentsSeparatedByString:@","];
        if ([components count] > 2)
            [self setEndColor:HSColorFromXMLComponents(components)];
        [self setHyperAngle:[[[aRepresentation attributeForName:@"angle"] stringValue] floatValue]];
        float centerX = [[[aRepresentation attributeForName:@"centerX"] stringValue] floatValue];
        float centerY = [[[aRepresentation attributeForName:@"centerY"] stringValue] floatValue];
        [self setHyperCenterX:centerX andY:centerY];
        [self setKindAsString:[[aRepresentation attributeForName:@"hyperKind"] stringValue]];
    }
    [pool release];
}
- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [NSXMLElement elementWithName:[self XMLElementName]];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSMutableDictionary *colors = [NSMutableDictionary dictionaryWithObject:[self hyperStartColor] forKey:@"startColor"];
    if ([self isHyperGradient]) {
        [element addAttribute:[NSXMLNode attributeWithName:@"hyperKind" stringValue:[self kindAsString]]];
        [element addAttribute:[NSXMLNode attributeWithName:@"angle" stringValue:[NSString stringWithFormat:@"%.2f", [self hyperAngle]]]];
        [element addAttribute:[NSXMLNode attributeWithName:@"centerX" stringValue:[NSString stringWithFormat:@"%.2f", [self hyperCenterX]]]];
        [element addAttribute:[NSXMLNode attributeWithName:@"centerY" stringValue:[NSString stringWithFormat:@"%.2f", [self hyperCenterY]]]];
        [colors setObject:[self hyperEndColor] forKey:@"endColor"];
    }
    for (NSString *key in [colors allKeys]) {
        NSColor *color = [colors objectForKey:key];
        if ([[color colorSpaceName] isEqualToString:NSPatternColorSpace]) {
            NSImage *image = [[color colorUsingColorSpaceName:NSPatternColorSpace] patternImage];
            if (!image)
                continue;
            // Quirk: the texture media is named after the start color for both colors.
            NSString *name = [@"startColor_textureImage" stringByAppendingPathExtension:@"png"];
            id media = [aContext convertedMediaForKey:name];
            if (!media) {
                media = [HSNewMedia mediaWithData:[image hyperPNGRepresentation] name:name type:@"png"];
                if (media)
                    [aContext setConvertedMedia:media forKey:name];
            }
            if (media) {
                [aContext addMedia:media];
                NSXMLElement *reference = [NSXMLElement elementWithName:@"textureMediaRef"];
                [reference addAttribute:[NSXMLNode attributeWithName:@"refId" stringValue:[[media mediaUID] stringValue]]];
                [element addChild:reference];
                [element addAttribute:[NSXMLNode attributeWithName:key stringValue:@"pattern"]];
            }
        } else {
            NSColor *rgbColor = color ? [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] : nil;
            CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 1.0;
            if (rgbColor) {
                red = [rgbColor redComponent];
                green = [rgbColor greenComponent];
                blue = [rgbColor blueComponent];
                alpha = [rgbColor alphaComponent];
            }
            NSString *value = [NSString stringWithFormat:@"%.8f,%.8f,%.8f,%.8f", red, green, blue, alpha];
            [element addAttribute:[NSXMLNode attributeWithName:key stringValue:value]];
        }
    }
    [pool release];
    return element;
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (id)XMLElementName
{
    return @"gradientColor";
}
- (id)copyWithZone:(NSZone *)aZone
{
    HSColor *copy = [super copyWithZone:aZone];
    if (copy) {
        [copy setClear:_isClear];
        [copy setSolid:_isSolid];
        [copy setKind:_kind];
        [copy setHyperCacheEnabled:_isCacheEnabled];
        [copy setCacheImage:_cache];
        [copy setAngle:_angle];
        [copy setCenterX:_centerX andY:_centerY];
        [copy setStartColor:_startColor];
        [copy setEndColor:_endColor];
    }
    return copy;
}
- (void)setKindAsString:(id)aString
{
    NSInteger kind;
    if ([aString isEqual:@"Axial"])
        kind = 0;
    else if ([aString isEqual:@"Radial"])
        kind = 1;
    else if ([aString isEqual:@"Rectangular"])
        kind = 2;
    else
        return;
    [self setHyperKind:kind];
}
- (id)kindAsString
{
    switch ([self hyperKind]) {
    case 0:
        return @"Axial";
    case 1:
        return @"Radial";
    case 2:
        return @"Rectangular";
    default:
        return nil;
    }
}
- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    if ([[aContext codingOperation] isEqualToString:HSCopyingCodingOperation])
        return [self keysForExtraStoringWithCodingContext:aContext];
    return [NSArray arrayWithObjects:@"isSolid", @"kindAsString", @"isCacheEnabled", [@"startColor" extraKeyForMultiRepresentations],
                                     [@"endColor" extraKeyForMultiRepresentations], @"angle", @"centerX", @"centerY", nil];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    if ([[aContext codingOperation] isEqualToString:HSCopyingCodingOperation])
        return [NSArray arrayWithObjects:@"isSolid", @"kindAsString", @"isCacheEnabled", @"startColor", @"endColor", @"angle", @"centerX", @"centerY", nil];
    if ([self isHyperSolid])
        return [NSArray arrayWithObjects:@"isSolid", [@"startColor" extraKeyForMultiRepresentations], nil];
    NSArray *keys = [NSArray arrayWithObjects:@"isSolid", @"kindAsString", @"isCacheEnabled", [@"startColor" extraKeyForMultiRepresentations],
                                              [@"endColor" extraKeyForMultiRepresentations], nil];
    // Quirk: rectangular gradients store no center, though drawing uses it.
    if ([self hyperKind] == 0)
        return [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"angle", @"centerX", nil]];
    if ([self hyperKind] == 1)
        return [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"centerX", @"centerY", nil]];
    return keys;
}
- (void)setCacheImage:(id)aImage
{
    // The original did not release the previous image; fixed.
    [_cache autorelease];
    _cache = [aImage retain];
}
// Draws into the current OpenGL context ([-1, 1] square): four smooth-shaded triangles
// from the borders (end color) to the center (start color).
- (void)drawRectangularGradientWithStartColor:(float *)aColor endColor:(float *)aColor2
{
    GLint shadeModel = GL_SMOOTH;
    float centerX = _centerX + _centerX - 1.0f;
    float centerY = _centerY + _centerY - 1.0f;
    glGetIntegerv(GL_SHADE_MODEL, &shadeModel);
    glShadeModel(GL_SMOOTH);
    glBegin(GL_POLYGON);
    glColor4f(aColor2[0], aColor2[1], aColor2[2], aColor2[3]);
    glVertex2f(-1.0f, -1.0f);
    glVertex2f(1.0f, -1.0f);
    glColor4f(aColor[0], aColor[1], aColor[2], aColor[3]);
    glVertex2f(centerX, centerY);
    glColor4f(aColor2[0], aColor2[1], aColor2[2], aColor2[3]);
    glVertex2f(-1.0f, 1.0f);
    glEnd();
    glBegin(GL_POLYGON);
    glColor4f(aColor2[0], aColor2[1], aColor2[2], aColor2[3]);
    glVertex2f(1.0f, 1.0f);
    glVertex2f(-1.0f, 1.0f);
    glColor4f(aColor[0], aColor[1], aColor[2], aColor[3]);
    glVertex2f(centerX, centerY);
    glColor4f(aColor2[0], aColor2[1], aColor2[2], aColor2[3]);
    glVertex2f(1.0f, -1.0f);
    glEnd();
    glShadeModel(shadeModel);
}
- (void)drawGradientInRect:(NSRect)aRect ofBounds:(NSRect)aBounds
{
    [self drawGradientInCocoaContext:[NSGraphicsContext currentContext] rect:aRect ofBounds:aBounds];
}
- (void)discardCache
{
    [_cache release];
    _cache = nil;
}
- (void)hyperDrawHighlightedInRect:(NSRect)aRect ofBounds:(NSRect)aBounds
{
    [super hyperDrawHighlightedInRect:aRect ofBounds:aBounds];
}
- (void)hyperDrawInRect:(NSRect)aRect ofBounds:(NSRect)aBounds
{
    if (!_isSolid) {
        [self drawGradientInRect:aRect ofBounds:aBounds];
    } else {
        [(NSColor *)[self hyperStartColor] set];
        NSRectFillUsingOperation(aRect, NSCompositingOperationSourceOver);
    }
}
- (void)setHyperCenterX:(CGFloat)aX andY:(CGFloat)aY
{
    if (HSColorFloatsAreClose(_centerX, aX) && HSColorFloatsAreClose(_centerY, aY))
        return;
    [[self undoManager] setActionName:HSColorChangeFillingActionName()];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperCenterX:_centerX andY:_centerY];
    [self setCenterX:aX andY:aY];
    [self postDidChange];
}
- (void)setCenterX:(CGFloat)aX andY:(CGFloat)aY
{
    _centerX = aX;
    _centerY = aY;
    if (_isCacheEnabled)
        [self discardCache];
}
- (void)setHyperCenterX:(CGFloat)aX
{
    [self setHyperCenterX:aX andY:_centerY];
}
- (void)setHyperAngle:(CGFloat)aAngle
{
    if (HSColorFloatsAreClose(_angle, aAngle))
        return;
    [[self undoManager] setActionName:HSColorChangeFillingActionName()];
    [(HSColor *)[[self undoManager] prepareWithInvocationTarget:self] setHyperAngle:_angle];
    [self setAngle:aAngle];
    [self postDidChange];
}
- (void)setAngle:(CGFloat)aAngle
{
    _angle = aAngle;
    if (_isCacheEnabled)
        [self discardCache];
}
- (CGFloat)hyperCenterY
{
    return _centerY;
}
- (CGFloat)hyperCenterX
{
    return _centerX;
}
- (CGFloat)hyperAngle
{
    return _angle;
}
- (void)hyperSwapGradientColors
{
    if (_isSolid || [_startColor isEqual:_endColor])
        return;
    [[self undoManager] setActionName:HSColorChangeFillingActionName()];
    [[[self undoManager] prepareWithInvocationTarget:self] hyperSwapGradientColors];
    [self swapGradientColors];
    [self postDidChange];
}
- (void)swapGradientColors
{
    if (_isSolid)
        return;
    NSColor *color = _endColor;
    _endColor = _startColor;
    _startColor = color;
    if (_isCacheEnabled)
        [self discardCache];
}
- (void)setHyperEndColor:(id)aColor
{
    if ([_endColor isEqual:aColor])
        return;
    [[self undoManager] setActionName:HSColorChangeFillingActionName()];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperEndColor:_endColor];
    [self setEndColor:aColor];
    [self postDidChange];
}
// The color is solid while both colors match (or the end color is unset).
- (void)setEndColor:(id)aColor
{
    _isSolid = _startColor == aColor || [aColor isEqual:_startColor] || aColor == nil;
    [_endColor autorelease];
    _endColor = [aColor retain];
    if (_isCacheEnabled)
        [self discardCache];
}
- (void)setHyperStartColor:(id)aColor
{
    if ([_startColor isEqual:aColor])
        return;
    [[self undoManager] setActionName:HSColorChangeFillingActionName()];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperStartColor:_startColor];
    [self setStartColor:aColor];
    [self postDidChange];
}
- (void)setStartColor:(id)aColor
{
    _isSolid = _endColor == aColor || [_endColor isEqual:aColor] || _endColor == nil;
    [_startColor autorelease];
    _startColor = [aColor retain];
    if (_isCacheEnabled)
        [self discardCache];
}
- (id)hyperEndColor
{
    return _endColor ? _endColor : [HSColor defaultColor];
}
- (id)hyperStartColor
{
    return _startColor ? _startColor : [HSColor defaultColor];
}
- (void)setHyperKind:(NSInteger)aKind
{
    if (_kind == aKind)
        return;
    [[self undoManager] setActionName:HSColorChangeFillingActionName()];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperKind:_kind];
    [self setKind:aKind];
    [self postDidChange];
}
- (void)setKind:(NSInteger)aKind
{
    _kind = (int)aKind;
    if (_isCacheEnabled)
        [self discardCache];
}
- (NSInteger)hyperKind
{
    return _kind;
}
- (void)setHyperCacheEnabled:(BOOL)aEnabled
{
    // Quirk: the cache is discarded when it gets enabled, not when it gets disabled.
    if (_isCacheEnabled != aEnabled) {
        _isCacheEnabled = aEnabled;
        if (aEnabled)
            [self discardCache];
    }
}
- (BOOL)isHyperCacheEnabled
{
    return _isCacheEnabled;
}
- (void)drawGradientInCocoaContext:(id)aContext rect:(NSRect)aRect ofBounds:(NSRect)aBounds
{
    [self drawGradientInCGContext:[aContext CGContext] rect:aRect ofBounds:aBounds];
}
// Axial: along the angle through the bounds center, with 2 * centerX as the color ramp length.
// Radial: unit circle over the bounds, starting from the (centerX, centerY) point.
// Rectangular: rendered with OpenGL into a pixel buffer the size of the rect.
- (void)drawGradientInCGContext:(struct CGContext *)aContext rect:(NSRect)aRect ofBounds:(NSRect)aBounds
{
    if (NSIsEmptyRect(aBounds) || NSIsEmptyRect(aRect))
        return;
    aBounds = NSInsetRect(aBounds, -1.0, -1.0);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    HSColorGradientInfo info = { { 0 }, { 0 }, 0 };
    CGFunctionCallbacks callbacks = { 0, HSColorGradientEvaluate, NULL };
    CGContextSaveGState(aContext);
    CGContextSetFillColorSpace(aContext, space);
    CGContextClipToRect(aContext, NSRectToCGRect(aRect));
    CGFloat components[4];
    [[[self hyperStartColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace] getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    for (int i = 0; i < 4; i++)
        info.startColor[i] = components[i];
    [[[self hyperEndColor] colorUsingColorSpaceName:NSDeviceRGBColorSpace] getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    for (int i = 0; i < 4; i++)
        info.endColor[i] = components[i];
    CGShadingRef shading = NULL;
    CGFunctionRef function = NULL;
    NSInteger kind = [self hyperKind];
    if (kind == 1) {
        CGContextConcatCTM(aContext, CGAffineTransformMake(aBounds.size.width, 0, 0, aBounds.size.height,
                                                           aBounds.origin.x + aBounds.size.width * 0.5f, aBounds.origin.y + aBounds.size.height * 0.5f));
        function = CGFunctionCreate(&info, 1, NULL, 4, NULL, &callbacks);
        info.length = 1.0f;
        shading = CGShadingCreateRadial(space, CGPointMake(_centerX - 0.5f, _centerY - 0.5f), 0, CGPointZero, 0.5f, function, true, true);
    } else if (kind == 0) {
        CGContextTranslateCTM(aContext, aBounds.origin.x + aBounds.size.width * 0.5, aBounds.origin.y + aBounds.size.height * 0.5);
        function = CGFunctionCreate(&info, 1, NULL, 4, NULL, &callbacks);
        info.length = _centerX + _centerX;
        float angle = (float)((_angle / 180.0f) * M_PI);
        CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
        // The projected length is truncated to integers, as in the original.
        float length = (float)(abs((int)(aBounds.size.height * sin(angle))) + abs((int)(aBounds.size.width * cos(angle))));
        CGPoint start = CGPointApplyAffineTransform(CGPointMake(length * -0.5f, 0), rotation);
        CGPoint end = CGPointApplyAffineTransform(CGPointMake(length * 0.5f, 0), rotation);
        shading = CGShadingCreateAxial(space, start, end, function, true, true);
    } else {
        unsigned int attributes[] = {
            NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, NSOpenGLPFAColorSize, 24, NSOpenGLPFAAlphaSize, 8, 0,
            NSOpenGLPFAWindow, NSOpenGLPFAColorSize, 24, NSOpenGLPFAAlphaSize, 8, 0,
            0
        };
        NSOpenGLPixelFormat *format = [NSOpenGLPixelFormat NSE_pixelFormatWithAttributesSequence:attributes];
        id context = format ? [NSEOpenGLContext contextWithFormat:format shareCategory:NSEDefaultOpenGLContextShareCategory] : nil;
        NSEPixelBufferOpenGLDrawable *drawable = context ? [[NSEPixelBufferOpenGLDrawable alloc] initWithOpenGLContext:context] : nil;
        if (drawable) {
            long high = aRect.size.height > 0 ? lroundf(ceilf(aRect.size.height)) : 0;
            long wide = aRect.size.width > 0 ? lroundf(ceilf(aRect.size.width)) : 0;
            [drawable setPixelsWide:wide pixelsHigh:high statically:NO];
            if ([drawable lockOpenGLFocus]) {
                [self drawRectangularGradientWithStartColor:info.startColor endColor:info.endColor];
                CGImageRef image = [drawable unlockOpenGLFocusAsImage];
                [drawable release];
                if (image) {
                    CGContextDrawImage(aContext, NSRectToCGRect(aRect), image);
                    CGImageRelease(image);
                }
            } else {
                [drawable release];
            }
        }
    }
    if (shading) {
        CGContextDrawShading(aContext, shading);
        CGShadingRelease(shading);
    }
    // The original leaked the function when no shading was made; fixed.
    CGFunctionRelease(function);
    CGColorSpaceRelease(space);
    CGContextRestoreGState(aContext);
}
- (void)setHyperSolidColor:(id)aColor
{
    if ([_startColor isEqual:aColor])
        return;
    [[self undoManager] setActionName:HSColorChangeFillingActionName()];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperSolidColor:_startColor];
    [_endColor release];
    _endColor = nil;
    [self setStartColor:aColor];
    [self postDidChange];
}
- (id)hyperSolidColor
{
    return [self hyperStartColor];
}
- (void)setSolid:(BOOL)aSolid
{
    _isSolid = aSolid;
}
- (void)setHyperClear:(BOOL)aClear
{
    if (_isClear == aClear)
        return;
    [[self undoManager] setActionName:HSColorChangeFillingActionName()];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperClear:_isClear];
    [self setClear:aClear];
    [self postDidChange];
}
- (void)setClear:(BOOL)aClear
{
    _isClear = aClear;
}
- (BOOL)isHyperGradient
{
    return ![self isHyperSolid];
}
- (BOOL)isHyperSolid
{
    return _isSolid;
}
- (BOOL)isHyperClear
{
    return _isClear;
}
// Named (system) colors follow the control tint.
- (void)controlTintDidChangeNotification:(id)aNotification
{
    if (_isClear)
        return;
    if (![[[self hyperStartColor] colorSpaceName] isEqualToString:NSNamedColorSpace]) {
        if (_isSolid || ![[[self hyperEndColor] colorSpaceName] isEqualToString:NSNamedColorSpace])
            return;
    }
    if (_isCacheEnabled)
        [self discardCache];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_cache release];
    [_startColor release];
    [_endColor release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _isClear = YES;
        _isSolid = YES;
        _kind = 0;
        _isCacheEnabled = YES;
        _angle = 0.0f;
        _centerX = 0.5f;
        _centerY = 0.5f;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTintDidChangeNotification:) name:NSControlTintDidChangeNotification object:nil];
    }
    return self;
}
@end
