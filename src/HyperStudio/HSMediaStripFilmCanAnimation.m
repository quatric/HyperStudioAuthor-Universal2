#import "HSMediaStripFilmCanAnimation.h"

@implementation HSMediaStripFilmCanAnimation

+ (id)animationWithView:(id)aView containerView:(id)aView2 windowWidthDelta:(CGFloat)aDelta duration:(CGFloat)aDuration invertResizingProgress:(BOOL)aProgress
{
    return [[[self alloc] initWithView:aView containerView:aView2 windowWidthDelta:aDelta duration:aDuration invertResizingProgress:aProgress] autorelease];
}

- (CGFloat)currentValueForContainerViewWidth
{
    NSRect frame = _originalContainerFrameInWindowCoordinates;
    frame.size.width = roundf(_windowWidthDelta * (float)[self currentResizingProgress] + _originalContainerFrameInWindowCoordinates.size.width);
    return [[_containerView superview] convertRect:frame fromView:nil].size.width;
}

- (CGFloat)currentValueForWindowWidth
{
    return roundf(_windowWidthDelta * (float)[self currentResizingProgress] + _originalWindowWidth);
}

// Maps the linear progress onto the film can frames, so the resize follows the can's width steps.
- (CGFloat)currentResizingProgress
{
    if (_isCurrentResizingProgressValid)
        return _currentResizingProgress;
    _isCurrentResizingProgressValid = YES;
    _currentResizingProgress = [self currentProgress];
    unsigned int frame = 0;
    if (![self getCurrentFilmCanAnimationFrame:&frame]) {
        if (_invertResizingProgress)
            _currentResizingProgress = 1.0f - _currentResizingProgress;
        return _currentResizingProgress;
    }
    unsigned int lastFrame = _countOfFrames - 1;
    unsigned int fromFrame = frame, toFrame = frame;
    if (_invertResizingProgress) {
        if (frame != 0) {
            _currentResizingProgress = 1.0f - _currentResizingProgress;
            fromFrame = frame - 1;
        }
    } else if (frame < lastFrame) {
        toFrame = frame + 1;
    }
    if (fromFrame == toFrame) {
        _currentResizingProgress = toFrame == 0 ? 0.0f : 1.0f;
        return _currentResizingProgress;
    }
    float progress = _currentResizingProgress;
    float totalDistance = [HSMediaStripAnimatingFilmCan filmCanWidthDistanceBetweenFrameIndex:0 andFrameIndex:lastFrame];
    float frameStep = 1.0f / (float)lastFrame;
    float frameProgress = (progress - (float)fromFrame * frameStep) / frameStep;
    float base = fromFrame == 0 ? 0.0f : (float)[HSMediaStripAnimatingFilmCan filmCanWidthDistanceBetweenFrameIndex:0 andFrameIndex:fromFrame] / totalDistance;
    float frameDistance = [HSMediaStripAnimatingFilmCan filmCanWidthDistanceBetweenFrameIndex:fromFrame andFrameIndex:toFrame];
    _currentResizingProgress = frameProgress * (frameDistance / totalDistance) + base;
    return _currentResizingProgress;
}

- (BOOL)getCurrentFilmCanAnimationFrame:(unsigned int *)aFrame
{
    unsigned int count = _countOfFrames;
    if (count == 0)
        return NO;
    if (!_isCurrentFrameValid) {
        _isCurrentFrameValid = YES;
        unsigned int lastFrame = count - 1;
        unsigned int frame = (unsigned int)roundf((float)lastFrame * (float)[self currentProgress]);
        if (lastFrame <= frame)
            frame = lastFrame;
        _currentFrameIndex = _invertResizingProgress ? lastFrame - frame : frame;
    }
    if (aFrame != NULL)
        *aFrame = _currentFrameIndex;
    return YES;
}

- (NSUInteger)countOfFrames
{
    return _countOfFrames;
}

- (void)setCurrentProgress:(CGFloat)aProgress
{
    _isCurrentResizingProgressValid = NO;
    _isCurrentFrameValid = NO;
    [super setCurrentProgress:aProgress];
    if ([[self delegate] respondsToSelector:@selector(mediaStripFilmCanAnimation:didChangeProgressTo:)])
        [(id)[self delegate] mediaStripFilmCanAnimation:self didChangeProgressTo:[self currentProgress]];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)dealloc
{
    // Fix: the container view retained in init was never released.
    [_containerView release];
    [super dealloc];
}

- (id)initWithView:(id)aView containerView:(id)aView2 windowWidthDelta:(CGFloat)aDelta duration:(CGFloat)aDuration invertResizingProgress:(BOOL)aProgress
{
    self = [super initWithDuration:aDuration animationCurve:NSAnimationLinear];
    if (self != nil) {
        _countOfFrames = (unsigned int)[aView countOfImages];
        _originalWindowWidth = [[aView window] frame].size.width;
        _windowWidthDelta = aDelta;
        _containerView = [aView2 retain];
        _originalContainerFrameInWindowCoordinates = [[_containerView superview] convertRect:[_containerView frame] toView:nil];
        _invertResizingProgress = aProgress;
        if (aProgress) {
            _originalWindowWidth -= aDelta;
            _originalContainerFrameInWindowCoordinates.size.width -= aDelta;
        }
    }
    return self;
}

@end
