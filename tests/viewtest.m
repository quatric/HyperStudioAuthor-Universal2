// CGEContext attachments, and an NSEView drawing Quartz into its OpenGL
// surface (read back with glReadPixels).
#import "NSEView.h"
#import "NSEOpenGLContext.h"
#import <OpenGL/gl.h>

@interface TestView : NSEView
{
@public
    NSColor *left;
}
@end

@implementation TestView
- (BOOL)drawOpenGLSurfaceQuartzTextureRect:(NSRect)aRect
{
    [(left ? left : [NSColor colorWithSRGBRed:1 green:0 blue:0 alpha:1]) set];
    NSRectFill(NSMakeRect(0, 0, 50, 100));
    [[NSColor colorWithSRGBRed:0 green:0 blue:1 alpha:1] set];
    NSRectFill(NSMakeRect(50, 0, 50, 100));
    return YES;
}
@end

static int failures;
#define CHECK(c) do { if (!(c)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #c); failures++; } } while (0)

int main(void)
{
    @autoreleasepool {
        // Attachments: set, get, save, change, restore, remove.
        CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
        CGContextRef c = CGBitmapContextCreate(NULL, 4, 4, 8, 16, space, kCGImageAlphaPremultipliedFirst);
        CFStringRef key = CFSTR("k"), other = CFSTR("o");
        CHECK(CGEContextGetAttachmentForKey(c, key) == NULL);
        CGEContextSetAttachmentForKey(c, key, CFSTR("one"));
        CHECK(CFEqual(CGEContextGetAttachmentForKey(c, key), CFSTR("one")));
        CGEContextSaveAttachments(c);
        CGEContextSetAttachmentForKey(c, key, CFSTR("two"));
        CGEContextSetAttachmentForKey(c, other, CFSTR("x"));
        CHECK(CFEqual(CGEContextGetAttachmentForKey(c, key), CFSTR("two")));
        CFDictionaryRef all = CGEContextCopyAttachments(c);
        CHECK(CFDictionaryGetCount(all) == 2);
        CFRelease(all);
        CGEContextRestoreAttachments(c);
        CHECK(CFEqual(CGEContextGetAttachmentForKey(c, key), CFSTR("one")));
        CHECK(CGEContextGetAttachmentForKey(c, other) == NULL);
        CGEContextSetAttachmentForKey(c, key, NULL);
        CHECK(CGEContextGetAttachmentForKey(c, key) == NULL);
        int marker;
        CGEContextSetDestination(c, CFSTR("d"), &marker);
        CHECK(CGEContextGetDestination(c, CFSTR("d")) == &marker);
        CGEContextSetDestination(c, CFSTR("d"), NULL);
        CHECK(CGEContextGetDestination(c, CFSTR("d")) == NULL);
        CGContextRelease(c);
        CGColorSpaceRelease(space);
        printf("attachments done\n");

        // The view: a window with an OpenGL surface showing Quartz drawing.
        [NSApplication sharedApplication];
        NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(-4000, -4000, 100, 100)
                                                       styleMask:NSWindowStyleMaskBorderless
                                                         backing:NSBackingStoreBuffered defer:NO];
        TestView *view = [[TestView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
        [window setContentView:view];
        [window orderFront:nil];
        [view setQuartzBackingEnabled:YES];
        [view enableOpenGLSurface];
        CHECK([view isOpenGLSurfaceEnabled]);
        CHECK(NSEqualRects([view openGLSurfaceBounds], NSMakeRect(0, 0, 100, 100)));
        NSInteger r = [view NSEView_displayOpenGLSurface];
        printf("displayOpenGLSurface -> %ld, associated %d\n", (long)r, [view lockAssociatedOpenGLContext]);
        [view unlockAssociatedOpenGLContext];
        CHECK(r == 1);
        NSOpenGLContext *gl = [view openGLContext];
        [gl makeCurrentContext];
        unsigned char px[4] = { 0 };
        glReadBuffer(GL_FRONT);
        glReadPixels(25, 50, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, px);
        printf("left  %d %d %d %d\n", px[0], px[1], px[2], px[3]);
        CHECK(px[0] > 200 && px[2] < 50);
        glReadPixels(75, 50, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, px);
        printf("right %d %d %d %d\n", px[0], px[1], px[2], px[3]);
        CHECK(px[2] > 200 && px[0] < 50);
        [NSOpenGLContext clearCurrentContext];

        // Invalidating part of it, then drawing just that (in green: only
        // that part changes).
        view->left = [NSColor colorWithSRGBRed:0 green:1 blue:0 alpha:1];
        [view setNeedsDisplayOpenGLSurfaceInRect:NSMakeRect(10, 10, 20, 20)];
        CHECK([view needsDisplayOpenGLSurface]);
        r = [view NSEView_displayOpenGLSurfaceAsNeeded];
        printf("displayAsNeeded -> %ld\n", (long)r);
        CHECK(r == 1);
        CHECK(![view needsDisplayOpenGLSurface]);
        [gl makeCurrentContext];
        glReadBuffer(GL_FRONT);
        glReadPixels(20, 20, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, px);
        printf("partial %d %d %d %d\n", px[0], px[1], px[2], px[3]);
        CHECK(px[1] > 200 && px[0] < 50);
        glReadPixels(40, 40, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, px);
        printf("outside %d %d %d %d\n", px[0], px[1], px[2], px[3]);
        CHECK(px[0] > 200 && px[1] < 50);
        glReadPixels(75, 50, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, px);
        CHECK(px[2] > 200 && px[0] < 50);
        [NSOpenGLContext clearCurrentContext];

        CGAffineTransform t = [view NSE_affineTransformToView:nil];
        CHECK(t.a == 1 && t.d == 1 && t.tx == 0 && t.ty == 0);
        [window orderOut:nil];
        [view release];
        [window release];
    }
    printf(failures ? "%d FAILED\n" : "all passed\n", failures);
    return failures != 0;
}
