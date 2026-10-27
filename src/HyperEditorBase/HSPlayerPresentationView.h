#import "HyperEditorBasePrefix.h"


@interface HSPlayerPresentationView : HSPlayerView
{
    NSButton *_exitFullScreenButton;
    NSViewAnimation *_showHideExitFullScreenButtonAnimation;
    BOOL _showExitFullScreenButtonAnimation;
}
- (void)validateExitFullScreenButton;
- (void)showExitFullScreenButton:(BOOL)aButton;
- (void)hideExitFullScreenButton;
- (void)showHideExitFullScreenButton;
- (void)delayedShowHideExitFullScreenButton;
- (void)createExitFullScreenButtonIfNeeded;
- (id)exitFullScreenButtonImage;
- (void)setupBackgroundAttributes;
- (void)setStack:(id)aStack;
- (BOOL)includesBorderThicknessInOptimalSize;
- (id)contentViewNibName;
- (void)applicationWillBecomeActive:(id)aActive;
- (void)dealloc;
- (id)onceInit;
@end

