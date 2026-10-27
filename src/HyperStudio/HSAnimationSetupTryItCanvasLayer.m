#import "HSAnimationSetupTryItCanvasLayer.h"

@implementation HSAnimationSetupTryItCanvasLayer

- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    if (aSelector != @selector(cancel:) && aSelector != @selector(cancelOperation:))
        return NO;
    [_delegate cancelForTryItCanvasLayer:self];
    return YES;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

@end
