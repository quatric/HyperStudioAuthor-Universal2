#import "HyperStudioPrefix.h"


@interface HSExportComboDialog : HSGenericModalController
{
    NSView *_mountedView;
    NSView *_containerView;
    NSButton *_backButton;
    NSView *_exportChoicesView;
    NSButton *_iTunesAudioButton;
    NSButton *_audioBookButton;
    NSButton *_podcastAudioButton;
    NSButton *_flashVideoButton;
    NSButton *_iPhoneButton;
    NSButton *_iPodButton;
    NSButton *_quickTimeMovieButton;
    NSButton *_stackToGoButton;
    NSButton *_webPageButton;
    NSButton *_imageSequenceButton;
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

