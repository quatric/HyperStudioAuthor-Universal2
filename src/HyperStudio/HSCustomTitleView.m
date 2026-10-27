#import "HSCustomTitleView.h"

@implementation HSCustomTitleView

- (void)setTitleFrontColor:(id)aColor
{
    if (_frontColor != aColor) {
        [_frontColor release];
        _frontColor = [aColor retain];
        [self setNeedsDisplay:YES];
    }
}

- (id)titleFrontColor
{
    return _frontColor ? _frontColor : [NSColor whiteColor];
}

- (void)setTitleShadowColor:(id)aColor
{
    if (_shadowColor != aColor) {
        [_shadowColor release];
        _shadowColor = [aColor retain];
        [self setNeedsDisplay:YES];
    }
}

- (id)titleShadowColor
{
    return _shadowColor ? _shadowColor : [NSColor blackColor];
}

- (void)setTitleShadowOffset:(NSSize)aOffset
{
    if (!NSEqualSizes(aOffset, _shadowOffset)) {
        _shadowOffset = aOffset;
        [self setNeedsDisplay:YES];
    }
}

- (NSSize)titleShadowOffset
{
    return _shadowOffset;
}

- (void)setDrawsTitle:(BOOL)aTitle
{
    if (_drawsTitle != aTitle) {
        _drawsTitle = aTitle;
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)drawsTitle
{
    return _drawsTitle;
}

- (id)ownerWindow
{
    return _ownerWindow;
}

// Double-clicking the title bar miniaturizes the window.
- (void)mouseDown:(id)aDown
{
    NSWindow *window = [self window];
    if ([aDown clickCount] > 1 && [(NSEvent *)aDown type] == NSLeftMouseUp) {
        if ([window styleMask] & NSMiniaturizableWindowMask)
            [window miniaturize:self];
    }
}

// The title is centred in the view; the shadow is drawn first, offset.
- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
    if (_drawsTitle) {
        NSTextFieldCell *cell = [self _titleCell];
        [cell setStringValue:[[self window] title]];
        NSRect bounds = [self bounds];
        NSSize cellSize = [_titleCell cellSize];
        NSRect frame = NSMakeRect(bounds.origin.x + floorf((bounds.size.width - cellSize.width) * 0.5f),
                                  bounds.origin.y + ceilf((bounds.size.height - cellSize.height) * 0.5f),
                                  cellSize.width, cellSize.height);
        if (!NSEqualSizes(_shadowOffset, NSZeroSize)) {
            NSRect shadowFrame = NSOffsetRect(frame, _shadowOffset.width, _shadowOffset.height);
            [_titleCell setTextColor:[self titleShadowColor]];
            [_titleCell drawInteriorWithFrame:shadowFrame inView:self];
        }
        [_titleCell setTextColor:[self titleFrontColor]];
        [_titleCell drawInteriorWithFrame:frame inView:self];
    }
}

- (id)_titleCell
{
    if (!_titleCell) {
        _titleCell = [NSTextFieldCell new];
        [_titleCell setAlignment:NSCenterTextAlignment];
        [_titleCell setFont:[self _titleFont]];
    }
    return _titleCell;
}

- (id)_titleFont
{
    return [NSFont systemFontOfSize:[self _titleFontSize]];
}

- (CGFloat)_titleFontSize
{
    NSWindow *window = [self window];
    NSUInteger styleMask = [window styleMask];
    BOOL small = [window isKindOfClass:[NSPanel class]] && (styleMask & NSUtilityWindowMask);
    return small ? [NSFont smallSystemFontSize] : [NSFont systemFontSize];
}

- (void)dealloc
{
    [_titleCell release];
    [_frontColor release];
    [_shadowColor release];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)aFrame ownerWindow:(id)aWindow
{
    self = [super initWithFrame:aFrame];
    if (self)
        _ownerWindow = aWindow;
    return self;
}
@end

@implementation NSWindow (HSCustomTitleExtension)

// Finds the title view in the window frame's subviews, adding one above the
// content view (using the delegate's class when it supplies one).
- (id)hyperCustomTitleView
{
    NSView *contentView = [self contentView];
    NSView *frameView = [contentView superview];
    NSEnumerator *enumerator = [[frameView subviews] objectEnumerator];
    id view;
    while ((view = [enumerator nextObject])) {
        if ([view isKindOfClass:[HSCustomTitleView class]])
            return view;
    }
    NSRect frameBounds = [frameView bounds];
    NSRect contentFrame = [contentView frame];
    id delegate = [self delegate];
    Class viewClass;
    if (![delegate respondsToSelector:@selector(hyperCustomTitleViewClass)] || !(viewClass = [delegate hyperCustomTitleViewClass]))
        viewClass = [HSCustomTitleView class];
    NSRect titleFrame = NSMakeRect(contentFrame.origin.x, contentFrame.origin.y + contentFrame.size.height, contentFrame.size.width,
                                   (frameBounds.origin.y + frameBounds.size.height) - (contentFrame.origin.y + contentFrame.size.height));
    view = [[[viewClass alloc] initWithFrame:titleFrame ownerWindow:self] autorelease];
    [(NSView *)view setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [frameView addSubview:view positioned:NSWindowBelow relativeTo:[[frameView subviews] objectAtIndex:0]];
    return view;
}

@end
