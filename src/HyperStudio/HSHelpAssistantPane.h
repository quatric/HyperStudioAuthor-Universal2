#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSHelpAssistantPane : HSObjectAssistantPane
{
    NSAttributedString *_informativeText;
    BOOL _dontShowThisMessageAgainSwitchHidden;
    NSString *_coachingHintKey;
    id _didDoneDelegate;
    SEL _didDoneSelector;
    void *_delegateContextInfo;
    BOOL _shouldDismissWhenDisappeared;
    BOOL _shouldDismissOnOkFromSwitcher;
    HSNonOpaqueTextView *_textView;
    NSButton *_dontShowThisMessageAgainSwitch;
    NSImageView *_addyImageView;
    HSObjectAssistantNavigationPaneSwitcher *_helpAssistantPaneSwitcher;
}
+ (id)paneWithCoachingKey:(id)aKey;
- (void)toggleDontShowThisMessageAgain:(id)aAgain;
- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (void)paneDidOK:(id)aOK;
- (BOOL)isCoachingPane;
- (void)invokeDidDoneSelectorIfNeeded;
- (BOOL)needsToBeSavedInHistory;
- (BOOL)isEqual:(id)aEqual;
- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide;
- (void)viewDidDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)updateUI;
- (void)setDontShowThisMessageAgainSwitchVisible:(BOOL)aVisible;
- (BOOL)ignoresPreferences;
- (BOOL)needsToShow;
- (BOOL)isDontShowThisMessageAgainSwitchVisible;
- (void)viewDidLoad;
- (id)navigationPaneSwitcher;
- (id)newBackgroundImage;
- (BOOL)requiresDarkBottomArea;
- (BOOL)assistantShouldBeKeyWindow;
- (void *)didDoneContextInfo;
- (SEL)didDoneSelector;
- (id)didDoneDelegate;
- (void)setDidDoneDelegate:(id)aDelegate didDoneSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (void)setCoachingKey:(id)aKey;
- (id)coachingKey;
- (void)setShouldDismissOnOkFromSwitcher:(BOOL)aSwitcher;
- (BOOL)shouldDismissOnOkFromSwitcher;
- (void)setShouldDismissWhenDisappeared:(BOOL)aDisappeared;
- (BOOL)shouldDismissWhenDisappeared;
- (BOOL)shouldDismissWhenDisappearedByDefault;
- (id)copyWithZone:(NSZone *)aZone;
- (id)init;
- (id)initWithCoachingKey:(id)aKey;
- (id)initWithInformativeText:(id)aText;
- (id)initWithInformativeText:(id)aText didEndDelegate:(id)aDelegate didDoneSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (id)initWithNibName:(id)aName informativeText:(id)aText didEndDelegate:(id)aDelegate didDoneSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (id)initWithNibName:(id)aName;
- (void)dealloc;
- (id)informativeText;
- (void)setInformativeText:(id)aText;
@end

