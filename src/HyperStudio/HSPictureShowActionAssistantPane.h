#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSPictureShowActionAssistantPane : HSNBAAssistantPane
{
    NSButton *_loopPictureShowButton;
    NSButton *_leaveLastPictureOnExitButton;
    NSButton *_showFilenameOnPictureButton;
    NSTextField *_timeDelayField;
    NSStepper *_timeDelayStepper;
    NSTextField *_URLField;
    NSButton *_chooseFolderButton;
}
- (void)validateURLField;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)timeDelayChanged:(id)aChanged;
- (void)showFilenameOnPicturesChanged:(id)aChanged;
- (void)loopPictureShowChanged:(id)aChanged;
- (void)leaveLastPictureOnExitChanged:(id)aChanged;
- (void)chooseFolder:(id)aFolder;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (id)actionType;
- (id)actionAttributes;
- (id)pictureShowActionAssistantPaneApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSPictureShowActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    BOOL _initialLoopPictureShow;
    BOOL _initialLeavesLastPictureOnExit;
    BOOL _initialShowsFilenameOnPicture;
    double _initialTimeDelay;
    NSURL *_initialUrl;
    BOOL _loopPictureShow;
    BOOL _leavesLastPictureOnExit;
    BOOL _showsFilenameOnPicture;
    double _timeDelay;
    NSURL *_url;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setURL:(id)aURL;
- (void)setTimeDelay:(double)aDelay;
- (void)setShowsFilenameOnPicture:(BOOL)aPicture;
- (void)setLeavesLastPictureOnExit:(BOOL)aExit;
- (void)setLoopPictureShow:(BOOL)aShow;
- (void)setUpInitialSettings;
- (id)pictureShowActionAttributes;
- (void)dealloc;
@end

