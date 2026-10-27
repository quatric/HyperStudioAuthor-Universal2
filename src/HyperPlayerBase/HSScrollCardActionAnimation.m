#import "HSScrollCardActionAnimation.h"
@implementation HSScrollCardActionAnimation
- (void)setCurrentProgress:(CGFloat)aProgress
{
    [super setCurrentProgress:aProgress];
    float y = roundf(_newOrigin.y - _dy * (1.0f - (float)aProgress));
    float x = roundf(_newOrigin.x - _dx * (1.0f - (float)aProgress));
    NSView *view = [_documentView enclosingScrollView];
    if (view == nil) {
        // no scroll view: the document view itself moves
        [_documentView setFrameOrigin:NSMakePoint(-x, -y)];
        view = _documentView;
    } else {
        NSClipView *clipView = [(NSScrollView *)view contentView];
        if (clipView == nil)
            return;
        [clipView scrollToPoint:NSMakePoint(x, y)];
        [(NSScrollView *)view reflectScrolledClipView:clipView];
    }
    [view displayIfNeeded];
}
- (void)dealloc
{
    [_documentView release];
    [super dealloc];
}
- (id)initWithView:(id)aView scrollPoint:(NSPoint)aPoint
{
    // scrolls so that aPoint (in the view) comes to the middle of what's
    // visible, without scrolling past the view's edges
    self = [self initWithDuration:HSObjectAssistantAnimationDuration() animationCurve:NSAnimationEaseInOut];
    if (self == nil)
        return nil;
    _documentView = [aView retain];
    NSScrollView *scrollView = [_documentView enclosingScrollView];
    NSRect frame = [_documentView frame];
    NSPoint point, origin;
    NSSize visible;
    if (scrollView == nil) {
        NSView *superview = [_documentView superview];
        if (superview == nil) {
            [self release];
            return nil;
        }
        point = [_documentView convertPoint:aPoint toView:superview];
        NSRect bounds = [superview bounds];
        visible = bounds.size;
        origin = NSMakePoint(bounds.origin.x - frame.origin.x, bounds.origin.y - frame.origin.y);
        point.x -= frame.origin.x;
        point.y -= frame.origin.y;
    } else {
        NSClipView *clipView = [scrollView contentView];
        if (clipView == nil) {
            [self release];
            return nil;
        }
        point = [_documentView convertPoint:aPoint toView:clipView];
        NSRect bounds = [clipView bounds];
        origin = bounds.origin;
        visible = bounds.size;
    }
    float x = (float)point.x - floorf((float)visible.width * 0.5f);
    if (x < 0)
        x = 0;
    else
        x = fminf(x, fmaxf((float)(frame.size.width - visible.width), 0));
    float y = (float)point.y - floorf((float)visible.height * 0.5f);
    if (y < 0)
        y = 0;
    else
        y = fminf(y, fmaxf((float)(frame.size.height - visible.height), 0));
    _newOrigin = NSMakePoint(x, y);
    _dx = x - (float)origin.x;
    _dy = y - (float)origin.y;
    return self;
}
@end
