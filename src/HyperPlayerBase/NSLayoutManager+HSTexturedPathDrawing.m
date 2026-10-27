#import "NSLayoutManager+HSTexturedPathDrawing.h"
@implementation NSLayoutManager (HSTexturedPathDrawing)
- (id)hyperRenderingPathWithGlyphRange:(NSRange)aRange textContainerOrigin:(NSPoint)aOrigin
{
    // glyph outlines are drawn upside down: each is placed at the negated
    // y of its line and flipped back
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:aOrigin];
    for (NSUInteger glyph = aRange.location; glyph < NSMaxRange(aRange); glyph++) {
        NSRect fragment = [self lineFragmentRectForGlyphAtIndex:glyph effectiveRange:NULL];
        NSPoint location = [self locationForGlyphAtIndex:glyph];
        NSBezierPath *glyphPath = [self hyperPathForGlyphRange:NSMakeRange(glyph, 1)
            atPoint:NSMakePoint(location.x + fragment.origin.x, -(location.y + fragment.origin.y))];
        NSAffineTransform *flip = [NSAffineTransform transform];
        [flip scaleXBy:1.0 yBy:-1.0];
        [glyphPath transformUsingAffineTransform:flip];
        [path appendBezierPath:glyphPath];
    }
    return path;
}
- (id)hyperPathForGlyphRange:(NSRange)aRange atPoint:(NSPoint)aPoint
{
    if (aRange.length == 0)
        return nil;
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:aPoint];
    NSGlyph *glyphs = [[NSMutableData dataWithLength:aRange.length * sizeof(NSGlyph)] mutableBytes];
    NSUInteger count = [self getGlyphs:glyphs range:aRange];
    NSFont *font = [[self textStorage] attribute:NSFontAttributeName atIndex:aRange.location effectiveRange:NULL];
    [path appendBezierPathWithGlyphs:glyphs count:count inFont:font];
    return path;
}
@end
