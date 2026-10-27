#import "HyperPlayerBasePrefix.h"
#import "HSNamedSublayersCanvasLayer.h"


@interface HSInteractivePlayerCanvasLayer : HSNamedSublayersCanvasLayer
{
}
+ (id)supportedIdentifiers;
- (id)interactiveObjectsLayer;
- (id)init;
- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory;
- (id)sublayerFactory;
@end

