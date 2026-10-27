#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSTransparentColorNodeUnit : HSNodeUnit
{
    NSColor *_transparentColor;
    double _hueTolerance;
    double _chromaTolerance;
    double _lightnessTolerance;
    BOOL _isTransparentColorEnabled;
}
- (void)setLightnessTolerance:(double)aTolerance;
- (double)lightnessTolerance;
- (void)setChromaTolerance:(double)aTolerance;
- (double)chromaTolerance;
- (void)setHueTolerance:(double)aTolerance;
- (double)hueTolerance;
- (void)setTransparentColor:(id)aColor;
- (id)transparentColor;
- (void)setTransparentColorEnabled:(BOOL)aEnabled;
- (BOOL)isTransparentColorEnabled;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (id)copyWithZone:(NSZone *)aZone;
- (void)HSTransparentColorNodeUnit_setTransparentColor:(id)aColor;
- (void)HSTransparentColorNodeUnit_setTransparentColorEnabled:(BOOL)aEnabled;
- (void)setToleranceAsDouble:(double)aDouble;
- (double)toleranceAsDouble;
- (void)setLightnessToleranceAsDouble:(double)aDouble;
- (double)lightnessToleranceAsDouble;
- (void)setChromaToleranceAsDouble:(double)aDouble;
- (double)chromaToleranceAsDouble;
- (void)setHueToleranceAsDouble:(double)aDouble;
- (double)hueToleranceAsDouble;
- (void)setTransparentColorAsColor:(id)aColor;
- (id)transparentColorAsColor;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)HSTransparentColorNodeUnit_preprocessColor:(id)aColor;
- (void)dealloc;
- (id)init;
@end

