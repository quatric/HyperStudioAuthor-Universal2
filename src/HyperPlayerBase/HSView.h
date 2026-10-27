#import "HyperPlayerBasePrefix.h"
#import "HSQuartzOpenGLView.h"


@interface HSView : HSQuartzOpenGLView
{
    int _cursorVisibilityState;
    int _previosCursorVisibilityState;
    unsigned int _contentChangesAccumulationCounter;
    NSMapTable *_drawingQualityLossAcceptanceRequests;
    float _acceptableDrawingQualityLoss;
    unsigned int _observesAndNotifiesOfSuperviewBoundsChanges:1;
    unsigned int _observesSuperviewNotifications:1;
    unsigned int _isAcceptableDrawingQualityLossCalculated:1;
}
- (void)interactiveSubviewDidUpdate;
- (BOOL)isRenderInteractiveSubview;
- (void)stopRenderInteractiveSubview;
- (void)beginRenderInteractiveSubview;
- (void)declineDrawingQualityLoss:(CGFloat)aLoss;
- (void)acceptDrawingQualityLoss:(CGFloat)aLoss;
- (CGFloat)acceptableDrawingQualityLoss;
- (void)viewDidMoveToSuperview;
- (void)viewWillMoveToSuperview:(id)aSuperview;
- (void)setObservesAndNotifiesOfSuperviewBoundsChanges:(BOOL)aChanges;
- (BOOL)observesAndNotifiesOfSuperviewBoundsChanges;
- (void)noteDidResetSuperview;
- (void)noteWillResetSuperview;
- (void)noteDidSetSuperview;
- (void)hyperSuperviewBoundsDidChange:(id)aChange;
- (void)noteSuperviewBoundsDidChange;
- (void)viewDidMoveToWindow;
- (void)viewWillMoveToWindow:(id)aWindow;
- (void)restorePreviosCursorVisabilityState;
- (void)savePreviosCursorVisabilityState;
- (void)obscureCursor;
- (void)hideCursor;
- (void)showCursor;
- (void)updateCursorAtPoint:(NSPoint)aPoint inside:(BOOL)aInside modifierFlags:(NSUInteger)aFlags event:(id)aEvent;
- (void)updateCursor;
- (void)updateCursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags event:(id)aEvent;
- (void)updateCursorWithMouseEvent:(id)aEvent;
- (void)updateCursorVisibilityAtPoint:(NSPoint)aPoint inside:(BOOL)aInside modifierFlags:(NSUInteger)aFlags event:(id)aEvent;
- (void)handleMouseMoved:(id)aMoved;
- (void)processAccumulatedContentChanges;
- (BOOL)areContentChangesBeingAccumulated;
- (void)endContentChangeAccumulation;
- (void)beginContentChangeAccumulation;
- (NSRect)userBoundingRectForViewRect:(NSRect)aRect;
- (NSRect)viewBoundingRectForUserRect:(NSRect)aRect;
- (NSPoint)convertPointFromViewSpaceToUserSpace:(NSPoint)aSpace;
- (NSPoint)convertPointFromUserSpaceToViewSpace:(NSPoint)aSpace;
- (CGAffineTransform)viewSpaceToUserSpaceCGAffineTransform;
- (id)viewSpaceToUserSpaceTransform;
- (CGAffineTransform)userSpaceToViewSpaceCGAffineTransform;
- (id)userSpaceToViewSpaceTransform;
- (void)dealloc;
- (CGAffineTransform)userSpaceToViewSpaceCGAffineTransformForZoomFactor:(CGFloat)aFactor;
@end

