#import "HyperStudioPrefix.h"


@interface HSArrowToolCanvasLayer : HSNamedSublayersCanvasLayer
{
    NSArray *_overridingOrderArray;
}
+ (id)supportedIdentifiers;
- (void)setEnabledSublayerIdentifiers:(id)aIdentifiers;
- (void)setEnabledSublayerIdentifiersWithOrder:(id)aOrder;
- (void)setOverridingOrderArray:(id)aArray;
- (id)enabledSelectedObjectsLayer;
- (id)enabledSelectionLayer;
- (id)enabledLayoutRulesLayer;
- (void)dealloc;
- (id)init;
- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory;
- (id)sublayerFactory;
@end

