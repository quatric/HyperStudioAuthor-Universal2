#import "HSHeadlineLayoutManager.h"
// Lays out a headline: the glyphs are drawn as one path, outlined and/or
// filled with a background graphic (stretched over the whole path's bounds).
@implementation HSHeadlineLayoutManager
- (id)background
{
    return _background;
}
- (void)setBackground:(id)aBackground
{
    if (_background != aBackground) {
        [_background release];
        _background = [aBackground retain];
    }
}
- (id)outlineColor
{
    return _outlineColor;
}
- (void)setOutlineColor:(id)aColor
{
    if (_outlineColor != aColor) {
        [_outlineColor release];
        _outlineColor = [aColor retain];
    }
}
- (CGFloat)outlineWidth
{
    return _outlineWidth;
}
- (void)setOutlineWidth:(CGFloat)aWidth
{
    _outlineWidth = aWidth;
}
- (BOOL)isOutlineEnabled
{
    return _isOutlineEnabled;
}
- (void)setOutlineEnabled:(BOOL)aEnabled
{
    _isOutlineEnabled = aEnabled;
}
- (void)drawGlyphsForGlyphRange:(NSRange)aRange atPoint:(NSPoint)aPoint
{
    NSBezierPath *path = [self hyperRenderingPathWithGlyphRange:aRange textContainerOrigin:aPoint];
    _fullPathBounds = [path bounds];
    [self drawPath:path];
}
- (void)drawPath:(id)aPath
{
    if (_isOutlineEnabled) {
        [(NSColor *)_outlineColor set];
        [aPath setLineWidth:_outlineWidth];
        [aPath stroke];
    }
    if (_background != nil) {
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [aPath addClip];
        [_background hyperDrawInRect:_fullPathBounds ofBounds:_fullPathBounds];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
}
- (void)dealloc
{
    [_background release];
    [_outlineColor release];
    [super dealloc];
}
@end
