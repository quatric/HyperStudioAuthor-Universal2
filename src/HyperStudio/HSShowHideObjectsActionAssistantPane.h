#import "HyperStudioPrefix.h"
#import "HSActionAssistantPane.h"
#import "HSActionAssistantSettingsApplier.h"


@interface HSShowHideObjectsActionAssistantPane : HSActionAssistantPane
{
    NSTableView *_objectsTableView;
    NSMenu *_actionMenu;
    NSTabView *_transitionsTab;
    NSPopUpButton *_showEffectTransitionPopup;
    NSSlider *_showEffectSpeedSlider;
    HSTransitionView *_showEffectTransitionPreview;
    NSButton *_showEffectTransitionImageView;
    NSPopUpButton *_hideEffectTransitionPopup;
    NSSlider *_hideEffectSpeedSlider;
    HSTransitionView *_hideEffectTransitionPreview;
    NSButton *_hideEffectTransitionImageView;
    NSButton *_objectsFilterSwitch;
    NSMutableArray *_availableObjects;
    HSStack *_stack;
    NSMutableDictionary *_objectIcons;
    NSDictionary *_resourceNames;
    NSString *_lastUserChosenShowTransitionName;
    double _lastUserChosenShowTransitionDuration;
    NSString *_lastUserChosenHideTransitionName;
    double _lastUserChosenHideTransitionDuration;
}
- (NSInteger)checkedObjects;
- (void)setLastUserChoosedTransitionParametersForHyperUID:(id)aUID;
- (void)selectCurrentObjectVisibilityActionTab;
- (void)startCurrentObjectVisibilityActionTransition;
- (void)availableCardObjectsDidChange:(id)aChange;
- (void)setStack:(id)aStack;
- (id)stack;
- (void)transitionViewDidFinishTransition:(id)aTransition;
- (void)transitionViewDidStopTransition:(id)aTransition;
- (void)stopTransitionPreviewIfNeeded:(id)aNeeded;
- (void)startHideEffectTransition;
- (void)startShowEffectTransition;
- (id)selectedObjectUID;
- (id)HSShowHideObjectsActionAssistantPane_applier;
- (void)HSShowHideObjectsActionAssistantPane_updateTransitionPreviewWithSettings:(id)aSettings;
- (void)HSShowHideObjectsActionAssistantPane_setValue:(id)aValue forSettingKey:(id)aKey transitionTypeKey:(id)aKey2 updatePreview:(BOOL)aPreview;
- (void)HSShowHideObjectsActionAssistantPane_validateUIWithActionSettings:(id)aSettings;
- (void)HSShowHideObjectsActionAssistantPane_validateEffectTransitionPopup:(id)aPopup speedSlider:(id)aSlider withTransitionSettings:(id)aSettings canBeEnabled:(BOOL)aEnabled;
- (void)validateUIWithNotification:(id)aNotification;
- (id)HSShowHideObjectsActionAssistantPane_availableCardObjects;
- (void)validateUI;
- (void)filterChanged:(id)aChanged;
- (void)previewHideEffectTransition:(id)aTransition;
- (void)previewShowEffectTransition:(id)aTransition;
- (void)actionHideEffectTransitionSpeedChanged:(id)aChanged;
- (void)actionHideEffectTransitionNameChanged:(id)aChanged;
- (void)actionShowEffectTransitionSpeedChanged:(id)aChanged;
- (void)actionShowEffectTransitionNameChanged:(id)aChanged;
- (void)tabView:(id)aView didSelectTabViewItem:(id)aItem;
- (void)tableViewSelectionDidChange:(id)aChange;
- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation;
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (BOOL)tableView:(id)aView shouldEditTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)arrayForObjectWithType:(id)aType name:(id)aName;
- (id)imageForObjectName:(id)aName selected:(BOOL)aSelected;
- (id)resourceNames;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (void)HSShowHideObjectsActionAssistantPane_addTableHeaderToolTips;
- (id)helpTopicKey;
- (void)HSShowHideObjectsActionAssistantPane_hideTransitionView:(id)aView;
- (Class)applierClass;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (void)viewDidLoad;
- (struct CGImage *)HSShowHideObjectsActionAssistantPane_copyImage:(struct CGImage *)aImage scalingToSize:(NSSize)aSize;
- (id)actionType;
- (void)dealloc;
- (void)awakeFromNib;
- (id)init;
@end

@interface HSShowHideObjectsActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSMutableDictionary *_actionSettings;
    NSMutableDictionary *_modifiedActionSettings;
    NSString *_defaultTransitionName;
    double _defaultTransitionDuration;
}
- (void)HSShowHideObjectsActionAssistantPaneApplier_applySettings:(id)aSettings;
- (void)synchronizeWithAction;
- (BOOL)conditionalEqualObjectSettings:(id)aSettings toOther:(id)aOther;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (id)checkAndCorrectEffectSettings:(id)aSettings;
- (void)setValue:(id)aValue forSettingKey:(id)aKey transitionTypeKey:(id)aKey2 objectUID:(id)aUID;
- (id)actionSettingsForObjectUID:(id)aUID;
- (void)setDefaultTransitionDuration:(double)aDuration;
- (void)setDefaultTransitionName:(id)aName;
- (id)showHideActionAttributes;
- (void)dealloc;
@end

