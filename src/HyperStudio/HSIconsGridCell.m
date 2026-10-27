#import "HSIconsGridCell.h"

@implementation HSIconsGridCell

// The image scaled down to fit (never up) and centered in the inset bounds.
- (NSRect)imageRectForBounds:(NSRect)aBounds
{
    NSSize inset = [self inset];
    NSRect bounds = NSInsetRect(aBounds, inset.width, inset.height);
    NSSize size = [[self image] size];
    if (bounds.size.width < size.width || bounds.size.height < size.height) {
        float aspect = size.width / size.height;
        if (aspect <= bounds.size.width / bounds.size.height) {
            size.width = aspect * bounds.size.height;
            size.height = bounds.size.height;
        } else {
            size.height = bounds.size.width / aspect;
            size.width = bounds.size.width;
        }
    }
    NSRect rect = NSMakeRect(bounds.size.width * 0.5f - size.width * 0.5f, bounds.size.height * 0.5f - size.height * 0.5f, size.width, size.height);
    return NSIntegralRect(NSOffsetRect(rect, bounds.origin.x, bounds.origin.y));
}

- (NSSize)inset
{
    return NSMakeSize(3, 3);
}

// The icon is fetched from the grid's data source the first time it is drawn.
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    if ([self image] == nil && !_initOnce) {
        NSUInteger index = [[aView cells] indexOfObject:self];
        if (index < (NSUInteger)[[aView dataSource] iconsCountInIconsGrid:aView])
            [self setImage:[[aView dataSource] iconAtIndex:index inIconsGrid:aView]];
        _initOnce = YES;
    }
    if ([self image] == nil)
        return;
    if ([self state] == NSControlStateValueOn) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(aFrame, 1, 1)];
        [path setLineWidth:2];
        [[NSColor alternateSelectedControlColor] set];
        [path stroke];
    }
    NSSize size = [[self image] size];
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    [context saveGraphicsState];
    [context setImageInterpolation:NSImageInterpolationHigh];
    NSRect fromRect = {NSZeroPoint, size};
    [self drawImage:[self image] inRect:[self imageRectForBounds:aFrame] fromRect:fromRect operation:NSCompositingOperationSourceOver fraction:1.0 flip:YES];
    [context restoreGraphicsState];
}

- (void)drawImage:(id)aImage inRect:(NSRect)aRect fromRect:(NSRect)aRect2 operation:(NSUInteger)aOperation fraction:(CGFloat)aFraction flip:(BOOL)aFlip
{
    if (!aFlip) {
        [aImage drawInRect:aRect fromRect:aRect2 operation:aOperation fraction:aFraction];
        return;
    }
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform scaleXBy:1.0 yBy:-1.0];
    [transform concat];
    [aImage drawInRect:NSMakeRect(aRect.origin.x, -aRect.origin.y - aRect.size.height, aRect.size.width, aRect.size.height) fromRect:aRect2 operation:aOperation fraction:aFraction];
    [transform concat];
}

@end
