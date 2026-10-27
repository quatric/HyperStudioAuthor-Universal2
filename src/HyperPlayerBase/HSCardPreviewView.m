#import "HSCardPreviewView.h"
@implementation HSCardPreviewView
// The visible part of the rect, made integral in the view (the rect is
// updated to it), grabbed from the focused view.
- (id)hyperBitmapImageRepresentationForRect:(NSRect *)aRect
{
    NSRect visible = [self userBoundingRectForViewRect:[self visibleRect]];
    NSRect rect = NSIntersectionRect(*aRect, visible);
    rect = NSIntegralRect([self viewBoundingRectForUserRect:rect]);
    *aRect = [self userBoundingRectForViewRect:rect];
    if (NSIsEmptyRect(*aRect))
        return nil;
    return [[[NSBitmapImageRep alloc] initWithFocusedViewRect:*aRect] autorelease];
}
- (void)drawRect:(NSRect)aRect
{
    [self drawBackgroundInRect:aRect];
    [self drawHyperRenderersInRect:aRect];
}
// Big enough for the card and every renderer beyond it on either side.
// (The size asked for isn't used.)
- (void)setFrameSize:(NSSize)aSize
{
    NSRect card = { NSZeroPoint, [self cardSize] };
    NSRect bounds = NSUnionRect([self renderersBoundingRect], card);
    float extraHeight = MAX(bounds.origin.y + bounds.size.height - (card.size.height + card.origin.y), card.origin.y - bounds.origin.y);
    float extraWidth = MAX(bounds.origin.x + bounds.size.width - (card.size.width + card.origin.x), card.origin.x - bounds.origin.x);
    [super setFrameSize:NSMakeSize(MAX(extraWidth, 0.0f) + bounds.size.width, MAX(extraHeight, 0.0f) + bounds.size.height)];
}
- (void)recalculateCentering
{
    NSRect bounds = [self renderersBoundingRect];
    [self setBoundsOrigin:NSMakePoint(MIN(bounds.origin.x, 0.0), MIN(bounds.origin.y, 0.0))];
}
- (void)drawBackgroundInRect:(NSRect)aRect
{
    id renderer = [[self userObject] queryHyperInterface:@protocol(HSBackgroundRenderer)];
    NSRect card = { NSZeroPoint, [self cardSize] };
    [renderer hyperDrawBackgroundInROI:NSIntersectionRect(aRect, card) ofBounds:card];
}
- (NSSize)cardSize
{
    id stack = [[[self userObject] hyperParent] queryHyperInterface:@protocol(HSStackAttributes)];
    return stack != nil ? [stack hyperCardSize] : NSZeroSize;
}
- (id)userObject
{
    return [[[self userObjects] queryHyperInterfaceForAllObjects:@protocol(HSNodeChild)] hyperParent];
}
@end
