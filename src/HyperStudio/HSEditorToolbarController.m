#import "HSEditorToolbarController.h"

@implementation HSEditorToolbarController

- (BOOL)validateCell:(id)aCell ofToolbarItem:(id)aItem
{
    return [super validateToolbarItem:aItem];
}

- (void)setupToolbar
{
    [NSBundle loadNibNamed:@"EditorToolbarViews" owner:self];
    [super setupToolbar];
}

- (id)toolbarFilename
{
    return @"EditorWindow";
}

- (void)dealloc
{
    [_browseEditModeControlContainer release];
    [_addRemoveCardControlContainer release];
    [super dealloc];
}

@end
