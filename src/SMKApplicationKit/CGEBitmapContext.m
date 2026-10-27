#import "CGEBitmapContext.h"
#import "CGEImage.h"
#import "CVEPixelBuffer.h"

CGContextRef CGEBitmapContextCreate(void *data, size_t width, size_t height, size_t bitsPerComponent,
                                    size_t bytesPerRow, CGColorSpaceRef space, CGBitmapInfo bitmapInfo)
{
    return CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, space, bitmapInfo);
}

CGContextRef CGEBitmapContextCreateWithData(void *data, size_t width, size_t height, size_t bitsPerComponent,
                                            size_t bytesPerRow, CGColorSpaceRef space, CGBitmapInfo bitmapInfo,
                                            CGBitmapContextReleaseDataCallback releaseCallback, void *releaseInfo)
{
    return CGBitmapContextCreateWithData(data, width, height, bitsPerComponent, bytesPerRow, space, bitmapInfo,
                                         releaseCallback, releaseInfo);
}

CGContextRef CGEBitmapContextCreateAsPixelBuffer(CVPixelBufferRef buffer, void *data,
                                                 CGBitmapContextReleaseDataCallback releaseCallback,
                                                 void *releaseInfo)
{
    if (CVPixelBufferIsPlanar(buffer))
        return NULL;
    int alphaMode = 0;
    CFNumberRef number = CVBufferGetAttachment(buffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, NULL);
    if (number)
        CFNumberGetValue(number, kCFNumberSInt32Type, &alphaMode);
    CGColorSpaceRef bufferSpace = CVImageBufferGetColorSpace(buffer);
    size_t bitsPerComponent = 0;
    CGColorSpaceModel model = kCGColorSpaceModelMonochrome;
    CGBitmapInfo bitmapInfo = 0;
    Boolean invertedDecode = false;
    if (!CVEPixelFormatTypeIsCGBitmapContextCompatible(CVPixelBufferGetPixelFormatType(buffer), alphaMode,
                                                       &bitsPerComponent, bufferSpace ? NULL : &model, &bitmapInfo,
                                                       bufferSpace ? NULL : &invertedDecode))
        return NULL;
    CGColorSpaceRef space = bufferSpace;
    if (!space) {
        // A context can't invert the decode the format needs.
        if (invertedDecode)
            return NULL;
        switch (model) {
        case kCGColorSpaceModelMonochrome:
            space = CGColorSpaceCreateDeviceGray();
            break;
        case kCGColorSpaceModelRGB:
            space = CGColorSpaceCreateDeviceRGB();
            break;
        case kCGColorSpaceModelCMYK:
            space = CGColorSpaceCreateDeviceCMYK();
            break;
        default:
            break;
        }
        if (!space)
            return NULL;
    }
    CGContextRef context = CGEBitmapContextCreateWithData(data, CVPixelBufferGetWidth(buffer),
                                                          CVPixelBufferGetHeight(buffer), bitsPerComponent,
                                                          CVPixelBufferGetBytesPerRow(buffer), space, bitmapInfo,
                                                          releaseCallback, releaseInfo);
    if (!bufferSpace)
        CGColorSpaceRelease(space);
    return context;
}

typedef struct {
    CVPixelBufferRef buffer;
    CVOptionFlags lockFlags;
} LockedPixelBuffer;

static void unlockPixelBuffer(void *releaseInfo, void *data)
{
    CVPixelBufferUnlockBaseAddress((CVPixelBufferRef)releaseInfo, 0);
    CVPixelBufferRelease((CVPixelBufferRef)releaseInfo);
}

static void unlockPixelBufferWithFlags(void *releaseInfo, void *data)
{
    LockedPixelBuffer *locked = releaseInfo;
    CVPixelBufferUnlockBaseAddress(locked->buffer, locked->lockFlags);
    CVPixelBufferRelease(locked->buffer);
    free(locked);
}

CGContextRef CGEBitmapContextCreateWithLockedPixelBuffer(CVPixelBufferRef buffer, CVOptionFlags lockFlags)
{
    CGContextRef context;
    if (lockFlags == 0) {
        context = CGEBitmapContextCreateAsPixelBuffer(buffer, CVPixelBufferGetBaseAddress(buffer),
                                                      unlockPixelBuffer, buffer);
        if (!context)
            return NULL;
    } else {
        LockedPixelBuffer *locked = malloc(sizeof(LockedPixelBuffer));
        if (!locked)
            return NULL;
        locked->buffer = buffer;
        locked->lockFlags = lockFlags;
        context = CGEBitmapContextCreateAsPixelBuffer(buffer, CVPixelBufferGetBaseAddress(buffer),
                                                      unlockPixelBufferWithFlags, locked);
        if (!context) {
            free(locked);
            return NULL;
        }
    }
    CVPixelBufferRetain(buffer);
    return context;
}

CGContextRef CGEBitmapContextCreateWithPixelBuffer(CVPixelBufferRef buffer, CVOptionFlags lockFlags)
{
    if (CVPixelBufferLockBaseAddress(buffer, lockFlags) != kCVReturnSuccess)
        return NULL;
    CGContextRef context = CGEBitmapContextCreateWithLockedPixelBuffer(buffer, lockFlags);
    if (!context)
        CVPixelBufferUnlockBaseAddress(buffer, lockFlags);
    return context;
}

static void releaseContext(void *info, const void *data, size_t size)
{
    CFRelease(info);
}

// A provider of the context's pixels that retains it.
static CGDataProviderRef createProviderOfContext(CGContextRef context)
{
    CGDataProviderRef provider =
        CGDataProviderCreateWithData(context, CGBitmapContextGetData(context),
                                     CGBitmapContextGetBytesPerRow(context) * CGBitmapContextGetHeight(context),
                                     releaseContext);
    if (provider)
        CFRetain(context);
    return provider;
}

CGImageRef CGEBitmapContextCreateImageNoCopy(CGContextRef context, const CGFloat *decode, bool shouldInterpolate,
                                             CGColorRenderingIntent intent)
{
    if (!context)
        return NULL;
    CGDataProviderRef provider = createProviderOfContext(context);
    if (!provider)
        return NULL;
    CGImageRef image = CGEImageCreateAsBitmapContext(context, provider, decode, shouldInterpolate, intent);
    CGDataProviderRelease(provider);
    return image;
}

CGImageRef CGEBitmapContextCreateImageMaskNoCopy(CGContextRef context, const CGFloat *decode,
                                                 bool shouldInterpolate)
{
    if (!context)
        return NULL;
    CGDataProviderRef provider = createProviderOfContext(context);
    if (!provider)
        return NULL;
    CGImageRef image = CGEImageMaskCreateAsBitmapContext(context, provider, decode, shouldInterpolate);
    CGDataProviderRelease(provider);
    return image;
}

void CGEBitmapContextShow(CGContextRef context)
{
    if (!context)
        return;
    CGImageRef image = CGBitmapContextGetColorSpace(context)
                           ? CGEBitmapContextCreateImageNoCopy(context, NULL, true, kCGRenderingIntentDefault)
                           : CGEBitmapContextCreateImageMaskNoCopy(context, NULL, true);
    if (image) {
        CGEImageShowAs(image, CFSTR("CGContextRef"), context);
        CGImageRelease(image);
    }
}

size_t CGEBitmapContextGetNumberOfComponents(CGContextRef context)
{
    if (!context)
        return 0;
    size_t components = CGColorSpaceGetNumberOfComponents(CGBitmapContextGetColorSpace(context));
    switch (CGBitmapContextGetAlphaInfo(context)) {
    case kCGImageAlphaPremultipliedLast:
    case kCGImageAlphaPremultipliedFirst:
    case kCGImageAlphaLast:
    case kCGImageAlphaFirst:
    case kCGImageAlphaOnly:
        return components + 1;
    case kCGImageAlphaNone:
    case kCGImageAlphaNoneSkipLast:
    case kCGImageAlphaNoneSkipFirst:
        return components;
    default:
        CFShow(CFSTR("Invalid / unsupported image alpha info."));
        return components;
    }
}

CFStringRef CGEBitmapContextCopyDescription(CGContextRef context)
{
    if (!context)
        return NULL;
    CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
    CFStringRef spaceDescription = space ? CFCopyDescription(space) : NULL;
    CFStringRef description = CFStringCreateWithFormat(
        kCFAllocatorDefault, NULL,
        CFSTR("<CGContextRef %p: width = %zu, height = %zu, bits per component = %zu, number of components = %zu, "
              "bits per pixel = %zu, bytes per row = %zu, color space = %@, bitmap info = %i>"),
        context, CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context),
        CGBitmapContextGetBitsPerComponent(context), CGEBitmapContextGetNumberOfComponents(context),
        CGBitmapContextGetBitsPerPixel(context), CGBitmapContextGetBytesPerRow(context), spaceDescription,
        (int)CGBitmapContextGetBitmapInfo(context));
    if (spaceDescription)
        CFRelease(spaceDescription);
    return description;
}

#pragma mark Line info keys

// Key layout, in longs: width along the transform's x and y columns, dash
// count (0 for fewer than 2 lengths), then with dashes the phase and each
// length as x/y pairs, then the style: join << 62 | cap << 60, and for miter
// joins the miter limit (at least 1) as frexp exponent << 49 | mantissa in 49
// bits.
enum { kMiterMantissaBits = 49 };

CFDataRef CGEBitmapCacheCreateLineInfoKey(CGFloat unitScale, CGFloat lineWidth, CGLineCap cap, CGLineJoin join,
                                          CGFloat miterLimit, CGFloat phase, const CGFloat *lengths, size_t count,
                                          CGAffineTransform transform)
{
    if (count < 2)
        count = 0;
    CFIndex length = (count ? 6 + 2 * count : 4) * sizeof(long);
    CFMutableDataRef key = CFDataCreateMutable(kCFAllocatorDefault, length);
    if (!key)
        return NULL;
    CFDataSetLength(key, length);
    long *words = (long *)CFDataGetMutableBytePtr(key);
    if (!words) {
        CFRelease(key);
        return NULL;
    }
    CGFloat sx = hypot(transform.a, transform.b), sy = hypot(transform.c, transform.d);
    *words++ = lround(sx * lineWidth / unitScale);
    *words++ = lround(lineWidth * sy / unitScale);
    *words++ = count;
    if (count) {
        *words++ = lround(sx * phase / unitScale);
        *words++ = lround(phase * sy / unitScale);
        for (size_t i = 0; i < count; i++) {
            *words++ = lround(lengths[i] * sx / unitScale);
            *words++ = lround(lengths[i] * sy / unitScale);
        }
    }
    unsigned long style = (unsigned long)join << 62 | (unsigned long)cap << 60;
    if (join == kCGLineJoinMiter) {
        int exponent = 0;
        CGFloat mantissa = frexp(fmax(1.0, miterLimit), &exponent);
        style |= (unsigned long)exponent << kMiterMantissaBits;
        style |= (unsigned long)lround(ldexp(mantissa, kMiterMantissaBits));
    }
    *words = style;
    return key;
}

CFStringRef CGEBitmapCacheCopyLineInfoKeyDescription(CFDataRef key, CGFloat unitScale)
{
    const long *words = (const long *)CFDataGetBytePtr(key);
    if (!words)
        return NULL;
    long width = words[0], height = words[1], count = words[2];
    const long *style = words + 3;
    CFStringRef dash;
    if (count == 0)
        dash = CFRetain(CFSTR("none"));
    else {
        CFMutableStringRef mutableDash = CFStringCreateMutable(kCFAllocatorDefault, 0);
        if (mutableDash) {
            CFStringAppendFormat(mutableDash, NULL, CFSTR("{%.3f"), words[3] * unitScale);
            CFStringAppendFormat(mutableDash, NULL, CFSTR(", %.3f}->"), words[4] * unitScale);
            for (long i = 0; i < count; i++) {
                if (i)
                    CFStringAppendFormat(mutableDash, NULL, CFSTR(", %.3f}-"), words[6 + 2 * (i - 1)] * unitScale);
                CFStringAppendFormat(mutableDash, NULL, CFSTR("{%.3f"), words[5 + 2 * i] * unitScale);
            }
            CFStringAppendFormat(mutableDash, NULL, CFSTR(", %.3f}"), words[4 + 2 * count] * unitScale);
        }
        dash = mutableDash;
        style = words + 5 + 2 * count;
    }

    unsigned long bits = *style;
    const char *capName;
    switch (bits >> 60 & 3) {
    case kCGLineCapButt:
        capName = "butt";
        break;
    case kCGLineCapRound:
        capName = "round";
        break;
    case kCGLineCapSquare:
        capName = "square";
        break;
    default:
        capName = "unknown";
    }
    CFStringRef joinName;
    switch (bits >> 62) {
    case kCGLineJoinMiter: {
        // The original masked 50 bits here, taking in the exponent's low bit.
        unsigned long mantissa = bits & ((1UL << kMiterMantissaBits) - 1);
        int exponent = (int)(bits >> kMiterMantissaBits & 0x7ff);
        joinName = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("miter (%.3f)"),
                                            ldexp((double)mantissa, exponent - kMiterMantissaBits));
        break;
    }
    case kCGLineJoinRound:
        joinName = CFRetain(CFSTR("round"));
        break;
    case kCGLineJoinBevel:
        joinName = CFRetain(CFSTR("bevel"));
        break;
    default:
        joinName = CFRetain(CFSTR("unknown"));
    }
    CFStringRef description = CFStringCreateWithFormat(
        kCFAllocatorDefault, NULL, CFSTR("width: {%.3f, %.3f}, cap: %s, join: %@, dash: %@"), width * unitScale,
        height * unitScale, capName, joinName, dash);
    if (joinName)
        CFRelease(joinName);
    if (dash)
        CFRelease(dash);
    return description;
}
