#import "HSMovieWithController.h"
#import "HSControllerCell.h"
#import "HSFunctions.h"
#import "HSMovieControllerCell.h"
#import "HSQTVRMovieControllerCell.h"
#import "HSView.h"

// Glue between a movie controller cell and the movie it controls: the cell's
// requests are forwarded to the delegate, and the movie/controller geometry
// comes from the cell (a QTVR cell for QTVR movies).
@implementation HSMovieWithController

- (void)setNeedsDisplayForController:(id)aController
{
    [[self delegate] setNeedsDisplayWithController:self];
}

- (void)stepBackwardForMovieController:(id)aController
{
    [[self delegate] stepBackwardWithController:self];
}

- (void)stepForwardForMovieController:(id)aController
{
    [[self delegate] stepForwardWithController:self];
}

- (void)gotoEndForMovieController:(id)aController
{
    struct HSTimeRange range = [[self delegate] playRangeForMovieWithController:self];
    [[self delegate] movieWithController:self setCurrentTime:HSMaxTimeRange(range)];
}

- (void)gotoBeginningForMovieController:(id)aController
{
    struct HSTimeRange range = [[self delegate] playRangeForMovieWithController:self];
    [[self delegate] movieWithController:self setCurrentTime:range.location];
}

// While the slider is dragged the movie stops temporarily; it plays again
// once the drag ends.
- (void)slideWasPlaying:(BOOL)aPlaying isFinal:(BOOL)aFinal forMovieController:(id)aController
{
    if (!aPlaying)
        return;
    if (aFinal)
        [[self delegate] playForMovieWithController:self];
    else
        [[self delegate] temporaryStopForMovieWithController:self];
}

- (void)stopForMovieController:(id)aController
{
    [[self delegate] stopForMovieWithController:self];
}

- (void)playForMovieController:(id)aController
{
    [[self delegate] playForMovieWithController:self];
}

- (struct HSTimeRange)playRangeForMovieController:(id)aController
{
    return [[self delegate] playRangeForMovieWithController:self];
}

- (void)movieController:(id)aController setCurrentTime:(double)aTime
{
    [[self delegate] movieWithController:self setCurrentTime:aTime];
}

- (double)currentTimeForMovieController:(id)aController
{
    return [[self delegate] currentTimeForMovieWithController:self];
}

- (double)durationForMovieController:(id)aController
{
    return [[self delegate] durationForMovieWithController:self];
}

- (BOOL)isPlayingForMovieController:(id)aController
{
    return [[self delegate] isPlayingForMovieWithController:self];
}

- (BOOL)isQTVRMovieForMovieController:(id)aController
{
    return [[self delegate] isQTVRMovieForMovieWithController:self];
}

// Decoded from the disassembly: 0 outside the movie frame, 2 on the
// controller, 1 elsewhere in the frame.
- (NSInteger)hitTestPoint:(NSPoint)aPoint inView:(id)aView inMovieFrame:(NSRect)aFrame
{
    if (![aView mouse:aPoint inRect:aFrame])
        return 0;
    if ([[self delegate] hasControllerForMovieWithController:self]) {
        NSRect userFrame = [(HSView *)aView userBoundingRectForViewRect:aFrame];
        NSRect controllerArea = [self controllerAreaForMovieFrame:userFrame isFlipped:[aView isFlipped]];
        if ([aView mouse:aPoint inRect:[(HSView *)aView viewBoundingRectForUserRect:controllerArea]])
            return 2;
    }
    return 1;
}

- (BOOL)handleMouseDownInController:(id)aController inView:(id)aView inMovieFrame:(NSRect)aFrame
{
    if (![[self delegate] hasControllerForMovieWithController:self])
        return NO;
    NSPoint point = [aView convertPoint:[aController locationInWindow] fromView:nil];
    NSRect userFrame = [(HSView *)aView userBoundingRectForViewRect:aFrame];
    NSRect controllerArea = [self controllerAreaForMovieFrame:userFrame isFlipped:[aView isFlipped]];
    if (![aView mouse:point inRect:[(HSView *)aView viewBoundingRectForUserRect:controllerArea]])
        return NO;
    [[self controllerCell] handleMouseDown:aController inRect:controllerArea ofView:aView];
    return YES;
}

// The original draws without a view.
- (void)drawController:(NSRect)aController
{
    NSView *view = nil;
    [[self controllerCell] drawWithFrame:aController inView:view];
}

- (NSSize)sizeWithControllerForSizeWithoutController:(NSSize)aController
{
    NSRect area = NSZeroRect;
    area.size = aController;
    return [self movieFrameForMovieArea:area isFlipped:NO].size;
}

- (NSSize)sizeWithoutControllerForSizeWithController:(NSSize)aController
{
    NSRect frame = NSZeroRect;
    frame.size = aController;
    return [self movieAreaForMovieFrame:frame isFlipped:NO].size;
}

- (NSRect)controllerAreaForMovieFrame:(NSRect)aFrame isFlipped:(BOOL)aFlipped
{
    return [[self controllerCell] controllerAreaForMovieFrame:aFrame isFlipped:aFlipped];
}

- (NSRect)movieFrameForMovieArea:(NSRect)aArea isFlipped:(BOOL)aFlipped
{
    return [[self controllerCell] movieFrameForMovieArea:aArea isFlipped:aFlipped];
}

- (NSRect)movieAreaForMovieFrame:(NSRect)aFrame isFlipped:(BOOL)aFlipped
{
    return [[self controllerCell] movieAreaForMovieFrame:aFrame isFlipped:aFlipped];
}

// Cached on first use.
- (NSSize)minControllerSize
{
    if (NSEqualSizes(_minControllerSize, NSZeroSize)) {
        HSControllerCell *cell = [self controllerCell];
        _minControllerSize.height = [cell controllerHeight];
        _minControllerSize.width = [cell minControllerWidth];
    }
    return _minControllerSize;
}

- (id)controllerCell
{
    if (_controller == nil && _delegate != nil) {
        Class cellClass = [_delegate isQTVRMovieForMovieWithController:self] ? [HSQTVRMovieControllerCell class] : [HSMovieControllerCell class];
        _controller = [cellClass new];
        [_controller setDelegate:self];
    }
    return _controller;
}

// The delegate is not retained.
- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_controller setDelegate:nil];
    [_controller release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _minControllerSize = NSZeroSize;
    return self;
}

@end
