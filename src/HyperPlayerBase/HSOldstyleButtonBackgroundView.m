#import "HSOldstyleButtonBackgroundView.h"
@implementation HSOldstyleButtonBackgroundView
- (void)drawRect:(NSRect)aRect
{
    if (!_rendersAsDefaultButton) {
        [super drawRect:aRect];
        return;
    }
    if ([self borderStyle] == 0) {
        // the default button's outline: two offset strokes around the button
        NSRect bounds = [self bounds];
        bounds.size.width -= 2;
        bounds.size.height -= 2;
        bounds.origin.y += 2;
        NSRect outline = NSMakeRect(bounds.origin.x, bounds.origin.y - 1, bounds.size.width + 1, bounds.size.height + 2);
        [self renderBorderWithBounds:outline invalidRect:aRect];
        outline.origin.x += 1;
        outline.origin.y -= 1;
        [self renderBorderWithBounds:outline invalidRect:aRect];
        [self renderFillWithBounds:bounds invalidRect:aRect];
        [self renderBorderWithBounds:bounds invalidRect:aRect];
        return;
    }
    // a thick ring around the button, then its own border inside it
    CGFloat thickness = [self borderThickness];
    [self setBorderThickness:3];
    NSRect ring = NSInsetRect([self bounds], -0.5, -0.5);
    [self renderFillWithBounds:ring invalidRect:aRect];
    [self renderBorderWithBounds:ring invalidRect:aRect];
    [self setBorderThickness:1];
    [self renderBorderWithBounds:NSInsetRect([self bounds], 4.5, 4.5) invalidRect:aRect];
    [self setBorderThickness:thickness];
}
- (void)setRendersAsDefaultButton:(BOOL)aButton
{
    _rendersAsDefaultButton = aButton;
}
- (BOOL)rendersAsDefaultButton
{
    return _rendersAsDefaultButton;
}
@end
