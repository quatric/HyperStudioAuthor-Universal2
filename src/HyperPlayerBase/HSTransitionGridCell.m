#import "HSTransitionGridCell.h"
// A cell of the transition chooser grid: a white card with a shadow, the
// transition's preview image and its name below; red frame when selected.
@implementation HSTransitionGridCell
- (NSRect)titleRectForBounds:(NSRect)aBounds
{
    CGFloat width = aBounds.size.width - 12;
    [[self stringRenderer] setContainerWidth:width];
    NSRect textBounds = [[self stringRenderer] boundingRectOfString:[self title]];
    return NSMakeRect(aBounds.size.width * 0.5f + aBounds.origin.x + width * -0.5f,
                      aBounds.origin.y + aBounds.size.height - textBounds.size.height - 6,
                      width, textBounds.size.height);
}
// Full width less margins, at the image's aspect ratio, near the bottom (the
// view is flipped).
- (NSRect)imageRectForBounds:(NSRect)aBounds
{
    NSSize imageSize = [(NSImage *)[self image] size];
    CGFloat width = aBounds.size.width - 24;
    CGFloat height = width / (imageSize.width / imageSize.height);
    return NSMakeRect(aBounds.size.width * 0.5f + aBounds.origin.x + width * -0.5f,
                      aBounds.origin.y + aBounds.size.height - height - 24,
                      width, height);
}
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    if ([self isEmpty])
        return;
    NSRect card = NSInsetRect(aFrame, 6, 4);
    [[NSGraphicsContext currentContext] saveGraphicsState];
    [(NSShadow *)[self shadow] set];
    [[NSColor whiteColor] set];
    [[NSBezierPath bezierPathWithRect:card] fill];
    [[NSGraphicsContext currentContext] restoreGraphicsState];
    if ([self state] == NSControlStateValueOn) {
        NSBezierPath *frame = [NSBezierPath bezierPathWithRect:NSInsetRect(card, 1, 1)];
        [frame setLineWidth:2];
        [[NSColor redColor] set];
        [frame stroke];
    }
    if ([self image] != nil) {
        NSSize imageSize = [(NSImage *)[self image] size];
        [self drawImage:[self image] inRect:[self imageRectForBounds:aFrame]
               fromRect:(NSRect){NSZeroPoint, imageSize}
              operation:NSCompositingOperationSourceOver fraction:1 flip:YES];
    }
    if ([self title] != nil) {
        [[self stringRenderer] setContainerWidth:[self titleRectForBounds:aFrame].size.width];
        [[self stringRenderer] drawString:[self title] atPoint:[self titleRectForBounds:aFrame].origin withColor:[NSColor blackColor]];
    }
}
- (id)stringRenderer
{
    if (_stringRenderer == nil) {
        _stringRenderer = [HSStringRenderer new];
        [_stringRenderer setAlignment:NSTextAlignmentCenter];
        [_stringRenderer setFont:[NSFont systemFontOfSize:[NSFont labelFontSize]]];
    }
    return _stringRenderer;
}
// Flipped: drawn upside down into the mirrored rect, then the flip undone.
- (void)drawImage:(id)aImage inRect:(NSRect)aRect fromRect:(NSRect)aRect2 operation:(NSUInteger)aOperation fraction:(CGFloat)aFraction flip:(BOOL)aFlip
{
    if (!aFlip) {
        [aImage drawInRect:aRect fromRect:aRect2 operation:aOperation fraction:aFraction];
        return;
    }
    NSAffineTransform *flip = [NSAffineTransform transform];
    [flip scaleXBy:1 yBy:-1];
    [flip concat];
    NSRect flipped = NSMakeRect(aRect.origin.x, -aRect.origin.y - aRect.size.height, aRect.size.width, aRect.size.height);
    [aImage drawInRect:flipped fromRect:aRect2 operation:aOperation fraction:aFraction];
    [flip concat];
}
- (id)shadow
{
    if (_shadow == nil) {
        _shadow = [NSShadow new];
        [_shadow setShadowColor:[NSColor colorWithCalibratedWhite:0 alpha:0.75]];
        [_shadow setShadowBlurRadius:5];
        [_shadow setShadowOffset:NSMakeSize(1, -1)];
    }
    return _shadow;
}
- (BOOL)isEmpty
{
    if ([self image] != nil)
        return NO;
    return [self title] == nil || [[self title] length] == 0;
}
- (void)dealloc
{
    [_shadow release];
    [_stringRenderer release];
    [super dealloc];
}
@end
@implementation HSTransitionGridCell (NSAccessibility)
- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute])
        return NSAccessibilityUnknownRole;
    if ([aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute])
        return @"";
    if ([aValue isEqualToString:NSAccessibilityDescriptionAttribute])
        return [self title];
    return [super accessibilityAttributeValue:aValue];
}
- (id)accessibilityAttributeNames
{
    return [[super accessibilityAttributeNames] arrayByAddingObject:NSAccessibilityDescriptionAttribute];
}
@end
