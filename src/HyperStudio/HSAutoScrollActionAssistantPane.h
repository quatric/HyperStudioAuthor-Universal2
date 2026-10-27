#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSAutoScrollActionAssistantPane : HSNBAAssistantPane
{
    NSTableView *_tableView;
    NSComboBox *_textNameCombobox;
    NSView *_containerView;
    NSView *_mainView;
    NSView *_emptyView;
    NSTextField *_numberOfStepsField;
    NSTextField *_stepsPerSecondField;
    NSMatrix *_scrollUnitsMatrix;
    NSTextField *_scrollAmountField;
    NSButton *_ignoreMouseClicksButton;
    NSButton *_testSpeedButton;
    NSMatrix *_scrollDirectionMatrix;
    NSView *_currentView;
    NSMutableArray *_availableTextViews;
    HSActionSynchronizer *_actionSynchronizer;
    NSImage *_playImage;
    NSImage *_stopImage;
    NSImage *_pressedPlayImage;
    NSImage *_pressedStopImage;
}
- (void)invalidateActionSynchronizer;
- (void)actionSynchronizerDidFinishPerformActions:(id)aActions;
- (BOOL)isScrolling;
- (void)setUpPauseButton;
- (void)setUpPlayButton;
- (void)setOptionsEnabled:(BOOL)aEnabled;
- (void)validateUI;
- (void)validateUIWithNotification:(id)aNotification;
- (void)controlTextDidEndEditing:(id)aEditing;
- (NSUInteger)comboBox:(id)aBox indexOfItemWithStringValue:(id)aValue;
- (id)comboBox:(id)aBox completedString:(id)aString;
- (id)comboBox:(id)aBox objectValueForItemAtIndex:(NSInteger)aIndex;
- (NSInteger)numberOfItemsInComboBox:(id)aBox;
- (void)controlTextDidChange:(id)aChange;
- (void)testSpeed:(id)aSpeed;
- (void)ignoreMouseClicksStateChanged:(id)aChanged;
- (void)scrollUnitsChanged:(id)aChanged;
- (void)scrollAmountChanged:(id)aChanged;
- (void)stepsPerSecondChanged:(id)aChanged;
- (void)numberOfStepsChanged:(id)aChanged;
- (void)scrollDirectionChanged:(id)aChanged;
- (void)textNameChanged:(id)aChanged;
- (id)helpTopicKey;
- (void)dealloc;
- (void)viewDidLoad;
- (id)initialKeyView;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setDefaultActionAttributes;
- (id)actionAttribute;
- (void)validateTestSpeedButton;
- (void)validateIgnoreMouseClicksButton;
- (void)validateScrollSpeed;
- (void)validateScrollDirection;
- (void)validateScrollAmount;
- (void)validateTextNames;
- (void)mountView:(id)aView;
- (id)availableTextViews;
- (id)actionType;
- (id)actionAttributes;
- (id)autoScrollActionAssistantPaneApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSAutoScrollActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    int _initialNumberOfSteps;
    int _initialStepsPerSecond;
    int _initialScrollAmount;
    int _initialScrollUnits;
    int _initialScrollDirection;
    BOOL _initialIsInEditMode;
    BOOL _initialIgnoreMouseClicks;
    NSArray *_initialTextViewNames;
    NSArray *_initialTextViewUIDs;
    int _numberOfSteps;
    int _stepsPerSecond;
    int _scrollAmount;
    int _scrollUnits;
    int _scrollDirection;
    BOOL _isInEditMode;
    BOOL _ignoreMouseClicks;
    NSArray *_textViewNames;
    NSArray *_textViewUIDs;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setIgnoreMouseClicks:(BOOL)aClicks;
- (void)setTextViewUIDs:(id)aDs;
- (void)setTextViewNames:(id)aNames;
- (void)setScrollDirection:(NSInteger)aDirection;
- (void)setScrollUnits:(NSInteger)aUnits;
- (void)setScrollAmount:(NSInteger)aAmount;
- (void)setStepsPerSecond:(NSInteger)aSecond;
- (void)setNumberOfSteps:(NSInteger)aSteps;
- (void)setUpInitialSettings;
- (id)autoScrollActionAttributes;
- (void)dealloc;
@end

