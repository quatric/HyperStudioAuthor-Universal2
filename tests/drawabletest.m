// The offscreen window and texture OpenGL drawables: drawing into a texture
// (through a framebuffer object, multisampled and not), read back.
#import "NSEOffscreenWindowOpenGLDrawable.h"
#import "NSETextureOpenGLDrawable.h"
#import "NSEOpenGLContext.h"
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>

static int failures;
#define CHECK(c) do { if (!(c)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #c); failures++; } } while (0)

// Draws a red left half and a green right half into the texture, then reads
// it back and checks.
static void drawAndCheck(NSETextureOpenGLDrawable *drawable, const char *label)
{
    NSOpenGLContext *focused = [drawable lockOpenGLFocus];
    printf("%s: focused %p (context %p)\n", label, focused, [drawable context]);
    CHECK(focused != nil);
    if (!focused)
        return;
    CHECK([NSOpenGLContext currentContext] == focused);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glClearColor(0, 1, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glColor4f(1, 0, 0, 1);
    glRectf(-1, -1, 0, 1);
    [drawable unlockOpenGLFocus];
    CHECK([NSOpenGLContext currentContext] != focused || focused == [drawable context]);

    NSOpenGLContext *context = [drawable context];
    [context makeCurrentContext];
    GLuint name = (GLuint)[drawable name];
    CHECK(name != 0);
    int w = (int)[drawable width], h = (int)[drawable height];
    unsigned char *pixels = calloc(w * h, 4);
    glBindTexture((GLenum)[drawable target], name);
    glGetTexImage((GLenum)[drawable target], 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
    glBindTexture((GLenum)[drawable target], 0);
    unsigned char *left = pixels + 4 * (h / 2 * w + w / 4), *right = pixels + 4 * (h / 2 * w + 3 * w / 4);
    printf("%s: texture %u left %d %d %d right %d %d %d (gl error %#x)\n", label, name,
           left[0], left[1], left[2], right[0], right[1], right[2], glGetError());
    CHECK(left[0] > 200 && left[1] < 50);
    CHECK(right[1] > 200 && right[0] < 50);
    free(pixels);
    [NSOpenGLContext clearCurrentContext];
}

int main(void)
{
    @autoreleasepool {
        [NSApplication sharedApplication];

        // An offscreen window drawable: its context draws to a window.
        NSEOffscreenWindowOpenGLDrawable *window = [[NSEOffscreenWindowOpenGLDrawable alloc] init];
        CHECK(window != nil);
        CHECK([window lockOpenGLFocus] == nil);
        [window setWidth:40 height:30 statically:YES];
        NSOpenGLContext *c = [window lockOpenGLFocus];
        CHECK(c == [window openGLContext]);
        GLint viewport[4];
        glGetIntegerv(GL_VIEWPORT, viewport);
        printf("window viewport %d %d %d %d\n", viewport[0], viewport[1], viewport[2], viewport[3]);
        CHECK(viewport[2] == 40 && viewport[3] == 30);
        [window unlockOpenGLFocus];

        // A texture drawn with the window's (multisampled) context.
        NSETextureOpenGLDrawable *texture = [[NSETextureOpenGLDrawable alloc] initWithOffscreenWindowDrawable:window];
        [texture setTarget:GL_TEXTURE_RECTANGLE_EXT];
        [texture setWidth:64 height:32 statically:NO];
        drawAndCheck(texture, "rect");
        // Again, reusing it all; then a new size.
        drawAndCheck(texture, "rect again");
        [texture setWidth:96 height:48 statically:NO];
        drawAndCheck(texture, "rect resized");
        GLuint name = (GLuint)[texture abandonName];
        CHECK(name != 0 && [texture name] == 0);
        [[texture context] makeCurrentContext];
        glDeleteTextures(1, &name);
        [NSOpenGLContext clearCurrentContext];
        [texture release];

        // A 2D texture with a plain context.
        NSOpenGLPixelFormatAttribute a[] = { NSOpenGLPFAAccelerated, NSOpenGLPFAColorSize, 24, NSOpenGLPFAAlphaSize, 8, 0 };
        NSEOpenGLContext *plain = [NSEOpenGLContext contextWithFormatAttributes:(unsigned *)a shareCategory:@"t"];
        texture = [[NSETextureOpenGLDrawable alloc] initWithContext:plain];
        [texture setTarget:GL_TEXTURE_2D];
        [texture setWidth:32 height:32 statically:YES];
        drawAndCheck(texture, "2d");
        [texture release];
        [window release];
    }
    printf(failures ? "%d FAILED\n" : "all passed\n", failures);
    return failures != 0;
}
