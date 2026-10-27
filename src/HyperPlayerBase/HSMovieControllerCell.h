#import "HyperPlayerBasePrefix.h"
#import "HSControllerCell.h"


@interface HSMovieControllerCell : HSControllerCell
{
    NSButtonCell *_playStopButtonCell;
    NSSliderCell *_sliderCell;
    NSButtonCell *_goToBeginningButtonCell;
    NSButtonCell *_goToEndButtonCell;
    BOOL _isTracking;
    BOOL _isTrackingInsideButtonCell;
    BOOL _wasPlayingBeforeTracking;
    BOOL _isSliding;
    BOOL _wasPlayingBeforeSliding;
}
+ (id)sliderBackgroundImage;
+ (id)goToEndButtonImage;
+ (id)goToBeginningButtonImage;
+ (id)stopButtonImage;
+ (id)playButtonImage;
+ (NSRect)goToEndButtonFrameForControllerArea:(NSRect)aArea;
+ (NSRect)goToBeginningButtonFrameForControllerArea:(NSRect)aArea;
+ (NSRect)sliderFrameForControllerArea:(NSRect)aArea;
+ (NSRect)playStopButtonFrameForControllerArea:(NSRect)aArea;
- (void)notifyDelegateForNeedsDisplay;
- (void)stepBackward:(id)aBackward;
- (void)stepForward:(id)aForward;
- (void)onGoToEnd:(id)aEnd;
- (void)onGoToBeginning:(id)aBeginning;
- (void)onSlide:(id)aSlide;
- (void)onPlayStop:(id)aStop;
- (BOOL)wasPlayingBeforeSliding;
- (BOOL)isSliding;
- (BOOL)wasPlayingBeforeTracking;
- (BOOL)isTrackingInsideButtonCell;
- (BOOL)isTracking;
- (void)trackSliderCell:(id)aCell origin:(NSPoint)aOrigin event:(id)aEvent view:(id)aView cellFrame:(NSRect)aFrame;
- (void)trackButtonCell:(id)aCell frame:(NSRect)aFrame event:(id)aEvent view:(id)aView sendActionContinuously:(BOOL)aContinuously;
- (void)handleMouseDown:(id)aDown inRect:(NSRect)aRect ofView:(id)aView;
- (void)updateSlider;
- (void)setPlayStopImage;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)dealloc;
- (id)init;
- (CGFloat)controllerHeight;
- (CGFloat)minControllerWidth;
@end

