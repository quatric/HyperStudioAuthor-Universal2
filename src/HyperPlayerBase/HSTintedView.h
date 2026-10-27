#import "HyperPlayerBasePrefix.h"


@interface HSTintedView : NSView <NSCoding>
{
    NSColor *_borderColor;
    NSColor *_tintColor;
    NSImage *_backgroundImage;
    float _borderThickness;
    float _cornerRadius;
    struct HSInset _shapeInset;
    NSColor *_patternColor;
    NSImage *_offscreenCache;
    NSSize _boundsSizeForBackgroundCache;
    NSBezierPath *_shapeBezier;
    struct HyperPlayerBase_anon16 _smkFlags;
}
+ (id)boxStyleDefaultColor;
- (id)menuForEvent:(id)aEvent;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (void)setOpaque:(BOOL)aOpaque;
- (BOOL)isOpaque;
- (void)setCornerRadius:(CGFloat)aRadius;
- (CGFloat)cornerRadius;
- (void)setBorderThickness:(CGFloat)aThickness;
- (CGFloat)borderThickness;
- (void)setBorderStyle:(NSInteger)aStyle;
- (void)_setBorderStyle:(NSInteger)aStyle force:(BOOL)aForce;
- (NSInteger)borderStyle;
- (void)drawRect:(NSRect)aRect;
- (void)renderBorderWithBounds:(NSRect)aBounds invalidRect:(NSRect)aRect;
- (void)renderFillWithBounds:(NSRect)aBounds invalidRect:(NSRect)aRect;
- (void)_drawBoxBorderWithBounds:(NSRect)aBounds operation:(NSUInteger)aOperation;
- (void)_drawBorderWithBounds:(NSRect)aBounds images:(id *)aImages operation:(NSUInteger)aOperation;
- (void)_alignRects:(NSRect *)aRects forBounds:(NSRect)aBounds flippedView:(BOOL)aView;
- (id)newImageWithName:(id)aName;
- (void)_drawBackgroundImageInRect:(NSRect)aRect;
- (void)_drawBackgroundImageAsPatternInRect:(NSRect)aRect;
- (void)_invalidateShapeBezier;
- (BOOL)getBoxBorderInnerPathRect:(NSRect *)aRect;
- (id)shapeBezierWithBounds:(NSRect)aBounds;
- (id)_shapeBezierWithBounds:(NSRect)aBounds;
- (id)_patternColor;
- (void)setBackgroundImage:(id)aImage;
- (id)backgroundImage;
- (void)setTintColor:(id)aColor;
- (id)tintColor;
- (void)setBorderColor:(id)aColor;
- (id)borderColor;
- (void)setCacheBackground:(BOOL)aBackground;
- (BOOL)cacheBackground;
- (void)setDrawsFill:(BOOL)aFill;
- (BOOL)drawsFill;
- (void)setDrawsBorder:(BOOL)aBorder;
- (BOOL)drawsBorder;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

