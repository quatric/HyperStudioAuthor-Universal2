#import "HSCanCloseDocumentParametersData.h"

@implementation HSCanCloseDocumentParametersData

- (void)invokeCanCloseCallbackFrom:(id)aFrom shouldClose:(BOOL)aClose
{
    NSMethodSignature *signature = [[self delegate] methodSignatureForSelector:[self selector]];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];

    [invocation setTarget:[self delegate]];
    [invocation setSelector:[self selector]];
    [invocation setArgument:&aFrom atIndex:2];
    [invocation setArgument:&aClose atIndex:3];
    if ([signature numberOfArguments] > 4) {
        void *contextInfo = [self contextInfo];
        [invocation setArgument:&contextInfo atIndex:4];
    }
    [invocation invoke];
}

- (void *)contextInfo
{
    return _contextInfo;
}

- (SEL)selector
{
    return _selector;
}

- (id)delegate
{
    return _delegate;
}

- (id)initWithDelegate:(id)aDelegate selector:(SEL)aSelector contextInfo:(void *)aInfo
{
    self = [super init];
    if (self != nil) {
        _delegate = aDelegate;
        _selector = aSelector;
        _contextInfo = aInfo;
    }
    return self;
}

@end
