#import "SMKApplicationKitPrefix.h"


@interface NSETextureOpenGLDrawable : NSObject
{
    NSEOpenGLContext *_context;
    struct _CGLContextObject *_coreContext;
    NSEOffscreenWindowOpenGLDrawable *_offscreenWindowDrawable;
    unsigned int _framebuffer;
    unsigned int _multisampleRenderbuffer;
    unsigned int _multisampleFramebuffer;
    int _previousViewport[4];
    unsigned int _previousFramebuffer;
    NSEOpenGLContext *_previousContext;
    unsigned int _name;
    unsigned int _target;
    unsigned int _cubeMapFace;
    int _level;
    unsigned int _internalFormat;
    int _zOffset;
    int _width;
    int _height;
    int _depth;
    int _border;
    unsigned int _isStaticSize:1;
    unsigned int _isSizeValidated:1;
    unsigned int _isInternalFormatValidated:1;
    unsigned int _isContextValidated:1;
    unsigned int _isSpecificationValidated:1;
    unsigned int _isAttachmentValidated:1;
    unsigned int _isWholeSurfaceTexture:1;
}
- (void)unlockOpenGLFocus;
- (float *)projectionPosttransform;
- (id)lockOpenGLFocus;
- (BOOL)NSETextureOpenGLDrawable_isWholeSurfaceTexture;
- (id)NSETextureOpenGLDrawable_createOffscreenContext;
- (void)noteContextUpdated;
- (void)setBorder:(NSInteger)aBorder;
- (NSInteger)border;
- (void)setDepth:(NSInteger)aDepth;
- (NSInteger)depth;
- (void)setWidth:(NSInteger)aWidth height:(NSInteger)aHeight statically:(BOOL)aStatically;
- (NSInteger)height;
- (NSInteger)width;
- (void)setZOffset:(NSInteger)aOffset;
- (NSInteger)zOffset;
- (void)setInternalFormat:(NSUInteger)aFormat;
- (NSUInteger)internalFormat;
- (void)setLevel:(NSInteger)aLevel;
- (NSInteger)level;
- (void)setCubeMapFace:(NSUInteger)aFace;
- (NSUInteger)cubeMapFace;
- (void)setTarget:(NSUInteger)aTarget;
- (NSUInteger)target;
- (void)setName:(NSUInteger)aName;
- (NSUInteger)abandonName;
- (NSUInteger)name;
- (void)NSETextureOpenGLDrawable_detach;
- (id)offscreenWindowDrawable;
- (id)context;
- (void)dealloc;
- (id)initWithOffscreenWindowDrawable:(id)aDrawable;
- (id)initWithContext:(id)aContext;
- (id)init;
- (void)NSETextureOpenGLDrawable_init;
@end

