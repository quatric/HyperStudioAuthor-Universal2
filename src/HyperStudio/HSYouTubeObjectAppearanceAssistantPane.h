#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSYouTubeObjectAppearanceAssistantPane : HSObjectAssistantPane
{
    NSTextField *_nameTextField;
    HSURLLinkButton *_authorLinkButton;
    NSTextField *_durationTextField;
    NSButton *_shadowSwitch;
    NSButton *_shadowButton;
    NSButton *_watchButton;
    NSButton *_changeButton;
}
- (void)youTubeDialog:(id)aDialog didEndWithReturnCode:(NSInteger)aCode;
- (void)updateShadow;
- (void)validateUI;
- (void)validateShadowAttributesWithNotification:(id)aNotification;
- (void)validateUIWithNotification:(id)aNotification;
- (void)changeVideo:(id)aVideo;
- (void)watchOnYouTube:(id)aTube;
- (void)editShadow:(id)aShadow;
- (void)setShadow:(id)aShadow;
- (void)showShadowPane;
- (void)setName:(id)aName;
- (id)shadowAttributes;
- (id)youTubeObjectAttributes;
- (id)nameTextfField;
- (id)initialKeyView;
- (BOOL)isEditingTextAttribute;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)dealloc;
- (id)init;
@end

