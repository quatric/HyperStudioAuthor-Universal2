#import "HSDesktopExportPanelController.h"

@implementation HSDesktopExportPanelController

- (void)endSheetWithReturnCode:(NSInteger)aCode
{
    if (aCode == NSModalResponseOK)
        [_savePanel ok:self];
    else
        [_savePanel cancel:self];
}

// The pre-10.6 directory/file sheet API is gone; only the URL-based path remains.
- (void)beginSheetForDirectory:(id)aDirectory file:(id)aFile modalForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    _modalDelegate = aDelegate;
    _didEndSelector = aSelector;
    if (![(id)aInfo isEqualToString:@"HSiBooksAuthorDocumentType"] && [_modalDelegate conformsToProtocol:@protocol(NSOpenSavePanelDelegate)] && ![[HSSystem sharedSystem] isSandboxed])
        [_savePanel setDelegate:_modalDelegate];
    [_savePanel setDirectoryURL:[NSURL fileURLWithPath:aDirectory isDirectory:YES]];
    [_savePanel setNameFieldStringValue:aFile];
    [_savePanel beginSheetModalForWindow:aWindow completionHandler:^(NSInteger result) {
        [self savePanelDidEnd:_savePanel returnCode:result contextInfo:aInfo];
    }];
}

- (void)savePanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    id controller = self;
    NSInteger code = aCode;
    void *info = aInfo;
    [_publisher setPublishLocation:[self directory]];
    [[self accessoryViewController] viewWillDisappear:NO];
    [NSApp endSheet:aEnd];
    [aEnd orderOut:self];
    if (_didEndSelector == NULL)
        return;
    NSMethodSignature *signature = [_modalDelegate methodSignatureForSelector:_didEndSelector];
    if (signature == nil)
        return;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:_modalDelegate];
    [invocation setSelector:_didEndSelector];
    [invocation setArgument:&controller atIndex:2];
    [invocation setArgument:&code atIndex:3];
    [invocation setArgument:&info atIndex:4];
    [invocation invoke];
}

- (id)directory
{
    return [[[_savePanel URL] path] stringByDeletingLastPathComponent];
}

- (id)filename
{
    return [[[_savePanel URL] path] lastPathComponent];
}

- (BOOL)isExpanded
{
    return [_savePanel isExpanded];
}

- (void)setRequiredFileType:(id)aType
{
    [_savePanel setAllowedFileTypes:[NSArray arrayWithObject:aType]];
    [_savePanel setCanSelectHiddenExtension:[aType length] != 0];
}

- (id)requiredFileType
{
    return [[_savePanel allowedFileTypes] objectAtIndex:0];
}

- (void)setAccessoryView:(id)aView
{
    if ([self accessoryView] == aView)
        return;
    [[self accessoryViewController] viewWillAppear:NO];
    [_savePanel setAccessoryView:aView];
}

- (id)accessoryView
{
    return [_savePanel accessoryView];
}

- (id)window
{
    return _savePanel;
}

- (void)dealloc
{
    [_savePanel release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _savePanel = [[NSSavePanel savePanel] retain];
        [_savePanel setPrompt:[[NSBundle mainBundle] localizedStringForKey:@"Export" value:@"" table:nil]];
    }
    return self;
}

@end
