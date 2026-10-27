#import "HyperPlayerBasePrefix.h"


@interface HSHeadlineLayoutManager : NSLayoutManager
{
    id<HSGraphics> _background;
    BOOL _isOutlineEnabled;
    float _outlineWidth;
    NSColor *_outlineColor;
    NSRect _fullPathBounds;
}
- (id)background;
- (void)setBackground:(id)aBackground;
- (id)outlineColor;
- (void)setOutlineColor:(id)aColor;
- (CGFloat)outlineWidth;
- (void)setOutlineWidth:(CGFloat)aWidth;
- (BOOL)isOutlineEnabled;
- (void)setOutlineEnabled:(BOOL)aEnabled;
- (void)drawGlyphsForGlyphRange:(NSRange)aRange atPoint:(NSPoint)aPoint;
- (void)drawPath:(id)aPath;
- (void)dealloc;
@end

