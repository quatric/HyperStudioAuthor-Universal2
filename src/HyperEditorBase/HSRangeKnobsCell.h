#import "HyperEditorBasePrefix.h"


@interface HSRangeKnobsCell : NSActionCell
{
    NSImage *_currentTintInactiveLeftKnobImage;
    NSImage *_currentTintInactiveRightKnobImage;
    NSImage *_currentTintActiveLeftKnobImage;
    NSImage *_currentTintActiveRightKnobImage;
    NSImage *_rightKnobImage;
    NSImage *_leftKnobImage;
    id _parent;
    int _activeKnobsMask;
}
+ (NSSize)minimalCellSize;
+ (BOOL)prefersTrackingUntilMouseUp;
- (void)setParent:(id)aParent;
- (id)parent;
- (NSRect)rightKnobImageFrameForImageSize:(NSSize)aSize inFrame:(NSRect)aFrame;
- (NSRect)leftKnobImageFrameForImageSize:(NSSize)aSize inFrame:(NSRect)aFrame;
- (NSRect)rightKnobImageRectInFrame:(NSRect)aFrame;
- (NSRect)leftKnobImageRectInFrame:(NSRect)aFrame;
- (void)stopTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView mouseIsUp:(BOOL)aUp;
- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView;
- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView;
- (void)trackActiveKnobWithOffset:(CGFloat)aOffset inFrame:(NSRect)aFrame;
- (void)drawRightKnobAtPosition:(CGFloat)aPosition inView:(id)aView inRect:(NSRect)aRect;
- (void)drawLeftKnobAtPosition:(CGFloat)aPosition inView:(id)aView inRect:(NSRect)aRect;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)reloadImages;
- (void)controlTintDidChange:(id)aChange;
- (void)dealloc;
- (id)init;
@end

