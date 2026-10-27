#import "HSDoubleActionButtonCell.h"

@implementation HSDoubleActionButtonCell

- (void)drawDoubleClickedInRect:(NSRect)aRect
{
    [[NSColor colorWithCalibratedWhite:0.0f alpha:0.5f] set];
    NSRectFillUsingOperation(aRect, NSCompositeSourceOver);
}

- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    [super drawInteriorWithFrame:aFrame inView:aView];
    if ([self state] == NSOnState && _isDoubleClicked)
        [self drawDoubleClickedInRect:aFrame];
}

- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp
{
    BOOL sendDoubleAction = NO;

    if ([(NSEvent *)aMouse type] == NSEventTypeLeftMouseDown) {
        if ([aMouse clickCount] == 2) {
            sendDoubleAction = _doubleAction != NULL;
            [self setDoubleClicked:YES];
        } else {
            [self setDoubleClicked:NO];
        }
    }

    BOOL result = [super trackMouse:aMouse inRect:aRect ofView:aView untilMouseUp:aUp];
    if (sendDoubleAction)
        [NSApp sendAction:_doubleAction to:[self target] from:aView];
    return result;
}

- (void)setDoubleClicked:(BOOL)aClicked
{
    if (_isDoubleClicked != aClicked) {
        _isDoubleClicked = aClicked;
        [[self controlView] setNeedsDisplay:YES];
    }
}

- (BOOL)isDoubleClicked
{
    return _isDoubleClicked;
}

- (SEL)doubleAction
{
    return _doubleAction;
}

- (void)setDoubleAction:(SEL)aAction
{
    _doubleAction = aAction;
}

@end
