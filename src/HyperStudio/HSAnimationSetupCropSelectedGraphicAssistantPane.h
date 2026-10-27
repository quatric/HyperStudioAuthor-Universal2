#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSAnimationSetupCropSelectedGraphicAssistantPane : HSObjectAssistantPane
{
    id<HSAnimationSetupCropSelectedGraphicAssistantPaneDelegate> _delegate;
    NSImage *_image;
    NSDictionary *_imageOptions;
    id _temporaryObject;
    HSActionsPaneGoBackContinueSwitcher *_paneSwitcher;
    HSButton *_selectSquireCardPartButton;
    HSButton *_selectCircleCardPartButton;
    HSButton *_selectCardPartUsingLassoButton;
}
- (void)selectCardPartUsingLasso:(id)aLasso;
- (void)selectCircleCardPart:(id)aPart;
- (void)selectSquireCardPart:(id)aPart;
- (void)proceedWithMode:(NSInteger)aMode;
- (void)releaseTemporaryObject;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
- (id)initWithImage:(id)aImage options:(id)aOptions;
- (id)windowTitle;
- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide;
- (void)paneWillGoBack:(id)aBack;
- (void)paneContinue:(id)aContinue;
- (id)navigationPaneSwitcher;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (id)temporaryObject;
@end

