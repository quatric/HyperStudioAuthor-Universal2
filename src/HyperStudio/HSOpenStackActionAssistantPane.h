#import "HyperStudioPrefix.h"
#import "HSActionAssistantPane.h"
#import "HSActionAssistantSettingsApplier.h"


@interface HSOpenStackActionAssistantPane : HSActionAssistantPane
{
    NSTextField *_stackNameField;
    HSImageView *_containerView;
    NSView *_placeholderView;
    NSView *_cardPreviewContentView;
    HSDropImageView *_stackDropArea;
    NSImageView *_cardPreviewView;
    NSView *_contentView;
    HSAssistantPaneMultiApplier *_paneMultiApplier;
    HSDocument *_previewDocument;
    NSString *_cachedPath;
}
- (id)thumbnailOfCard:(id)aCard ofSize:(NSSize)aSize;
- (void)mountContentView:(id)aView;
- (void)setPreviewDocument:(id)aDocument;
- (id)previewDocument;
- (void)setCachedPath:(id)aPath;
- (id)objectAssistantForNavigationPaneSwitcher:(id)aSwitcher;
- (BOOL)canGoToNextPane;
- (id)nextPaneForObjectAssistant:(id)aAssistant;
- (void)chooseStack:(id)aStack;
- (id)helpTopicKey;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)validateUserInterface;
- (void)viewDidLoad;
- (id)actionAttributes;
- (id)actionType;
- (id)openStackActionAssistantApplier;
- (Class)applierClass;
- (id)navigationPaneSwitcher;
- (id)paneMultiApplier;
- (void)dealloc;
- (id)init;
- (BOOL)shouldRewindToPreviousHubPane;
- (void)toggleOpenInSeparateWindow:(id)aSender;
@end

@interface HSOpenStackActionAssistantApplier : HSActionAssistantSettingsApplier
{
    BOOL _shouldOpenInSeparateWindow;
    NSURL *_initialURL;
    NSURL *_URL;
}
- (void)setURL:(id)aURL;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (id)openStackActionAttributes;
- (void)setShouldOpenInSeparateWindow:(BOOL)aOpen;
@end

@interface HSOpenStackActionAssistantPane (HSDropImageViewDelegate)
- (void)hyperImageView:(id)aView didAcceptedDropWithDraggingInfo:(id)aInfo;
- (NSUInteger)draggingEntered:(id)aEntered inHyperImageView:(id)aView;
@end

