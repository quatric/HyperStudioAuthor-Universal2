#import "HSGradientColor.h"
#import "BTPointer.h"
#import "CGEColor.h"
#import "EXCodingContext.h"
#import "HSColor.h"
#import "HSFunctions.h"
#import "NSColor+BTCGExtensions.h"
#import "NSObject+HyperObject.h"

// An NSColor standing in for an HSColor (solid or gradient). Plain color
// requests go to the embedded color (the start color, with the overridden
// alpha if there is one); drawing and CG conversion use the whole gradient.
@implementation HSGradientColor

+ (id)colorWithGradientColor:(id)aColor overriddenAlpha:(CGFloat)aAlpha
{
    HSGradientColor *color = [[[self alloc] init] autorelease];
    [color setHyperHSColor:[aColor hyperHSColor]];
    [color setOverridesAlphaWithValue:aAlpha originalColor:aColor];
    return color;
}

+ (id)gradientColorWithHSColor:(id)aColor
{
    HSGradientColor *color = [[[self alloc] init] autorelease];
    [color setHyperHSColor:aColor];
    return color;
}

// Solid only when both ends are the same object.
+ (id)gradientColorWithStartColor:(id)aColor endColor:(id)aColor2
{
    HSColor *hsColor = [[HSColor new] autorelease];
    [hsColor setClear:NO];
    [hsColor setSolid:aColor == aColor2];
    [hsColor setStartColor:aColor];
    [hsColor setEndColor:aColor2];
    HSGradientColor *color = [[[self alloc] init] autorelease];
    [color setHyperHSColor:hsColor];
    return color;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"overridesAlpha", @"overriddenAlpha", @"hyperHSColor", @"storedOriginalColor", nil];
}

- (BOOL)shouldUseHyperDefaultImplementationForKeyValueCoding
{
    return YES;
}

- (BOOL)canBeExtraPostLoaded
{
    return YES;
}

- (CGFloat)overriddenAlpha
{
    return _overriddenAlpha;
}

- (void)setStoredOriginalColor:(id)aColor
{
    if (_storedOriginalColor != aColor) {
        [_storedOriginalColor release];
        _storedOriginalColor = [aColor retain];
    }
}

- (id)storedOriginalColor
{
    return _storedOriginalColor;
}

- (void)setOverriddenAlpha:(CGFloat)aAlpha
{
    _overriddenAlpha = aAlpha;
}

- (BOOL)overridesAlpha
{
    return _overridesAlpha;
}

- (void)setOverridesAlpha:(BOOL)aAlpha
{
    _overridesAlpha = aAlpha;
}

- (id)hyperHSColor
{
    return _color;
}

- (void)encodeWithCoder:(id)aCoder
{
    [super encodeWithCoder:aCoder];
    NSDictionary *dictionary = [_color extraDictionaryRepresentation];
    if ([aCoder allowsKeyedCoding]) {
        [aCoder encodeObject:dictionary forKey:@"HSHyperColor"];
        [aCoder encodeBool:_overridesAlpha forKey:@"HSHyperOverridesAlpha"];
        [aCoder encodeFloat:_overriddenAlpha forKey:@"HSHyperOverriddenAlpha"];
        [aCoder encodeObject:_storedOriginalColor forKey:@"HSOriginalColorKey"];
    } else {
        [aCoder encodeObject:dictionary];
        [aCoder encodeValueOfObjCType:"c" at:&_overridesAlpha];
        float alpha = _overriddenAlpha;
        [aCoder encodeValueOfObjCType:"f" at:&alpha];
        [aCoder encodeObject:_storedOriginalColor];
    }
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self == nil)
        return nil;
    char overridesAlpha = 0;
    float overriddenAlpha = 1.0f;
    NSDictionary *dictionary;
    id originalColor;
    _overridesAlpha = NO;
    if ([aCoder allowsKeyedCoding]) {
        dictionary = [aCoder decodeObjectForKey:@"HSHyperColor"];
        overridesAlpha = [aCoder decodeBoolForKey:@"HSHyperOverridesAlpha"];
        overriddenAlpha = [aCoder decodeFloatForKey:@"HSHyperOverriddenAlpha"];
        originalColor = [aCoder decodeObjectForKey:@"HSOriginalColorKey"];
    } else {
        dictionary = [aCoder decodeObject];
        [aCoder decodeValueOfObjCType:"c" at:&overridesAlpha];
        [aCoder decodeValueOfObjCType:"f" at:&overriddenAlpha];
        originalColor = [aCoder decodeObject];
    }
    HSColor *hsColor = dictionary != nil ? [HSColor objectWithExtraDictionary:dictionary] : [[HSColor new] autorelease];
    [self setHyperHSColor:hsColor];
    if (overridesAlpha)
        [self setOverridesAlphaWithValue:overriddenAlpha originalColor:originalColor];
    return self;
}

// NSColor would otherwise archive a class cluster member.
- (Class)classForCoder
{
    return [self class];
}

- (NSUInteger)hash
{
    return [_color hash];
}

- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[HSGradientColor class]])
        return NO;
    return [_color isEqual:[aEqual hyperHSColor]];
}

- (id)patternImage
{
    return [[self embeddedColor] patternImage];
}

- (void)writeToPasteboard:(id)aPasteboard
{
    [[self embeddedColor] writeToPasteboard:aPasteboard];
}

- (CGFloat)alphaComponent
{
    return [[self embeddedColor] alphaComponent];
}

- (void)getComponents:(CGFloat *)aComponents
{
    [[self embeddedColor] getComponents:aComponents];
}

- (NSInteger)numberOfComponents
{
    return [[self embeddedColor] numberOfComponents];
}

- (id)colorSpace
{
    return [[self embeddedColor] colorSpace];
}

- (void)getCyan:(CGFloat *)aCyan magenta:(CGFloat *)aMagenta yellow:(CGFloat *)aYellow black:(CGFloat *)aBlack alpha:(CGFloat *)aAlpha
{
    [[self embeddedColor] getCyan:aCyan magenta:aMagenta yellow:aYellow black:aBlack alpha:aAlpha];
}

- (CGFloat)blackComponent
{
    return [[self embeddedColor] blackComponent];
}

- (CGFloat)yellowComponent
{
    return [[self embeddedColor] yellowComponent];
}

- (CGFloat)magentaComponent
{
    return [[self embeddedColor] magentaComponent];
}

- (CGFloat)cyanComponent
{
    return [[self embeddedColor] cyanComponent];
}

- (void)getWhite:(CGFloat *)aWhite alpha:(CGFloat *)aAlpha
{
    [[self embeddedColor] getWhite:aWhite alpha:aAlpha];
}

- (CGFloat)whiteComponent
{
    return [[self embeddedColor] whiteComponent];
}

- (void)getHue:(CGFloat *)aHue saturation:(CGFloat *)aSaturation brightness:(CGFloat *)aBrightness alpha:(CGFloat *)aAlpha
{
    [[self embeddedColor] getHue:aHue saturation:aSaturation brightness:aBrightness alpha:aAlpha];
}

- (CGFloat)brightnessComponent
{
    return [[self embeddedColor] brightnessComponent];
}

- (CGFloat)saturationComponent
{
    return [[self embeddedColor] saturationComponent];
}

- (CGFloat)hueComponent
{
    return [[self embeddedColor] hueComponent];
}

- (void)getRed:(CGFloat *)aRed green:(CGFloat *)aGreen blue:(CGFloat *)aBlue alpha:(CGFloat *)aAlpha
{
    [[self embeddedColor] getRed:aRed green:aGreen blue:aBlue alpha:aAlpha];
}

- (CGFloat)blueComponent
{
    return [[self embeddedColor] blueComponent];
}

- (CGFloat)greenComponent
{
    return [[self embeddedColor] greenComponent];
}

- (CGFloat)redComponent
{
    return [[self embeddedColor] redComponent];
}

- (id)localizedColorNameComponent
{
    return [[self embeddedColor] localizedColorNameComponent];
}

- (id)localizedCatalogNameComponent
{
    return [[self embeddedColor] localizedCatalogNameComponent];
}

- (id)colorNameComponent
{
    return [[self embeddedColor] colorNameComponent];
}

- (id)catalogNameComponent
{
    return [[self embeddedColor] catalogNameComponent];
}

// Both ends get the alpha; kind and angle carry over (the center does not).
- (id)colorWithAlphaComponent:(CGFloat)aComponent
{
    NSColor *endColor = [[_color hyperEndColor] colorWithAlphaComponent:aComponent];
    NSColor *startColor = [[_color hyperStartColor] colorWithAlphaComponent:aComponent];
    HSGradientColor *color = [[self class] gradientColorWithStartColor:startColor endColor:endColor];
    HSColor *hsColor = [color hyperHSColor];
    [hsColor setHyperKind:[_color hyperKind]];
    [hsColor setHyperAngle:[_color hyperAngle]];
    return color;
}

- (id)blendedColorWithFraction:(CGFloat)aFraction ofColor:(id)aColor
{
    return [[self embeddedColor] blendedColorWithFraction:aFraction ofColor:aColor];
}

- (id)colorUsingColorSpace:(id)aSpace
{
    return [[self embeddedColor] colorUsingColorSpace:aSpace];
}

- (id)colorUsingColorSpaceName:(id)aName device:(id)aDevice
{
    return [[self embeddedColor] colorUsingColorSpaceName:aName device:aDevice];
}

- (id)colorUsingColorSpaceName:(id)aName
{
    return [[self embeddedColor] colorUsingColorSpaceName:aName];
}

- (id)colorSpaceName
{
    return [[self embeddedColor] colorSpaceName];
}

- (void)setStroke
{
    [[self embeddedColor] setStroke];
}

- (void)setFill
{
    [[self embeddedColor] setFill];
}

- (void)set
{
    [(NSColor *)[self embeddedColor] set];
}

- (id)shadowWithLevel:(CGFloat)aLevel
{
    return [[self embeddedColor] shadowWithLevel:aLevel];
}

- (id)highlightWithLevel:(CGFloat)aLevel
{
    return [[self embeddedColor] highlightWithLevel:aLevel];
}

- (void)setOverridesAlphaWithValue:(CGFloat)aValue originalColor:(id)aColor
{
    _overridesAlpha = YES;
    _overriddenAlpha = aValue;
    [_embeddedColor release];
    _embeddedColor = nil;
    [self setStoredOriginalColor:aColor];
}

- (id)originalColor
{
    return _storedOriginalColor != nil ? _storedOriginalColor : self;
}

- (void)setHyperHSColor:(id)aColor
{
    if (_color != aColor) {
        [_color release];
        _color = [aColor retain];
        [_embeddedColor release];
        _embeddedColor = nil;
    }
}

- (id)embeddedColor
{
    if (_embeddedColor == nil && [_color hyperStartColor] != nil) {
        NSColor *color = [_color hyperStartColor];
        if (_overridesAlpha)
            color = [color colorWithAlphaComponent:_overriddenAlpha];
        _embeddedColor = [color retain];
    }
    return _embeddedColor;
}

- (id)clonedTransparentColor
{
    return [[self class] colorWithGradientColor:self overriddenAlpha:0.0];
}

- (void)drawSwatchInRect:(NSRect)aRect
{
    [_color drawGradientInCocoaContext:[NSGraphicsContext currentContext] rect:aRect ofBounds:aRect];
}

// The gradient in the unit square, from calibrated RGB start/end colors:
// kind 0 is axial along the angle, 1 radial from the center, 2 rectangular
// from the center out to the edges. Anything else falls back to NSColor.
- (struct CGEColor *)BT_coreGraphicsExtendedColor
{
    if (_color == nil)
        return [super BT_coreGraphicsExtendedColor];
    CGColorRef startColor = [[[_color hyperStartColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace] BT_coreGraphicsColor];
    if (startColor == NULL)
        return [super BT_coreGraphicsExtendedColor];
    CGColorRef endColor = [[[_color hyperEndColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace] BT_coreGraphicsColor];
    if (endColor == NULL)
        return [super BT_coreGraphicsExtendedColor];

    // Two colors of four components each. The original copied the start
    // color's component count from both without a bound; it is capped at 4.
    CGFloat components[8] = { 0 };
    size_t count = MIN(CGColorGetNumberOfComponents(startColor), (size_t)4);
    memcpy(components, CGColorGetComponents(startColor), count * sizeof(CGFloat));
    memcpy(components + 4, CGColorGetComponents(endColor), MIN(count, CGColorGetNumberOfComponents(endColor)) * sizeof(CGFloat));

    CGEColorRef gradient;
    CGColorSpaceRef space = CGColorGetColorSpace(startColor);
    switch ([_color hyperKind]) {
    case 0: {
        CGPoint start = CGPointMake(0.5, 0.5);
        CGPoint end = CGPointMake(0.5, 0.5);
        float angle = fmodf((float)(([_color hyperAngle] * M_PI) / 180.0), 2.0f * (float)M_PI);
        if (angle < 0.0f)
            angle = (float)(angle + 2.0 * M_PI);
        float c = cosf(angle);
        float s = sinf(angle);
        // The base corner is the start for the upper half turn, the end for
        // the lower; the other point is the base projected along the angle.
        CGPoint *base = angle < M_PI ? &start : &end;
        CGPoint *tip = angle < M_PI ? &end : &start;
        if (angle < M_PI_2 || (angle < 3.0 * M_PI_2 && angle >= M_PI)) {
            *base = CGPointMake(0.0, 0.0);
            *tip = CGPointMake(c * (s + c) + 0.0f, (s + c) * s + 0.0f);
        } else {
            *base = CGPointMake(1.0, 0.0);
            *tip = CGPointMake(c * (s - c) + 1.0f, (s - c) * s + 0.0f);
        }
        gradient = CGEColorCreateLinearAxialGradient(space, start, end, 0, NULL, components, true, true);
        break;
    }
    case 1:
        gradient = CGEColorCreateLinearRadialGradient(space, CGPointMake(0.5, 0.5), 0.0, CGPointMake(0.5, 0.5), 0.5,
                                                      CGAffineTransformIdentity, 0, NULL, components, true, true);
        break;
    case 2:
        gradient = CGEColorCreateLinearRectangularGradient(space, CGRectMake(0.5, 0.5, 0.0, 0.0), CGRectMake(0.0, 0.0, 1.0, 1.0),
                                                           CGAffineTransformIdentity, 0, NULL, components, true, true);
        break;
    default:
        gradient = NULL;
        break;
    }
    if (gradient == NULL)
        return [super BT_coreGraphicsExtendedColor];
    return [BTPointer autoreleasedPointer:gradient withDisposer:CGEColorRelease];
}

- (id)queryHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(aInterface, @protocol(HSMutableColor)) || HSProtocolsAreEqual(aInterface, @protocol(HSColor)))
        return [_color queryHyperInterface:aInterface];
    return [super queryHyperInterface:aInterface];
}

// The original did not release the stored original color.
- (void)dealloc
{
    [_color release];
    [_embeddedColor release];
    [_storedOriginalColor release];
    [super dealloc];
}

@end
