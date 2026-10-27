// The pixel buffer OpenGL drawable: drawing read back as images, pixel
// buffers and links, and as a layer drawn into a CGContext.
#import "NSEPixelBufferOpenGLDrawable.h"
#import "NSEOpenGLContext.h"
#import <OpenGL/gl.h>

static int failures;
#define CHECK(c) do { if (!(c)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #c); failures++; } } while (0)

// Red bottom half, green top half (in OpenGL's coordinates).
static void draw(void)
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glClearColor(0, 1, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glColor4f(1, 0, 0, 1);
    glRectf(-1, -1, 1, 0);
}

// The RGBA of a pixel of an image (top row first).
static void pixelOfImage(CGImageRef image, size_t x, size_t y, unsigned char *rgba)
{
    size_t w = CGImageGetWidth(image), h = CGImageGetHeight(image);
    unsigned char *data = calloc(w * h, 4);
    CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    CGContextRef c = CGBitmapContextCreate(data, w, h, 8, w * 4, space, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(c, CGRectMake(0, 0, w, h), image);
    memcpy(rgba, data + 4 * (y * w + x), 4);
    CGContextRelease(c);
    CGColorSpaceRelease(space);
    free(data);
}

int main(void)
{
    @autoreleasepool {
        [NSApplication sharedApplication];
        NSEPixelBufferOpenGLDrawable *drawable = [[NSEPixelBufferOpenGLDrawable alloc] init];
        CHECK(drawable != nil);
        CHECK([drawable lockOpenGLFocus] == nil);
        [drawable setPixelsWide:48 pixelsHigh:32 statically:YES];

        // As an image: GL's bottom row is the image's top row.
        CHECK([drawable lockOpenGLFocus] != nil);
        draw();
        CGImageRef image = [drawable unlockOpenGLFocusAsImage];
        CHECK(image != NULL);
        if (image) {
            unsigned char top[4], bottom[4];
            pixelOfImage(image, 24, 4, top);
            pixelOfImage(image, 24, 28, bottom);
            printf("image %zux%zu top %d %d %d bottom %d %d %d\n", CGImageGetWidth(image), CGImageGetHeight(image),
                   top[0], top[1], top[2], bottom[0], bottom[1], bottom[2]);
            CHECK(CGImageGetWidth(image) == 48 && CGImageGetHeight(image) == 32);
            CHECK(top[0] > 200 && top[1] < 50);
            CHECK(bottom[1] > 200 && bottom[0] < 50);
            CGImageRelease(image);
        }

        // As a pixel buffer, from the pool.
        CHECK([drawable lockOpenGLFocus] != nil);
        draw();
        CVPixelBufferRef buffer = [drawable unlockOpenGLFocusAsPixelBuffer];
        CHECK(buffer != NULL);
        if (buffer) {
            CVPixelBufferLockBaseAddress(buffer, kCVPixelBufferLock_ReadOnly);
            unsigned char *base = CVPixelBufferGetBaseAddress(buffer);
            size_t rowBytes = CVPixelBufferGetBytesPerRow(buffer);
            unsigned char *first = base + 4 * 24, *last = base + 31 * rowBytes + 4 * 24;
            printf("buffer %zux%zu %.4s row0 BGRA %d %d %d row31 %d %d %d\n", CVPixelBufferGetWidth(buffer),
                   CVPixelBufferGetHeight(buffer), (char *)&(OSType){ CFSwapInt32HostToBig(CVPixelBufferGetPixelFormatType(buffer)) },
                   first[0], first[1], first[2], last[0], last[1], last[2]);
            CHECK(first[2] > 200 && first[1] < 50);
            CHECK(last[1] > 200 && last[2] < 50);
            CVPixelBufferUnlockBaseAddress(buffer, kCVPixelBufferLock_ReadOnly);
            CHECK(CVBufferGetAttachment(buffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, NULL) != NULL);
            CVPixelBufferRelease(buffer);
        }

        // As a link: its pixel buffer and image.
        [drawable setPixelBufferAttachment:@"v" forKey:CFSTR("k") mode:kCVAttachmentMode_ShouldPropagate];
        CHECK([drawable lockOpenGLFocus] != nil);
        draw();
        id<NSEPixelBufferLink> link = [drawable unlockOpenGLFocusAsPixelBufferLink];
        CHECK(link != nil);
        if (link) {
            printf("link %s %lux%lu bpr %lu\n", object_getClassName(link), (unsigned long)[link width],
                   (unsigned long)[link height], (unsigned long)[link bytesPerRow]);
            CHECK([(id)[link attachmentForKey:CFSTR("k") mode:NULL] isEqual:@"v"]);
            CGImageRef linked = [link newImageWithDecode:NULL interpolation:YES colorRenderingIntent:0];
            CHECK(linked != NULL);
            if (linked) {
                unsigned char top[4];
                pixelOfImage(linked, 24, 4, top);
                CHECK(top[0] > 200 && top[1] < 50);
                CGImageRelease(linked);
            }
            CVPixelBufferRef linkBuffer = [link pixelBuffer];
            CHECK(linkBuffer != NULL);
            if (linkBuffer) {
                CHECK(CVPixelBufferGetWidth(linkBuffer) == 48);
                CHECK(CVBufferGetAttachment(linkBuffer, CFSTR("k"), NULL) != NULL);
            }
            [link release];
        }
        // Drawing again after a link (synchronizing the pixel buffer object).
        CHECK([drawable lockOpenGLFocus] != nil);
        draw();
        [drawable unlockOpenGLFocus];

        // A layer into a CGContext: a rect in its user space.
        CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
        unsigned char *data = calloc(100 * 100, 4);
        CGContextRef c = CGBitmapContextCreate(data, 100, 100, 8, 400, space, kCGImageAlphaPremultipliedLast);
        CGContextScaleCTM(c, 2, 2);
        CHECK([drawable beginOpenGLLayerForCGContext:c rect:CGRectMake(5, 5, 20, 20) opacity:1]);
        printf("layer pixels %lux%lu\n", (unsigned long)[drawable pixelsWide], (unsigned long)[drawable pixelsHigh]);
        // Fill the rect in the layer's coordinates: red lower half (y 5-15).
        glClearColor(0, 0, 1, 1);
        glClear(GL_COLOR_BUFFER_BIT);
        glColor4f(1, 0, 0, 1);
        glRectf(5, 5, 25, 15);
        CHECK([drawable endOpenGLLayerForCGContext]);
        // Bitmap rows are top first: device y 20 (user 10) is row 79, device
        // y 40 (user 20) row 59.
        unsigned char *low = data + 4 * (79 * 100 + 30), *high = data + 4 * (59 * 100 + 30);
        unsigned char *outside = data + 4 * (95 * 100 + 95);
        printf("layer low %d %d %d high %d %d %d outside %d\n", low[0], low[1], low[2], high[0], high[1], high[2], outside[3]);
        CHECK(low[0] > 200 && low[2] < 50);
        CHECK(high[2] > 200 && high[0] < 50);
        CHECK(outside[3] == 0);
        CGContextRelease(c);
        CGColorSpaceRelease(space);
        free(data);
        [drawable release];
    }
    printf(failures ? "%d FAILED\n" : "all passed\n", failures);
    return failures != 0;
}
