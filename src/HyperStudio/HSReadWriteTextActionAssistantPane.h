#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSReadWriteTextActionAssistantPane : HSNBAAssistantPane <NSOpenSavePanelDelegate, NSObject, NSAnimationDelegate>
{
    HSPopUpButton *_textObjectsPopUpButton;
    HSPopUpButton *_chooseFilePopUpButton;
    NSMatrix *_operationMatrix;
    NSButton *_changeModeButton;
    NSTextField *_warningMessageTextField;
    id<HSReadWriteTextActionAttributes> _attributes;
    NSMenu *_textObjectsMenu;
    NSMenu *_fileMenu;
    BOOL _textObjectIsMissing;
    BOOL _noTextObjects;
    NSRect _frameForRead;
    NSRect _frameForWrite;
    NSString *_tooltipForRead;
    NSString *_tooltipForWrite;
}
- (void)HSReadWriteTextActionAssistantPane_removeObservers;
- (void)HSReadWriteTextActionAssistantPane_addObservers;
- (void)HSReadWriteTextActionAssistantPane_modeWasUndoneOrRedone:(id)aRedone;
- (void)HSReadWriteTextActionAssistantPane_modeWillBeUndoneOrRedone:(id)aRedone;
- (void)HSReadWriteTextActionAssistantPane_operationWasUndoneOrRedone:(id)aRedone;
- (void)HSReadWriteTextActionAssistantPane_operationWillBeUndoneOrRedone:(id)aRedone;
- (void)HSReadWriteTextActionAssistantPane_fileURLWasUndoneOrRedone:(id)aRedone;
- (void)HSReadWriteTextActionAssistantPane_fileURLWillBeUndoneOrRedone:(id)aRedone;
- (void)HSReadWriteTextActionAssistantPane_targetObjectWasUndoneOrRedone:(id)aRedone;
- (void)HSReadWriteTextActionAssistantPane_targetObjectWillBeUndoneOrRedone:(id)aRedone;
- (void)HSReadWriteTextActionAssistantPane_objectEditableStateDidChange:(id)aChange;
- (void)HSReadWriteTextActionAssistantPane_objectNameDidChange:(id)aChange;
- (void)HSReadWriteTextActionAssistantPane_objectsWillChange:(id)aChange;
- (void)HSReadWriteTextActionAssistantPane_cardsWillChange:(id)aChange;
- (void)HSReadWriteTextActionAssistantPane_removeItemAtPopUpByNodeChild:(id)aChild withErrorText:(id)aText;
- (void)HSReadWriteTextActionAssistantPane_autosetupTextObjectSettings;
- (void)HSReadWriteTextActionAssistantPane_autosetupFileURLSettings;
- (void)animationDidStop:(id)aStop;
- (void)animationDidEnd:(id)aEnd;
- (void)operationChanged:(id)aChanged;
- (void)modeChanged:(id)aChanged;
- (void)textObjectChanged:(id)aChanged;
- (void)HSReadWriteTextActionAssistantPane_swapButtonsWithAnimation;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)panel:(id)aPanel userEnteredFilename:(id)aFilename confirmed:(BOOL)aConfirmed;
- (void)HSReadWriteTextActionAssistantPane_validateWarningMessageTextField;
- (void)HSReadWriteTextActionAssistantPane_validateOperationMatrix;
- (void)HSReadWriteTextActionAssistantPane_validateTextObjectsPopUpButton;
- (void)HSReadWriteTextActionAssistantPane_setControlsEnabled:(BOOL)aEnabled;
- (void)HSReadWriteTextActionAssistantPane_validateFilePopUpButton;
- (id)fileMenu;
- (id)textObjectsMenu;
- (void)HSReadWriteTextActionAssistantPane_composeFileMenu;
- (void)HSReadWriteTextActionAssistantPane_composeTextObjectsMenu;
- (void)HSReadWriteTextActionAssistantPane_openPathInFinder:(id)aFinder;
- (void)HSReadWriteTextActionAssistantPane_openDialogToChooseFile;
- (void)HSReadWriteTextActionAssistantPane_updateUserDefaultsWithUserURL:(id)aURL actionURL:(id)aURL2;
- (id)HSReadWriteTextActionAssistantPane_actionURLForUserURL:(id)aURL excludeApplicationBundle:(BOOL)aBundle relativeToStack:(BOOL *)aStack;
- (void)popUpButtonWillPopUp:(id)aUp;
- (void)HSReadWriteTextActionAssistantPane_removeObserverFromPopUpButton;
- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (id)documentDirectoryURL;
- (id)actionAttributes;
- (id)actionType;
- (id)readWriteTextActionAssistantPaneApplier;
- (Class)applierClass;
- (void)viewDidLoad;
- (void)dealloc;
- (id)init;
@end

@interface HSReadWriteTextActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    HSUID *_initialTargetObjectUID;
    NSURL *_initialFileURL;
    int _initialMode;
    int _initialOperation;
    HSUID *_targetObjectUID;
    NSURL *_fileURL;
    int _mode;
    int _operation;
    id<HSReadWriteTextActionAttributes> _actionAttributes;
    unsigned int _isFileURLRelativeToStackInitially:1;
    unsigned int _isFileURLRelativeToStack:1;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setModeAsInitial;
- (void)setOperationAsInitial;
- (void)setFileURLAsInitial;
- (void)setTargetObjectAsInitial;
- (void)setInitialModeToObject;
- (void)setInitialOperationToObject;
- (void)setInitialFileURLToObject;
- (void)setInitialTargetObjectToObject;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setCurrentModeToObject;
- (void)setCurrentOperationToObject;
- (void)setCurrentFileURLToObject;
- (void)setCurrentTargetObjectUIDToObject;
- (void)setMode:(NSInteger)aMode;
- (void)setOperation:(NSInteger)aOperation;
- (void)setFileURL:(id)aURL relativeToStack:(BOOL)aStack;
- (void)setTargetObjectUID:(id)aUID;
- (id)readWriteTextActionAttributes;
- (void)setUpInitialSettings;
- (void)dealloc;
@end

