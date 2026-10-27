#import "HSProgressPlaceholderView.h"

@implementation HSProgressPlaceholderView

- (void)drawRect:(NSRect)aRect
{
    [[NSColor whiteColor] setFill];
    [NSBezierPath fillRect:aRect];
    NSRect bounds = [self bounds];
    [[NSColor grayColor] set];
    [NSBezierPath strokeRect:bounds];
    if ([_title length] == 0)
        return;
    NSTextFieldCell *cell = [[NSTextFieldCell alloc] initTextCell:@""];
    [cell setAttributedStringValue:_title];
    NSSize size = [cell cellSizeForBounds:bounds];
    [cell drawInteriorWithFrame:NSMakeRect((bounds.size.width - size.width) * 0.5 + bounds.origin.x, bounds.size.height * 0.5 + bounds.origin.y, size.width, size.height) inView:self];
    [cell release];
}

- (void)setIsSpinning:(BOOL)aSpinning
{
    if (_isSpinning == aSpinning)
        return;
    _isSpinning = aSpinning;
    if (aSpinning)
        [_progressIndicator startAnimation:self];
    else
        [_progressIndicator stopAnimation:self];
}

- (BOOL)isSpinning
{
    return _isSpinning;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_progressIndicator stopAnimation:self];
    [_progressIndicator release];
    [_title release];
    [super dealloc];
}

- (void)setTitle:(id)aTitle
{
    [_title autorelease];
    _title = [aTitle copy];
}

- (id)title
{
    return [[_title copy] autorelease];
}

- (void)frameDidChanged:(id)aChanged
{
    [_progressIndicator setFrame:[self progressIndicatorFrameForBounds:[self bounds]]];
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        _progressIndicator = [[NSProgressIndicator alloc] initWithFrame:[self progressIndicatorFrameForBounds:NSMakeRect(0.0, 0.0, aFrame.size.width, aFrame.size.height)]];
        [_progressIndicator setIndeterminate:YES];
        [_progressIndicator setStyle:NSProgressIndicatorStyleSpinning];
        [self addSubview:_progressIndicator];
        [self setPostsFrameChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(frameDidChanged:) name:NSViewFrameDidChangeNotification object:self];
    }
    return self;
}

- (NSRect)progressIndicatorFrameForBounds:(NSRect)aBounds
{
    return NSMakeRect(aBounds.size.width * 0.5 + aBounds.origin.x - 16.0, aBounds.size.height * 0.5 + aBounds.origin.y - 36.0, 32.0, 32.0);
}

@end
