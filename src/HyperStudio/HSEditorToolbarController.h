#import "HyperStudioPrefix.h"


@interface HSEditorToolbarController : HSToolbarController
{
    NSView *_addRemoveCardControlContainer;
    NSView *_browseEditModeControlContainer;
}
- (BOOL)validateCell:(id)aCell ofToolbarItem:(id)aItem;
- (void)setupToolbar;
- (id)toolbarFilename;
- (void)dealloc;
@end

