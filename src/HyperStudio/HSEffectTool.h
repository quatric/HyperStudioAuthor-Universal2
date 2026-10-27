#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSEffectTool : HSTool <HSToolCanvasLayerClient, NSObject>
{
    HSEffect *_effect;
    float _intencity;
    NSImage *_previewInputImage;
    HSDragCardViewCanvasLayer *_dragCardCanvasLayer;
}
- (id)effectDisplayName;
- (id)effectPreviewImage;
- (id)effect;
- (id)defaultEffectSettings:(NSPoint)aSettings intencity:(CGFloat)aIntencity;
- (id)previewInputImage;
- (void)setEffectIntencity:(CGFloat)aIntencity;
- (CGFloat)effectIntencity;
- (BOOL)isIntencitySupported;
- (id)effectName;
- (void)setEffectName:(id)aName;
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
- (id)applyEffectToImage:(id)aImage atPoint:(NSPoint)aPoint frameSize:(NSSize)aSize;
- (BOOL)wantsToTrackMouseInToolCanvasLayer:(id)aLayer;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (id)settingsIdentifiers;
- (id)primarySettingsIdentifier;
- (void)dealloc;
@end

