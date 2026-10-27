#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSRunAppleScriptActionAssistantPane : HSNBAAssistantPane <NSTextViewDelegate, NSTextDelegate, NSObject>
{
    HSPlaceholderTextView *_scriptView;
    NSButton *_checkButton;
    NSButton *_runButton;
    OSAScriptView *_offScreenScriptView;
    OSAScriptController *_scriptController;
}
- (void)textViewDidChangeSelection:(id)aSelection;
- (void)textDidChange:(id)aChange;
- (void)showErrorAlert;
- (BOOL)compile:(id *)aCompile;
- (void)validateStyleForContainsText;
- (void)validateButtons;
- (void)validateUI;
- (void)runScript:(id)aScript;
- (void)compileScript:(id)aScript;
- (void)chooseScriptFile:(id)aFile;
- (id)helpTopicKey;
- (void)paneDidOK:(id)aOK;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (id)actionType;
- (id)actionAttributes;
- (id)runAppleScriptActionAssistantPaneApplier;
- (Class)applierClass;
- (void)dealloc;
- (id)init;
@end

@interface HSRunAppleScriptActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    BOOL _initialUseCustomAppleScriptSource;
    NSURL *_initialAppleScriptURL;
    NSString *_initialAppleScriptSource;
    BOOL _useCustomAppleScriptSource;
    NSURL *_appleScriptURL;
    NSString *_appleScriptSource;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setAppleScriptSource:(id)aSource;
- (void)setAppleScriptURL:(id)aURL;
- (void)setUseCustomAppleScriptSource:(BOOL)aSource;
- (void)setUpInitialSettings;
- (id)runAppleScriptActionAttributes;
- (void)dealloc;
@end

