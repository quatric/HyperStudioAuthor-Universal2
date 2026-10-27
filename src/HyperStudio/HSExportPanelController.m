#import "HSExportPanelController.h"

@implementation HSExportPanelController

- (void)cancel:(id)aCancel
{
    [self endSheetWithReturnCode:0];
}

- (void)ok:(id)aOk
{
    [self endSheetWithReturnCode:1];
}

- (void)toggleExtensionHidden:(id)aHidden
{
    [self doesNotRecognizeSelector:_cmd];
}

// Ends the sheet, then calls the modal delegate's did-end selector with the
// return code filled in.
- (void)endSheetWithReturnCode:(NSInteger)aCode
{
    int returnCode = (int)aCode;
    [NSApp endSheet:[self window] returnCode:aCode];
    [[self window] orderOut:self];
    if (_didEndSheetInvocation) {
        [_didEndSheetInvocation setArgument:&returnCode atIndex:3];
        NSInvocation *invocation = [_didEndSheetInvocation autorelease];
        _didEndSheetInvocation = nil;
        [invocation invoke];
    }
}

- (void)beginSheetForDirectory:(id)aDirectory file:(id)aFile modalForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    id sheet = self;
    void *contextInfo = aInfo;
    if (aDelegate && aSelector) {
        NSMethodSignature *signature = [aDelegate methodSignatureForSelector:aSelector];
        if (signature) {
            _didEndSheetInvocation = [[NSInvocation invocationWithMethodSignature:signature] retain];
            [_didEndSheetInvocation setTarget:aDelegate];
            [_didEndSheetInvocation setSelector:aSelector];
            [_didEndSheetInvocation setArgument:&sheet atIndex:2];
            [_didEndSheetInvocation setArgument:&contextInfo atIndex:4];
        }
    }
    [NSApp beginSheet:[self window] modalForWindow:aWindow modalDelegate:nil didEndSelector:NULL contextInfo:contextInfo];
}

- (id)directory
{
    return nil;
}

- (id)filename
{
    return nil;
}

- (BOOL)isExpanded
{
    return YES;
}

- (BOOL)isNeedRunExportDialog
{
    return _needRunExportDialog;
}

- (void)setNeedRunExportDialog:(BOOL)aDialog
{
    _needRunExportDialog = aDialog;
}

- (void)setRequiredFileType:(id)aType
{
    if (![_requiredFileType isEqualToString:aType]) {
        [_requiredFileType release];
        _requiredFileType = [aType retain];
    }
}

- (id)requiredFileType
{
    return _requiredFileType;
}

- (void)setAccessoryViewController:(id)aController
{
    if (_accessoryViewController != aController) {
        [_accessoryViewController release];
        _accessoryViewController = [aController retain];
    }
}

- (id)accessoryViewController
{
    return _accessoryViewController;
}

// Swaps the accessory view and resizes the window by the difference between
// the new view and the container.
- (void)setAccessoryView:(id)aView
{
    if ([self accessoryView] != aView) {
        [_accessoryViewController viewWillAppear:NO];
        NSRect windowFrame = [[self window] frame];
        NSRect containerFrame = [_accessoryViewContainer frame];
        NSRect viewFrame = [aView frame];
        [_accessoryViewContainer setContentView:aView];
        windowFrame.size.width = (viewFrame.size.width - containerFrame.size.width) + windowFrame.size.width;
        windowFrame.size.height = (viewFrame.size.height - containerFrame.size.height) + windowFrame.size.height;
        [[self window] setFrame:windowFrame display:YES animate:YES];
    }
}

- (id)accessoryView
{
    return [_accessoryViewContainer contentView];
}

- (void)dealloc
{
    [_requiredFileType release];
    [_accessoryViewController release];
    [super dealloc];
}

- (id)initWithPublisher:(id)aPublisher
{
    self = [self init];
    if (self)
        _publisher = aPublisher;
    return self;
}

@end
