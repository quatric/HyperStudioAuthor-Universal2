#import "HyperStudioPrefix.h"
#import "HSAnimationSetupCropSelectedGraphicAssistantPane.h"


@interface HSAnimationSetupPickPartOfCardAssistantPane : HSAnimationSetupCropSelectedGraphicAssistantPane
{
    HSButton *_selectCardObjectButton;
}
- (void)paneContinue:(id)aContinue;
- (void)selectCardObject:(id)aObject;
- (id)windowTitle;
- (void)viewDidLoad;
- (BOOL)requiresDarkBottomArea;
- (BOOL)assistantShouldBeKeyWindow;
- (id)initWithOptions:(id)aOptions;
- (void)viewWillAppear:(BOOL)aAppear;
@end

