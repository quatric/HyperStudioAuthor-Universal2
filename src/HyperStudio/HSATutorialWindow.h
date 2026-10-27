#import "HyperStudioPrefix.h"


@interface HSATutorialWindow : HSWindow
- (BOOL)canBecomeMainWindow;
- (id)nextResponder;
- (void)setWindowController:(id)aController;
- (id)supplementalTargetForAction:(SEL)aAction sender:(id)aSender;
@end
