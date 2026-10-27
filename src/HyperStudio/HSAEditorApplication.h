#import "HyperStudioPrefix.h"


@interface HSAEditorApplication : HSApplication
{
    int _colorPickerMode;
    id<HSKeyEventsConsumer> _keyEventsConsumer;
}
+ (id)sharedHyperApplication;
- (void)hide:(id)aHide;
- (void)setColorPickerMode:(NSInteger)aMode;
- (void)toggleColorPanel:(id)aPanel;
- (void)orderFrontFontPanel:(id)aPanel;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (void)sendEvent:(id)aEvent;
- (BOOL)sendAction:(SEL)aAction to:(id)aTo from:(id)aFrom;
- (void)noteMainWindowDidHandleMouseMovedEvent;
- (BOOL)performAction:(SEL)aAction target:(id)aTarget validate:(BOOL)aValidate;
- (void)hideSplashWindow;
- (void)beginSheet:(id)aSheet modalForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (struct _NSModalSession *)beginModalSessionForWindow:(id)aWindow relativeToWindow:(id)aWindow2;
- (struct _NSModalSession *)beginModalSessionForWindow:(id)aWindow;
- (NSInteger)runModalForWindow:(id)aWindow relativeToWindow:(id)aWindow2;
- (NSInteger)runModalForWindow:(id)aWindow;
- (id)init;
@end

@interface HSValidateActionItem : NSObject <NSValidatedUserInterfaceItem>
{
    SEL _action;
}
- (void)setAction:(SEL)aAction;
- (SEL)action;
- (NSInteger)tag;
@end

