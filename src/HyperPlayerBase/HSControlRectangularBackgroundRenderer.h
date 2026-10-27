#import "HyperPlayerBasePrefix.h"


@interface HSControlRectangularBackgroundRenderer : NSObject
{
    NSImage * _textures[9];
    BOOL _fractionValid;
    float _fraction;
    BOOL _scalesImagesToFit;
    NSColor *_backgroundColor;
    BOOL _shouldTileMiddleParts;
}
- (void)setShouldTileMiddleParts:(BOOL)aParts;
- (BOOL)shouldTileMiddleParts;
- (void)setFraction:(CGFloat)aFraction;
- (CGFloat)fraction;
- (void)drawInRect:(NSRect)aRect invalidRect:(NSRect)aRect2 inView:(id)aView;
- (void)setScalesImagesToFit:(BOOL)aFit;
- (BOOL)scalesImagesToFit;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (NSRect)correctedDestinationRectForTexture:(NSInteger)aTexture destinationRect:(NSRect)aRect;
- (void)setImage:(id)aImage forType:(NSInteger)aType;
- (id)imageForType:(NSInteger)aType;
- (void)dealloc;
@end

