#import "HSiBooksAuthorPublisher.h"

@implementation HSiBooksAuthorPublisher

- (id)finishWindow
{
    if (_finishWindow == nil) {
        _windowController = [[HSiBooksAuthorFinishWindowController alloc] initWithStorePath:_storePath];
        _finishWindow = [[_windowController window] retain];
    }
    return _finishWindow;
}

- (void)dealloc
{
    [_windowController release];
    [super dealloc];
}

@end
