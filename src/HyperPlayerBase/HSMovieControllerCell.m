#import "HSMovieControllerCell.h"
#import "HSFunctions.h"
#import "HSPlayerBaseID.h"
#import "HSView.h"

// Float compare with the relative tolerance used throughout the player.
static BOOL HSMovieControllerDurationIsPositive(float aDuration)
{
    float magnitude = aDuration != 0.0f ? fabsf(aDuration) : 1.0f;
    float tolerance = magnitude > 1.0f ? magnitude * 0.0005f : 0.0005f;
    return aDuration > 0.0f + tolerance;
}

@implementation HSMovieControllerCell

+ (id)sliderBackgroundImage
{
    static NSImage *image = nil;
    if (image == nil)
        image = [[HSPlayerBaseID imageNamed:@"MovieSliderBackground"] retain];
    return image;
}

+ (id)goToEndButtonImage
{
    static NSImage *image = nil;
    if (image == nil)
        image = [[HSPlayerBaseID imageNamed:@"MovieGoToEndButton"] retain];
    return image;
}

+ (id)goToBeginningButtonImage
{
    static NSImage *image = nil;
    if (image == nil)
        image = [[HSPlayerBaseID imageNamed:@"MovieGoToBeginningButton"] retain];
    return image;
}

+ (id)stopButtonImage
{
    static NSImage *image = nil;
    if (image == nil)
        image = [[HSPlayerBaseID imageNamed:@"MovieStopButton"] retain];
    return image;
}

+ (id)playButtonImage
{
    static NSImage *image = nil;
    if (image == nil)
        image = [[HSPlayerBaseID imageNamed:@"MoviePlayButton"] retain];
    return image;
}

+ (NSRect)goToEndButtonFrameForControllerArea:(NSRect)aArea
{
    CGFloat width = [(NSImage *)[self goToEndButtonImage] size].width;
    return NSMakeRect(aArea.size.width - width + aArea.origin.x, aArea.origin.y, width, aArea.size.height);
}

+ (NSRect)goToBeginningButtonFrameForControllerArea:(NSRect)aArea
{
    CGFloat width = [(NSImage *)[self goToBeginningButtonImage] size].width;
    NSRect endFrame = [self goToEndButtonFrameForControllerArea:aArea];
    return NSMakeRect(aArea.size.width - endFrame.size.width - width + aArea.origin.x, aArea.origin.y, width, aArea.size.height);
}

+ (NSRect)sliderFrameForControllerArea:(NSRect)aArea
{
    float width = aArea.size.width;
    width -= [self playStopButtonFrameForControllerArea:aArea].size.width;
    width -= [self goToBeginningButtonFrameForControllerArea:aArea].size.width;
    width -= [self goToEndButtonFrameForControllerArea:aArea].size.width;
    NSRect playStopFrame = [self playStopButtonFrameForControllerArea:aArea];
    return NSMakeRect(aArea.origin.x + playStopFrame.size.width, aArea.origin.y, width < 0.0f ? 1.0f : width, aArea.size.height);
}

+ (NSRect)playStopButtonFrameForControllerArea:(NSRect)aArea
{
    return NSMakeRect(aArea.origin.x, aArea.origin.y, [(NSImage *)[self playButtonImage] size].width, aArea.size.height);
}

- (void)notifyDelegateForNeedsDisplay
{
    [[self delegate] setNeedsDisplayForController:self];
}

- (void)stepBackward:(id)aBackward
{
    [_delegate stepBackwardForMovieController:self];
}

- (void)stepForward:(id)aForward
{
    [_delegate stepForwardForMovieController:self];
}

- (void)onGoToEnd:(id)aEnd
{
    [_delegate gotoEndForMovieController:self];
}

- (void)onGoToBeginning:(id)aBeginning
{
    [_delegate gotoBeginningForMovieController:self];
}

- (void)onSlide:(id)aSlide
{
    double duration = [_delegate durationForMovieController:self];
    [_delegate movieController:self setCurrentTime:[_sliderCell floatValue] * duration];
    float value = 0.0f;
    if (HSMovieControllerDurationIsPositive((float)duration))
        value = [_delegate currentTimeForMovieController:self] / duration;
    [_sliderCell setFloatValue:value];
    [_delegate slideWasPlaying:[self wasPlayingBeforeSliding] isFinal:![self isSliding] forMovieController:self];
}

- (void)onPlayStop:(id)aStop
{
    // A click inside toggles; releasing outside keeps the previous state.
    BOOL startPlaying = ![self wasPlayingBeforeTracking] && [self isTrackingInsideButtonCell];
    BOOL keepPlaying = [self wasPlayingBeforeTracking] && ![self isTrackingInsideButtonCell];
    if (keepPlaying || startPlaying)
        [_delegate playForMovieController:self];
    else
        [_delegate stopForMovieController:self];
}

- (BOOL)wasPlayingBeforeSliding
{
    return _wasPlayingBeforeSliding;
}

- (BOOL)isSliding
{
    return _isSliding;
}

- (BOOL)wasPlayingBeforeTracking
{
    return _wasPlayingBeforeTracking;
}

- (BOOL)isTrackingInsideButtonCell
{
    return _isTrackingInsideButtonCell;
}

- (BOOL)isTracking
{
    return _isTracking;
}

- (void)trackSliderCell:(id)aCell origin:(NSPoint)aOrigin event:(id)aEvent view:(id)aView cellFrame:(NSRect)aFrame
{
    NSCell *cell = aCell;
    NSPoint lastPoint = [aView convertPointFromViewSpaceToUserSpace:[aView convertPoint:[aEvent locationInWindow] fromView:nil]];
    lastPoint.x -= aOrigin.x;
    if (![aCell startTrackingAt:lastPoint inView:aView])
        return;

    [NSApp sendAction:[cell action] to:[cell target] from:nil];
    BOOL keepTracking;
    do {
        NSEvent *event;
        NSPoint point;
        do {
            event = [[aView window] nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged untilDate:[NSDate distantFuture] inMode:NSDefaultRunLoopMode dequeue:YES];
            point = [aView convertPointFromViewSpaceToUserSpace:[aView convertPoint:[event locationInWindow] fromView:nil]];
            point.x -= aOrigin.x;
            if ([event type] == NSEventTypeLeftMouseUp) {
                [aView setNeedsDisplay:YES];
                [self notifyDelegateForNeedsDisplay];
                [NSApp sendAction:[cell action] to:[cell target] from:nil];
                [aCell stopTracking:lastPoint at:point inView:aView mouseIsUp:YES];
                return;
            }
        } while ([event type] != NSEventTypeLeftMouseDragged);

        [aView setNeedsDisplay:YES];
        [self notifyDelegateForNeedsDisplay];
        [NSApp sendAction:[cell action] to:[cell target] from:nil];
        keepTracking = [aCell continueTracking:lastPoint at:point inView:aView];
        lastPoint = point;
    } while (keepTracking);
}

- (void)trackButtonCell:(id)aCell frame:(NSRect)aFrame event:(id)aEvent view:(id)aView sendActionContinuously:(BOOL)aContinuously
{
    NSCell *cell = aCell;
    _isTracking = aContinuously;
    _isTrackingInsideButtonCell = YES;
    [aCell setHighlighted:YES];
    [aView setNeedsDisplay:YES];
    [self notifyDelegateForNeedsDisplay];

    for (;;) {
        NSEvent *event = [[aView window] nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged untilDate:[NSDate distantFuture] inMode:NSDefaultRunLoopMode dequeue:YES];
        NSPoint point = [aView convertPointFromViewSpaceToUserSpace:[aView convertPoint:[event locationInWindow] fromView:nil]];
        _isTrackingInsideButtonCell = NSPointInRect(point, aFrame);
        if ([event type] == NSEventTypeLeftMouseUp)
            break;
        if ([event type] == NSEventTypeLeftMouseDragged) {
            [aCell setHighlighted:_isTrackingInsideButtonCell];
            [aView setNeedsDisplay:YES];
            [self notifyDelegateForNeedsDisplay];
            if (aContinuously)
                [NSApp sendAction:[cell action] to:[cell target] from:nil];
        }
    }

    [aCell setHighlighted:NO];
    [aView setNeedsDisplay:YES];
    [self notifyDelegateForNeedsDisplay];
    if (aContinuously || _isTrackingInsideButtonCell)
        [NSApp sendAction:[cell action] to:[cell target] from:nil];
    _isTrackingInsideButtonCell = NO;
    _isTracking = NO;
}

- (void)handleMouseDown:(id)aDown inRect:(NSRect)aRect ofView:(id)aView
{
    NSPoint point = [aView convertPointFromViewSpaceToUserSpace:[aView convertPoint:[aDown locationInWindow] fromView:nil]];
    NSRect playStopFrame = [[self class] playStopButtonFrameForControllerArea:aRect];
    NSRect sliderFrame = [[self class] sliderFrameForControllerArea:aRect];
    NSRect beginningFrame = [[self class] goToBeginningButtonFrameForControllerArea:aRect];
    NSRect endFrame = [[self class] goToEndButtonFrameForControllerArea:aRect];

    if (NSPointInRect(point, playStopFrame)) {
        _wasPlayingBeforeTracking = [_delegate isPlayingForMovieController:self];
        [self trackButtonCell:_playStopButtonCell frame:playStopFrame event:aDown view:aView sendActionContinuously:YES];
        _wasPlayingBeforeTracking = NO;
    } else if (NSPointInRect(point, sliderFrame)) {
        _wasPlayingBeforeSliding = [_delegate isPlayingForMovieController:self];
        _isSliding = YES;
        [self trackSliderCell:_sliderCell origin:aRect.origin event:aDown view:aView cellFrame:sliderFrame];
        _isSliding = NO;
        [NSApp sendAction:[_sliderCell action] to:[_sliderCell target] from:nil];
        _wasPlayingBeforeSliding = NO;
    } else if (NSPointInRect(point, beginningFrame)) {
        [self trackButtonCell:_goToBeginningButtonCell frame:beginningFrame event:aDown view:aView sendActionContinuously:NO];
    } else if (NSPointInRect(point, endFrame)) {
        [self trackButtonCell:_goToEndButtonCell frame:endFrame event:aDown view:aView sendActionContinuously:NO];
    }
}

- (void)updateSlider
{
    if (![self isSliding]) {
        double duration = [_delegate durationForMovieController:self];
        double currentTime = [_delegate currentTimeForMovieController:self];
        float value = 0.0f;
        if (HSMovieControllerDurationIsPositive((float)duration))
            value = currentTime / duration;
        [_sliderCell setFloatValue:value];
        return;
    }

    // While sliding, keep the knob inside the play range.
    struct HSTimeRange playRange = [_delegate playRangeForMovieController:self];
    double duration = [_delegate durationForMovieController:self];
    float minimum = 0.0f;
    float maximum = 0.0f;
    if (HSMovieControllerDurationIsPositive((float)duration)) {
        double end = HSMaxTimeRange(playRange);
        minimum = playRange.location / duration;
        maximum = end / duration;
    }
    if ([_sliderCell floatValue] < minimum)
        [_sliderCell setFloatValue:minimum];
    if ([_sliderCell floatValue] > maximum)
        [_sliderCell setFloatValue:maximum];
}

- (void)setPlayStopImage
{
    BOOL playing = [_delegate isPlayingForMovieController:self];
    [_playStopButtonCell setImage:playing ? [[self class] stopButtonImage] : [[self class] playButtonImage]];
}

- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    NSRect sliderFrame = [[self class] sliderFrameForControllerArea:aFrame];
    [self setPlayStopImage];
    [self updateSlider];
    [_playStopButtonCell drawWithFrame:[[self class] playStopButtonFrameForControllerArea:aFrame] inView:aView];
    [[[self class] sliderBackgroundImage] drawInRect:sliderFrame fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    [_sliderCell drawWithFrame:sliderFrame inView:aView];
    [_goToBeginningButtonCell drawWithFrame:[[self class] goToBeginningButtonFrameForControllerArea:aFrame] inView:aView];
    [_goToEndButtonCell drawWithFrame:[[self class] goToEndButtonFrameForControllerArea:aFrame] inView:aView];
}

- (void)dealloc
{
    [_goToEndButtonCell release];
    [_goToBeginningButtonCell release];
    [_sliderCell release];
    [_playStopButtonCell release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _playStopButtonCell = [[NSButtonCell alloc] initImageCell:[[self class] playButtonImage]];
        [_playStopButtonCell setBordered:NO];
        [_playStopButtonCell setTarget:self];
        [_playStopButtonCell setAction:@selector(onPlayStop:)];

        _sliderCell = [[NSSliderCell alloc] init];
        [_sliderCell setControlSize:NSControlSizeSmall];
        [_sliderCell setMinValue:0.0];
        [_sliderCell setMaxValue:1.0];
        [_sliderCell setFloatValue:0.0f];
        [_sliderCell setTarget:self];
        [_sliderCell setAction:@selector(onSlide:)];

        // The edge buttons step frame by frame; onGoToBeginning:/onGoToEnd: are unused.
        _goToBeginningButtonCell = [[NSButtonCell alloc] initImageCell:[[self class] goToBeginningButtonImage]];
        [_goToBeginningButtonCell setBordered:NO];
        [_goToBeginningButtonCell setTarget:self];
        [_goToBeginningButtonCell setAction:@selector(stepBackward:)];

        _goToEndButtonCell = [[NSButtonCell alloc] initImageCell:[[self class] goToEndButtonImage]];
        [_goToEndButtonCell setBordered:NO];
        [_goToEndButtonCell setTarget:self];
        [_goToEndButtonCell setAction:@selector(stepForward:)];

        _isTracking = NO;
        _isTrackingInsideButtonCell = NO;
        _wasPlayingBeforeTracking = NO;
        _isSliding = NO;
        _wasPlayingBeforeSliding = NO;
    }
    return self;
}

- (CGFloat)controllerHeight
{
    return 16.0;
}

- (CGFloat)minControllerWidth
{
    float buttonsWidth = [(NSImage *)[HSMovieControllerCell playButtonImage] size].width
        + [(NSImage *)[HSMovieControllerCell goToBeginningButtonImage] size].width
        + [(NSImage *)[HSMovieControllerCell goToEndButtonImage] size].width;
    // Room for a slider twice the controller height, rounded down to an even width.
    int width = (int)(float)([self controllerHeight] * 2.0 + buttonsWidth);
    return (float)((double)(width / 2) * 2.0);
}

@end
