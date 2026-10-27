#import "SMKApplicationKitPrefix.h"


@interface NSEOpenGLFramebufferClipper : NSObject
{
    NSEOpenGLContext *_context;
    struct _CGLContextObject *_coreContext;
    struct CGEBitmapRect _clipBounds;
    struct CGEBitmapRect *_clipRects;
    unsigned int _clipRectCount;
    unsigned int _renderbuffer;
    unsigned int _textureTarget;
    unsigned int _textureName;
    int _textureWidth;
    int _textureHeight;
    unsigned int _framebuffer;
    unsigned int _downsamplingFramebuffer;
    NSEOpenGLContext *_offscreenContext;
    id _offscreenContextDrawable;
    float _projectionPosttransform[16];
    int _previousViewport[4];
    unsigned int _previousFramebuffer;
    NSEOpenGLContext *_previousContext;
    unsigned int _isTextureSizeValidated:1;
    unsigned int _isTextureAttached:1;
    unsigned int _isContextValidated:1;
}
- (void)unlockOpenGLFocus;
- (float *)projectionPosttransform;
- (id)lockOpenGLFocusWithClipBounds:(struct CGEBitmapRect)aBounds rects:(struct CGEBitmapRect *)aRects count:(NSUInteger)aCount;
- (BOOL)NSEOpenGLFramebufferClipper_validateTextureTargetAndCalculateTextureSize:(BOOL)aSize withOpenGLExtensions:(char **)aExtensions;
- (id)NSEOpenGLFramebufferClipper_createOffscreenContext;
- (void)noteContextUpdated;
- (id)context;
- (void)dealloc;
- (id)initWithOpenGLContext:(id)aContext;
- (id)init;
@end

