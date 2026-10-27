#import "HyperPlayerBasePrefix.h"
#import "HSGenericRenderLayer.h"


@interface HSGenericVideoStreamRenderLayer : HSGenericRenderLayer
{
    id<HSVideoStreamAttributes> _videoStreamAttributes;
    NSEPixelBufferOpenGLDrawable *_offscreenOpenGLDrawable;
    unsigned int _isOpenGLEnabled:1;
    unsigned int _isOpenGLPrepared:1;
}
- (id)validationAttributesForBitmapRenderCache;
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate;
- (BOOL)drawQuartzFrameImage:(struct CGImage *)aImage toRect:(NSRect)aRect withClipRegion:(id)aRegion delegate:(id)aDelegate;
- (BOOL)drawOpenGLTextureBuffer:(struct __CVBuffer *)aBuffer toRect:(NSRect)aRect withClipRegion:(id)aRegion delegate:(id)aDelegate;
- (void)HSGenericVideoStreamRenderLayer_drawBindedOpenGLTextureForPixelBuffer:(struct __CVBuffer *)aBuffer withOpacity:(CGFloat)aOpacity inRect:(NSRect)aRect;
- (id)calculateBoundingRegion;
- (void)fillBoundingRegionAttributesSet:(id)aSet;
- (void)fillVisualizationMaskAttributesSet:(id)aSet;
- (void)fillVisualizationAttributesSet:(id)aSet;
- (BOOL)isEmpty;
- (id)videoStreamAttributes;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy;
@end

