#import "HSAFTPServerFinishWindowController.h"

@implementation HSAFTPServerFinishWindowController

- (id)windowNibName
{
    return @"FTPServerFinishWindow";
}

// Without a store path the window only offers the finish view.
- (void)windowDidLoad
{
    [super windowDidLoad];
    if ([_storePath length] == 0) {
        NSRect frame = _finishView != nil ? [_finishView frame] : NSZeroRect;
        [[self window] setContentSize:frame.size];
        [[self window] setContentView:_finishView];
    }
}

- (IBAction)onPreviewSiteNow:(id)aSender
{
    [NSApp endSheet:[self window] returnCode:0];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:_storePath]];
    [[self window] close];
}

@end
