#import "HSCoachingTextContainer.h"

@implementation HSCoachingTextContainer

// Lines that run into the obstacle stop at its left edge.
- (NSRect)lineFragmentRectForProposedRect:(NSRect)aRect sweepDirection:(NSUInteger)aDirection movementDirection:(NSUInteger)aDirection2 remainingRect:(NSRect *)aRect2
{
    NSRect rect = [super lineFragmentRectForProposedRect:aRect sweepDirection:aDirection movementDirection:aDirection2 remainingRect:aRect2];
    if (!NSEqualRects(_obstacleRect, NSZeroRect) && NSIntersectsRect(aRect, _obstacleRect))
        rect.size.width = NSIntersectionRect(aRect, _obstacleRect).origin.x - aRect.origin.x;
    return rect;
}

- (void)setObstacleRect:(NSRect)aRect
{
    if (!NSEqualRects(_obstacleRect, aRect))
        _obstacleRect = aRect;
}

- (NSRect)obstacleRect
{
    return _obstacleRect;
}

@end
