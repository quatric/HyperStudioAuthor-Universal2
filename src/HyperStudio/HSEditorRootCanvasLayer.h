#import "HyperStudioPrefix.h"


@interface HSEditorRootCanvasLayer : HSRootCanvasLayer
{
}
+ (id)arrowToolIdentifiers;
+ (id)supportedIdentifiers;
- (void)renderTopLayersInRect:(NSRect)aRect;
- (void)renderBitmapToolsLayerInRect:(NSRect)aRect;
- (NSRange)rangeOfBottomLayers;
- (void)setRepresentedObject:(id)aObject;
- (void)setCard:(id)aCard;
- (id)card;
- (id)arrowToolIdentifiers;
- (id)vectorToolsIdentifiers;
- (id)bitmapToolsIdentifiers;
- (void)fixOnionSkinCanvasLayerIfNeeded;
- (BOOL)isEnabledOnionSkinNextCanvasLayer;
- (BOOL)isEnabledOnionSkinPreviousCanvasLayer;
- (id)enabledArrowToolCanvasLayer;
- (id)runtimeEditorCanvasLayer;
- (id)arrowToolCanvasLayer;
- (id)vectorToolsCanvasLayer;
- (id)bitmapToolsSelectionCanvasLayer;
- (id)bitmapToolsCanvasLayer;
- (void)dealloc;
- (id)init;
- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory;
- (id)sublayerFactory;
@end

