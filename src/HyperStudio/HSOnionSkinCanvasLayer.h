#import "HyperStudioPrefix.h"


@interface HSOnionSkinCanvasLayer : HSSimpleCanvasSublayer
{
    struct CGImage *_image;
}
- (void)willResignActiveLayer;
- (void)didBecomeActiveLayer;
- (void)renderRect:(NSRect)aRect;
- (void)invalidateDisplay;
- (void)dealloc;
- (void)setCGImage:(struct CGImage *)aImage;
@end

