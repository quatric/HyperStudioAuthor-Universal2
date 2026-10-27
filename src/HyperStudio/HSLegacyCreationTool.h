#import "HyperStudioPrefix.h"
#import "HSCreationTool.h"


@interface HSLegacyCreationTool : HSCreationTool <HSToolCanvasLayerClient, NSObject>
{
    BOOL _toolLayerIsSetUp;
}
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)cleanupToolLayer;
- (void)setupToolLayer;
- (id)toolLayer;
- (id)toolLayerNoVerify;
- (BOOL)worksInBitmapLayer;
- (id)defaultToolCursorName;
- (void)handleAutoscrollingWithMouseEvent:(id)aEvent;
- (void)handleFlagsChanged:(id)aChanged;
- (void)handleMouseUp:(id)aUp;
- (void)handleMouseDragged:(id)aDragged;
- (void)handleMouseDown:(id)aDown;
- (void)mouseMoved:(id)aMoved;
- (BOOL)wantsToSwitchToolInToolCanvasLayer:(id)aLayer event:(id)aEvent viewPoint:(NSPoint)aPoint newToolTag:(int *)aTag newTemplateIndex:(int *)aIndex skipToolApplying:(BOOL *)aApplying;
- (id)cursorForToolCanvasLayer:(id)aLayer;
- (BOOL)handleKeyEventSelector:(SEL)aSelector inToolCanvasLayer:(id)aLayer;
- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint inToolCanvasLayer:(id)aLayer;
- (BOOL)handleMouseMoved:(id)aMoved inToolCanvasLayer:(id)aLayer;
- (void)handleAutoscrollingWithMouseEvent:(id)aEvent whileTrackingInToolCanvasLayer:(id)aLayer;
- (BOOL)wantsAutoscrollingWhileTrackingInToolCanvasLayer:(id)aLayer;
- (void)handleFlagsChanged:(id)aChanged whileTrackingInToolCanvasLayer:(id)aLayer;
- (void)handleMouseUp:(id)aUp whileTrackingInToolCanvasLayer:(id)aLayer;
- (void)handleMouseDragged:(id)aDragged whileTrackingInToolCanvasLayer:(id)aLayer;
- (void)handleMouseDown:(id)aDown whileTrackingInToolCanvasLayer:(id)aLayer;
- (BOOL)wantsToTrackMouseInToolCanvasLayer:(id)aLayer;
@end

