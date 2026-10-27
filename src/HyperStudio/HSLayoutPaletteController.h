#import "HyperStudioPrefix.h"


@interface HSLayoutPaletteController : HSValidatedUserInterfacePaletteController
{
    NSView *_advancedSettingsContainer;
    NSView *_basicSettingsContainer;
    NSPopUpButton *_gridButton;
    NSButton *_snapToGridButton;
    NSButton *_showGuidelinesButton;
    NSButton *_alignBottomButton;
    NSButton *_alignTopButton;
    NSButton *_alignYCenterButton;
    NSButton *_alignLeftButton;
    NSButton *_alignRightButton;
    NSButton *_alignXCenterButton;
    NSButton *_orderFrontButton;
    NSButton *_orderBackButton;
    NSButton *_orderForwardButton;
    NSButton *_orderBackwardButton;
    NSButton *_scaleToFillButton;
    NSButton *_scaleToFitButton;
    NSButton *_xFlipButton;
    NSButton *_yFlipButton;
    NSButton *_centerButton;
    SMKBackgroundPopUpButton *_rotateButton;
    NSButton *_collapseButton;
}
- (void)switchToEditor;
- (void)rotateSelectedObject_forward:(id)aForward;
- (void)gridAction:(id)aAction;
- (void)startCollapseAnimation:(id)aAnimation;
- (NSRect)collapsedPaletteFrame;
- (BOOL)isPaletteExpanded;
- (void)validateUserInterface;
- (void)validateGridButton;
- (void)didLoadNib;
- (id)nibName;
@end

