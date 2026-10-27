#import "HyperPlayerBasePrefix.h"


@interface HSGenericModalController : NSResponder
{
    NSWindow *_window;
    id _delegate;
    SEL _didEndSelector;
    BOOL _runningAsSheet;
    NSWindow *_sheetWindow;
    BOOL _isPaused;
    NSButton *_defaultButton;
}
- (void)finishDialog:(BOOL)aDialog;
- (void)continueDialog;
- (void)pauseDialog;
- (void)cancel:(id)aCancel;
- (void)ok:(id)aOk;
- (void)sheetDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)runForWindow:(id)aWindow delegate:(id)aDelegate didEndSelector:(SEL)aSelector;
- (NSInteger)runModalWithDelegate:(id)aDelegate;
- (NSInteger)runModal;
- (void)applyChanges;
- (void)willCloseWindow;
- (void)willShowWindow;
- (void)didLoadNib;
- (id)nibName;
- (id)parentWindow;
- (id)window;
- (void)loadUI;
- (void)dealloc;
- (id)delegate;
@end

@interface HSGenericModalController (ButtonObjectValidation)
+ (BOOL)isValidButtonObject:(id)aObject validateIcon:(BOOL)aIcon;
@end

@interface HSGenericModalController (PreviewImageVisualRectCalculation)
+ (NSRect)previewImageVisualRectForObject:(id)aObject;
@end

