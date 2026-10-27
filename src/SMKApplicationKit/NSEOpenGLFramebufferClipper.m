#import "NSEOpenGLFramebufferClipper.h"
#import "NSEOpenGLDrawableSupport.h"

// Draws into part of an OpenGL context: the drawing goes to a framebuffer
// object (or, without one, an offscreen context) the size of the clip bounds,
// and when focus is unlocked only the clip rects of it are copied into the
// context, by blitting or as textured quads. The projection posttransform
// maps the context's viewport onto the clip bounds.

// The posttransform mapping a viewport to the clip bounds, upside down for a
// window's texture.
static void setPosttransform(float *m, const GLint *viewport, struct CGEBitmapRect clip, BOOL flipped)
{
    memset(m, 0, 16 * sizeof(*m));
    double width = (float)clip.width, height = (float)clip.height;
    double dx = viewport[0] - clip.x;
    m[0] = viewport[2] / (float)width;
    m[10] = 1;
    m[12] = (viewport[2] + dx + dx) / width - 1;
    if (flipped) {
        double dy = clip.y - viewport[1];
        m[5] = -viewport[3] / (float)height;
        m[13] = (dy + dy - viewport[3]) / height + 1;
    }
    else {
        double dy = viewport[1] - clip.y;
        m[5] = viewport[3] / (float)height;
        m[13] = (viewport[3] + dy + dy) / height - 1;
    }
    m[15] = 1;
}

@implementation NSEOpenGLFramebufferClipper

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithOpenGLContext:(id)aContext
{
    if ((self = [super init])) {
        _context = [aContext retain];
        _coreContext = [aContext CGLContextObj];
    }
    return self;
}

- (void)dealloc
{
    if (_coreContext && (_textureName || _framebuffer) && CGLLockContext(_coreContext) == kCGLNoError) {
        CGLContextObj cgl_ctx = _coreContext;
        if (_framebuffer)
            glDeleteFramebuffersEXT(1, &_framebuffer);
        if (_renderbuffer)
            glDeleteRenderbuffersEXT(1, &_renderbuffer);
        if (_downsamplingFramebuffer)
            glDeleteFramebuffersEXT(1, &_downsamplingFramebuffer);
        if (_textureName)
            glDeleteTextures(1, &_textureName);
        CGLUnlockContext(_coreContext);
    }
    [_offscreenContext clearDrawable];
    [_offscreenContext release];
    [_offscreenContextDrawable release];
    [_context release];
    [super dealloc];
}

- (id)context
{
    return _context;
}

- (void)noteContextUpdated
{
    _isContextValidated = 0;
    _textureTarget = 0;
}

- (float *)projectionPosttransform
{
    return _projectionPosttransform;
}

// An offscreen context like the context but single buffered.
- (id)NSEOpenGLFramebufferClipper_createOffscreenContext
{
    if ((_offscreenContext = NSEOpenGLCreateSingleBufferedContext(_context))) {
        GLint opacity = 1;
        [_context getValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
        [_offscreenContext setValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
    }
    return _offscreenContext;
}

// Picks the texture target and, if asked, the texture size for the clip
// bounds (powers of two where the renderer needs them).
- (BOOL)NSEOpenGLFramebufferClipper_validateTextureTargetAndCalculateTextureSize:(BOOL)aSize withOpenGLExtensions:(char **)aExtensions
{
    CGLContextObj cgl_ctx = _coreContext;
    const GLubyte **extensions = (const GLubyte **)aExtensions;
    BOOL changed = NO;
    if (!_textureTarget || !_isContextValidated) {
        if (!*extensions && !(*extensions = glGetString(GL_EXTENSIONS)))
            return NO;
        GLenum target = gluCheckExtension((const GLubyte *)"GL_EXT_texture_rectangle", *extensions)
                        ? GL_TEXTURE_RECTANGLE_EXT : GL_TEXTURE_2D;
        if (_textureTarget != target) {
            _textureTarget = target;
            _isTextureAttached = 0;
            changed = YES;
        }
    }
    if (!aSize && !changed)
        return YES;

    int width = (int)_clipBounds.width, height = (int)_clipBounds.height;
    // (The original reads the extensions here even when they weren't fetched.)
    if (_textureTarget != GL_TEXTURE_RECTANGLE_EXT &&
        (*extensions || (*extensions = glGetString(GL_EXTENSIONS))) &&
        !gluCheckExtension((const GLubyte *)"GL_ARB_texture_non_power_of_two", *extensions)) {
        NSUInteger w = 1, h = 1;
        while (w < _clipBounds.width)
            w *= 2;
        while (h < _clipBounds.height)
            h *= 2;
        width = (int)w;
        height = (int)h;
    }
    if (_textureWidth != width || _textureHeight != height) {
        _textureWidth = width;
        _textureHeight = height;
        _isTextureSizeValidated = 0;
    }
    return YES;
}

- (id)lockOpenGLFocusWithClipBounds:(struct CGEBitmapRect)aBounds rects:(struct CGEBitmapRect *)aRects count:(NSUInteger)aCount
{
    if (!aBounds.width || !aBounds.height || !aCount)
        return nil;
    BOOL resized = aBounds.width != _clipBounds.width || aBounds.height != _clipBounds.height;
    _clipBounds = aBounds;
    if (CGLLockContext(_coreContext) != kCGLNoError)
        return nil;
    CGLContextObj cgl_ctx = _coreContext;
    id focused = nil;
    const GLubyte *extensions = NULL;
    GLint samples = -1;
    BOOL useRenderbuffer;

    if (!_isContextValidated) {
        if (!(extensions = glGetString(GL_EXTENSIONS))) {
            CGLUnlockContext(_coreContext);
            return nil;
        }
        if (!gluCheckExtension((const GLubyte *)"GL_EXT_framebuffer_object", extensions))
            goto offscreen;
        useRenderbuffer = YES;
        if (gluCheckExtension((const GLubyte *)"GL_EXT_framebuffer_blit", extensions)) {
            // Renderers whose multisampled framebuffers don't work.
            if (NSAppKitVersionNumber < 1138) {
                if (NSAppKitVersionNumber >= 1038)
                    useRenderbuffer = !NSEOpenGLRendererIs(cgl_ctx, "NVIDIA Corporation", "NVIDIA GeForce 9400M OpenGL Engine");
                else {
                    static const char *const list[] = {
                        "NVIDIA Corporation", "NVIDIA GeForce 9400M OpenGL Engine",
                        "NVIDIA GeForce 9600M GT OpenGL Engine", NULL, NULL
                    };
                    useRenderbuffer = !NSEOpenGLRendererIsListed(cgl_ctx, list);
                }
            }
            else {
                static const char *const list[] = {
                    "ATI Technologies Inc.", "AMD Radeon HD 6750M OpenGL Engine", NULL,
                    "NVIDIA Corporation", "NVIDIA GeForce 9400M OpenGL Engine", NULL, NULL
                };
                useRenderbuffer = !NSEOpenGLRendererIsListed(cgl_ctx, list);
            }
        }
        [[_context format] getValues:&samples forAttribute:NSOpenGLPFASamples forVirtualScreen:[_context currentVirtualScreen]];
        if (samples >= 1) {
            // Multisampling needs a multisampled renderbuffer, else the
            // offscreen context.
            if (!useRenderbuffer || !gluCheckExtension((const GLubyte *)"GL_EXT_framebuffer_multisample", extensions))
                goto offscreen;
            if (samples == 6 && NSEOpenGLRendererIs(cgl_ctx, "ATI Technologies Inc.", "ATI Radeon X1600 OpenGL Engine"))
                goto offscreen;
            if (NSEOpenGLRendererIs(cgl_ctx, "ATI Technologies Inc.", "ATI Radeon HD 2400 XT OpenGL Engine"))
                goto offscreen;
        }
    }
    else {
        if (!_framebuffer)
            goto offscreen;
        useRenderbuffer = _renderbuffer != 0;
    }

    // A framebuffer object the size of the clip bounds.
    if (!_framebuffer) {
        glGenFramebuffersEXT(1, &_framebuffer);
        if (!_framebuffer)
            goto offscreen;
    }
    glGetIntegerv(GL_FRAMEBUFFER_BINDING_EXT, (GLint *)&_previousFramebuffer);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _framebuffer);
    if (useRenderbuffer) {
        BOOL attached;
        if (_renderbuffer)
            attached = YES;
        else {
            glGenRenderbuffersEXT(1, &_renderbuffer);
            if (!_renderbuffer)
                goto failed;
            attached = NO;
        }
        if (!attached || resized || !_isContextValidated) {
            GLint previousRenderbuffer = 0;
            glGetIntegerv(GL_RENDERBUFFER_BINDING_EXT, &previousRenderbuffer);
            glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, _renderbuffer);
            if (attached && !resized) {
                GLint renderbufferSamples = 0;
                glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_SAMPLES_EXT, &renderbufferSamples);
                if (renderbufferSamples != samples)
                    attached = NO;
            }
            GLint width = (GLint)_clipBounds.width, height = (GLint)_clipBounds.height;
            BOOL allocate = !attached;
            if (attached && resized) {
                // Big enough already?
                glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_WIDTH_EXT, &width);
                if ((NSUInteger)(long)width < _clipBounds.width) {
                    width = (GLint)_clipBounds.width;
                    attached = NO;
                    allocate = YES;
                }
                else {
                    glGetRenderbufferParameterivEXT(GL_RENDERBUFFER_EXT, GL_RENDERBUFFER_HEIGHT_EXT, &height);
                    if ((NSUInteger)(long)height < _clipBounds.height) {
                        width = (GLint)_clipBounds.width;
                        height = (GLint)_clipBounds.height;
                        attached = NO;
                        allocate = YES;
                    }
                }
            }
            if (allocate) {
                if (NSAppKitVersionNumber < 1138 &&
                    NSEOpenGLRendererIs(cgl_ctx, "ATI Technologies Inc.", "ATI Radeon HD 6750M OpenGL Engine")) {
                    if (width < 33)
                        width = 33;
                    if (height < 33)
                        height = 33;
                }
                if (samples == -1)
                    [[_context format] getValues:&samples forAttribute:NSOpenGLPFASamples
                                forVirtualScreen:[_context currentVirtualScreen]];
                GLint opacity = 1;
                [_context getValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
                GLenum format = opacity ? GL_RGB : GL_RGBA;
                while (glGetError() != GL_NO_ERROR)
                    ;
                if (samples == 0)
                    glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, format, width, height);
                else
                    glRenderbufferStorageMultisampleEXT(GL_RENDERBUFFER_EXT, samples, format, width, height);
                if (glGetError() != GL_NO_ERROR)
                    useRenderbuffer = NO;
            }
            glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, previousRenderbuffer);
            if (!useRenderbuffer)
                goto failed;
        }
        if (!attached) {
            glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_RENDERBUFFER_EXT, _renderbuffer);
            if (glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) != GL_FRAMEBUFFER_COMPLETE_EXT)
                goto failed;
        }
        // Multisampled: resolved into a texture through a second framebuffer.
        GLint downsample = samples == -1 ? (GLint)_downsamplingFramebuffer : samples;
        if (!downsample) {
            if (_textureName) {
                glDeleteTextures(1, &_textureName);
                _textureName = 0;
                _isTextureAttached = 0;
                _isTextureSizeValidated = 0;
            }
        }
        else if (!_downsamplingFramebuffer) {
            glGenFramebuffersEXT(1, &_downsamplingFramebuffer);
            if (!_downsamplingFramebuffer)
                goto failed;
            _isTextureAttached = 0;
        }
    }
    else if (_downsamplingFramebuffer) {
        glDeleteFramebuffersEXT(1, &_downsamplingFramebuffer);
        _downsamplingFramebuffer = 0;
        _isTextureAttached = 0;
    }

    if (!useRenderbuffer || _downsamplingFramebuffer) {
        // A texture attached to the framebuffer (or the downsampling one).
        if (![self NSEOpenGLFramebufferClipper_validateTextureTargetAndCalculateTextureSize:resized || !_isTextureSizeValidated
                                                                     withOpenGLExtensions:(char **)&extensions])
            goto failed;
        GLint width = _textureWidth, height = _textureHeight;
        BOOL bound;
        if (!_textureName) {
            glGenTextures(1, &_textureName);
            if (!_textureName)
                goto failed;
            glBindTexture(_textureTarget, _textureName);
            glTexParameteri(_textureTarget, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
            glTexParameteri(_textureTarget, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
            bound = YES;
        }
        else if (_isTextureAttached && !_isTextureSizeValidated) {
            glBindTexture(_textureTarget, _textureName);
            glGetTexLevelParameteriv(_textureTarget, 0, GL_TEXTURE_WIDTH, &width);
            if (width < _textureWidth) {
                width = _textureWidth;
                height = _textureHeight;
                _isTextureAttached = 0;
            }
            else {
                glGetTexLevelParameteriv(_textureTarget, 0, GL_TEXTURE_HEIGHT, &height);
                if (height < _textureHeight) {
                    width = _textureWidth;
                    height = _textureHeight;
                    _isTextureAttached = 0;
                }
            }
            bound = YES;
        }
        else
            bound = NO;
        if (!_isTextureAttached) {
            if (_downsamplingFramebuffer)
                glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _downsamplingFramebuffer);
            if (!bound)
                glBindTexture(_textureTarget, _textureName);
            glTexImage2D(_textureTarget, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, NULL);
            glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, _textureTarget, _textureName, 0);
            if (glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) != GL_FRAMEBUFFER_COMPLETE_EXT)
                goto failed;
            if (_downsamplingFramebuffer)
                glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _framebuffer);
            _isTextureAttached = 1;
        }
        _isTextureSizeValidated = 1;
        if (!_downsamplingFramebuffer && _renderbuffer) {
            glDeleteRenderbuffersEXT(1, &_renderbuffer);
            _renderbuffer = 0;
        }
    }

    glGetIntegerv(GL_VIEWPORT, _previousViewport);
    glViewport(0, 0, (GLsizei)_clipBounds.width, (GLsizei)_clipBounds.height);
    setPosttransform(_projectionPosttransform, _previousViewport, _clipBounds, NO);
    [_offscreenContext clearDrawable];
    [_offscreenContext release];
    _offscreenContext = nil;
    [_offscreenContextDrawable release];
    _offscreenContextDrawable = nil;
    if ((focused = _context))
        goto focus;

failed:
    focused = nil;
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _previousFramebuffer);
    _previousFramebuffer = 0;

offscreen:
    // No framebuffer object: an offscreen context drawing into a pixel buffer
    // or an offscreen window, whose contents become the texture.
    focused = nil;
    if (_framebuffer) {
        glDeleteFramebuffersEXT(1, &_framebuffer);
        _framebuffer = 0;
    }
    if (_renderbuffer) {
        glDeleteRenderbuffersEXT(1, &_renderbuffer);
        _renderbuffer = 0;
    }
    if (_downsamplingFramebuffer) {
        glDeleteFramebuffersEXT(1, &_downsamplingFramebuffer);
        _downsamplingFramebuffer = 0;
    }
    _isTextureAttached = 0;
    if ([self NSEOpenGLFramebufferClipper_validateTextureTargetAndCalculateTextureSize:resized || !_isTextureSizeValidated
                                                                 withOpenGLExtensions:(char **)&extensions]) {
        if (!_textureName) {
            glGenTextures(1, &_textureName);
            if (!_textureName)
                goto offscreenFailed;
            glBindTexture(_textureTarget, _textureName);
            glTexParameteri(_textureTarget, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
            glTexParameteri(_textureTarget, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        }
        BOOL wasPixelBuffer = [_offscreenContextDrawable isKindOfClass:[NSOpenGLPixelBuffer class]];
        BOOL usePixelBuffer = wasPixelBuffer;
        if (!_isContextValidated || !_offscreenContextDrawable) {
            if (!extensions && !(extensions = glGetString(GL_EXTENSIONS)))
                goto offscreenFailed;
            if (gluCheckExtension((const GLubyte *)"GL_APPLE_pixel_buffer", extensions)) {
                // Pixel buffers can't be multisampled.
                if (samples == -1)
                    [[_context format] getValues:&samples forAttribute:NSOpenGLPFASamples
                                forVirtualScreen:[_context currentVirtualScreen]];
                usePixelBuffer = samples == 0;
            }
            if (wasPixelBuffer != usePixelBuffer) {
                [_offscreenContext clearDrawable];
                [_offscreenContextDrawable release];
                _offscreenContextDrawable = nil;
            }
        }
        GLint viewport[4];
        if (!usePixelBuffer) {
            int width = _textureWidth < 16 ? 16 : _textureWidth;
            int height = _textureHeight < 16 ? 16 : _textureHeight;
            BOOL setViewport = resized || !_offscreenContextDrawable;
            if (!_offscreenContextDrawable) {
                _offscreenContextDrawable = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, width, height)
                                                                        styleMask:NSWindowStyleMaskBorderless
                                                                          backing:NSBackingStoreNonretained
                                                                            defer:NO];
                if (!_offscreenContextDrawable)
                    goto offscreenFailed;
                [_offscreenContextDrawable setReleasedWhenClosed:NO];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [_offscreenContextDrawable useOptimizedDrawing:YES];
#pragma clang diagnostic pop
            }
            else if (resized || !_isTextureSizeValidated) {
                NSRect content = [_offscreenContextDrawable contentRectForFrameRect:[_offscreenContextDrawable frame]];
                if (_isTextureSizeValidated ||
                    (width - 0.001953125 <= content.size.width && height - 0.001953125 <= content.size.height))
                    height = (int)lround(content.size.height);
                else {
                    [_offscreenContextDrawable setContentSize:NSMakeSize(width, height)];
                    [_offscreenContext update];
                }
            }
            if (!_offscreenContext) {
                NSView *view = [_offscreenContextDrawable contentView];
                if (!view || ![self NSEOpenGLFramebufferClipper_createOffscreenContext])
                    goto offscreenFailed;
                [_offscreenContext setView:view];
                if ([_offscreenContext view] != view)
                    goto offscreenFailed;
                [_offscreenContext setCurrentVirtualScreen:[_context currentVirtualScreen]];
            }
            else if (!_isContextValidated)
                [_offscreenContext setCurrentVirtualScreen:[_context currentVirtualScreen]];
            glGetIntegerv(GL_VIEWPORT, viewport);
            setPosttransform(_projectionPosttransform, viewport, _clipBounds, YES);
            _coreContext = [_offscreenContext CGLContextObj];
            if (setViewport) {
                cgl_ctx = _coreContext;
                // At the top of the window.
                glViewport(0, height - (GLint)_clipBounds.height, (GLsizei)_clipBounds.width, (GLsizei)_clipBounds.height);
            }
        }
        else {
            GLint opacity = 1;
            [_context getValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
            GLenum format = opacity ? GL_RGB : GL_RGBA;
            BOOL reused;
            if ([_offscreenContextDrawable textureTarget] == _textureTarget &&
                [_offscreenContextDrawable textureInternalFormat] == format &&
                (_isTextureSizeValidated || ([(NSOpenGLPixelBuffer *)_offscreenContextDrawable pixelsWide] >= _textureWidth &&
                                             [(NSOpenGLPixelBuffer *)_offscreenContextDrawable pixelsHigh] >= _textureHeight)))
                reused = YES;
            else {
                GLint minimum[2] = { 0, 0 };
                glGetIntegerv(GL_MIN_PBUFFER_VIEWPORT_DIMS_APPLE, minimum);
                [_offscreenContext clearDrawable];
                [_offscreenContextDrawable release];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                _offscreenContextDrawable = [[NSOpenGLPixelBuffer alloc] initWithTextureTarget:_textureTarget
                                                                         textureInternalFormat:format
                                                                         textureMaxMipMapLevel:0
                                                                                    pixelsWide:MAX(_textureWidth, minimum[0])
                                                                                    pixelsHigh:MAX(_textureHeight, minimum[1])];
#pragma clang diagnostic pop
                if (!_offscreenContextDrawable)
                    goto offscreenFailed;
                reused = NO;
            }
            if (!_offscreenContext || !reused) {
                if (!_offscreenContext && ![self NSEOpenGLFramebufferClipper_createOffscreenContext])
                    goto offscreenFailed;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [_offscreenContext setPixelBuffer:_offscreenContextDrawable cubeMapFace:0 mipMapLevel:0
                             currentVirtualScreen:[_context currentVirtualScreen]];
                if ([_offscreenContext pixelBuffer] != _offscreenContextDrawable)
                    goto offscreenFailed;
#pragma clang diagnostic pop
            }
            else if (!_isContextValidated)
                [_offscreenContext setCurrentVirtualScreen:[_context currentVirtualScreen]];
            glGetIntegerv(GL_VIEWPORT, viewport);
            setPosttransform(_projectionPosttransform, viewport, _clipBounds, NO);
            _coreContext = [_offscreenContext CGLContextObj];
            if (!wasPixelBuffer || resized) {
                cgl_ctx = _coreContext;
                glViewport(0, 0, (GLsizei)_clipBounds.width, (GLsizei)_clipBounds.height);
            }
        }
        _isTextureSizeValidated = 1;
        focused = _offscreenContext;
    }
offscreenFailed:
    if (!focused) {
        if (_textureName) {
            glDeleteTextures(1, &_textureName);
            _textureName = 0;
            _isTextureSizeValidated = 0;
        }
        [_offscreenContext clearDrawable];
        [_offscreenContext release];
        _offscreenContext = nil;
        [_offscreenContextDrawable release];
        _offscreenContextDrawable = nil;
        CGLUnlockContext(_coreContext);
        return nil;
    }

focus:
    _previousContext = (NSEOpenGLContext *)[[NSOpenGLContext currentContext] retain];
    if (_previousContext != focused)
        [focused makeCurrentContext];
    _isContextValidated = 1;
    _clipRects = aRects;
    _clipRectCount = (unsigned int)aCount;
    return focused;
}

- (void)unlockOpenGLFocus
{
    CGLContextObj cgl_ctx = _coreContext;
    id focused;
    if (!_framebuffer) {
        // The offscreen drawable's contents into the texture.
        glFlush();
        cgl_ctx = _coreContext = [_context CGLContextObj];
        glBindTexture(_textureTarget, _textureName);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if ([_offscreenContextDrawable isKindOfClass:[NSOpenGLPixelBuffer class]])
            [_context setTextureImageToPixelBuffer:_offscreenContextDrawable colorBuffer:GL_FRONT];
        else {
            GLint opacity = 1;
            [_context getValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
            [_context createTexture:_textureTarget fromView:[_offscreenContextDrawable contentView]
                     internalFormat:opacity ? GL_RGB : GL_RGBA];
        }
#pragma clang diagnostic pop
        focused = _offscreenContext;
    }
    else {
        if (_renderbuffer) {
            // Blitting the clip rects out of the renderbuffer.
            glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, _framebuffer);
            if (!_downsamplingFramebuffer) {
                glBindFramebufferEXT(GL_DRAW_FRAMEBUFFER_EXT, _previousFramebuffer);
                for (unsigned int i = 0; i < _clipRectCount; i++) {
                    struct CGEBitmapRect r = _clipRects[i];
                    GLint x = r.x - _clipBounds.x, y = r.y - _clipBounds.y;
                    glBlitFramebufferEXT(x, y, x + r.width, y + r.height, r.x, r.y, r.x + r.width, r.y + r.height,
                                         GL_COLOR_BUFFER_BIT, GL_NEAREST);
                }
            }
            else {
                // Resolving into the downsampling framebuffer's texture.
                glBindFramebufferEXT(GL_DRAW_FRAMEBUFFER_EXT, _downsamplingFramebuffer);
                if (!NSEOpenGLRendererIs(cgl_ctx, "ATI Technologies Inc.", "ATI Radeon X1600 OpenGL Engine")) {
                    for (unsigned int i = 0; i < _clipRectCount; i++) {
                        struct CGEBitmapRect r = _clipRects[i];
                        GLint x = r.x - _clipBounds.x, y = r.y - _clipBounds.y;
                        glBlitFramebufferEXT(x, y, x + r.width, y + r.height, x, y, x + r.width, y + r.height,
                                             GL_COLOR_BUFFER_BIT, GL_NEAREST);
                    }
                }
                else {
                    // That one loses the read framebuffer after each blit.
                    for (unsigned int i = 0; i < _clipRectCount; i++) {
                        struct CGEBitmapRect r = _clipRects[i];
                        GLint x = r.x - _clipBounds.x, y = r.y - _clipBounds.y;
                        if (i)
                            glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, _framebuffer);
                        glBlitFramebufferEXT(x, y, x + r.width, y + r.height, x, y, x + r.width, y + r.height,
                                             GL_COLOR_BUFFER_BIT, GL_NEAREST);
                    }
                }
            }
        }
        glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, _previousFramebuffer);
        _previousFramebuffer = 0;
        glViewport(_previousViewport[0], _previousViewport[1], _previousViewport[2], _previousViewport[3]);
        if (_textureName)
            glBindTexture(_textureTarget, _textureName);
        focused = _context;
    }

    if (_textureName) {
        // The texture's clip rects drawn as quads, in window coordinates.
        GLboolean textureEnabled = glIsEnabled(_textureTarget);
        if (!textureEnabled)
            glEnable(_textureTarget);
        GLboolean blendEnabled = glIsEnabled(GL_BLEND);
        if (blendEnabled)
            glDisable(GL_BLEND);
        GLint viewport[4];
        glGetIntegerv(GL_VIEWPORT, viewport);
        GLfloat m[16] = { 0 };
        m[0] = viewport[2] ? 2.0f / viewport[2] : 1.0f;
        m[5] = viewport[3] ? 2.0f / viewport[3] : 1.0f;
        m[10] = 1;
        m[12] = -1.0f - viewport[0] * m[0];
        m[13] = -1.0f - viewport[1] * m[5];
        m[15] = 1;
        glMatrixMode(GL_PROJECTION);
        glLoadMatrixf(m);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        if (_textureTarget != GL_TEXTURE_RECTANGLE_EXT) {
            GLint width = 0, height = 0;
            glGetTexLevelParameteriv(_textureTarget, 0, GL_TEXTURE_WIDTH, &width);
            glGetTexLevelParameteriv(_textureTarget, 0, GL_TEXTURE_HEIGHT, &height);
            GLfloat t[16] = { 0 };
            t[0] = 1.0f / width;
            t[5] = 1.0f / height;
            t[10] = 1;
            t[15] = 1;
            glMatrixMode(GL_TEXTURE);
            glLoadMatrixf(t);
        }
        glBegin(GL_QUADS);
        for (unsigned int i = 0; i < _clipRectCount; i++) {
            struct CGEBitmapRect r = _clipRects[i];
            GLint x = r.x - _clipBounds.x, y = r.y - _clipBounds.y;
            GLint w = (GLint)r.width, h = (GLint)r.height;
            glTexCoord2i(x, y);
            glVertex2i(r.x, r.y);
            glTexCoord2i(x, y + h);
            glVertex2i(r.x, r.y + h);
            glTexCoord2i(x + w, y + h);
            glVertex2i(r.x + w, r.y + h);
            glTexCoord2i(x + w, y);
            glVertex2i(r.x + w, r.y);
        }
        glEnd();
        if (_textureTarget != GL_TEXTURE_RECTANGLE_EXT)
            glLoadIdentity();
        if (blendEnabled)
            glEnable(GL_BLEND);
        if (!textureEnabled)
            glDisable(_textureTarget);
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
