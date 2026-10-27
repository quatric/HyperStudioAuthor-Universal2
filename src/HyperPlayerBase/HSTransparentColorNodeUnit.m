#import "HSTransparentColorNodeUnit.h"
#import "HSTransparentColorAttributesImplementation.h"
#import "HSProtocolIdentifier.h"
#import "HSFunctions.h"
#import "EXCodingContext.h"

// The color made transparent in an image, with HCL tolerances. Changes to
// the color only notify while the feature is enabled, and the reverse.
@implementation HSTransparentColorNodeUnit

- (void)setLightnessTolerance:(double)aTolerance
{
    if (_lightnessTolerance == aTolerance)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute) withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Transparent Color Lightness Tolerance" value:@"" table:@"UndoManager"]];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] notifyChange:0x200 ofAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute) withUserInfo:nil];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] setLightnessTolerance:_lightnessTolerance];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] notifyChange:0x100 ofAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute) withUserInfo:nil];
    _lightnessTolerance = aTolerance;
    [self notifyChange:2 ofAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute) withUserInfo:nil];
}

- (double)lightnessTolerance
{
    return _lightnessTolerance;
}

- (void)setChromaTolerance:(double)aTolerance
{
    if (_chromaTolerance == aTolerance)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSTransparentColorChromaToleranceAttribute) withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Transparent Color Chroma Tolerance" value:@"" table:@"UndoManager"]];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] notifyChange:0x200 ofAttribute:@protocol(HSTransparentColorChromaToleranceAttribute) withUserInfo:nil];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] setChromaTolerance:_chromaTolerance];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] notifyChange:0x100 ofAttribute:@protocol(HSTransparentColorChromaToleranceAttribute) withUserInfo:nil];
    _chromaTolerance = aTolerance;
    [self notifyChange:2 ofAttribute:@protocol(HSTransparentColorChromaToleranceAttribute) withUserInfo:nil];
}

- (double)chromaTolerance
{
    return _chromaTolerance;
}

- (void)setHueTolerance:(double)aTolerance
{
    if (_hueTolerance == aTolerance)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSTransparentColorHueToleranceAttribute) withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Transparent Color Hue Tolerance" value:@"" table:@"UndoManager"]];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] notifyChange:0x200 ofAttribute:@protocol(HSTransparentColorHueToleranceAttribute) withUserInfo:nil];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] setHueTolerance:_hueTolerance];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] notifyChange:0x100 ofAttribute:@protocol(HSTransparentColorHueToleranceAttribute) withUserInfo:nil];
    _hueTolerance = aTolerance;
    [self notifyChange:2 ofAttribute:@protocol(HSTransparentColorHueToleranceAttribute) withUserInfo:nil];
}

- (double)hueTolerance
{
    return _hueTolerance;
}

- (void)setTransparentColor:(id)aColor
{
    NSColor *color = [self HSTransparentColorNodeUnit_preprocessColor:aColor];
    BOOL changed = color == nil ? _transparentColor != nil : ![_transparentColor isEqual:color];
    if (!changed)
        return;
    if (_isTransparentColorEnabled)
        [self notifyChange:1 ofAttribute:@protocol(HSTransparentColorAttribute) withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Transparent Color" value:@"" table:@"UndoManager"]];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] notifyChange:0x200 ofAttribute:@protocol(HSTransparentColorAttribute) withUserInfo:nil];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] setTransparentColor:_transparentColor];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] notifyChange:0x100 ofAttribute:@protocol(HSTransparentColorAttribute) withUserInfo:nil];
    [color retain];
    [_transparentColor release];
    _transparentColor = color;
    if (_isTransparentColorEnabled)
        [self notifyChange:2 ofAttribute:@protocol(HSTransparentColorAttribute) withUserInfo:nil];
}

- (id)transparentColor
{
    return _transparentColor;
}

- (void)setTransparentColorEnabled:(BOOL)aEnabled
{
    if (!aEnabled == !_isTransparentColorEnabled)
        return;
    if (_transparentColor != nil)
        [self notifyChange:1 ofAttribute:@protocol(HSTransparentColorEnabledAttribute) withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Enable/Disable Transparent Color" value:@"" table:@"UndoManager"]];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] notifyChange:0x200 ofAttribute:@protocol(HSTransparentColorEnabledAttribute) withUserInfo:nil];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] setTransparentColorEnabled:_isTransparentColorEnabled];
    [(HSTransparentColorNodeUnit *)[undoManager prepareWithInvocationTarget:self] notifyChange:0x100 ofAttribute:@protocol(HSTransparentColorEnabledAttribute) withUserInfo:nil];
    _isTransparentColorEnabled = aEnabled;
    if (_transparentColor != nil)
        [self notifyChange:2 ofAttribute:@protocol(HSTransparentColorEnabledAttribute) withUserInfo:nil];
}

- (BOOL)isTransparentColorEnabled
{
    return _isTransparentColorEnabled;
}

- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSTransparentColorAttributes), aInterface))
        return [HSTransparentColorAttributesImplementation class];
    return Nil;
}

- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSTransparentColorAttributes), aInterface);
}

- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSTransparentColorAttributes)], nil];
}

- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocols:@protocol(HSTransparentColorEnabledAttribute), @protocol(HSTransparentColorAttribute),
            @protocol(HSTransparentColorHueToleranceAttribute), @protocol(HSTransparentColorChromaToleranceAttribute),
            @protocol(HSTransparentColorLightnessToleranceAttribute), nil];
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSTransparentColorNodeUnit *copy = [[[self class] allocWithZone:aZone] init];
    [copy HSTransparentColorNodeUnit_setTransparentColorEnabled:_isTransparentColorEnabled];
    [copy HSTransparentColorNodeUnit_setTransparentColor:_transparentColor];
    [copy setHueToleranceAsDouble:_hueTolerance];
    [copy setChromaToleranceAsDouble:_chromaTolerance];
    [copy setLightnessToleranceAsDouble:_lightnessTolerance];
    return copy;
}

- (void)HSTransparentColorNodeUnit_setTransparentColor:(id)aColor
{
    [aColor retain];
    [_transparentColor release];
    _transparentColor = aColor;
}

- (void)HSTransparentColorNodeUnit_setTransparentColorEnabled:(BOOL)aEnabled
{
    _isTransparentColorEnabled = aEnabled;
}

// Older documents store one tolerance for all three components.
- (void)setToleranceAsDouble:(double)aDouble
{
    _hueTolerance = aDouble;
    _chromaTolerance = aDouble;
    _lightnessTolerance = aDouble;
}

- (double)toleranceAsDouble
{
    return 0.0;
}

- (void)setLightnessToleranceAsDouble:(double)aDouble
{
    _lightnessTolerance = aDouble;
}

- (double)lightnessToleranceAsDouble
{
    return _lightnessTolerance;
}

- (void)setChromaToleranceAsDouble:(double)aDouble
{
    _chromaTolerance = aDouble;
}

- (double)chromaToleranceAsDouble
{
    return _chromaTolerance;
}

- (void)setHueToleranceAsDouble:(double)aDouble
{
    _hueTolerance = aDouble;
}

- (double)hueToleranceAsDouble
{
    return _hueTolerance;
}

- (void)setTransparentColorAsColor:(id)aColor
{
    NSColor *color = [[self HSTransparentColorNodeUnit_preprocessColor:aColor] retain];
    [_transparentColor release];
    _transparentColor = color;
    _isTransparentColorEnabled = color != nil;
}

- (id)transparentColorAsColor
{
    return _transparentColor;
}

// Note: the color keys are only loaded when the unit is disabled or has no
// color yet (original behaviour).
- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [[[super keysForExtraLoadingWithCodingContext:aContext] mutableCopy] autorelease];
    [keys addObject:@"toleranceAsDouble"];
    if (!_isTransparentColorEnabled || _transparentColor == nil) {
        [keys addObject:[@"transparentColorAsColor" extraKeyForMultiRepresentations]];
        [keys addObject:@"hueToleranceAsDouble"];
        [keys addObject:@"chromaToleranceAsDouble"];
        [keys addObject:@"lightnessToleranceAsDouble"];
    }
    return keys;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    if (!_isTransparentColorEnabled || _transparentColor == nil)
        return [super keysForExtraStoringWithCodingContext:aContext];
    NSMutableArray *keys = [[[super keysForExtraStoringWithCodingContext:aContext] mutableCopy] autorelease];
    [keys addObject:[@"transparentColorAsColor" extraKeyForMultiRepresentations]];
    [keys addObject:@"hueToleranceAsDouble"];
    [keys addObject:@"chromaToleranceAsDouble"];
    [keys addObject:@"lightnessToleranceAsDouble"];
    return keys;
}

// Device colors are moved into the main display's color space.
- (id)HSTransparentColorNodeUnit_preprocessColor:(id)aColor
{
    NSString *colorSpaceName = [aColor colorSpaceName];
    if (![colorSpaceName isEqualToString:NSDeviceWhiteColorSpace] && ![colorSpaceName isEqualToString:NSDeviceBlackColorSpace]
        && ![colorSpaceName isEqualToString:NSDeviceRGBColorSpace] && ![colorSpaceName isEqualToString:NSDeviceCMYKColorSpace])
        return aColor;
    // Original: ColorSync profile of the main display (CMGetProfileByAVID).
    CGColorSpaceRef displayColorSpace = CGDisplayCopyColorSpace(CGMainDisplayID());
    if (displayColorSpace == NULL)
        return aColor;
    NSColorSpace *colorSpace = [[NSColorSpace alloc] initWithCGColorSpace:displayColorSpace];
    CGColorSpaceRelease(displayColorSpace);
    if (colorSpace == nil)
        return aColor;
    NSColor *converted = [aColor colorUsingColorSpace:colorSpace];
    [colorSpace release];
    return converted != nil ? converted : aColor;
}

- (void)dealloc
{
    [_transparentColor release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _hueTolerance = 0.13;
        _chromaTolerance = 0.13;
        _lightnessTolerance = 0.13;
    }
    return self;
}

@end
