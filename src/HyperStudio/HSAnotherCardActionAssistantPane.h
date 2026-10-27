#import "HyperStudioPrefix.h"
#import "HSActionAssistantPane.h"
#import "HSActionAssistantSettingsApplier.h"


@interface HSAnotherCardActionAssistantPane : HSActionAssistantPane
{
    HSStoryboardView *_storyboardView;
    HSImageView *_containerView;
    HSDropImageView *_stackDropArea;
    NSTextField *_stackNameField;
    NSButton *_openInSeparateWindowSwitch;
    NSView *_storyboardContentView;
    NSView *_placeholderView;
    NSView *_contentView;
    HSAssistantPaneMultiApplier *_paneMultiApplier;
    HSDocument *_previewDocument;
    BOOL _ignoreActionAttributesChanging;
}
- (void)mountContentView:(id)aView;
- (void)setPreviewDocument:(id)aDocument;
- (id)previewDocument;
- (void)animationDidEnd:(id)aEnd;
- (void)animationDidStop:(id)aStop;
- (void)invalidateAnimation;
- (void)validateUIWithNotification:(id)aNotification;
- (BOOL)canGoToNextPane;
- (id)objectAssistantForNavigationPaneSwitcher:(id)aSwitcher;
- (id)nextPaneForObjectAssistant:(id)aAssistant;
- (id)navigationPaneSwitcher;
- (id)paneMultiApplier;
- (void)chooseCurrentStack:(id)aStack;
- (void)chooseStack:(id)aStack;
- (void)storyboardSelectionDidChange:(id)aChange;
- (CGFloat)storyboardScaleFactorForColumnsCount:(NSInteger)aCount;
- (void)validateUserInterface;
- (id)helpTopicKey;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (void)updateObjectWithApplier;
- (void)viewDidLoad;
- (id)actionAttributes;
- (id)actionType;
- (id)anotherCardActionAsssistantApplier;
- (Class)applierClass;
- (void)dealloc;
- (id)init;
- (BOOL)shouldRewindToPreviousHubPane;
- (void)toggleOpenInSeparateWindow:(id)aSender;
@end

@interface HSAnotherCardActionAssistantApplier : HSActionAssistantSettingsApplier
{
    BOOL _shouldOpenInSeparateWindow;
    BOOL _initialShouldOpenInSeparateWindow;
    NSURL *_initialURL;
    HSUID *_initialCardUID;
    int _initialCardIDOldFileFormat;
    NSURL *_URL;
    HSUID *_cardUID;
    int _cardIDOldFileFormat;
}
- (void)setCardID:(NSInteger)aID;
- (void)setCardUID:(id)aUID;
- (void)setURL:(id)aURL;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)otherCardActionAttributes;
- (void)dealloc;
- (void)setShouldOpenInSeparateWindow:(BOOL)aOpen;
@end

@interface HSAnotherCardActionAssistantPane (HSDropImageViewDelegate)
- (void)hyperImageView:(id)aView didAcceptedDropWithDraggingInfo:(id)aInfo;
- (NSUInteger)draggingEntered:(id)aEntered inHyperImageView:(id)aView;
@end

