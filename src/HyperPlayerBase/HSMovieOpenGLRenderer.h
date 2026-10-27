#import "HyperPlayerBasePrefix.h"
#import "HSMovieVisualContextRenderer.h"


@interface HSMovieOpenGLRenderer : HSMovieVisualContextRenderer <HSMovieRenderer, NSObject>
{
    struct OpaqueCMProfileRef *_workingColorProfile;
    struct CGColorSpace *_workingCGColorSpace;
    NSColorSpace *_workingColorSpace;
    unsigned char _destinationColorProfileMD5[16];
    struct OpaqueCMWorldRef *_colorWorld;
    struct _CGLContextObject *_coreGLContext;
    NSEPixelBufferOpenGLDrawable *_offscreenOpenGLRenderer;
    NSETextureOpenGLDrawable *_textureOpenGLDrawable;
    unsigned int _colorLUTGridPointCount;
    char *_colorLUT;
    unsigned int _colorLUTTexture;
    struct __HSFrameOpenGLProgram *_frameOpenGLProgram2D;
    struct __HSFrameOpenGLProgram *_frameOpenGLProgram2DRect;
    id<NSEPixelBufferLink> _currentFramePixelBufferLink;
    struct CGImage *_currentFrameImage;
    unsigned int _frameOpenGLFragmentShaderComplexity:2;
    unsigned int _isColorLUTTextureValid:1;
    unsigned int _isOffscreenOpenGLPrepared:1;
}
- (BOOL)HSMovieOpenGLRenderer_updateFrameOpenGLProgram:(struct __HSFrameOpenGLProgram *)aProgram forTextureRectangle:(BOOL)aRectangle matchColors:(BOOL)aColors;
- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2 withTransparentColor:(id)aColor hueTolerance:(double)aTolerance chromaTolerance:(double)aTolerance2 lightnessTolerance:(double)aTolerance3;
- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2;
- (struct CGImage *)currentFrameImage;
- (id)HSMovieOpenGLRenderer_currentFramePixelBufferLink;
- (void)HSMovieOpenGLRenderer_prepareOffscreenOpenGLContextIfNeeded;
- (BOOL)HSMovieOpenGLRenderer_bindCLUTTextureIfNeededInOpenGLContext:(struct _CGLContextObject *)aContext;
- (BOOL)HSMovieOpenGLRenderer_updateColorLUTIfNeededWithDestinationColorProfile:(struct OpaqueCMProfileRef *)aProfile;
- (struct __HSFrameOpenGLProgram *)HSMovieOpenGLRenderer_createFrameOpenGLProgram;
- (void)invalidateCurrentFrame;
- (void)didUpdateCurrentFrameImageBuffer:(struct __CVBuffer *)aBuffer;
- (void)dealloc;
- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage;
- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage visualContext:(struct OpaqueQTVisualContext *)aContext;
@end

