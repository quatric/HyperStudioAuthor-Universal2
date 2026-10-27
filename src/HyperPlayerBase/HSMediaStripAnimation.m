#import "HSMediaStripAnimation.h"
@implementation HSMediaStripAnimation
- (id)runLoopModesForAnimating
{
    return [NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, nil];
}
- (void)setCurrentProgress:(CGFloat)aProgress
{
    [super setCurrentProgress:aProgress];
    NSEnumerator *enumerator = [_dataSource itemsEnumeratorForAnimation:self];
    id item;
    while ((item = [enumerator nextObject]) != nil)
        [item animateWithProgress:aProgress];
}
- (id)initWithDataSource:(id)aSource duration:(double)aDuration
{
    self = [super initWithDuration:aDuration animationCurve:NSAnimationEaseInOut];
    if (self != nil)
        _dataSource = aSource;     // not retained
    return self;
}
@end
