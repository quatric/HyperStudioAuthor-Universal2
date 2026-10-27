#import "HyperStudioPrefix.h"
#import "HSEffectTool.h"


@interface HSEffectPerObjectTool : HSEffectTool
{
    id _mouseDownObject;
    NSPoint _lastClickedCenter;
}
- (void)applyEffect:(id)aEffect centerPoint:(NSPoint)aPoint isNewCenterNearPrevious:(BOOL)aPrevious;
- (id)defaultEffectSettings:(NSPoint)aSettings intencity:(CGFloat)aIntencity;
- (void)handleMouseUp:(id)aUp whileTrackingInToolCanvasLayer:(id)aLayer;
- (void)handleMouseDown:(id)aDown whileTrackingInToolCanvasLayer:(id)aLayer;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
@end

