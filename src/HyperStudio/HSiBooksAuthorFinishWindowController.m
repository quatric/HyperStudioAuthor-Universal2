#import "HSiBooksAuthorFinishWindowController.h"

@implementation HSiBooksAuthorFinishWindowController

- (void)onOpenFolder:(id)aFolder
{
    [NSApp endSheet:[self window] returnCode:0];
    [[NSWorkspace sharedWorkspace] openFile:[_storePath stringByDeletingLastPathComponent]];
    [[self window] close];
}

- (id)windowNibName
{
    return @"HSiBooksAuthorPublisherFinishWindow";
}

@end
