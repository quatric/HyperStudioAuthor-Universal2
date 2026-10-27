#import "HyperPlayerBasePrefix.h"


@interface HSTexturedView : NSView
{
    HSControlRectangularBackgroundRenderer *_renderer;
}
- (void)setShouldTileMiddleParts:(BOOL)aParts;
- (BOOL)shouldTileMiddleParts;
- (void)drawRect:(NSRect)aRect;
- (void)setScalesTexturesToFit:(BOOL)aFit;
- (BOOL)scalesTexturesToFit;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (void)setRenderer:(id)aRenderer;
- (id)renderer;
- (void)setFraction:(CGFloat)aFraction;
- (CGFloat)fraction;
- (void)setImage:(id)aImage forType:(NSInteger)aType;
- (id)imageForType:(NSInteger)aType;
- (id)initWithFrame:(NSRect)aFrame;
- (BOOL)isOpaque;
- (void)dealloc;
@end

