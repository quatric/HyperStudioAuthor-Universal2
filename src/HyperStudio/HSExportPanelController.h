#import "HyperStudioPrefix.h"


@interface HSExportPanelController : NSWindowController
{
    NSString *_requiredFileType;
    id _publisher;
    NSBox *_accessoryViewContainer;
    NSButton *_hideExtensionButton;
    NSInvocation *_didEndSheetInvocation;
    HSExportAccessoryViewController *_accessoryViewController;
    BOOL _needRunExportDialog;
}
- (void)cancel:(id)aCancel;
- (void)ok:(id)aOk;
- (void)toggleExtensionHidden:(id)aHidden;
- (void)endSheetWithReturnCode:(NSInteger)aCode;
- (void)beginSheetForDirectory:(id)aDirectory file:(id)aFile modalForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (id)directory;
- (id)filename;
- (BOOL)isExpanded;
- (BOOL)isNeedRunExportDialog;
- (void)setNeedRunExportDialog:(BOOL)aDialog;
- (void)setRequiredFileType:(id)aType;
- (id)requiredFileType;
- (void)setAccessoryViewController:(id)aController;
- (id)accessoryViewController;
- (void)setAccessoryView:(id)aView;
- (id)accessoryView;
- (void)dealloc;
- (id)initWithPublisher:(id)aPublisher;
@end

