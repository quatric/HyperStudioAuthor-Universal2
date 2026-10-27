#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"
#import "HSCommentsTextView.h"


@interface HSStackSizesAssistantPane : HSObjectAssistantPane
{
    NSMatrix *_chooseSizeMatrix;
    NSPopUpButton *_standartSizesPopupButton;
    NSTextField *_widthTextField;
    NSStepper *_widthStepper;
    NSTextField *_heightTextField;
    NSStepper *_heightStepper;
    HSObjectAssistantNavigationPaneSwitcher *_paneSwitcher;
    HSStackAssistantPaneApplier *_applier;
    NSArray *_cardSizesInfo;
    BOOL _useDefaultCardSize;
}
- (void)stackWidthChanged:(id)aChanged;
- (void)stackHeightChanged:(id)aChanged;
- (void)standartSizeChanged:(id)aChanged;
- (void)sizeTypeChanged:(id)aChanged;
- (void)setUseDefaultCardSize:(BOOL)aSize;
- (id)helpTopicKey;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (BOOL)control:(id)aControl didFailToFormatString:(id)aString errorDescription:(id)aDescription;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)applier;
- (void)setApplier:(id)aApplier;
- (id)navigationPaneSwitcher;
- (void)enableCustomSizeControls:(BOOL)aControls;
- (void)showAlert;
- (void)showMaximumExceededSizeAlert;
- (void)validateUI;
- (id)cardSizesInfo;
- (void)validateCardSizeControls;
- (id)stackAttributes;
- (void)viewDidLoad;
- (void)dealloc;
- (id)init;
@end

@interface HSStackAssistantPaneApplier : HSAssistantPaneApplier
{
    NSSize _initialCardSize;
    int _initialSelectedSizeMatrixIndex;
    int _initialSelectedStandartSizeIndex;
    NSSize _currentCardSize;
    int _currentSelectedSizeMatrixIndex;
    int _currentSelectedStandartSizeIndex;
}
- (BOOL)areSettingsEqual;
- (void)setSelectedStandartSizeIndex:(NSInteger)aIndex;
- (NSInteger)selectedStandartSizeIndex;
- (void)setSelectedSizeMatrixIndex:(NSInteger)aIndex;
- (NSInteger)selectedSizeMatrixIndex;
- (void)setHyperCardSize:(NSSize)aSize;
- (NSSize)hyperCardSize;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)applyChanges;
- (id)initWithObject:(id)aObject;
- (id)undoActionName;
- (id)stackAttributes;
@end

