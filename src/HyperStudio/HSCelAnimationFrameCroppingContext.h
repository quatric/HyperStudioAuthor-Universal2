#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSCelAnimationFrameCroppingContext : NSObject
{
    NSBezierPath *_croppingPath;
    NSSize _originalFrameSize;
    NSSize _selectedFrameSize;
    NSRect _requestedFrameRect;
    NSAffineTransform *_contextTransform;
}
- (id)contextTransform;
- (NSRect)requestedFrameRect;
- (NSSize)selectedFrameSize;
- (NSSize)originalFrameSize;
- (id)croppingPath;
- (void)dealloc;
- (id)initWithCroppingPath:(id)aPath originalFrameSize:(NSSize)aSize selectedFrameSize:(NSSize)aSize2 requestedFrameRect:(NSRect)aRect contextTransform:(id)aTransform;
@end

@interface HSAnimationSetupPickImageAssistantPane : HSObjectAssistantPane
{
    HSAnimationModeController *_animationModeController;
    id<HSAnimationSetupPickImageAssistantPaneDelegate> _delegate;
    HSButton *_selectPartOfCardButton;
    HSButton *_selectGraphicButton;
    HSButton *_selectSequenceButton;
    HSButton *_selectMovieButton;
    NSControl *_selectPartOfCardTextButton;
    NSControl *_selectGraphicTextButton;
    NSControl *_selectSequenceTextButton;
    NSControl *_selectMovieTextButton;
    HSImportDialogController *_importGraphicDialogController;
    HSImportDialogController *_importMovieDialogController;
    HSObjectAssistantNavigationPaneSwitcher *_navigationPaneSwitcher;
    BOOL _paneOpenedAsModalViewController;
    float _tolerance;
}
+ (id)applySmartCroppingToImageMedia:(id)aMedia context:(id)aContext;
+ (id)applyCroppingToImageMedia:(id)aMedia context:(id)aContext;
+ (id)celAnimationMovieWithGIF:(id)aGIF croppingPath:(id)aPath selectedFrameSize:(NSSize)aSize;
+ (id)celAnimationMovieWithFrameFormat:(id)aFormat firstFrame:(NSInteger)aFrame count:(NSUInteger)aCount croppingPath:(id)aPath selectedFrameSize:(NSSize)aSize;
+ (id)frameMediaWithPath:(id)aPath frameImage:(id *)aImage;
+ (id)movieForCelAnimationWithOptions:(id)aOptions;
- (void)createAnimationFromImage:(id)aImage dialogOptions:(id)aOptions isAnimatedGif:(BOOL)aGif;
- (void)selectMovieObjectFromDialog:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)selectGraphicObjectFromDialog:(id)aDialog returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)setTolerance:(CGFloat)aTolerance;
- (CGFloat)tolerance;
- (id)windowTitle;
- (id)helpTopicKey;
- (void)paneWillGoBack:(id)aBack;
- (id)findFileForCelAnimationForPath:(id)aPath;
- (void)proceed:(id)aProceed;
- (void)notePaneOpenedAsModalViewController;
- (void)setAnimationModeController:(id)aController;
- (id)animationModeController;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)viewDidLoad;
- (id)navigationPaneSwitcher;
- (BOOL)requiresDarkBottomArea;
- (void)dealloc;
- (id)init;
@end

