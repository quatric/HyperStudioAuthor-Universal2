#import "HyperPlayerBasePrefix.h"


@interface HSGraphicComposition : NSObject
{
}
- (id)createOpenGLRendererForContext:(id)aContext pixelFormat:(id)aFormat;
- (id)createQuartzRendererForSize:(CGSize)aSize;
- (BOOL)hasOpenGLRenderer;
- (BOOL)hasQuartzRenderer;
- (BOOL)isNewFrameAtTime:(double)aTime relativeToTime:(double)aTime2;
- (BOOL)isSlow;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
@end

