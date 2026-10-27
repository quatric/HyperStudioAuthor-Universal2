#import "HSInfoTagWindow.h"

@implementation HSInfoTagWindow

- (void)close
{
    [super close];
    if (![self isReleasedWhenClosed])
        [self _setFadingOut:NO];
}

- (void)orderFront:(id)aFront
{
    [self _setFadingOut:NO];
    [self _adjustFrame];
    [super orderFront:aFront];
}

- (void)makeKeyAndOrderFront:(id)aFront
{
    [self _setFadingOut:NO];
    [self _adjustFrame];
    [super makeKeyAndOrderFront:aFront];
}

- (void)_adjustFrame
{
    NSScreen *screen = [self screen];
    NSRect frame = [self frame];
    NSRect screenFrame = [screen frame];
    if (frame.size.width < screenFrame.size.width) {
        if (screenFrame.size.width + screenFrame.origin.x < frame.size.width + frame.origin.x)
            frame.origin.x -= ((frame.size.width + frame.origin.x) - (screenFrame.size.width + screenFrame.origin.x)) + 5.0;
        if (frame.origin.x < screenFrame.origin.x)
            frame.origin.x += screenFrame.origin.x - frame.origin.x;
    }
    if (frame.size.height < screenFrame.size.height) {
        if (screenFrame.size.height + screenFrame.origin.y < frame.size.height + frame.origin.y)
            frame.origin.y -= ((frame.size.height + frame.origin.y) - (screenFrame.size.height + screenFrame.origin.y)) + 5.0;
        if (frame.origin.y < screenFrame.origin.y)
            frame.origin.y += screenFrame.origin.y - frame.origin.y;
    }
    [self setFrame:frame display:NO];
}

- (void)fadeOut
{
    [self _setFadingOut:YES];
}

- (void)_fadeOut:(id)aOut
{
    float alpha = [self alphaValue] - _fadeOutStep;
    if (alpha > 0.0f)
        [self setAlphaValue:alpha];
    else
        [self close];
}

- (void)_setFadingOut:(BOOL)aOut
{
    if (!aOut) {
        if (_fadeOutTimer != nil) {
            [_fadeOutTimer invalidate];
            [_fadeOutTimer release];
            _fadeOutTimer = nil;
            [self setAlphaValue:_storedAlphaValue];
        }
    } else if (_fadeOutTimer == nil) {
        _storedAlphaValue = [self alphaValue];
        _fadeOutTimer = [[NSTimer scheduledTimerWithTimeInterval:_fadeOutInterval target:self selector:@selector(_fadeOut:) userInfo:nil repeats:YES] retain];
    }
}

- (BOOL)isFadingOut
{
    return _fadeOutTimer != nil;
}

- (BOOL)canBecomeMainWindow
{
    return NO;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (id)initWithContentRect:(NSRect)aRect styleMask:(NSUInteger)aMask backing:(NSUInteger)aBacking defer:(BOOL)aDefer
{
    self = [super initWithContentRect:aRect styleMask:aMask backing:aBacking defer:aDefer];
    if (self != nil) {
        _fadeOutStep = 0.01f;
        _fadeOutInterval = 0.01f;
    }
    return self;
}

@end
