#import "HyperEditorBasePrefix.h"


@interface HSRangeCell : NSActionCell
{
    double _duration;
    double _startTime;
    double _finishTime;
    NSTextFieldCell *_startTextField;
    NSTextFieldCell *_finishTextField;
    HSRangeKnobsCell *_rangeKnobsSubCell;
    HSRangeIndicatorCell *_rangeIndicatorSubCell;
    int _focusedKnobs;
    int _timeFormatLength;
    NSCell *_trackingCell;
    SEL _leftKnobClickAction;
    SEL _rightKnobClickAction;
}
+ (BOOL)prefersTrackingUntilMouseUp;
- (void)setControlSize:(NSUInteger)aSize;
- (void)setFinishTextFieldValue:(double)aValue;
- (void)setStartTextFieldValue:(double)aValue;
- (void)updateTimeFormatWithIndicatorLength:(CGFloat)aLength;
- (NSInteger)timeFormatLength;
- (void)setTimeFormatLength:(NSInteger)aLength;
- (id)dateFormatterForLength:(NSInteger)aLength;
- (double)secondsValueAtPosition:(CGFloat)aPosition inFrame:(NSRect)aFrame;
- (CGFloat)positionFromFinishTimeSecondsValueInFrame:(NSRect)aFrame;
- (CGFloat)positionFromStartTimeSecondsValueInFrame:(NSRect)aFrame;
- (void)update;
- (void)setEnabled:(BOOL)aEnabled;
- (void)stopTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView mouseIsUp:(BOOL)aUp;
- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView;
- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView;
- (void)setFocusedKnobs:(NSInteger)aKnobs;
- (NSInteger)focusedKnobs;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)shiftTimeBoundsForDelta:(double)aDelta;
- (SEL)rightKnobClickAction;
- (void)setRightKnobClickAction:(SEL)aAction;
- (SEL)leftKnobClickAction;
- (void)setLeftKnobClickAction:(SEL)aAction;
- (NSRect)indicatorRectInFrame:(NSRect)aFrame;
- (NSRect)activeIndicatorRectInFrame:(NSRect)aFrame;
- (NSRect)rightKnobRectInFrame:(NSRect)aFrame;
- (NSRect)leftKnobRectInFrame:(NSRect)aFrame;
- (CGFloat)indicatorLengthForFrame:(NSRect)aFrame;
- (void)setFinishTime:(double)aTime;
- (double)finishTime;
- (void)setStartTime:(double)aTime;
- (double)startTime;
- (void)setDuration:(double)aDuration;
- (double)duration;
- (void)dealloc;
- (id)init;
@end

