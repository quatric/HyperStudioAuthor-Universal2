#import "NSETextureOpenGLDrawable.h"
#import "NSEOffscreenWindowOpenGLDrawable.h"
#import "NSEOpenGLDrawableSupport.h"

// Drawing into a texture (one level, cube map face or 3D slice of it): through
// a framebuffer object attached to it (multisampled and blitted in when the
// context is), else in an offscreen window whose contents are copied into it.

@implementation NSETextureOpenGLDrawable

- (void)NSETextureOpenGLDrawable_init
{
    _coreContext = [_context CGLContextObj];
    _internalFormat = GL_RGBA;
    _height = 1;
    _depth = 1;
}

- (id)init
{
    NSEOffscreenWindowOpenGLDrawable *drawable = [[NSEOffscreenWindowOpenGLDrawable alloc] init];
    if (!drawable) {
        [self release];
        return nil;
    }
    self = [self initWithOffscreenWindowDrawable:drawable];
    [drawable release];
    return self;
}

- (id)initWithContext:(id)aContext
{
    if ((self = [super init])) {
        _context = [aContext retain];
        [self NSETextureOpenGLDrawable_init];
    }
    return self;
}

- (id)initWithOffscreenWindowDrawable:(id)aDrawable
{
    if ((self = [super init])) {
        _offscreenWindowDrawable = [aDrawable retain];
        _context = [[_offscreenWindowDrawable openGLContext] retain];
        [self NSETextureOpenGLDrawable_init];
    }
    return self;
}

- (void)dealloc
{
    if (_coreContext && (_name || _framebuffer) && CGLLockContext(_coreContext) == kCGLNoError) {
        CGLContextObj cgl_ctx = _coreContext;
        if (_multisampleFramebuffer)
            glDeleteFramebuffersEXT(1, &_multisampleFramebuffer);
        if (_multisampleRenderbuffer)
            glDeleteRenderbuffersEXT(1, &_multisampleRenderbuffer);
        if (_framebuffer)
            glDeleteFramebuffersEXT(1, &_framebuffer);
        if (_name)
            glDeleteTextures(1, &_name);
        CGLUnlockContext(_coreContext);
    }
    [_offscreenWindowDrawable release];
    [_context release];
    [super dealloc];
}

- (id)context
{
    return _context;
}

// The offscreen window drawable, if it draws with the context.
- (id)offscreenWindowDrawable
{
    return _context == [_offscreenWindowDrawable openGLContext] ? _offscreenWindowDrawable : nil;
}

// Detaches the texture from the framebuffer. Call with the context locked.
- (void)NSETextureOpenGLDrawable_detach
{
    CGLContextObj cgl_ctx = _coreContext;
    GLint previous = 0;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING_EXT, &previous);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _framebuffer);
    GLenum attachment = NSEOpenGLInternalFormatIsDepth(_internalFormat) ? GL_DEPTH_ATTACHMENT_EXT : GL_COLOR_ATTACHMENT0_EXT;
    switch (_target) {
    case GL_TEXTURE_1D:
        glFramebufferTexture1DEXT(GL_FRAMEBUFFER_EXT, attachment, 0, 0, 0);
        break;
    case GL_TEXTURE_2D:
    case GL_TEXTURE_RECTANGLE_EXT:
    case GL_TEXTURE_CUBE_MAP:
        glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachment, 0, 0, 0);
        break;
    case GL_TEXTURE_3D:
        glFramebufferTexture3DEXT(GL_FRAMEBUFFER_EXT, attachment, 0, 0, 0, 0);
        break;
    }
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, previous);
}

- (NSUInteger)name
{
    return _name;
}

// Gives up the texture (the caller owns it now).
- (NSUInteger)abandonName
{
    GLuint name = _name;
    if (_isAttachmentValidated) {
        if (CGLLockContext(_coreContext) == kCGLNoError) {
            [self NSETextureOpenGLDrawable_detach];
            CGLUnlockContext(_coreContext);
        }
        _isAttachmentValidated = 0;
    }
    _isSpecificationValidated = 0;
    _name = 0;
    return name;
}

// Deleting the texture it had.
- (void)setName:(NSUInteger)aName
{
    if (_name == aName)
        return;
    if (_name) {
        if (CGLLockContext(_coreContext) == kCGLNoError) {
            if (_isAttachmentValidated)
                [self NSETextureOpenGLDrawable_detach];
            CGLContextObj cgl_ctx = _coreContext;
            glDeleteTextures(1, &_name);
            CGLUnlockContext(_coreContext);
        }
        _isAttachmentValidated = 0;
        _isSpecificationValidated = 0;
    }
    _name = (unsigned int)aName;
}

- (NSUInteger)target
{
    return _target;
}

// A texture of another target is a new one.
- (void)setTarget:(NSUInteger)aTarget
{
    if (_target == aTarget)
        return;
    if (_name) {
        if (CGLLockContext(_coreContext) == kCGLNoError) {
            if (_isAttachmentValidated)
                [self NSETextureOpenGLDrawable_detach];
            CGLContextObj cgl_ctx = _coreContext;
            glDeleteTextures(1, &_name);
            CGLUnlockContext(_coreContext);
        }
        _isAttachmentValidated = 0;
        _isSpecificationValidated = 0;
        _name = 0;
    }
    _target = (unsigned int)aTarget;
}

- (NSUInteger)cubeMapFace
{
    return _cubeMapFace;
}

- (void)setCubeMapFace:(NSUInteger)aFace
{
    if (_cubeMapFace != aFace) {
        _isAttachmentValidated = 0;
        _isSpecificationValidated = 0;
        _cubeMapFace = (unsigned int)aFace;
    }
}

- (NSInteger)level
{
    return _level;
}

- (void)setLevel:(NSInteger)aLevel
{
    if (_level != aLevel) {
        _isAttachmentValidated = 0;
        _isSpecificationValidated = 0;
        _level = (int)aLevel;
    }
}

- (NSUInteger)internalFormat
{
    return _internalFormat;
}

- (void)setInternalFormat:(NSUInteger)aFormat
{
    if (_internalFormat != aFormat) {
        _isSpecificationValidated = 0;
        _isInternalFormatValidated = 0;
        _internalFormat = (unsigned int)aFormat;
    }
}

- (NSInteger)zOffset
{
    return _zOffset;
}

- (void)setZOffset:(NSInteger)aOffset
{
    if (_zOffset != aOffset) {
        _isAttachmentValidated = 0;
        _zOffset = (int)aOffset;
    }
}

- (NSInteger)width
{
    return _width;
}

- (NSInteger)height
{
    return _height;
}

- (void)setWidth:(NSInteger)aWidth height:(NSInteger)aHeight statically:(BOOL)aStatically
{
    if (_width == aWidth && _height == aHeight) {
        if (_isStaticSize == (aStatically != NO))
            return;
    }
    else
        _isSpecificationValidated = 0;
    _isSizeValidated = 0;
    _width = (int)aWidth;
    _height = (int)aHeight;
    _isStaticSize = aStatically != NO;
}

- (NSInteger)depth
{
    return _depth;
}

- (void)setDepth:(NSInteger)aDepth
{
    if (_depth != aDepth) {
        _isSpecificationValidated = 0;
        _depth = (int)aDepth;
    }
}

- (NSInteger)border
{
    return _border;
}

- (void)setBorder:(NSInteger)aBorder
{
    if (_border != aBorder) {
        _isSpecificationValidated = 0;
        _border = (int)aBorder;
    }
}

- (void)noteContextUpdated
{
    _isContextValidated = 0;
}

// A context for the offscreen window, sharing with the context.
- (id)NSETextureOpenGLDrawable_createOffscreenContext
{
    return NSEOpenGLCreateSingleBufferedContext(_context);
}

// Whether the texture is all of the offscreen window, so made from it whole.
- (BOOL)NSETextureOpenGLDrawable_isWholeSurfaceTexture
{
    if ((_target != GL_TEXTURE_2D && _target != GL_TEXTURE_RECTANGLE_EXT && _target != GL_TEXTURE_CUBE_MAP) ||
        _level > 0 || _border > 0)
        return NO;
    NSSize size = [[[_offscreenWindowDrawable openGLContext] view] frame].size;
    return _width - 0.001953125 <= size.width && size.width <= _width + 0.001953125 &&
           _height - 0.001953125 <= size.height && size.height <= _height + 0.001953125 &&
           size.width >= 15.998046875 && size.height >= 15.998046875;
}

- (id)lockOpenGLFocus
{
    if (!_target || _width < 1 || _height < 1 || _depth < 1 || CGLLockContext(_coreContext) != kCGLNoError)
        return nil;
    CGLContextObj cgl_ctx = _coreContext;
    id focused = nil;
    BOOL specified = NO, restoreFramebuffer = NO;
    GLint samples = 0;
    GLenum format, type;
    if (!_name) {
        glGenTextures(1, &_name);
        if (!_name)
            goto unlock;
    }

    if (!_isContextValidated) {
        const GLubyte *extensions = glGetString(GL_EXTENSIONS);
        if (!extensions || !gluCheckExtension((const GLubyte *)"GL_EXT_framebuffer_object", extensions))
            goto offscreen;
        [[_context format] getValues:&samples forAttribute:NSOpenGLPFASamples forVirtualScreen:[_context currentVirtualScreen]];
        if (samples > 0) {
            if (!gluCheckExtension((const GLubyte *)"GL_EXT_framebuffer_blit", extensions) ||
                !gluCheckExtension((const GLubyte *)"GL_EXT_framebuffer_multisample", extensions))
                goto offscreen;
            // Renderers whose multisampled framebuffers don't work.
            const char *const list[] = {
                "NVIDIA Corporation", "NVIDIA GeForce 9400M OpenGL Engine",
                NSAppKitVersionNumber >= 1038 ? "" : "NVIDIA GeForce 9600M GT OpenGL Engine", NULL,
                "ATI Technologies Inc.", "ATI Radeon HD 2400 XT OpenGL Engine",
                samples == 6 ? "ATI Radeon X1600 OpenGL Engine" : "", NULL, NULL
            };
            if (NSEOpenGLRendererIsListed(cgl_ctx, list))
                goto offscreen;
        }
    }
    else if (!_framebuffer)
        goto offscreen;
    else if (_multisampleFramebuffer)
        samples = -1;

    // The texture's image.
    if (!_isSpecificationValidated) {
        if (!NSEOpenGLFormatAndTypeForInternalFormat(_internalFormat, &format, &type))
            goto offscreen;
        glBindTexture(_target, _name);
        switch (_target) {
        case GL_TEXTURE_1D:
            glTexImage1D(GL_TEXTURE_1D, _level, _internalFormat, _width, _border, format, type, NULL);
            break;
        case GL_TEXTURE_2D:
        case GL_TEXTURE_RECTANGLE_EXT:
            glTexImage2D(_target, _level, _internalFormat, _width, _height, _border, format, type, NULL);
            break;
        case GL_TEXTURE_CUBE_MAP:
            glTexImage2D(_cubeMapFace, _level, _internalFormat, _width, _height, _border, format, type, NULL);
            break;
        case GL_TEXTURE_3D:
            glTexImage3D(GL_TEXTURE_3D, _level, _internalFormat, _width, _height, _depth, _border, format, type, NULL);
            break;
        }
        _isSpecificationValidated = 1;
        _isAttachmentValidated = 0;
        specified = YES;
    }

    GLenum attachment = NSEOpenGLInternalFormatIsDepth(_internalFormat) ? GL_DEPTH_ATTACHMENT_EXT : GL_COLOR_ATTACHMENT0_EXT;
    if (samples == 0) {
        if (_multisampleFramebuffer) {
            glDeleteFramebuffersEXT(1, &_multisampleFramebuffer);
            _multisampleFramebuffer = 0;
        }
        if (_multisampleRenderbuffer) {
            glDeleteRenderbuffersEXT(1, &_multisampleRenderbuffer);
            _multisampleRenderbuffer = 0;
        }
        restoreFramebuffer = NO;
    }
    else {
        // A multisampled renderbuffer drawn into, blitted into the texture.
        BOOL valid = _isSizeValidated && _isInternalFormatValidated;
        BOOL allocate;
        if (!_multisampleRenderbuffer) {
            glGenRenderbuffersEXT(1, &_multisampleRenderbuffer);
            if (!_multisampleRenderbuffer)
                goto failed;
            valid = NO;
            allocate = YES;
        }
        else
            allocate = !valid || !_isContextValidated;
        if (allocate) {
            GLint previousRenderbuffer = 0;
            glGetIntegerv(GL_RENDERBUFFER_BINDING_EXT, &previousRenderbuffer);
            glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, _multisampleRenderbuffer);
            if (valid || _isContextValidated) {
                GLint renderbufferSamples = 0;
                glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_SAMPLES_EXT, &renderbufferSamples);
                if (valid)
                    valid = renderbufferSamples == samples;
                else
                    samples = renderbufferSamples;
            }
            GLint width = _width, height = _height;
            if (_multisampleFramebuffer && !_isSizeValidated) {
                // Big enough (or for a static size, the size) already?
                glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_WIDTH_EXT, &width);
                if (!_isStaticSize) {
                    if (width < _width) {
                        valid = NO;
                        width = _width;
                    }
                    glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_HEIGHT_EXT, &height);
                    if (height < _height) {
                        valid = NO;
                        height = _height;
                    }
                }
                else if (width != _width) {
                    valid = NO;
                    width = _width;
                }
                else {
                    glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_HEIGHT_EXT, &height);
                    if (height != _height) {
                        valid = NO;
                        height = _height;
                    }
                }
            }
            if (!valid) {
                while (glGetError() != GL_NO_ERROR)
                    ;
                glRenderbufferStorageMultisampleEXT(GL_RENDERBUFFER_EXT, samples, _internalFormat, width, height);
                if (glGetError() != GL_NO_ERROR)
                    samples = 0;
            }
            glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, previousRenderbuffer);
            if (!samples)
                goto failed;
        }
        if (!_multisampleFramebuffer) {
            glGenFramebuffersEXT(1, &_multisampleFramebuffer);
            if (!_multisampleFramebuffer)
                goto failed;
        }
        else if (valid)
            goto attach;
        glGetIntegerv(GL_FRAMEBUFFER_BINDING_EXT, (GLint *)&_previousFramebuffer);
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _multisampleFramebuffer);
        glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, attachment, GL_RENDERBUFFER_EXT, _multisampleRenderbuffer);
        restoreFramebuffer = YES;
        if (glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) != GL_FRAMEBUFFER_COMPLETE_EXT)
            goto failed;
    }

attach:
    // The framebuffer the texture's attached to.
    if (!_framebuffer) {
        glGenFramebuffersEXT(1, &_framebuffer);
        if (!_framebuffer)
            goto failed;
    }
    if (!restoreFramebuffer)
        glGetIntegerv(GL_FRAMEBUFFER_BINDING_EXT, (GLint *)&_previousFramebuffer);
    GLuint framebuffer;
    if (!_isAttachmentValidated) {
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _framebuffer);
        switch (_target) {
        case GL_TEXTURE_1D:
            glFramebufferTexture1DEXT(GL_FRAMEBUFFER_EXT, attachment, GL_TEXTURE_1D, _name, _level);
            break;
        case GL_TEXTURE_2D:
        case GL_TEXTURE_RECTANGLE_EXT:
            glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachment, _target, _name, _level);
            break;
        case GL_TEXTURE_CUBE_MAP:
            glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, attachment, _cubeMapFace, _name, _level);
            break;
        case GL_TEXTURE_3D:
            glFramebufferTexture3DEXT(GL_FRAMEBUFFER_EXT, attachment, GL_TEXTURE_3D, _name, _level, _zOffset);
            break;
        }
        if (glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) != GL_FRAMEBUFFER_COMPLETE_EXT) {
            restoreFramebuffer = YES;
            goto failed;
        }
        _isAttachmentValidated = 1;
        if ((framebuffer = _multisampleFramebuffer))
            glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, framebuffer);
    }
    else if (!(framebuffer = _multisampleFramebuffer))
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _framebuffer);
    else if (!restoreFramebuffer)
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, framebuffer);
    glGetIntegerv(GL_VIEWPORT, _previousViewport);
    glViewport(0, 0, _width, _height);
    if (_context != [_offscreenWindowDrawable openGLContext]) {
        [_offscreenWindowDrawable release];
        _offscreenWindowDrawable = nil;
    }
    focused = _context;
    if (specified)
        glBindTexture(_target, 0);
    goto focus;

failed:
    if (specified)
        glBindTexture(_target, 0);
    if (restoreFramebuffer) {
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _previousFramebuffer);
        _previousFramebuffer = 0;
    }

offscreen:
    // No framebuffer objects: an offscreen window.
    if (_multisampleFramebuffer) {
        glDeleteFramebuffersEXT(1, &_multisampleFramebuffer);
        _multisampleFramebuffer = 0;
    }
    if (_multisampleRenderbuffer) {
        glDeleteRenderbuffersEXT(1, &_multisampleRenderbuffer);
        _multisampleRenderbuffer = 0;
    }
    if (_framebuffer) {
        glDeleteFramebuffersEXT(1, &_framebuffer);
        _framebuffer = 0;
        _isAttachmentValidated = 0;
    }
    {
        BOOL sized = _offscreenWindowDrawable && _isSizeValidated;
        // (The original tests the internal format here, not whether it's
        // validated, so the opacity is only set for a format of 0.)
        BOOL formatted = _offscreenWindowDrawable && _internalFormat;
        NSOpenGLContext *context;
        if (!_offscreenWindowDrawable) {
            context = [self NSETextureOpenGLDrawable_createOffscreenContext];
            if (context) {
                _offscreenWindowDrawable = [[NSEOffscreenWindowOpenGLDrawable alloc] initWithOpenGLContext:context];
                [context release];
            }
            if (!_offscreenWindowDrawable)
                goto offscreenFailed;
        }
        else {
            context = [_offscreenWindowDrawable openGLContext];
            if (_context != context && !_isContextValidated)
                [context setCurrentVirtualScreen:[_context currentVirtualScreen]];
        }
        if (!formatted) {
            GLint opacity = !(_internalFormat == GL_RGBA || _internalFormat - GL_RGBA2 < 7);
            [context setValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
        }
        if (!sized)
            [_offscreenWindowDrawable setWidth:_width height:_height statically:_isStaticSize];
        if ((focused = [_offscreenWindowDrawable lockOpenGLFocus])) {
            _isWholeSurfaceTexture = [self NSETextureOpenGLDrawable_isWholeSurfaceTexture];
            _coreContext = [focused CGLContextObj];
        }
    }
offscreenFailed:
    if (!focused && _context != [_offscreenWindowDrawable openGLContext]) {
        [_offscreenWindowDrawable release];
        _offscreenWindowDrawable = nil;
    }
    if (!focused) {
unlock:
        CGLUnlockContext(_coreContext);
        return nil;
    }

focus:
    _previousContext = (NSEOpenGLContext *)[[NSOpenGLContext currentContext] retain];
    if (_previousContext != focused)
        [focused makeCurrentContext];
    _isSizeValidated = 1;
    _isInternalFormatValidated = 1;
    _isContextValidated = 1;
    return focused;
}

// Drawing into the offscreen window flips it.
- (float *)projectionPosttransform
{
    if (_coreContext == [_context CGLContextObj] || !_isWholeSurfaceTexture)
        return NULL;
    static const float flip[16] = { 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    return (float *)[[NSData dataWithBytes:flip length:sizeof(flip)] bytes];
}

- (void)unlockOpenGLFocus
{
    CGLContextObj cgl_ctx = _coreContext;
    NSOpenGLContext *focused;
    if (_framebuffer) {
        focused = _context;
        if (_multisampleFramebuffer) {
            GLbitfield mask = NSEOpenGLInternalFormatIsDepth(_internalFormat) ? GL_DEPTH_BUFFER_BIT : GL_COLOR_BUFFER_BIT;
            glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, _multisampleFramebuffer);
            glBindFramebufferEXT(GL_DRAW_FRAMEBUFFER_EXT, _framebuffer);
            glBlitFramebufferEXT(0, 0, _width, _height, 0, 0, _width, _height, mask, GL_NEAREST);
        }
        glFlush();
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _previousFramebuffer);
        _previousFramebuffer = 0;
        glViewport(_previousViewport[0], _previousViewport[1], _previousViewport[2], _previousViewport[3]);
    }
    else {
        focused = [_offscreenWindowDrawable openGLContext];
        if (_isWholeSurfaceTexture) {
            if (_context == focused)
                glFlush();
            else {
                glFinish();
                cgl_ctx = _coreContext = [_context CGLContextObj];
            }
            glBindTexture(_target, _name);
            [_context createTexture:_target fromView:[focused view] internalFormat:_internalFormat];
            glBindTexture(_target, 0);
        }
        else {
            // The window's viewport copied into the texture.
            glBindTexture(_target, _name);
            GLint viewport[4];
            glGetIntegerv(GL_VIEWPORT, viewport);
            GLenum format, type;
            switch (_target) {
            case GL_TEXTURE_1D:
                glCopyTexImage1D(GL_TEXTURE_1D, _level, _internalFormat, viewport[0], viewport[1], viewport[2], _border);
                break;
            case GL_TEXTURE_2D:
            case GL_TEXTURE_RECTANGLE_EXT:
                glCopyTexImage2D(_target, _level, _internalFormat, viewport[0], viewport[1], viewport[2], viewport[3], _border);
                break;
            case GL_TEXTURE_CUBE_MAP:
                glCopyTexImage2D(_cubeMapFace, _level, _internalFormat, viewport[0], viewport[1], viewport[2], viewport[3], _border);
                break;
            case GL_TEXTURE_3D:
                if (NSEOpenGLFormatAndTypeForInternalFormat(_internalFormat, &format, &type)) {
                    glTexImage3D(GL_TEXTURE_3D, _level, _internalFormat, _width, _height, _depth, _border, format, type, NULL);
                    glCopyTexSubImage3D(GL_TEXTURE_3D, _level, 0, 0, _zOffset, viewport[0], viewport[1], viewport[2], viewport[3]);
                }
                break;
            }
            glBindTexture(_target, 0);
            if (_context == focused)
                glFlush();
            else {
                glFinish();
                _coreContext = [_context CGLContextObj];
            }
        }
        [_offscreenWindowDrawable unlockOpenGLFocus];
    }
    CGLUnlockContext(_coreContext);
    if ([NSOpenGLContext currentContext] == focused) {
        if (_previousContext)
            [_previousContext makeCurrentContext];
        else
            [NSOpenGLContext clearCurrentContext];
    }
    [_previousContext release];
    _previousContext = nil;
}

@end
