#import "HyperStudioPrefix.h"
#import "HSExportAccessoryViewController.h"


@interface HSMovieExportAccessoryViewController : HSExportAccessoryViewController
{
    NSMatrix *_exportOptionMatrix;
    NSPopUpButton *_movieSizePopUpButton;
    NSButton *_useRoundedCornersSwitch;
    NSTextField *_framesPerSecondLimitField;
    NSStepper *_framesPerSecondLimitStepper;
    NSPopUpButton *_transitionsPopUpButton;
    NSTextField *_slideDelayTextField;
    NSStepper *_slideDelayStepper;
}
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewDidLoad;
- (void)changeSlideDelayByStepper:(id)aStepper;
- (void)changeSlideDelay:(id)aDelay;
- (void)changeTransition:(id)aTransition;
- (void)changeFramesPerSecondLimitByStepper:(id)aStepper;
- (void)controlTextDidChange:(id)aChange;
- (double)fixedFramesPerSecondLimitForValue:(double)aValue;
- (void)changeMovieSize:(id)aSize;
- (void)toggleExportOption:(id)aOption;
- (BOOL)useRoundedCorners;
@end

