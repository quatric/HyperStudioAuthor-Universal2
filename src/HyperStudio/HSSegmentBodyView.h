#import "HyperStudioPrefix.h"


@interface HSSegmentBodyView : NSView
{
    HSSegmentView *_segmentView;
    NSMutableArray *_graphicObjects;
    HSSegmentGuiderGraphicObject *_guider;
    BOOL _isTracking;
    BOOL _isTrackingCurrentTime;
    int _trackingPegIndex;
}
- (BOOL)needsAutoscrollForMouseEvent:(id)aEvent;
- (void)startTrackingWithEvent:(id)aEvent;
- (id)objectHitTest:(NSPoint)aTest;
- (void)handleMouseDragged:(id)aDragged;
- (void)mouseDown:(id)aDown;
- (void)drawRect:(NSRect)aRect;
- (void)resetCursorRects;
- (BOOL)isOpaque;
- (void)setupGuider;
- (void)setupPegs;
- (void)setupSelection;
- (void)setupBody;
- (void)setupBackground;
- (void)refreshCurrentValue;
- (void)refresh;
- (id)segmentView;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame segmentView:(id)aView;
@end

