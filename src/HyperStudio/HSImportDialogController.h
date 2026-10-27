#import "HyperStudioPrefix.h"


@interface HSImportDialogController : NSWindowController
{
    NSString *_dialogType;
    NSMutableArray *_paneViewControllerClasses;
    NSMutableArray *_paneViewControllers;
    id _modalDelegate;
    SEL _didEndSelector;
    NSSegmentedControl *_tabTitlesControl;
    NSTabView *_tabView;
    NSView *_accessoryViewContainer;
    NSString *_defaultButtonTitle;
    NSButton *_defaultButton;
    NSButton *_cancelButton;
    id<HSImportDialogPaneViewController> _currentPaneViewController;
    HSDocument *_hyperDocument;
    BOOL _isObjectTypeOptionsDisabled;
    BOOL _isObjectOptionsDisabled;
    BOOL _captureImageButtonEnabled;
    NSString *_helpTopicKey;
    NSDictionary *_dialogInterfaceOptions;
    NSDictionary *_options;
}
+ (id)defaultButtonTitleForObject:(id)aObject;
+ (void)registerPaneViewController:(Class)aController withIdentifier:(id)aIdentifier;
- (void)restrictionPaneDidChange:(id)aChange;
- (void)tableViewSelectionDidChange:(id)aChange;
- (void)gridControlSelectionDidChange:(id)aChange;
- (void)validateUIElements;
- (void)updatePanels;
- (void)adjustDefaultAndCancelButtons;
- (id)defaultButtonTitle;
- (void)setDefaultButtonTitle:(id)aTitle;
- (id)paneViewControllers;
- (BOOL)captureImageButtonEnabled;
- (void)setCaptureImageButtonEnabled:(BOOL)aEnabled;
- (id)options;
- (void)setOptions:(id)aOptions;
- (void)setHelpTopicKey:(id)aKey;
- (id)helpTopicKey;
- (void)setObjectOptionsDisabled:(BOOL)aDisabled;
- (BOOL)isObjectOptionsDisabled;
- (void)showHelp:(id)aHelp;
- (id)hyperDocument;
- (void)setHyperDocument:(id)aDocument;
- (id)dialogUserOptions;
- (id)fileDisplayName;
- (id)fileName;
- (id)dialogType;
- (void)changeSelectedPane:(id)aPane;
- (void)addToCard:(id)aCard;
- (void)cancel:(id)aCancel;
- (void)sheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)beginSheetForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (NSInteger)runModal;
- (void)setupDialogInterfaceWithOptions:(id)aOptions;
- (void)windowDidLoad;
- (id)initWithPropertyList:(id)aList;
- (id)initWithPaneViewControllerClasses:(id)aClasses;
- (id)initWithDialogType:(id)aType;
- (void)dealloc;
@end

@interface NSObject (HSImportDialogControllerPaneSorting)
- (NSInteger)importDialogControllerPaneCompare:(id)aCompare;
@end

