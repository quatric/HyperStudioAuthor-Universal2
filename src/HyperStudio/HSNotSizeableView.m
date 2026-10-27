#import "HSNotSizeableView.h"

@implementation HSNotSizeableView

- (void)removeFromSuperview
{
    NSWindow *window = [self window];
    if (NSEqualSizes(_lastMaxSize, [window maxSize]))
        [[self window] setMaxSize:_windowMaxSize];
    // Original quirk kept: the window's minimum is compared with the saved window minimum, not the last one set.
    if (NSEqualSizes(_windowMinSize, [window minSize]))
        [[self window] setMinSize:_windowMinSize];
    _maxSizeInited = NO;
    _minSizeInited = NO;
    [super removeFromSuperview];
}

- (void)viewDidMoveToWindow
{
    [self performSelector:@selector(viewDidFinishResizingInWindow) withObject:self afterDelay:0.0];
}

- (void)viewDidFinishResizingInWindow
{
    NSWindow *window = [self window];
    NSSize maxSize = [self maxSize];
    NSSize minSize = [self minSize];
    if (window == nil || (NSEqualSizes(maxSize, NSZeroSize) && NSEqualSizes(minSize, NSZeroSize)))
        return;
    if (!_maxSizeInited) {
        _windowMaxSize = [window maxSize];
        _maxSizeInited = YES;
    }
    if (!_minSizeInited) {
        _windowMinSize = [window minSize];
        _minSizeInited = YES;
    }
    NSRect viewFrame = [self frame];
    NSRect windowFrame = [window frame];
    NSRect newFrame = windowFrame;
    float maxWidth = (maxSize.width - viewFrame.size.width) + windowFrame.size.width;
    float minWidth = (minSize.width - viewFrame.size.width) + windowFrame.size.width;
    float minHeight = (minSize.height - viewFrame.size.height) + windowFrame.size.height;
    float maxHeight = (maxSize.height - viewFrame.size.height) + windowFrame.size.height;
    if (maxWidth < windowFrame.size.width && maxSize.width != 0.0)
        newFrame.size.width = maxWidth;
    else if (windowFrame.size.width < minWidth && minSize.width != 0.0)
        newFrame.size.width = minWidth;
    if (maxHeight < windowFrame.size.height && maxSize.height != 0.0) {
        newFrame.origin.y = windowFrame.origin.y + (windowFrame.size.height - maxHeight);
        newFrame.size.height = maxHeight;
    } else if (windowFrame.size.height < minHeight && minSize.height != 0.0) {
        newFrame.origin.y = windowFrame.origin.y - (minHeight - windowFrame.size.height);
        newFrame.size.height = minHeight;
    }
    if (!NSEqualRects(windowFrame, newFrame))
        [window setFrame:newFrame display:YES animate:YES];
    if (maxSize.width == 0.0)
        maxWidth = _windowMaxSize.width;
    if (maxSize.height == 0.0)
        maxHeight = _windowMaxSize.height;
    if (minSize.width == 0.0)
        minWidth = _windowMinSize.width;
    if (minSize.height == 0.0)
        minHeight = _windowMinSize.height;
    _lastMinSize = NSMakeSize(minWidth, minHeight);
    _lastMaxSize = NSMakeSize(maxWidth, maxHeight);
    [window setMaxSize:_lastMaxSize];
    [window setMinSize:_lastMinSize];
}

- (NSSize)minSize
{
    return _minSize;
}

- (NSSize)maxSize
{
    return _maxSize;
}

- (void)setMaxSize:(NSSize)aSize minSize:(NSSize)aSize2
{
    [self setMaxSize:aSize];
    [self setMinSize:aSize2];
}

- (void)setMinSize:(NSSize)aSize
{
    _minSize = aSize;
}

- (void)setMaxSize:(NSSize)aSize
{
    _maxSize = aSize;
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        _minSize = NSZeroSize;
        _maxSize = NSZeroSize;
    }
    return self;
}

@end
