#import "HyperStudioPrefix.h"
#import "HSLegacyLineTool.h"


@interface HSLegacyPolyCurveTool : HSLegacyLineTool
{
    BOOL _savedWindowAcceptsMouseMovedEventsFlag;
    BOOL _isStraightLineMode;
    BOOL _isAppendPending;
    BOOL _isAppendPendingWithCurrentPoint;
    NSPoint _pendingPoint;
    NSEvent *_autoscrollEvent;
}
+ (Class)userObjectClass;
- (void)prototypeObjectDidChange;
- (void)updatePrototypeWithObjectKindName;
- (id)localizedObjectKindName;
- (id)nonLocalizedObjectKindName;
- (BOOL)prototypeHasClosedPath;
- (void)performIdleMouseAutoscroll;
- (void)resetIdleMouseAutoscrollingWithMouseMovedEvent:(id)aEvent;
- (void)stopIdleMouseAutoscrolling;
- (void)startIdleMouseAutoscrollingWithMouseMovedEvent:(id)aEvent;
- (void)launchIdleMouseAutoscroll;
- (void)handleIdleMouseAutoscroll:(id)aAutoscroll;
- (void)autoscrollWithMouseEvent:(id)aEvent;
- (BOOL)needsAutoscrollForMouseEvent:(id)aEvent;
- (void)saveChangesAndNotify:(BOOL)aNotify;
- (void)cancelOperation:(id)aOperation;
- (void)handleMouseUp:(id)aUp;
- (void)handleAutoscrollingWithMouseEvent:(id)aEvent;
- (void)handleMouseDragged:(id)aDragged;
- (void)mouseMoved:(id)aMoved;
- (BOOL)shouldHandleMouseMovedEvent:(id)aEvent;
- (void)mouseEvent:(id)aEvent;
- (BOOL)isPointCloseToClosePath:(NSPoint)aPath;
- (void)handleMouseDown:(id)aDown;
- (NSUInteger)currentPointIndex;
- (NSInteger)editingMode;
- (void)setStraightLineMode:(BOOL)aMode;
- (BOOL)isStraightLineMode;
- (BOOL)isObjectResizedScaledProportionally;
- (BOOL)leaveTrackingObjectAndNotify:(BOOL)aNotify registerInCard:(BOOL)aCard forceSwitchTool:(BOOL)aTool;
- (void)setView:(id)aView;
- (void)dealloc;
@end

