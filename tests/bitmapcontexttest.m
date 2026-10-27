// CGEBitmapContext: contexts over data and pixel buffers, images sharing the
// pixels, component counts, descriptions and line info keys.
#import "CGEBitmapContext.h"

static int failures;
#define CHECK(...) do { if (!(__VA_ARGS__)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #__VA_ARGS__); failures++; } } while (0)

static int released;
static void countRelease(void *info, void *data)
{
    released++;
    free(data);
}

static bool HasText(CFStringRef string, const char *text)
{
    CFStringRef find = CFStringCreateWithCString(NULL, text, kCFStringEncodingUTF8);
    bool found = CFStringFind(string, find, 0).location != kCFNotFound;
    CFRelease(find);
    return found;
}

int main(void)
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();

    // Own data with a release callback.
    CGContextRef context = CGEBitmapContextCreateWithData(malloc(4 * 4 * 4), 4, 4, 8, 16, rgb,
                                                          kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host,
                                                          countRelease, NULL);
    CHECK(context != NULL);
    CHECK(CGEBitmapContextGetNumberOfComponents(context) == 4);
    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    CGContextFillRect(context, CGRectMake(0, 0, 4, 4));

    // The image shares the pixels and keeps the context alive.
    CGImageRef image = CGEBitmapContextCreateImageNoCopy(context, NULL, false, kCGRenderingIntentDefault);
    CHECK(image && CGImageGetWidth(image) == 4 && CGImageGetBytesPerRow(image) == 16);
    CGContextSetRGBFillColor(context, 0, 0, 1, 1);
    CGContextFillRect(context, CGRectMake(0, 0, 4, 4));
    CGContextRelease(context);
    CHECK(released == 0);
    CFDataRef pixels = CGDataProviderCopyData(CGImageGetDataProvider(image));
    const uint32_t *pixel = (const uint32_t *)CFDataGetBytePtr(pixels);
    CHECK(pixel[0] == 0xff0000ff); // blue, drawn after the image was made
    CFRelease(pixels);
    CGImageRelease(image);
    CHECK(released == 1);

    // No-alpha and gray.
    context = CGEBitmapContextCreate(NULL, 3, 2, 8, 0, rgb, kCGImageAlphaNoneSkipLast);
    CHECK(CGEBitmapContextGetNumberOfComponents(context) == 3);
    CFStringRef description = CGEBitmapContextCopyDescription(context);
    CHECK(HasText(description, "width = 3, height = 2, bits per component = 8, number of components = 3, "
                               "bits per pixel = 32"));
    CFRelease(description);
    CGContextRelease(context);
    CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
    context = CGEBitmapContextCreate(NULL, 5, 5, 8, 0, gray, kCGImageAlphaNone);
    CHECK(CGEBitmapContextGetNumberOfComponents(context) == 1);
    CGContextRelease(context);
    CGColorSpaceRelease(gray);

    // An alpha-only context gives a mask.
    context = CGEBitmapContextCreate(NULL, 4, 4, 8, 0, NULL, kCGImageAlphaOnly);
    CHECK(context && CGEBitmapContextGetNumberOfComponents(context) == 1);
    CGContextRelease(context);
    context = CGEBitmapContextCreate(NULL, 4, 4, 8, 0, CGColorSpaceCreateDeviceGray(), kCGImageAlphaNone);
    CGImageRef mask = CGEBitmapContextCreateImageMaskNoCopy(context, NULL, false);
    CHECK(mask && CGImageIsMask(mask));
    CGImageRelease(mask);
    CGContextRelease(context);

    // Over a pixel buffer: drawing lands in the buffer, which is unlocked
    // and released with the context.
    CVPixelBufferRef buffer = NULL;
    CVPixelBufferCreate(NULL, 8, 6, kCVPixelFormatType_32BGRA, NULL, &buffer);
    CHECK(buffer != NULL);
    // Without an alpha info attachment the alpha is "as is", which bitmap
    // contexts can't draw into.
    CHECK(CGEBitmapContextCreateWithPixelBuffer(buffer, 0) == NULL && CFGetRetainCount(buffer) == 1);
    int premultiplied = 1;
    CFNumberRef alphaInfo = CFNumberCreate(NULL, kCFNumberSInt32Type, &premultiplied);
    CVBufferSetAttachment(buffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, alphaInfo, kCVAttachmentMode_ShouldPropagate);
    CFRelease(alphaInfo);
    context = CGEBitmapContextCreateWithPixelBuffer(buffer, 0);
    CHECK(context && CGBitmapContextGetWidth(context) == 8 && CGBitmapContextGetHeight(context) == 6);
    CHECK(CFGetRetainCount(buffer) == 2);
    CGContextSetRGBFillColor(context, 0, 1, 0, 1);
    CGContextFillRect(context, CGRectMake(0, 0, 8, 6));
    CGContextRelease(context);
    CHECK(CFGetRetainCount(buffer) == 1);
    CVPixelBufferLockBaseAddress(buffer, kCVPixelBufferLock_ReadOnly);
    const uint8_t *bgra = CVPixelBufferGetBaseAddress(buffer);
    CHECK(bgra[0] == 0 && bgra[1] == 255 && bgra[2] == 0 && bgra[3] == 255);
    CVPixelBufferUnlockBaseAddress(buffer, kCVPixelBufferLock_ReadOnly);
    // Read-only lock flags go with the context.
    context = CGEBitmapContextCreateWithPixelBuffer(buffer, kCVPixelBufferLock_ReadOnly);
    CHECK(context != NULL);
    CGContextRelease(context);
    CHECK(CFGetRetainCount(buffer) == 1);
    // Planar buffers can't be contexts.
    CVPixelBufferRef planar = NULL;
    CVPixelBufferCreate(NULL, 8, 6, kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, NULL, &planar);
    CHECK(planar && CGEBitmapContextCreateWithPixelBuffer(planar, 0) == NULL);
    CVPixelBufferRelease(planar);
    CVPixelBufferRelease(buffer);

    // Line info keys: same device-pixel style → same key.
    CGFloat dash[] = {2, 1};
    CFDataRef key1 = CGEBitmapCacheCreateLineInfoKey(1, 2, kCGLineCapRound, kCGLineJoinMiter, 4, 0.5, dash, 2,
                                                     CGAffineTransformMakeScale(2, 3));
    CFDataRef key2 = CGEBitmapCacheCreateLineInfoKey(0.5, 1, kCGLineCapRound, kCGLineJoinMiter, 4, 0.25,
                                                     (CGFloat[]){1, 0.5}, 2, CGAffineTransformMakeScale(2, 3));
    CHECK(key1 && CFDataGetLength(key1) == 10 * sizeof(long) && CFEqual(key1, key2));
    description = CGEBitmapCacheCopyLineInfoKeyDescription(key1, 1);
    CHECK(CFEqual(description, CFSTR("width: {4.000, 6.000}, cap: round, join: miter (4.000), dash: "
                                     "{1.000, 2.000}->{4.000, 6.000}-{2.000, 3.000}")));
    CFRelease(description);
    CFRelease(key1);
    CFRelease(key2);
    // A single dash length counts as none; non-miter joins drop the limit.
    key1 = CGEBitmapCacheCreateLineInfoKey(1, 3, kCGLineCapSquare, kCGLineJoinBevel, 10, 0, dash, 1,
                                           CGAffineTransformIdentity);
    CHECK(CFDataGetLength(key1) == 4 * sizeof(long));
    description = CGEBitmapCacheCopyLineInfoKeyDescription(key1, 1);
    CHECK(CFEqual(description, CFSTR("width: {3.000, 3.000}, cap: square, join: bevel, dash: none")));
    CFRelease(description);
    CFRelease(key1);
    key1 = CGEBitmapCacheCreateLineInfoKey(1, 1, kCGLineCapButt, kCGLineJoinMiter, 10, 0, NULL, 0,
                                           CGAffineTransformIdentity);
    key2 = CGEBitmapCacheCreateLineInfoKey(1, 1, kCGLineCapButt, kCGLineJoinMiter, 3, 0, NULL, 0,
                                           CGAffineTransformIdentity);
    CHECK(!CFEqual(key1, key2));
    description = CGEBitmapCacheCopyLineInfoKeyDescription(key2, 1);
    CHECK(HasText(description, "miter (3.000)"));
    CFRelease(description);
    CFRelease(key1);
    CFRelease(key2);

    CGColorSpaceRelease(rgb);
    if (failures)
        printf("%d FAILED\n", failures);
    else
        printf("all passed\n");
    return failures != 0;
}
