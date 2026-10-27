#import "HyperStudioPrefix.h"
#import "HSMainWindowStatusbarController.h"


@interface HSStoryboardStatusbarController : HSMainWindowStatusbarController
{
}
- (void)validateUI;
- (void)setZoomControlsEnabled:(BOOL)aEnabled;
- (id)nibName;
- (void)setZoomFactor:(CGFloat)aFactor;
@end

