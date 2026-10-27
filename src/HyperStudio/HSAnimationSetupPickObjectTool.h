#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSAnimationSetupPickObjectTool : HSTool <HSAnimationPickObjectCanvasLayerDelegate>
{
    id<HSAnimationSetupPickObjectToolDelegate> _delegate;
    HSAuxiliaryVisualizationCanvasLayer *_visualizationCanvasLayer;
    id _highlightedObject;
}
- (void)cancelFromPickObjectCanvasLayer:(id)aLayer;
- (void)animationPickObjectCanvasLayer:(id)aLayer pickedObject:(id)aObject final:(BOOL)aFinal event:(id)aEvent;
- (void)highlightObject:(id)aObject;
- (id)visualizationCanvasLayer;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (BOOL)allowsActiveInPlaceEditors;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (BOOL)shouldResetToolOnAddObjects;
- (void)dealloc;
@end

