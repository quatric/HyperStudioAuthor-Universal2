#import "HyperPlayerBasePrefix.h"
#import "HSRootCanvasLayer.h"


@interface HSPlayerRootCanvasLayer : HSRootCanvasLayer
{
}
+ (id)supportedIdentifiers;
- (void)setRepresentedObject:(id)aObject;
- (void)setCard:(id)aCard;
- (id)card;
- (id)interactiveObjectsLayer;
- (id)interactivePlayerCanvasLayer;
- (id)init;
- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory;
- (id)sublayerFactory;
@end

