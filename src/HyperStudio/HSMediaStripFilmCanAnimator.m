#import "HSMediaStripFilmCanAnimator.h"

@implementation HSMediaStripFilmCanAnimator

+ (id)synchronousAnimatorWithFilmCanView:(id)aView containerView:(id)aView2 enclosingScrollView:(id)aView3 windowWidthDelta:(CGFloat)aDelta
{
    return [[[self alloc] initWithFilmCanView:aView containerView:aView2 enclosingScrollView:aView3 windowWidthDelta:aDelta] autorelease];
}

- (void)closeAndAnimate:(BOOL)aAnimate
{
    if (aAnimate)
        [self animateFilmCanForOpening:NO];
    else
        [self performFilmCanOpening:NO];
}

- (void)openAndAnimate:(BOOL)aAnimate
{
    if (aAnimate)
        [self animateFilmCanForOpening:YES];
    else
        [self performFilmCanOpening:YES];
}

- (void)mediaStripFilmCanAnimation:(id)aAnimation didChangeProgressTo:(CGFloat)aTo
{
    unsigned int frameIndex = 0;
    BOOL frameChanged = [aAnimation getCurrentFilmCanAnimationFrame:&frameIndex];
    if (frameChanged)
        [_animatingView setRenderedImageIndex:frameIndex];
    float windowWidth = [aAnimation currentValueForWindowWidth];
    float containerWidth = [aAnimation currentValueForContainerViewWidth];
    [self resizeContainerViewToWidth:containerWidth windowToWidth:windowWidth forceWindowUpdate:frameChanged];
}

// Applies the end state of the film can animation at once.
- (void)performFilmCanOpening:(BOOL)aOpening
{
    [_filmCanAnimation stopAnimation];
    [self setFilmCanAnimation:nil];
    float delta = _windowWidthDelta;
    if (!aOpening)
        delta = -delta;
    NSView *superview = [_containerView superview];
    NSRect rect = [superview convertRect:[_containerView frame] toView:nil];
    rect.size.width += delta;
    rect = [superview convertRect:rect fromView:nil];
    NSRect windowFrame = [[_animatingView window] frame];
    [self resizeContainerViewToWidth:rect.size.width windowToWidth:delta + windowFrame.size.width forceWindowUpdate:NO];
}

- (void)resizeContainerViewToWidth:(CGFloat)aWidth windowToWidth:(CGFloat)aWidth2 forceWindowUpdate:(BOOL)aUpdate
{
    NSRect oldFrame = [_containerView frame];
    NSRect newFrame = oldFrame;
    newFrame.size.width = aWidth;
    BOOL containerChanged = !NSEqualRects(newFrame, oldFrame);
    if (containerChanged) {
        [[_containerView superview] setNeedsDisplayInRect:oldFrame];
        [_containerView setFrame:newFrame];
        [[_containerView superview] setNeedsDisplayInRect:newFrame];
    }
    NSWindow *window = [_animatingView window];
    NSRect windowFrame = [window frame];
    NSRect newWindowFrame = windowFrame;
    newWindowFrame.size.width = aWidth2;
    if (!NSEqualRects(newWindowFrame, windowFrame)) {
        [window setFrame:newWindowFrame display:YES];
    } else if (aUpdate || containerChanged) {
        if (containerChanged)
            [_enclosingScrollView tile];
        [window displayIfNeeded];
    }
}

- (void)animateFilmCanForOpening:(BOOL)aOpening
{
    [_filmCanAnimation stopAnimation];
    [self setFilmCanAnimation:nil];
    id animation = [[HSMediaStripFilmCanAnimation animationWithView:_animatingView containerView:_containerView windowWidthDelta:_windowWidthDelta duration:0.5 invertResizingProgress:!aOpening] retain];
    [animation setDelegate:self];
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    [self setFilmCanAnimation:animation];
    [animation startAnimation];
}

- (void)animationDidEnd:(id)aEnd
{
    [self discardAnimation:aEnd];
}

- (void)animationDidStop:(id)aStop
{
    [self discardAnimation:aStop];
}

- (BOOL)animationShouldStart:(id)aStart
{
    if (_filmCanAnimation == aStart)
        [_animatingView setIsRenderingEnabled:YES];
    return YES;
}

- (void)discardAnimation:(id)aAnimation
{
    if (_filmCanAnimation == aAnimation) {
        [_animatingView setIsRenderingEnabled:NO];
        [self setFilmCanAnimation:nil];
    }
    [aAnimation setDelegate:nil];
    [aAnimation release];
}

- (void)setFilmCanAnimation:(id)aAnimation
{
    if (_filmCanAnimation != aAnimation) {
        [_filmCanAnimation release];
        _filmCanAnimation = [aAnimation retain];
    }
}

- (id)filmCanAnimation
{
    return _filmCanAnimation;
}

- (void)dealloc
{
    [_animatingView release];
    [_containerView release];
    [_enclosingScrollView release];
    [_filmCanAnimation release];
    [super dealloc];
}

- (id)initWithFilmCanView:(id)aView containerView:(id)aView2 enclosingScrollView:(id)aView3 windowWidthDelta:(CGFloat)aDelta
{
    self = [super init];
    if (self) {
        _animatingView = [aView retain];
        _containerView = [aView2 retain];
        _windowWidthDelta = aDelta;
        _enclosingScrollView = [aView3 retain];
    }
    return self;
}

@end
