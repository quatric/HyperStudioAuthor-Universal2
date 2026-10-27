#import "HSSplashScreenWindowController.h"

@implementation HSSplashScreenWindowController

+ (id)sharedSplashWindow
{
    static HSSplashScreenWindowController *sharedSplashWindow = nil;
    if (sharedSplashWindow == nil)
        sharedSplashWindow = [[HSSplashScreenWindowController alloc] init];
    return sharedSplashWindow;
}

- (void)addSplashImage
{
    if ([[[[self window] contentView] subviews] count] != 0)
        return;
    NSSize size = [(NSImage *)[self image] size];
    NSImageView *imageView = [[NSImageView allocWithZone:[self zone]] initWithFrame:NSMakeRect(0.0, 0.0, size.width, size.height)];
    [imageView setImage:[self image]];
    [[[self window] contentView] addSubview:imageView];
    [imageView release];
}

- (id)image
{
    if (_image == nil) {
        NSString *name = @"HSSplash.png";
        _image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]]];
    }
    return _image;
}

- (id)window
{
    if (_window == nil) {
        NSSize size = [(NSImage *)[self image] size];
        _window = [[NSPanel allocWithZone:[self zone]] initWithContentRect:NSMakeRect(0.0, 0.0, size.width, size.height) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
        [_window setOpaque:NO];
        [_window setHasShadow:NO];
        [_window setBackgroundColor:[NSColor clearColor]];
        [_window setReleasedWhenClosed:NO];
        [_window setLevel:CGWindowLevelForKey(kCGFloatingWindowLevelKey)];
        [_window setBecomesKeyOnlyIfNeeded:YES];
    }
    return _window;
}

- (BOOL)isSplashVisible
{
    return [_window isVisible];
}

- (void)hideSplashWaitUntilTimeout:(BOOL)aTimeout
{
    if (![self isSplashVisible])
        return;
    if (aTimeout) {
        NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - _slashWindowShowTimeInterval;
        if (elapsed < _slashWindowTimeout)
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:_slashWindowTimeout - elapsed]];
    }
    [[self window] close];
    [_window release];
    _window = nil;
    _slashWindowTimeout = 0.0;
    _slashWindowShowTimeInterval = 0.0;
}

- (void)showSplashWithMinimalTimeout:(double)aTimeout
{
    if ([[self window] isVisible])
        return;
    [self addSplashImage];
    [(NSWindow *)[self window] center];
    [[self window] orderFront:nil];
    _slashWindowTimeout = aTimeout;
    _slashWindowShowTimeInterval = [NSDate timeIntervalSinceReferenceDate];
}

- (void)dealloc
{
    [_window release];
    [_image release];
    [super dealloc];
}

@end
