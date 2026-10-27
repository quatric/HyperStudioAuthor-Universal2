#import "HyperPlayerBasePrefix.h"


@interface HSMovieWithController : NSObject <HSMovieControllerCellDelegate>
{
    id<HSMovieWithControllerDelegate> _delegate;
    HSControllerCell *_controller;
    NSSize _minControllerSize;
}
- (void)setNeedsDisplayForController:(id)aController;
- (void)stepBackwardForMovieController:(id)aController;
- (void)stepForwardForMovieController:(id)aController;
- (void)gotoEndForMovieController:(id)aController;
- (void)gotoBeginningForMovieController:(id)aController;
- (void)slideWasPlaying:(BOOL)aPlaying isFinal:(BOOL)aFinal forMovieController:(id)aController;
- (void)stopForMovieController:(id)aController;
- (void)playForMovieController:(id)aController;
- (struct HSTimeRange)playRangeForMovieController:(id)aController;
- (void)movieController:(id)aController setCurrentTime:(double)aTime;
- (double)currentTimeForMovieController:(id)aController;
- (double)durationForMovieController:(id)aController;
- (BOOL)isPlayingForMovieController:(id)aController;
- (BOOL)isQTVRMovieForMovieController:(id)aController;
- (NSInteger)hitTestPoint:(NSPoint)aPoint inView:(id)aView inMovieFrame:(NSRect)aFrame;
- (BOOL)handleMouseDownInController:(id)aController inView:(id)aView inMovieFrame:(NSRect)aFrame;
- (void)drawController:(NSRect)aController;
- (NSSize)sizeWithControllerForSizeWithoutController:(NSSize)aController;
- (NSSize)sizeWithoutControllerForSizeWithController:(NSSize)aController;
- (NSRect)controllerAreaForMovieFrame:(NSRect)aFrame isFlipped:(BOOL)aFlipped;
- (NSRect)movieFrameForMovieArea:(NSRect)aArea isFlipped:(BOOL)aFlipped;
- (NSRect)movieAreaForMovieFrame:(NSRect)aFrame isFlipped:(BOOL)aFlipped;
- (NSSize)minControllerSize;
- (id)controllerCell;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
- (id)init;
@end

