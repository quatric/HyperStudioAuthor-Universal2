#import "HyperStudioPrefix.h"


@interface HSExportComboDialog : HSGenericModalController
{
    NSView *_mountedView;
    NSView *_containerView;
    NSButton *_backButton;
    NSImageView *_exportOptionImage;
    NSView *_exportChoicesView;
    NSButton *_iTunesAudioButton;
    NSButton *_audioBookButton;
    NSButton *_podcastAudioButton;
    NSButton *_flashVideoButton;
    NSButton *_iPhoneButton;
    NSButton *_iPodButton;
    NSButton *_quickTimeMovieButton;
    NSButton *_stackToGoButton;
    NSButton *_iBooksAuthorButton;
    NSButton *_ftpServerButton;
    NSButton *_imageSequenceButton;
    NSButton *_webPageButton;
    NSButton *_webAppButton;
    NSView *_exportChannelView;
    NSMatrix *_exportChannelMatrix;
    NSTextField *_publishToDotMacTextField;
    int _exportFormat;
    int _publishType;
}
- (void)exportToImageSequence:(id)aSequence;
- (void)exportToWebPage:(id)aPage;
- (void)exportToStackToGo:(id)aGo;
- (void)exportToQuickTimeMovie:(id)aMovie;
- (void)exportToiPod:(id)aPod;
- (void)exportToiPhone:(id)aPhone;
- (void)exportToVideoPodcast:(id)aPodcast;
- (void)cancel:(id)aCancel;
- (NSInteger)publishType;
- (NSInteger)exportFormat;
- (void)willShowWindow;
- (void)mountView:(id)aView animate:(BOOL)aAnimate;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

