#import "HyperPlayerBasePrefix.h"


@interface HSTextUnderlineRenderingInfo : NSObject
{
    NSColor *_outlineColor;
    NSColor *_underlineColor;
    NSColor *_underlinePDFColor;
    float _fontPointSize;
    float _outlineWidth;
    NSRange _characterRange;
    BOOL _shouldDrawOutline;
    BOOL _shouldDrawUnderline;
    BOOL _outlineColorSameAsForegroundColor;
}
- (BOOL)joinInfo:(id)aInfo;
- (BOOL)isAdjacent:(id)aAdjacent;
- (BOOL)isEqual:(id)aEqual;
- (BOOL)outlineColorSameAsForegroundColor;
- (BOOL)shouldDrawUnderline;
- (BOOL)shouldDrawOutline;
- (CGFloat)fontPointSize;
- (CGFloat)outlineWidth;
- (id)underlineColor;
- (id)outlineColor;
- (void)setCharacterRange:(NSRange)aRange;
- (NSRange)characterRange;
- (BOOL)shouldUseSystemImplementationForRendering;
- (void)dealloc;
- (id)initWithAttributes:(id)aAttributes characterRange:(NSRange)aRange;
- (BOOL)shouldUsePDFUnderlineColor;
- (id)underlinePDFColor;
@end

@interface HSLayoutManager : NSLayoutManager
{
}
- (void)drawUnderlineForGlyphRange:(NSRange)aRange underlineType:(NSInteger)aType baselineOffset:(CGFloat)aOffset lineFragmentRect:(NSRect)aRect lineFragmentGlyphRange:(NSRange)aRange2 containerOrigin:(NSPoint)aOrigin;
- (void)hyperDrawUnderlineForGlyphRange:(NSRange)aRange underlineType:(NSInteger)aType baselineOffset:(CGFloat)aOffset lineFragmentRect:(NSRect)aRect lineFragmentGlyphRange:(NSRange)aRange2 containerOrigin:(NSPoint)aOrigin info:(id)aInfo;
- (id)underlineBezierPathForGlyphRange:(NSRange)aRange underlineType:(NSInteger)aType baselineOffset:(CGFloat)aOffset lineFragmentRect:(NSRect)aRect lineFragmentGlyphRange:(NSRange)aRange2 containerOrigin:(NSPoint)aOrigin textContainer:(id)aContainer info:(id)aInfo;
- (void)showPackedGlyphs:(char *)aGlyphs length:(NSUInteger)aLength glyphRange:(NSRange)aRange atPoint:(NSPoint)aPoint font:(id)aFont color:(id)aColor printingAdjustment:(NSSize)aAdjustment;
- (void)drawGlyphsForGlyphRange:(NSRange)aRange atPoint:(NSPoint)aPoint;
@end

@interface HSLayoutManager_HSGlyphDrawingInfo : NSObject
{
    NSFont *_font;
    int _textDrawingMode;
    int _textStrokingMode;
    float _lineWidth;
    NSColor *_fillColor;
    NSColor *_strokeColor;
    NSTextContainer *_textContainer;
}
+ (id)glyphDrawingInfoForContext:(struct CGContext *)aContext;
- (void)attachFillColor:(id)aColor strokeColor:(id)aColor2 colorBoundsForTextContainerForGlyphAtIndex:(NSUInteger)aIndex atLayoutManager:(id)aManager toContext:(struct CGContext *)aContext;
- (void)attachLineWidth:(CGFloat)aWidth toContext:(struct CGContext *)aContext;
- (void)attachTextStrokingMode:(NSInteger)aMode toContext:(struct CGContext *)aContext;
- (void)attachTextDrawingMode:(NSInteger)aMode toContext:(struct CGContext *)aContext;
- (void)attachFont:(id)aFont toContext:(struct CGContext *)aContext;
- (void)dealloc;
- (id)init;
@end

