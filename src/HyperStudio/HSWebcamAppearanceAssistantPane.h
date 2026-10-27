#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSWebcamAppearanceAssistantPane : HSObjectAssistantPane
{
    NSTextField *_nameTextField;
    NSTextField *_locationTextField;
    NSTextField *_refreshRateTextField;
    NSTextField *_sizeTextField;
    NSTextField *_localTimeTextField;
    NSTextField *_copyrightTextField;
    NSButton *_shadowSwitch;
    NSButton *_shadowButton;
    NSButton *_reloadButton;
    NSImage *_reloadImage;
    NSImage *_pressedReloadImage;
    NSTimer *_oneMinuteTimer;
}
- (void)invalidateLocalTime:(id)aTime;
- (id)currentTimeStringForTimeZone:(id)aZone;
- (void)updateShadow;
- (void)validateUI;
- (void)validateShadowAttributesWithNotification:(id)aNotification;
- (void)validateUIWithNotification:(id)aNotification;
- (void)editShadow:(id)aShadow;
- (void)setShadow:(id)aShadow;
- (void)showShadowPane;
- (void)reloadWebPage:(id)aPage;
- (void)setName:(id)aName;
- (id)shadowAttributes;
- (id)webPageObjectAttributes;
- (id)nameTextfField;
- (id)initialKeyView;
- (BOOL)isEditingTextAttribute;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)dealloc;
- (void)viewDidLoad;
- (id)init;
@end

