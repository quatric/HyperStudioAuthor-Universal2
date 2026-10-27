#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSGeometryBehaviorNodeUnit : HSNodeUnit
{
    BOOL _prefersToMaintainSizeScaleAspectRatio;
}
- (void)setPrefersToMaintainSizeScaleAspectRatio:(BOOL)aRatio;
- (BOOL)prefersToMaintainSizeScaleAspectRatio;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)copyWithZone:(NSZone *)aZone;
@end

