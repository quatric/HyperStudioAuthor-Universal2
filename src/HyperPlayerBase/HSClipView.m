#import "HSClipView.h"
// A clip view that can refuse to scroll, and keeps the document view's
// origin in view when it resizes.
@implementation HSClipView
- (void)encodeWithCoder:(id)aCoder
{
    [super encodeWithCoder:aCoder];
    if ([aCoder allowsKeyedCoding])
        [aCoder encodeBool:_isScrollingDisabled forKey:@"HSHyperScrollable"];
}
- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self != nil) {
        if ([aCoder allowsKeyedCoding])
            _isScrollingDisabled = [aCoder decodeBoolForKey:@"HSHyperScrollable"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ownFrameChanged:)
                                                     name:NSViewFrameDidChangeNotification object:self];
    }
    return self;
}
- (void)ownFrameChanged:(id)aChanged
{
    if ([self documentView] != nil)
        [self scrollToPoint:[[self documentView] frame].origin];
}
- (void)setScrollable:(BOOL)aScrollable
{
    if (_isScrollingDisabled != !aScrollable)
        _isScrollingDisabled = !aScrollable;
}
- (BOOL)isScrollable
{
    return !_isScrollingDisabled;
}
- (NSPoint)constrainScrollPoint:(NSPoint)aPoint
{
    if (!_isScrollingDisabled)
        return [super constrainScrollPoint:aPoint];
    return [self bounds].origin;
}
// AppKit asks this one since 10.9 (it no longer calls
// -constrainScrollPoint:): the same rule for the bounds origin.
- (NSRect)constrainBoundsRect:(NSRect)aRect
{
    if (!_isScrollingDisabled)
        return [super constrainBoundsRect:aRect];
    aRect.origin = [self bounds].origin;
    return aRect;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end
