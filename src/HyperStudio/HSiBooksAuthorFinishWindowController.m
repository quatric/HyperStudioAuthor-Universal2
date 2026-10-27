#import "HSiBooksAuthorFinishWindowController.h"

@implementation HSiBooksAuthorFinishWindowController

- (void)onOK:(id)aOK
{
    [NSApp endSheet:[self window] returnCode:1];
    [[self window] close];
}

- (void)onOpenFolder:(id)aFolder
{
    [NSApp endSheet:[self window] returnCode:0];
    [[NSWorkspace sharedWorkspace] openFile:[_storePath stringByDeletingLastPathComponent]];
    [[self window] close];
}

- (void)windowDidLoad
{
    [_storePathTextField setStringValue:_storePath];
}

- (id)windowNibName
{
    return @"HSiBooksAuthorPublisherFinishWindow";
}

- (void)dealloc
{
    [_storePath release];
    [super dealloc];
}

- (id)initWithStorePath:(id)aPath
{
    if (aPath == nil)
        return nil;
    self = [super initWithWindow:nil];
    if (self != nil)
        _storePath = [aPath copy];
    return self;
}

- (id)initWithWindow:(id)aWindow
{
    [self release];
    return nil;
}

@end
