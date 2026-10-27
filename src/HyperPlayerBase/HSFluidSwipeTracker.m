#import "HSFluidSwipeTracker.h"
#import "HSFluidSwipe.h"

@implementation HSFluidSwipeTracker

- (BOOL)wantsScrollEventsForSwipeTrackingOnAxis:(int)aAxis
{
    return aAxis == 1;
}

- (void)scrollWheel:(NSEvent *)aEvent
{
    if ([NSEvent isSwipeTrackingFromScrollEventsEnabled] && [aEvent phase] == NSEventPhaseBegan) {
        if (_stopper != NULL && *_stopper == NO) {
            *_stopper = YES;
            _stopper = NULL;
        }

        HSFluidSwipe *swipe = [HSFluidSwipe swipe];
        __block BOOL stopped = NO;
        [aEvent trackSwipeEventWithOptions:0
                  dampenAmountThresholdMin:-1.0
                                       max:1.0
                              usingHandler:^(CGFloat gestureAmount, NSEventPhase phase, BOOL isComplete, BOOL *stop) {
            if (stopped) {
                *stop = YES;
                return;
            }
            [swipe setPhase:(unsigned int)phase];
            [swipe setGestureAmount:(float)gestureAmount];
            [swipe setIsComplete:isComplete];
            if (phase == NSEventPhaseCancelled) {
                [swipe setIsCanceled:YES];
            }
            if (isComplete) {
                _stopper = NULL;
            }
            id view = [[[aEvent window] contentView] hitTest:[aEvent locationInWindow]];
            [view tryToPerform:@selector(handleFluidSwipe:) with:swipe];
        }];
        _stopper = &stopped;
        return;
    }
    [super scrollWheel:aEvent];
}

@end
