#import "HSRangeCell.h"

// The range of a movie: an indicator of the duration with the selected
// part, its start and finish knobs, and their times written below.

@implementation HSRangeCell

+ (BOOL)prefersTrackingUntilMouseUp
{
    return YES;
}

- (void)setControlSize:(NSUInteger)aSize
{
    [super setControlSize:aSize];
    [_startTextField setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:aSize]]];
    [_finishTextField setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:aSize]]];
}

- (void)setFinishTextFieldValue:(double)aValue
{
    [_finishTextField setObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:aValue]];
}

- (void)setStartTextFieldValue:(double)aValue
{
    [_startTextField setObjectValue:[NSDate dateWithTimeIntervalSinceReferenceDate:aValue]];
}

// The longest time format (H:mm:ss, mm:ss, ss) where both times fit.
- (void)updateTimeFormatWithIndicatorLength:(CGFloat)aLength
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[_startTextField font], NSFontAttributeName, nil];
    // NSCalendarDate (of the seconds) in the original.
    NSDate *start = [NSDate dateWithTimeIntervalSinceReferenceDate:(unsigned int)_startTime];
    NSDate *finish = [NSDate dateWithTimeIntervalSinceReferenceDate:(unsigned int)_finishTime];
    NSInteger length = 2;
    while (YES) {
        NSDateFormatter *formatter = [self dateFormatterForLength:length];
        CGFloat startWidth = [[formatter stringFromDate:start] sizeWithAttributes:attributes].width;
        CGFloat finishWidth = [[formatter stringFromDate:finish] sizeWithAttributes:attributes].width;
        if (finishWidth + startWidth + 5.0 < aLength)
            break;
        length--;
    }
    [self setTimeFormatLength:length];
}

- (NSInteger)timeFormatLength
{
    return _timeFormatLength;
}

- (void)setTimeFormatLength:(NSInteger)aLength
{
    if (_timeFormatLength != aLength) {
        _timeFormatLength = (int)aLength;
        NSDateFormatter *formatter = [self dateFormatterForLength:aLength];
        [_startTextField setFormatter:formatter];
        [_finishTextField setFormatter:formatter];
    }
}

- (id)dateFormatterForLength:(NSInteger)aLength
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    if (aLength == 0)
        [formatter setDateFormat:@"ss"];
    else if (aLength == 1)
        [formatter setDateFormat:@"mm:ss"];
    else if (aLength == 2)
        [formatter setDateFormat:@"H:mm:ss"];
    return [formatter autorelease];
}

- (double)secondsValueAtPosition:(CGFloat)aPosition inFrame:(NSRect)aFrame
{
    float length = [self indicatorLengthForFrame:aFrame];
    float position = aPosition;
    if (position >= 0 && position <= length)
        return (double)position * _duration / (length != 0 ? (double)length : 1.0);
    if (position >= 0 && position > length)
        return _duration;
    return 0;
}

- (CGFloat)positionFromFinishTimeSecondsValueInFrame:(NSRect)aFrame
{
    if (_duration == 0)
        _duration = 1;
    return (float)([self indicatorLengthForFrame:aFrame] * _finishTime / _duration);
}

- (CGFloat)positionFromStartTimeSecondsValueInFrame:(NSRect)aFrame
{
    if (_duration == 0)
        _duration = 1;
    return (float)([self indicatorLengthForFrame:aFrame] * _startTime / _duration);
}

- (void)update
{
    id view = [self controlView];
    if ([view isKindOfClass:[NSControl class]])
        [(NSControl *)view updateCell:self];
}

- (void)setEnabled:(BOOL)aEnabled
{
    [_rangeKnobsSubCell setEnabled:aEnabled];
    [_rangeIndicatorSubCell setEnabled:aEnabled];
    [super setEnabled:aEnabled];
}

- (void)stopTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView mouseIsUp:(BOOL)aUp
{
    [_trackingCell stopTracking:aTracking at:aAt inView:aView mouseIsUp:aUp];
    _trackingCell = nil;
}

- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView
{
    return [_trackingCell continueTracking:aTracking at:aAt inView:aView];
}

// The indicator (moving the range), else the knobs.
- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView
{
    if ([_rangeIndicatorSubCell startTrackingAt:aAt inView:aView])
        _trackingCell = _rangeIndicatorSubCell;
    else if ([_rangeKnobsSubCell startTrackingAt:aAt inView:aView])
        _trackingCell = _rangeKnobsSubCell;
    return _trackingCell != nil;
}

- (void)setFocusedKnobs:(NSInteger)aKnobs
{
    _focusedKnobs = (int)aKnobs;
}

- (NSInteger)focusedKnobs
{
    return _focusedKnobs;
}

// The times go below the knobs, if there's room.
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    [_rangeIndicatorSubCell drawInteriorWithFrame:aFrame inView:aView];
    [_rangeKnobsSubCell drawInteriorWithFrame:aFrame inView:aView];
    if (_startTextField == nil || _finishTextField == nil)
        return;
    NSSize indicatorSize = [[_rangeIndicatorSubCell class] minimalCellSize];
    NSSize knobsSize = [[_rangeKnobsSubCell class] minimalCellSize];
    CGFloat textHeight = [_startTextField cellSize].height;
    NSColor *color = [self isEnabled] ? [NSColor blackColor] : [NSColor grayColor];
    [_startTextField setTextColor:color];
    [_finishTextField setTextColor:color];
    float y = aFrame.size.height - (knobsSize.height + indicatorSize.height) - 1.0 - textHeight;
    if (y < 0)
        return;
    [self updateTimeFormatWithIndicatorLength:[self indicatorLengthForFrame:aFrame]];
    NSRect rect = NSMakeRect(knobsSize.width * 0.5 - 1.0 - 1.0, y, aFrame.size.width - knobsSize.width + 4.0, textHeight);
    [_startTextField drawInteriorWithFrame:rect inView:aView];
    [_finishTextField drawInteriorWithFrame:rect inView:aView];
}

// Moves the focused knobs (both keep the range's length within the
// duration) and tells the control's target.
- (void)shiftTimeBoundsForDelta:(double)aDelta
{
    double start = [self startTime] + aDelta;
    double finish = aDelta + [self finishTime];
    double length = [self finishTime] - [self startTime];
    NSControl *view = (NSControl *)[self controlView];
    if (_focusedKnobs == 3) {
        if (start < 0 || finish < start) {
            [self setStartTime:0];
            [self setFinishTime:length];
        } else if ([self duration] < finish) {
            [self setFinishTime:[self duration]];
            [self setStartTime:[self finishTime] - length];
        } else {
            [self setStartTime:start];
            [self setFinishTime:finish];
        }
    } else if (_focusedKnobs == 2)
        [self setFinishTime:finish];
    else if (_focusedKnobs == 1)
        [self setStartTime:start];
    [view sendAction:[view action] to:[view target]];
}

- (SEL)rightKnobClickAction
{
    return _rightKnobClickAction;
}

- (void)setRightKnobClickAction:(SEL)aAction
{
    _rightKnobClickAction = aAction;
}

- (SEL)leftKnobClickAction
{
    return _leftKnobClickAction;
}

- (void)setLeftKnobClickAction:(SEL)aAction
{
    _leftKnobClickAction = aAction;
}

// The indicator lies at the bottom, above the knobs, half a knob in.
- (NSRect)indicatorRectInFrame:(NSRect)aFrame
{
    NSSize knobsSize = [[_rangeKnobsSubCell class] minimalCellSize];
    NSSize indicatorSize = [[_rangeIndicatorSubCell class] minimalCellSize];
    return NSMakeRect(knobsSize.width * 0.5, aFrame.size.height - (indicatorSize.height + knobsSize.height), [self indicatorLengthForFrame:aFrame], indicatorSize.height);
}

- (NSRect)activeIndicatorRectInFrame:(NSRect)aFrame
{
    NSSize knobsSize = [[_rangeKnobsSubCell class] minimalCellSize];
    NSSize indicatorSize = [[_rangeIndicatorSubCell class] minimalCellSize];
    float start = [self positionFromStartTimeSecondsValueInFrame:aFrame];
    float finish = [self positionFromFinishTimeSecondsValueInFrame:aFrame];
    return NSMakeRect(knobsSize.width * 0.5 + start, aFrame.size.height - (indicatorSize.height + knobsSize.height), finish - [self positionFromStartTimeSecondsValueInFrame:aFrame], indicatorSize.height);
}

- (NSRect)rightKnobRectInFrame:(NSRect)aFrame
{
    NSSize knobsSize = [[_rangeKnobsSubCell class] minimalCellSize];
    float position = [self positionFromFinishTimeSecondsValueInFrame:aFrame];
    return NSMakeRect(position + knobsSize.width * 0.5, aFrame.size.height - knobsSize.height, knobsSize.width * 0.5, knobsSize.height);
}

- (NSRect)leftKnobRectInFrame:(NSRect)aFrame
{
    NSSize knobsSize = [[_rangeKnobsSubCell class] minimalCellSize];
    float position = [self positionFromStartTimeSecondsValueInFrame:aFrame];
    return NSMakeRect(position, aFrame.size.height - knobsSize.height, knobsSize.width * 0.5, knobsSize.height);
}

- (CGFloat)indicatorLengthForFrame:(NSRect)aFrame
{
    float width = aFrame.size.width;
    if (width != 0)
        width = width - [[_rangeKnobsSubCell class] minimalCellSize].width;
    return width;
}

// Kept within the start time and the duration.
- (void)setFinishTime:(double)aTime
{
    double time = aTime;
    if (time < _startTime)
        time = _startTime;
    else if (_duration < time)
        time = _duration;
    _finishTime = time;
    [self setFinishTextFieldValue:time];
    [self update];
}

- (double)finishTime
{
    return _finishTime;
}

// Kept within 0 and the finish time (the duration if none yet).
- (void)setStartTime:(double)aTime
{
    if (_finishTime == 0)
        _finishTime = _duration;
    double time = aTime;
    if (time < 0)
        time = 0;
    else if (_finishTime < time)
        time = _finishTime;
    _startTime = time;
    [self setStartTextFieldValue:time];
    [self update];
}

- (double)startTime
{
    return _startTime;
}

- (void)setDuration:(double)aDuration
{
    if (_duration != aDuration) {
        [self setEnabled:aDuration != 0];
        _duration = aDuration;
        [self setFinishTime:aDuration];
        [self update];
    }
}

- (double)duration
{
    return _duration;
}

- (void)dealloc
{
    [_startTextField release];
    [_finishTextField release];
    if ([_rangeKnobsSubCell parent] == self)
        [_rangeKnobsSubCell setParent:nil];
    [_rangeKnobsSubCell release];
    if ([_rangeIndicatorSubCell parent] == self)
        [_rangeIndicatorSubCell setParent:nil];
    [_rangeIndicatorSubCell release];
    [super dealloc];
}

// The start time on the left, the finish time on the right.
- (id)init
{
    if ((self = [super init])) {
        _startTextField = [NSTextFieldCell new];
        [_startTextField setAlignment:NSTextAlignmentLeft];
        [self setStartTextFieldValue:0];
        _finishTextField = [NSTextFieldCell new];
        [_finishTextField setAlignment:NSTextAlignmentRight];
        [self setFinishTextFieldValue:0];
        _rangeKnobsSubCell = [HSRangeKnobsCell new];
        [_rangeKnobsSubCell setParent:self];
        _rangeIndicatorSubCell = [HSRangeIndicatorCell new];
        [_rangeIndicatorSubCell setParent:self];
    }
    return self;
}

@end
