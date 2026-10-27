#import "HyperStudioPrefix.h"


@interface HSSharedCardBorderRenderer : NSObject
{
    NSImage *_topBorder;
    NSImage *_rightBorder;
    NSImage *_bottomBorder;
    NSImage *_leftBorder;
    NSImage *_topLeftCorner;
    NSImage *_topRightCorner;
    NSImage *_bottomLeftCorner;
    NSImage *_bottomRightCorner;
    NSPoint _borderInset;
}
+ (id)selectedBorderRenderer;
+ (id)borderRenderer;
+ (id)imageNamed:(id)aNamed prefix:(id)aPrefix suffix:(id)aSuffix size:(NSSize *)aSize;
- (NSPoint)inset;
- (void)renderAroundRect:(NSRect)aRect;
- (void)setImagePrefix:(id)aPrefix;
- (id)initSelectedRenderer;
- (id)init;
- (id)initRendererWithImagePrefix:(id)aPrefix suffix:(id)aSuffix;
- (void)dealloc;
@end

@interface HSCardBorderRenderer : NSObject
{
    NSSize _thumbnailSize;
    NSImage *_borderImage;
    NSImage *_selectedBorderImage;
    NSColor *_fillColor;
}
+ (id)defaultFillColor;
+ (NSPoint)selectedBorderInsetForCardThumbnailSize:(NSSize)aSize;
+ (NSPoint)borderInsetForCardThumbnailSize:(NSSize)aSize;
+ (id)selectedBorderedThumbnailWithCardThumbnail:(id)aThumbnail inset:(NSPoint *)aInset;
+ (id)selectedBorderedThumbnailWithCardThumbnail:(id)aThumbnail;
+ (id)borderedThumbnailWithCardThumbnail:(id)aThumbnail inset:(NSPoint *)aInset;
+ (id)borderedThumbnailWithCardThumbnail:(id)aThumbnail;
- (void)setFillColor:(id)aColor;
- (id)fillColor;
- (id)selectedBorderedThumbnailWithCardThumbnail:(id)aThumbnail isHighlighted:(BOOL)aHighlighted inset:(NSPoint *)aInset;
- (id)borderedThumbnailWithCardThumbnail:(id)aThumbnail isHighlighted:(BOOL)aHighlighted inset:(NSPoint *)aInset;
- (id)borderedThumbnailWithBorderImage:(id)aImage cardImage:(id)aImage2 renderer:(id)aRenderer isHighlighted:(BOOL)aHighlighted inset:(NSPoint *)aInset;
- (id)selectedBorderImage;
- (id)borderImage;
- (id)imageWithBorderRenderer:(id)aRenderer;
- (void)drawSemiTransparentCardBorderInRect:(NSRect)aRect wholeImageRect:(NSRect)aRect2;
- (NSSize)imageSizeWithBorderRenderer:(id)aRenderer thumbnailInset:(NSPoint *)aInset;
- (NSPoint)selectedBorderInset;
- (NSPoint)borderInset;
- (void)setCardBorderRendererType:(id)aType;
- (void)setBorderedThumbnailSize:(NSSize)aSize;
- (NSSize)thumbnailSize;
- (void)setThumbnailSize:(NSSize)aSize;
- (void)dealloc;
- (id)init;
- (id)initWithThumbnailSize:(NSSize)aSize;
@end

