#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSResizingBehaviorNodeUnit : HSNodeUnit
{
    BOOL _prefersToMaintainSizeAspectRatio;
}
- (void)setPrefersToMaintainSizeAspectRatio:(BOOL)aRatio;
- (BOOL)prefersToMaintainSizeAspectRatio;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)copyWithZone:(NSZone *)aZone;
@end

