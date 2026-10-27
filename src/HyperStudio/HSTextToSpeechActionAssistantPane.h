#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSTextToSpeechActionAssistantPane : HSNBAAssistantPane <NSTextViewDelegate, NSTextDelegate, NSObject, NSTableViewDataSource, NSTableViewDelegate, NSControlTextEditingDelegate>
{
    NSPopUpButton *_speechPitch;
    NSPopUpButton *_speechRate;
    NSPopUpButton *_voices;
    NSMatrix *_readTextMatrix;
    NSView *_containerView;
    NSView *_textFieldView;
    NSImageView *_noTextObjectView;
    NSView *_textObjectsView;
    NSView *_currentView;
    HSPlaceholderTextView *_textToSpeakField;
    NSTableView *_textObjectsTableView;
    NSButton *_tryItButton;
    BOOL _isSpeaking;
    NSMutableArray *_availableTextObjects;
    NSImage *_playImage;
    NSImage *_stopImage;
    NSImage *_pressedPlayImage;
    NSImage *_pressedStopImage;
}
+ (id)stopButtonGraphiteImage;
+ (id)stopButtonAquaImage;
+ (id)stopButtonImage;
+ (id)playButtonGraphiteImage;
+ (id)playButtonAquaImage;
+ (id)playButtonImage;
- (void)fillVoicesPopUpMenu;
- (void)addItemsInVoicesMenuForGender:(id)aGender fromArray:(id)aArray;
- (void)updateSpeechText;
- (void)validateTryItButton;
- (void)validateView;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)setUpStopButton;
- (void)setUpPlayButton;
- (id)speechSettings;
- (void)speechManagerDidFinishSpeaking:(id)aSpeaking;
- (void)textDidChange:(id)aChange;
- (void)tableViewSelectionDidChange:(id)aChange;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (void)tryIt:(id)aIt;
- (void)voiceChanged:(id)aChanged;
- (void)speechRateChanged:(id)aChanged;
- (void)speechPitchChanged:(id)aChanged;
- (void)textToSpeakSourceChanged:(id)aChanged;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (void)mountView:(id)aView;
- (void)dealloc;
- (void)viewDidLoad;
- (id)availableTextObjects;
- (id)actionType;
- (id)actionAttributes;
- (id)textToSpeechActionAssistantPaneApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSTextToSpeechActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSString *_initialTextToSpeak;
    HSUID *_initialTextObjectUID;
    BOOL _initialUsesTextObject;
    int _initialPitch;
    int _initialRate;
    SMKSpeechVoice *_initialSpeechVoice;
    NSString *_textToSpeak;
    HSUID *_textObjectUID;
    BOOL _usesTextObject;
    int _pitch;
    int _rate;
    SMKSpeechVoice *_speechVoice;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setRelativeSpeechRate:(NSInteger)aRate;
- (void)setRelativeSpeechPitch:(NSInteger)aPitch;
- (void)setUsesTextObject:(BOOL)aObject;
- (void)setSpeechVoice:(id)aVoice;
- (void)setTextObjectUID:(id)aUID;
- (void)setTextToSpeak:(id)aSpeak;
- (void)setUpInitialSettings;
- (id)textToSpeechActionAttributes;
- (void)dealloc;
@end

