#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSPlaceObjectTool : HSTool <HSPlaceObjectCanvasLayerOwner>
{
    id<HSPlaceObjectToolDelegate> _delegate;
    HSPlaceObjectCanvasLayer *_placeObjectCanvasLayer;
    NSPoint _lastPoint;
    BOOL _needsAddObject;
}
- (void)placeObjectCanvasLayer:(id)aLayer mouseMovedToPoint:(NSPoint)aPoint;
- (void)cancelPlacingObjectForPlaceObjectCanvasLayer:(id)aLayer;
- (void)finishPlacingObjectForPlaceObjectCanvasLayer:(id)aLayer;
- (void)removeObject;
- (void)addObject;
- (void)run;
- (id)placeObjectCanvasLayer;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (BOOL)allowsActiveInPlaceEditors;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (BOOL)shouldResetToolOnSelectObjects;
- (BOOL)shouldResetToolOnAddObjects;
- (void)dealloc;
@end

