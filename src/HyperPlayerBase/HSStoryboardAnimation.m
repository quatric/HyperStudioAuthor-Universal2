#import "HSStoryboardAnimation.h"
@implementation HSStoryboardAnimation
- (id)runLoopModesForAnimating
{
    return [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, nil];
}
- (void)setCurrentProgress:(CGFloat)aProgress
{
    [super setCurrentProgress:aProgress];
    int count = (int)[_items numberOfItems];
    for (int i = 0; i < count; i++)
        [[_items objectInStoryboardItemsAtIndex:i] animateWithProgress:aProgress];
}
- (void)setItems:(id)aItems
{
    [_items release];
    _items = [aItems retain];
}
- (void)dealloc
{
    [_items release];
    [super dealloc];
}
- (id)initWithItems:(id)aItems duration:(double)aDuration
{
    self = [super initWithDuration:aDuration animationCurve:NSAnimationEaseInOut];
    if (self != nil)
        [self setItems:aItems];
    return self;
}
@end
