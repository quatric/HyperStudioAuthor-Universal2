#import "HSScroller.h"
@implementation HSScroller
- (void)trackScrollButtons:(id)aButtons
{
    id scrollView = [self enclosingHyperScrollView];
    [scrollView willStartTrackingScroller:self];
    [super trackScrollButtons:aButtons];
    [scrollView didFinishTrackingScroller:self];
}
- (void)trackKnob:(id)aKnob
{
    id scrollView = [self enclosingHyperScrollView];
    [scrollView willStartTrackingScroller:self];
    [super trackKnob:aKnob];
    [scrollView didFinishTrackingScroller:self];
}
- (id)enclosingHyperScrollView
{
    // the target, the superview or the enclosing scroll view, if it's an
    // HSScrollView
    id target = [self target];
    if ([target isKindOfClass:[HSScrollView class]])
        return target;
    if ([[self superview] isKindOfClass:[HSScrollView class]])
        return [self superview];
    id scrollView = [self enclosingScrollView];
    return [scrollView isKindOfClass:[HSScrollView class]] ? scrollView : nil;
}
@end
