#import "HyperPlayerBasePrefix.h"


@interface HSAlert : NSObject
{
    NSButton *_firstButton;
    NSButton *_secondButton;
    NSButton *_thirdButton;
    NSButton *_helpButton;
    HSAlertView *_alertView;
    NSImageView *_imageView;
    NSWindow *_window;
    unsigned int _addButtonNumber;
    float _minButtonWidth;
    id _delegate;
    BOOL _inited;
    BOOL _canClose;
    BOOL _modal;
    BOOL _sheet;
    NSInvocation *_alertDidEndSheetInvocation;
    int _style;
    NSString *_helpAnchor;
}
+ (id)applicationIcon;
+ (id)informationalIcon;
+ (id)criticalIcon;
+ (id)warningIcon;
+ (id)mascotIcon;
+ (id)iconForKey:(id)aKey;
+ (id)iconForAlertStyle:(NSInteger)aStyle;
+ (NSInteger)defaultAlertStyle;
+ (id)alertWithMessageText:(id)aText defaultButton:(id)aButton alternateButton:(id)aButton2 otherButton:(id)aButton3 informativeText:(id)aText2;
- (void)closeWindow;
- (id)window;
- (void)closeWithCode:(NSInteger)aCode;
- (void)close;
- (id)anchor;
- (void)setHelpAnchor:(id)aAnchor;
- (BOOL)showsHelp;
- (void)setShowsHelp:(BOOL)aHelp;
- (id)buttons;
- (void)addButtonWithTitle:(id)aTitle;
- (void)setupButton:(id)aButton withTitle:(id)aTitle;
- (void)layout;
- (void)setIcon:(id)aIcon;
- (id)icon;
- (void)setDoNotShowAgainPreferenceKey:(id)aKey;
- (id)doNotShowAgainPreferenceKey;
- (void)setCustomView:(id)aView;
- (id)customView;
- (void)setBottomInformativeText:(id)aText;
- (id)bottomInformativeText;
- (void)setInformativeText:(id)aText;
- (id)informativeText;
- (void)setMessageText:(id)aText;
- (id)messageText;
- (void)setCanClose:(BOOL)aClose;
- (BOOL)canClose;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)beginSheetModalForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (NSInteger)runModal;
- (NSInteger)alertStyle;
- (void)setAlertStyle:(NSInteger)aStyle;
- (void)dealloc;
- (void)initOnce;
- (id)init;
- (id)nibName;
@end

@interface HSAlert (IBActions)
- (void)help:(id)aHelp;
- (void)thirdButtonPressed:(id)aPressed;
- (void)secondButtonPressed:(id)aPressed;
- (void)firstButtonPressed:(id)aPressed;
@end

