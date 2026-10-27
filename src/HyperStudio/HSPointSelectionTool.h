#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSPointSelectionTool : HSTool
{
    HSTrackingPointCanvasLayer *_trackingPointCanvasLayer;
    NSPoint _selectedPoint;
    id<HSPointSelectionToolDelegate> _delegate;
}
- (void)trackingPointCanvasLayerDidCancelTracking;
- (void)trackingPointCanvasLayer:(id)aLayer didFinishTrackingWithPoint:(NSPoint)aPoint;
- (NSPoint)trackingPointCanvasLayer:(id)aLayer shouldChoosePoint:(NSPoint)aPoint;
- (id)trackingPointCanvasLayer;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (NSPoint)selectedPoint;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (void)dealloc;
- (id)init;
@end

