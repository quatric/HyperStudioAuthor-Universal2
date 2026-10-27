#import "HyperPlayerBasePrefix.h"


@interface HSTrackingLoop : NSObject
{
    HSView *_view;
    id _client;
    HSCursor *_cursor;
    BOOL _isRunning;
    BOOL _isTracking;
    BOOL _wasTracked;
    BOOL _isAutoscrollingEnabled;
    BOOL _clientImplementsCursorOverriding;
    BOOL _isAborted;
    NSPoint _lastMouseLocation;
}
+ (id)autoscrollingTrackingLoopWithView:(id)aView client:(id)aClient;
+ (id)nonAutoscrollingTrackingLoopWithView:(id)aView client:(id)aClient;
+ (id)trackingLoopWithView:(id)aView client:(id)aClient;
- (NSPoint)lastMouseLocation;
- (BOOL)wasTracked;
- (BOOL)isTracking;
- (BOOL)isRunning;
- (void)pause;
- (void)resume;
- (void)abort;
- (void)runWithMouseDownEvent:(id)aEvent;
- (void)updateCursorWithMouseEvent:(id)aEvent handledByView:(BOOL *)aView;
- (void)autoscrollWithMouseDraggedEvent:(id)aEvent withClient:(id)aClient;
- (BOOL)mouseEventShouldCauseAutoscrolling:(id)aAutoscrolling withClient:(id)aClient;
- (void)setCursor:(id)aCursor;
- (id)cursor;
- (id)autoscrollingClient;
- (id)client;
- (BOOL)supportsAutoscrolling;
- (id)view;
- (void)dealloc;
- (id)initWithView:(id)aView client:(id)aClient autoscrolling:(BOOL)aAutoscrolling;
@end

