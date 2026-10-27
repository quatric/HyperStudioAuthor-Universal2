#import "HyperPlayerBasePrefix.h"


@interface HSVectorBrushRenderer : NSObject <HSBrushRenderer, NSObject>
{
    HSVectorBrushNodeUnit *_owner;
    struct CGImage *_cacheImage;
}
- (void)HSVectorBrushRenderer_drawInContext:(struct CGContext *)aContext;
- (void)drawInRegion:(id)aRegion;
- (void)invalidateCache;
- (void)setCacheImage:(struct CGImage *)aImage;
- (struct CGImage *)cacheImage;
- (void)dealloc;
- (id)initWithOwner:(id)aOwner;
@end

