// What the OpenGL drawables (the framebuffer clipper, the texture and pixel
// buffer drawables) share: renderer quirk lists and offscreen contexts.
#import "NSEOpenGLContext.h"
#import <OpenGL/CGLMacro.h>
#import <OpenGL/glu.h>

// Whether the renderer is one of a list: vendor, its renderers, NULL, ... and
// a final NULL. A vendor with no renderers listed matches all of them.
static inline BOOL NSEOpenGLRendererIsListed(CGLContextObj cgl_ctx, const char *const *list)
{
    const char *vendor = NULL, *renderer = NULL;
    while (*list) {
        if (!vendor && !(vendor = (const char *)glGetString(GL_VENDOR)))
            return NO;
        BOOL vendorMatches = strcmp(vendor, *list) == 0;
        list++;
        if (vendorMatches) {
            if (!*list)
                return YES;
            for (; *list; list++) {
                if (!renderer && !(renderer = (const char *)glGetString(GL_RENDERER)))
                    return NO;
                if (strcmp(renderer, *list) == 0)
                    return YES;
            }
        }
        else
            while (*list)
                list++;
        list++;
    }
    return NO;
}

static inline BOOL NSEOpenGLRendererIs(CGLContextObj cgl_ctx, const char *vendor, const char *renderer)
{
    const char *s = (const char *)glGetString(GL_VENDOR);
    if (!s || strcmp(s, vendor) != 0 || !(s = (const char *)glGetString(GL_RENDERER)))
        return NO;
    return strcmp(s, renderer) == 0;
}

// A new context sharing with a context, like it but single buffered.
static inline NSEOpenGLContext *NSEOpenGLCreateSingleBufferedContext(NSEOpenGLContext *context)
{
    NSOpenGLPixelFormat *format = [context format];
    GLint screen = [context currentVirtualScreen];
    GLint doubleBuffered = 0;
    [format getValues:&doubleBuffered forAttribute:NSOpenGLPFADoubleBuffer forVirtualScreen:screen];
    if (!doubleBuffered)
        return [[NSEOpenGLContext alloc] initWithFormat:format shareContext:context];

    // The format's attributes but double buffering.
    static const NSOpenGLPixelFormatAttribute flags[25] = {
        1, 6, 0x33, 0x34, 0x35, 0x36, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x47, 0x48,
        0x49, 0x4a, 0x4b, 0x4c, 0x4e, 0x50, 0x51, 0x53, 0x5a, 0x5b, 0x60, 0x61
    };
    static const NSOpenGLPixelFormatAttribute values[11] = {
        7, 8, 0xb, 0xc, 0xd, 0xe, 0x37, 0x38, 0x46, 0x54, 0x80
    };
    NSOpenGLPixelFormatAttribute attributes[64], *a = attributes;
    for (int i = 0; i < 25; i++) {
        GLint value = 0;
        [format getValues:&value forAttribute:flags[i] forVirtualScreen:screen];
        if (value)
            *a++ = flags[i];
    }
    for (int i = 0; i < 11; i++) {
        GLint value = 0;
        [format getValues:&value forAttribute:values[i] forVirtualScreen:screen];
        *a++ = values[i];
        *a++ = value;
    }
    *a = 0;
    NSOpenGLPixelFormat *singleBuffered = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
    if (!singleBuffered)
        return nil;
    NSEOpenGLContext *result = [[NSEOpenGLContext alloc] initWithFormat:singleBuffered shareContext:context];
    [singleBuffered release];
    return result;
}

// The format and type for specifying a texture of an internal format, NO for
// ones it can't be.
static inline BOOL NSEOpenGLFormatAndTypeForInternalFormat(GLenum internalFormat, GLenum *format, GLenum *type)
{
    switch (internalFormat) {
    case GL_DEPTH_COMPONENT16:
        *format = GL_DEPTH_COMPONENT;
        *type = GL_UNSIGNED_SHORT;
        return YES;
    case GL_DEPTH_COMPONENT:
    case GL_DEPTH_COMPONENT24:
    case GL_DEPTH_COMPONENT32:
        *format = GL_DEPTH_COMPONENT;
        *type = GL_UNSIGNED_INT;
        return YES;
    case GL_R3_G3_B2:
        *format = GL_RGB;
        *type = GL_UNSIGNED_BYTE_3_3_2;
        return YES;
    case GL_RGB4:
    case GL_RGB5:
        *format = GL_RGB;
        *type = GL_UNSIGNED_SHORT_5_6_5;
        return YES;
    case GL_RGB:
    case GL_RGB8:
        *format = GL_RGB;
        *type = GL_UNSIGNED_BYTE;
        return YES;
    case GL_RGB10:
    case GL_RGB10_A2:
        *format = GL_BGRA;
        *type = GL_UNSIGNED_INT_2_10_10_10_REV;
        return YES;
    case GL_RGB12:
    case GL_RGB16:
        *format = GL_RGB;
        *type = GL_UNSIGNED_SHORT;
        return YES;
    case GL_RGBA2:
    case GL_RGBA4:
        *format = GL_BGRA;
        *type = GL_UNSIGNED_SHORT_4_4_4_4_REV;
        return YES;
    case GL_RGB5_A1:
        *format = GL_BGRA;
        *type = GL_UNSIGNED_SHORT_1_5_5_5_REV;
        return YES;
    case GL_RGBA:
    case GL_RGBA8:
        *format = GL_BGRA;
        *type = GL_UNSIGNED_INT_8_8_8_8_REV;
        return YES;
    case GL_RGBA12:
    case GL_RGBA16:
        *format = GL_RGBA;
        *type = GL_UNSIGNED_SHORT;
        return YES;
    }
    return NO;
}

// Depth formats attach as depth, the rest as color.
static inline BOOL NSEOpenGLInternalFormatIsDepth(GLenum internalFormat)
{
    return internalFormat == GL_DEPTH_COMPONENT || internalFormat - GL_DEPTH_COMPONENT16 < 3;
}
