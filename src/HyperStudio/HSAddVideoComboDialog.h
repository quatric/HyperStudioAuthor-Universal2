#import "HyperStudioPrefix.h"


@interface HSAddVideoComboDialog : HSGenericModalController
{
    NSButton *_firstButton;
    NSButton *_secondButton;
    NSButton *_addWebCamsButton;
    NSButton *_fourthButton;
    NSButton *_addYouTubeButton;
    SEL _action;
}
- (void)addYouTubeMovie:(id)aMovie;
- (void)recordVideo:(id)aVideo;
- (void)webcam:(id)aWebcam;
- (void)liveVideo:(id)aVideo;
- (void)diskFile:(id)aFile;
- (SEL)action;
- (void)didLoadNib;
- (id)nibName;
@end

