#import "HyperStudioPrefix.h"
#import "HSMainWindowStatusbarController.h"


@interface HSEditorWindowStatusbarController : HSMainWindowStatusbarController
{
    HSCustomPopUpButton *_zoomPopUpButton;
    HSSegmentedCell *_zoomToActualSizeCell;
    NSButton *_zoomToMinButton;
    NSButton *_zoomToMaxButton;
}
- (void)didLoadNib;
- (void)setZoomControlsEnabled:(BOOL)aEnabled;
- (void)setupScalePopUpButton;
- (void)updateScalePopUpButtonTarget;
- (void)setZoomFactor:(CGFloat)aFactor;
- (id)nibName;
@end

