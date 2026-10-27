#import "CGEImage.h"
#import "CVEPixelBuffer.h"
#import "CFEURL.h"

static void releaseMallocBytes(void *info, const void *data, size_t size)
{
    free((void *)data);
}

CGDataProviderRef CGEDataProviderCreateWithBytes(void *bytes, size_t length)
{
    return CGDataProviderCreateWithData(NULL, bytes, length, releaseMallocBytes);
}

static void releaseAllocatorBytes(void *info, const void *data, size_t size)
{
    CFAllocatorDeallocate((CFAllocatorRef)info, (void *)data);
}

CGDataProviderRef CGEDataProviderCreateWithCFBytes(void *bytes, size_t length, CFAllocatorRef allocator)
{
    return CGDataProviderCreateWithData((void *)allocator, bytes, length, releaseAllocatorBytes);
}

// A read-only locked pixel buffer is the provider's info; other lock flags go
// with it.
typedef struct {
    CVPixelBufferRef buffer;
    CVOptionFlags lockFlags;
} LockedPixelBuffer;

static const void *getReadOnlyBytes(void *info)
{
    if (CVPixelBufferLockBaseAddress((CVPixelBufferRef)info, kCVPixelBufferLock_ReadOnly) != kCVReturnSuccess)
        return NULL;
    return CVPixelBufferGetBaseAddress((CVPixelBufferRef)info);
}

static void releaseReadOnlyBytes(void *info, const void *pointer)
{
    CVPixelBufferUnlockBaseAddress((CVPixelBufferRef)info, kCVPixelBufferLock_ReadOnly);
}

static void releaseReadOnlyInfo(void *info)
{
    CVPixelBufferRelease((CVPixelBufferRef)info);
}

static const void *getLockedBytes(void *info)
{
    LockedPixelBuffer *locked = info;
    if (CVPixelBufferLockBaseAddress(locked->buffer, locked->lockFlags) != kCVReturnSuccess)
        return NULL;
    return CVPixelBufferGetBaseAddress(locked->buffer);
}

static void releaseLockedBytes(void *info, const void *pointer)
{
    LockedPixelBuffer *locked = info;
    CVPixelBufferUnlockBaseAddress(locked->buffer, locked->lockFlags);
}

static void releaseLockedInfo(void *info)
{
    LockedPixelBuffer *locked = info;
    CVPixelBufferRelease(locked->buffer);
    free(locked);
}

CGDataProviderRef CGEDataProviderCreateWithPixelBuffer(CVPixelBufferRef buffer, CVOptionFlags lockFlags)
{
    size_t size = CVEPixelBufferGetDataSize(buffer);
    if (!size)
        return NULL;
    CGDataProviderRef provider;
    if (lockFlags == kCVPixelBufferLock_ReadOnly) {
        CGDataProviderDirectCallbacks callbacks = { 0, getReadOnlyBytes, releaseReadOnlyBytes, NULL, releaseReadOnlyInfo };
        if (!(provider = CGDataProviderCreateDirect(buffer, size, &callbacks)))
            return NULL;
    }
    else {
        LockedPixelBuffer *locked = malloc(sizeof(*locked));
        if (!locked)
            return NULL;
        locked->buffer = buffer;
        locked->lockFlags = lockFlags;
        CGDataProviderDirectCallbacks callbacks = { 0, getLockedBytes, releaseLockedBytes, NULL, releaseLockedInfo };
        if (!(provider = CGDataProviderCreateDirect(locked, size, &callbacks))) {
            free(locked);
            return NULL;
        }
    }
    CVPixelBufferRetain(buffer);
    return provider;
}

typedef struct {
    CFMutableDataRef data;
    CFIndex offset;
} DataAndOffset;

static size_t putBytes(void *info, const void *buffer, size_t count)
{
    DataAndOffset *d = info;
    size_t left = CFDataGetLength(d->data) - d->offset;
    size_t replaced = count < left ? count : left;
    size_t appended = count > left ? count - left : 0;
    if (replaced)
        CFDataReplaceBytes(d->data, CFRangeMake(d->offset, replaced), buffer, replaced);
    if (appended)
        CFDataAppendBytes(d->data, (const UInt8 *)buffer + replaced, appended);
    d->offset += count;
    return count;
}

static void releaseConsumer(void *info)
{
    DataAndOffset *d = info;
    CFIndex length = CFDataGetLength(d->data);
    if (length != d->offset)
        CFDataDeleteBytes(d->data, CFRangeMake(d->offset, length - d->offset));
    CFRelease(d->data);
    CFAllocatorDeallocate(kCFAllocatorDefault, d);
}

CGDataConsumerRef CGEDataConsumerCreateWithCFDataAndOffset(CFMutableDataRef data, CFIndex offset)
{
    if (CFDataGetLength(data) < offset)
        CFDataSetLength(data, offset);
    DataAndOffset *d = CFAllocatorAllocate(kCFAllocatorDefault, sizeof(*d), 0);
    d->data = data;
    d->offset = offset;
    CGDataConsumerCallbacks callbacks = { putBytes, releaseConsumer };
    CGDataConsumerRef consumer = CGDataConsumerCreate(d, &callbacks);
    if (!consumer)
        CFAllocatorDeallocate(kCFAllocatorDefault, d);
    else
        CFRetain(data);
    return consumer;
}

CGImageRef CGEImageCreateAsBitmapContext(CGContextRef context, CGDataProviderRef provider, const CGFloat *decode,
                                         bool shouldInterpolate, CGColorRenderingIntent intent)
{
    CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
    if (!space)
        return NULL;
    return CGImageCreate(CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context),
                         CGBitmapContextGetBitsPerComponent(context), CGBitmapContextGetBitsPerPixel(context),
                         CGBitmapContextGetBytesPerRow(context), space, CGBitmapContextGetBitmapInfo(context),
                         provider, decode, shouldInterpolate, intent);
}

static CGColorSpaceRef createDeviceSpace(CGColorSpaceModel model)
{
    switch (model) {
    case kCGColorSpaceModelMonochrome:
        return CGColorSpaceCreateDeviceGray();
    case kCGColorSpaceModelRGB:
        return CGColorSpaceCreateDeviceRGB();
    case kCGColorSpaceModelCMYK:
        return CGColorSpaceCreateDeviceCMYK();
    default:
        return NULL;
    }
}

CGImageRef CGEImageCreateAsPixelFormatType(size_t width, size_t height, OSType type, size_t bytesPerRow,
                                           CGColorSpaceRef space, int alphaMode, CGDataProviderRef provider,
                                           const CGFloat *decode, bool shouldInterpolate,
                                           CGColorRenderingIntent intent)
{
    size_t bitsPerComponent = 0, bitsPerPixel = 0;
    CGColorSpaceModel model = 0;
    CGBitmapInfo bitmapInfo = 0;
    Boolean invertedDecode = false;
    if (!CVEPixelFormatTypeIsCGImageCompatible(type, alphaMode, &bitsPerComponent, &bitsPerPixel,
                                               space ? NULL : &model, &bitmapInfo, &invertedDecode))
        return NULL;
    CGColorSpaceRef imageSpace = space;
    if (!imageSpace && !(imageSpace = createDeviceSpace(model)))
        return NULL;

    // Formats stored inverted get their decode swapped.
    CGFloat *imageDecode = (CGFloat *)decode;
    if (invertedDecode && !space) {
        size_t components = CGColorSpaceGetNumberOfComponents(imageSpace);
        switch (bitmapInfo & kCGBitmapAlphaInfoMask) {
        case kCGImageAlphaPremultipliedLast:
        case kCGImageAlphaPremultipliedFirst:
        case kCGImageAlphaLast:
        case kCGImageAlphaFirst:
        case kCGImageAlphaOnly:
            components++;
            break;
        case kCGImageAlphaNone:
        case kCGImageAlphaNoneSkipLast:
        case kCGImageAlphaNoneSkipFirst:
            break;
        default:
            CFShow(CFSTR("Invalid / unsupported image alpha info."));
            break;
        }
        if (!(imageDecode = malloc(components * 2 * sizeof(*imageDecode)))) {
            CGColorSpaceRelease(imageSpace);
            return NULL;
        }
        for (size_t i = 0; i < components; i++) {
            imageDecode[2 * i] = decode ? decode[2 * i + 1] : 1;
            imageDecode[2 * i + 1] = decode ? decode[2 * i] : 0;
        }
    }
    CGImageRef image = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, imageSpace,
                                     bitmapInfo, provider, imageDecode, shouldInterpolate, intent);
    if (!space)
        CGColorSpaceRelease(imageSpace);
    if (imageDecode != decode)
        free(imageDecode);
    return image;
}

static int alphaModeOfPixelBuffer(CVPixelBufferRef buffer)
{
    int alphaMode = 0;
    CFNumberRef number = CVBufferGetAttachment(buffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, NULL);
    if (number)
        CFNumberGetValue(number, kCFNumberSInt32Type, &alphaMode);
    return alphaMode;
}

CGImageRef CGEImageCreateAsPixelBuffer(CVPixelBufferRef buffer, CGDataProviderRef provider, const CGFloat *decode,
                                       bool shouldInterpolate, CGColorRenderingIntent intent)
{
    if (CVPixelBufferIsPlanar(buffer))
        return NULL;
    int alphaMode = alphaModeOfPixelBuffer(buffer);
    return CGEImageCreateAsPixelFormatType(CVPixelBufferGetWidth(buffer), CVPixelBufferGetHeight(buffer),
                                           CVPixelBufferGetPixelFormatType(buffer),
                                           CVPixelBufferGetBytesPerRow(buffer), CVImageBufferGetColorSpace(buffer),
                                           alphaMode, provider, decode, shouldInterpolate, intent);
}

CGImageRef CGEImageCreateWithPixelBuffer(CVPixelBufferRef buffer, CVOptionFlags lockFlags, const CGFloat *decode,
                                         bool shouldInterpolate, CGColorRenderingIntent intent)
{
    CGDataProviderRef provider = CGEDataProviderCreateWithPixelBuffer(buffer, lockFlags);
    if (!provider)
        return NULL;
    CGImageRef image = CGEImageCreateAsPixelBuffer(buffer, provider, decode, shouldInterpolate, intent);
    CGDataProviderRelease(provider);
    return image;
}

CGImageRef CGEImageMaskCreateAsBitmapContext(CGContextRef context, CGDataProviderRef provider, const CGFloat *decode,
                                             bool shouldInterpolate)
{
    size_t bitsPerPixel = CGBitmapContextGetBitsPerPixel(context);
    if (CGColorSpaceGetNumberOfComponents(CGBitmapContextGetColorSpace(context)) >= 2) {
        // Alpha first in memory.
        CGBitmapInfo info = CGBitmapContextGetBitmapInfo(context);
        CGBitmapInfo order = info & kCGBitmapByteOrderMask;
        CGImageAlphaInfo alpha = (CGImageAlphaInfo)(info & kCGBitmapAlphaInfoMask);
        if (order == kCGBitmapByteOrder16Little)
            return NULL;
        if (order == kCGBitmapByteOrder32Little) {
            if (bitsPerPixel != 32 || (alpha != kCGImageAlphaPremultipliedLast && alpha != kCGImageAlphaLast))
                return NULL;
        }
        else if (alpha != kCGImageAlphaPremultipliedFirst && alpha != kCGImageAlphaFirst)
            return NULL;
    }
    return CGImageMaskCreate(CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context),
                             CGBitmapContextGetBitsPerComponent(context), CGBitmapContextGetBitsPerPixel(context),
                             CGBitmapContextGetBytesPerRow(context), provider, decode, shouldInterpolate);
}

CGImageRef CGEImageMaskCreateAsPixelFormatType(size_t width, size_t height, OSType type, size_t bytesPerRow,
                                               CGDataProviderRef provider, const CGFloat *decode,
                                               bool shouldInterpolate)
{
    size_t bitsPerComponent = 0, bitsPerPixel = 0;
    CGColorSpaceModel model = 0;
    CGBitmapInfo info = 0;
    Boolean invertedDecode = false;
    if (!CVEPixelFormatTypeIsCGImageCompatible(type, 0, &bitsPerComponent, &bitsPerPixel, &model, &info,
                                               &invertedDecode))
        return NULL;
    if (model != kCGColorSpaceModelMonochrome) {
        // Alpha first in memory.
        CGBitmapInfo order = info & kCGBitmapByteOrderMask;
        CGImageAlphaInfo alpha = (CGImageAlphaInfo)(info & kCGBitmapAlphaInfoMask);
        if ((model != kCGColorSpaceModelRGB && model != kCGColorSpaceModelCMYK) || order == kCGBitmapByteOrder16Little)
            return NULL;
        if (order == kCGBitmapByteOrder32Little) {
            if (bitsPerPixel != 32 || alpha != kCGImageAlphaLast)
                return NULL;
        }
        else if (alpha != kCGImageAlphaFirst)
            return NULL;
    }
    CGFloat inverted[2];
    if (invertedDecode) {
        inverted[0] = decode ? decode[1] : 1;
        inverted[1] = decode ? decode[0] : 0;
        decode = inverted;
    }
    return CGImageMaskCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, provider, decode,
                             shouldInterpolate);
}

CGImageRef CGEImageMaskCreateAsPixelBuffer(CVPixelBufferRef buffer, CGDataProviderRef provider, const CGFloat *decode,
                                           bool shouldInterpolate)
{
    if (CVPixelBufferIsPlanar(buffer))
        return NULL;
    // (Of a buffer with alpha info -1 there's no mask.)
    if (CVBufferGetAttachment(buffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, NULL) &&
        alphaModeOfPixelBuffer(buffer) == -1)
        return NULL;
    return CGEImageMaskCreateAsPixelFormatType(CVPixelBufferGetWidth(buffer), CVPixelBufferGetHeight(buffer),
                                               CVPixelBufferGetPixelFormatType(buffer),
                                               CVPixelBufferGetBytesPerRow(buffer), provider, decode,
                                               shouldInterpolate);
}

CGImageRef CGEImageMaskCreateWithPixelBuffer(CVPixelBufferRef buffer, CVOptionFlags lockFlags, const CGFloat *decode,
                                             bool shouldInterpolate)
{
    CGDataProviderRef provider = CGEDataProviderCreateWithPixelBuffer(buffer, lockFlags);
    if (!provider)
        return NULL;
    CGImageRef image = CGEImageMaskCreateAsPixelBuffer(buffer, provider, decode, shouldInterpolate);
    CGDataProviderRelease(provider);
    return image;
}

void CGEImageShowAs(CGImageRef image, CFStringRef name, const void *object)
{
    if (!image)
        return;
    CFURLRef url = CFEURLCreateTemporaryFileURLForObject(kUTTypePNG, name, object);
    if (!url)
        return;
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    if (destination) {
        CGImageRef shown;
        if (!CGImageIsMask(image))
            shown = CGImageRetain(image);
        else {
            // Masks as gray images.
            shown = NULL;
            CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
            if (gray) {
                const CGFloat *maskDecode = CGImageGetDecode(image);
                CGFloat decode[2] = { 1, 0 };
                if (maskDecode) {
                    decode[0] = maskDecode[1];
                    decode[1] = maskDecode[0];
                }
                shown = CGImageCreate(CGImageGetWidth(image), CGImageGetHeight(image),
                                      CGImageGetBitsPerComponent(image), CGImageGetBitsPerPixel(image),
                                      CGImageGetBytesPerRow(image), gray, CGImageGetBitmapInfo(image),
                                      CGImageGetDataProvider(image), decode, CGImageGetShouldInterpolate(image),
                                      kCGRenderingIntentDefault);
                CGColorSpaceRelease(gray);
            }
        }
        if (shown) {
            CGImageDestinationAddImage(destination, shown, NULL);
            CGImageRelease(shown);
            if (CGImageDestinationFinalize(destination))
                [[NSWorkspace sharedWorkspace] openURL:(NSURL *)url];
        }
        CFRelease(destination);
    }
    CFRelease(url);
}

void CGEImageShow(CGImageRef image)
{
    if (image)
        CGEImageShowAs(image, CFSTR("CGImageRef"), image);
}
