#import "HSAExportPanelController.h"

@implementation HSAExportPanelController

- (id)initWithPublisher:(id)aPublisher
{
    self = [self init];
    if (self != nil) {
        _publisher = aPublisher;
    }
    return self;
}

// The sheet reports to the delegate like an NSSavePanel does: (panel, returnCode, contextInfo).
- (void)beginSheetForDirectory:(id)aDirectory file:(id)aFile modalForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo
{
    if (aDelegate != nil && aSelector != NULL) {
        NSMethodSignature *signature = [aDelegate methodSignatureForSelector:aSelector];
        if (signature != nil) {
            _didEndSheetInvocation = [[NSInvocation invocationWithMethodSignature:signature] retain];
            [_didEndSheetInvocation setTarget:aDelegate];
            [_didEndSheetInvocation setSelector:aSelector];
            [_didEndSheetInvocation setArgument:&self atIndex:2];
            [_didEndSheetInvocation setArgument:&aInfo atIndex:4];
        }
    }
    [NSApp beginSheet:[self window] modalForWindow:aWindow modalDelegate:nil didEndSelector:NULL contextInfo:aInfo];
}

- (void)endSheetWithReturnCode:(int)aCode
{
    [NSApp endSheet:[self window] returnCode:aCode];
    [[self window] orderOut:self];
    if (_didEndSheetInvocation != nil) {
        [_didEndSheetInvocation setArgument:&aCode atIndex:3];
        NSInvocation *invocation = [_didEndSheetInvocation autorelease];
        _didEndSheetInvocation = nil;
        [invocation invoke];
    }
}

- (IBAction)ok:(id)aSender
{
    [self endSheetWithReturnCode:1];
}

- (IBAction)cancel:(id)aSender
{
    [self endSheetWithReturnCode:0];
}

- (id)directory
{
    return nil;
}

- (id)filename
{
    return nil;
}

- (id)requiredFileType
{
    return nil;
}

- (void)setRequiredFileType:(id)aType
{
}

- (id)accessoryView
{
    return nil;
}

- (void)setAccessoryView:(id)aView
{
}

- (id)accessoryViewController
{
    return nil;
}

- (void)setAccessoryViewController:(id)aController
{
}

@end
