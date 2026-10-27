#import "HyperStudioPrefix.h"
#import "HSExportPanelController.h"


@interface HSDesktopExportPanelController : HSExportPanelController
{
    NSSavePanel *_savePanel;
    id _modalDelegate;
    SEL _didEndSelector;
}
- (void)endSheetWithReturnCode:(NSInteger)aCode;
- (void)beginSheetForDirectory:(id)aDirectory file:(id)aFile modalForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (void)savePanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (id)directory;
- (id)filename;
- (BOOL)isExpanded;
- (void)setRequiredFileType:(id)aType;
- (id)requiredFileType;
- (void)setAccessoryView:(id)aView;
- (id)accessoryView;
- (id)window;
- (void)dealloc;
- (id)init;
@end

