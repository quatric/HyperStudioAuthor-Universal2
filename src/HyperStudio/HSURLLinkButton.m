#import "HSURLLinkButton.h"

@implementation HSURLLinkButton

- (void)dealloc
{
    [_URL release];
    [super dealloc];
}

- (void)drawRect:(NSRect)aRect
{
    if ([[self title] length] == 0)
        return;
    NSMutableAttributedString *title = [[[NSMutableAttributedString alloc] initWithAttributedString:[self attributedTitle]] autorelease];
    if (_URL != nil) {
        [title addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(0, [title length])];
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:NSMakeRange(0, [title length])];
    }
    [[self cell] drawTitle:title withFrame:[self bounds] inView:self];
}

- (BOOL)sendAction:(SEL)aAction to:(id)aTo
{
    if (_URL != nil)
        [[NSWorkspace sharedWorkspace] openURL:_URL];
    return YES;
}

- (id)URL
{
    return _URL;
}

- (void)setURL:(id)aURL
{
    [_URL autorelease];
    [[self window] invalidateCursorRectsForView:self];
    if (_URL != nil)
        [self removeToolTip:_toolTipTag];
    _URL = [aURL copy];
    if (_URL != nil)
        _toolTipTag = (int)[self addToolTipRect:[self bounds] owner:_URL userData:NULL];
}

- (void)resetCursorRects
{
    if (_toolTipTag != 0)
        [self removeToolTip:_toolTipTag];
    if (_URL != nil && [self isEnabled]) {
        [self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
        _toolTipTag = (int)[self addToolTipRect:[self bounds] owner:_URL userData:NULL];
    }
}

- (void)setEnabled:(BOOL)aEnabled
{
    [[self window] invalidateCursorRectsForView:self];
    [super setEnabled:aEnabled];
}

- (void)awakeFromNib
{
    [self setTitle:[self title]];
}

@end
