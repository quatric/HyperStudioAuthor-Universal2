#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSGhostWriterActionAssistantPane : HSNBAAssistantPane <NSTextViewDelegate, NSTextDelegate, NSObject>
{
    NSMenu *_speedsMenu;
    NSMenu *_commandsMenu;
    HSTokenButton *_textObjectsButton;
    HSTokenButton *_speedsButton;
    HSTokenButton *_commandsButton;
    HSTokenTextView *_tokenTextView;
    NSTextField *_notAvailableTextField;
    NSMutableArray *_availableTextViews;
}
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)addToken:(id)aToken;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (void)tokenTextView:(id)aView didPopUpCell:(id)aCell;
- (id)availableTextViews;
- (id)ghostWriterActionAttributes;
- (id)actionAttributes;
- (id)ghostWriterAssistantPaneApplier;
- (Class)applierClass;
- (id)actionType;
- (void)dealloc;
- (id)init;
- (id)attributedStringFromCommands:(id)aCommands;
- (BOOL)isTargetCommandValid:(id)aValid;
- (id)objectWithUID:(id)aUID;
- (id)menuItemWithRepresentedUID:(id)aUID fromMenu:(id)aMenu;
- (id)commandsFromAttributedString:(id)aString;
- (void)setUnvailableColorsToCell:(id)aCell;
@end

@interface HSGhostWriterActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSArray *_initialCommands;
    NSArray *_commands;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setCommands:(id)aCommands;
- (void)setUpInitialSettings;
- (id)ghostWriterActionAttributes;
- (void)dealloc;
@end

