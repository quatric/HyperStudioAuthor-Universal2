#import "HSMoviePixelBufferRenderer.h"
#import "HSFunctions.h"

// A movie renderer drawing with Quartz: frames come as ARGB pixel buffers in
// sRGB and are drawn as images. Drawing with a transparent color copies the
// visible part of the frame into a BGRA buffer (from a pool kept at that
// size) with the color keyed out.

// Tolerances this high key out every color.
static const double kHSMoviePixelBufferRendererFullTolerance = 0.9980392156862745;

@implementation HSMoviePixelBufferRenderer

- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2 withTransparentColor:(id)aColor hueTolerance:(double)aTolerance chromaTolerance:(double)aTolerance2 lightnessTolerance:(double)aTolerance3
{
    NSColor *color = [aColor colorUsingColorSpace:_workingColorSpace];
    if (color == nil) {
        [self drawCurrentFrameInRect:aRect fromRelativeRect:aRect2];
        return;
    }
    if (aTolerance3 >= kHSMoviePixelBufferRendererFullTolerance && aTolerance2 >= kHSMoviePixelBufferRendererFullTolerance
        && aTolerance >= kHSMoviePixelBufferRendererFullTolerance)
        return;
    [self HSMoviePixelBufferRenderer_drawFramePixelBuffer:[self currentFrameImageBuffer] inRect:aRect fromRelativeRect:aRect2 withTransparentColor:color hueTolerance:aTolerance chromaTolerance:aTolerance2 lightnessTolerance:aTolerance3];
}

// Original quirk kept: a color with no sRGB equivalent keys out black (the
// components of nil are zero) instead of drawing the frame as it is.
- (void)drawFramePixelBuffer:(struct __CVBuffer *)aBuffer inRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2 withTransparentColor:(id)aColor hueTolerance:(double)aTolerance chromaTolerance:(double)aTolerance2 lightnessTolerance:(double)aTolerance3
{
    NSColor *color = [aColor colorUsingColorSpace:_workingColorSpace];
    if (color == nil || aTolerance3 < kHSMoviePixelBufferRendererFullTolerance || aTolerance2 < kHSMoviePixelBufferRendererFullTolerance
        || aTolerance < kHSMoviePixelBufferRendererFullTolerance)
        [self HSMoviePixelBufferRenderer_drawFramePixelBuffer:aBuffer inRect:aRect fromRelativeRect:aRect2 withTransparentColor:color hueTolerance:aTolerance chromaTolerance:aTolerance2 lightnessTolerance:aTolerance3];
}

// Original quirk kept: the clip is left on the current context.
- (void)HSMoviePixelBufferRenderer_drawFramePixelBuffer:(struct __CVBuffer *)aBuffer inRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2 withTransparentColor:(id)aColor hueTolerance:(double)aTolerance chromaTolerance:(double)aTolerance2 lightnessTolerance:(double)aTolerance3
{
    if (!(aRect2.size.width > 0 && aRect2.size.height > 0) || aBuffer == NULL)
        return;
    size_t bufferWidth = CVPixelBufferGetWidth(aBuffer);
    size_t bufferHeight = CVPixelBufferGetHeight(aBuffer);
    if (bufferWidth == 0 || bufferHeight == 0)
        return;
    CGRect source = CGRectMake(aRect2.origin.x * bufferWidth, aRect2.origin.y * bufferHeight,
                               aRect2.size.width * bufferWidth, aRect2.size.height * bufferHeight);
    CGRect integral = CGRectIntegral(source);
    long x = lroundf(integral.origin.x);
    long y = lroundf(integral.origin.y);
    size_t width = lroundf(integral.size.width);
    size_t height = lroundf(integral.size.height);
    if ([self HSMoviePixelBufferRenderer_pixelBufferPoolWithWidth:width height:height] == NULL)
        return;
    CVPixelBufferRef copy = NULL;
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _pixelBufferPool, &copy);
    if (copy == NULL)
        return;
    CVBufferPropagateAttachments(aBuffer, copy);
    CVBufferRemoveAttachment(copy, (CFStringRef)kCVEImageBufferOpaquenessKey);
    if (CVPixelBufferLockBaseAddress(copy, 0) != kCVReturnSuccess) {
        CVPixelBufferRelease(copy);
        return;
    }
    if (CVPixelBufferLockBaseAddress(aBuffer, kCVPixelBufferLock_ReadOnly) != kCVReturnSuccess) {
        CVPixelBufferUnlockBaseAddress(copy, 0);
        CVPixelBufferRelease(copy);
        return;
    }
    CGFloat components[4] = {0, 0, 0, 0};
    [aColor getComponents:components];
    // Pixel buffers run top down.
    size_t sourceRowBytes = CVPixelBufferGetBytesPerRow(aBuffer);
    const UInt8 *sourceBytes = (const UInt8 *)CVPixelBufferGetBaseAddress(aBuffer) + (bufferHeight - y - height) * sourceRowBytes + x * 4;
    UInt8 red = lroundf(components[0] * 255.0);
    UInt8 green = lroundf(components[1] * 255.0);
    UInt8 blue = lroundf(components[2] * 255.0);
    OSType format = CVPixelBufferGetPixelFormatType(aBuffer);
    if (format == kCVPixelFormatType_32BGRA)
        HSBitmapBGRA8888PremultipliedCopyRemovingColorFromBGRA8888(CVPixelBufferGetBaseAddress(copy), CVPixelBufferGetBytesPerRow(copy), sourceBytes, sourceRowBytes,
                                                                   width, height, red, green, blue, aTolerance, aTolerance2, aTolerance3);
    else if (format == kCVPixelFormatType_32ARGB)
        HSBitmapBGRA8888PremultipliedCopyRemovingColorFromARGB8888(CVPixelBufferGetBaseAddress(copy), CVPixelBufferGetBytesPerRow(copy), sourceBytes, sourceRowBytes,
                                                                   width, height, red, green, blue, aTolerance, aTolerance2, aTolerance3);
    CVPixelBufferUnlockBaseAddress(aBuffer, kCVPixelBufferLock_ReadOnly);
    CVPixelBufferUnlockBaseAddress(copy, 0);
    CGImageRef image = CGEImageCreateWithPixelBuffer(copy, 1, NULL, false, kCGRenderingIntentPerceptual);
    CVPixelBufferRelease(copy);
    if (image == NULL)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextClipToRect(context, NSRectToCGRect(aRect));
    CGFloat scaleX = aRect.size.width / source.size.width;
    CGFloat scaleY = aRect.size.height / source.size.height;
    CGContextDrawImage(context, CGRectMake(aRect.origin.x - (source.origin.x - x) * scaleX, aRect.origin.y - (source.origin.y - y) * scaleY,
                                           width * scaleX, height * scaleY), image);
    CGImageRelease(image);
}

// A pool of BGRA buffers of the size, made again when the size changes.
- (struct __CVPixelBufferPool *)HSMoviePixelBufferRenderer_pixelBufferPoolWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight
{
    if (_pixelBufferPool == NULL) {
        NSDictionary *propagated = [NSDictionary dictionaryWithObject:(id)_workingCGColorSpace forKey:(NSString *)kCVImageBufferCGColorSpaceKey];
        NSDictionary *nonPropagated = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], kCVEPixelBufferAlphaInfoKey, nil];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
            [NSNumber numberWithUnsignedLong:aWidth], kCVPixelBufferWidthKey,
            [NSNumber numberWithUnsignedLong:aHeight], kCVPixelBufferHeightKey,
            nonPropagated, kCVBufferNonPropagatedAttachmentsKey,
            propagated, kCVBufferPropagatedAttachmentsKey,
            kCFBooleanTrue, kCVPixelBufferCGImageCompatibilityKey, nil];
        if (attributes != nil)
            CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (CFDictionaryRef)attributes, &_pixelBufferPool);
    }
    // Fix: the original goes on to copy the attributes of a pool it failed to make.
    if (_pixelBufferPool == NULL)
        return NULL;
    NSDictionary *attributes = (NSDictionary *)CVPixelBufferPoolGetPixelBufferAttributes(_pixelBufferPool);
    NSUInteger width = [[attributes objectForKey:(NSString *)kCVPixelBufferWidthKey] unsignedLongValue];
    NSUInteger height = [[attributes objectForKey:(NSString *)kCVPixelBufferHeightKey] unsignedLongValue];
    if (width == aWidth && height == aHeight)
        return _pixelBufferPool;
    CFMutableDictionaryRef newAttributes = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, CFDictionaryGetCount((CFDictionaryRef)attributes), (CFDictionaryRef)attributes);
    if (newAttributes == NULL)
        return _pixelBufferPool;
    CVPixelBufferPoolRelease(_pixelBufferPool);
    _pixelBufferPool = NULL;
    NSNumber *newWidth = width == aWidth ? nil : [NSNumber numberWithUnsignedLong:aWidth];
    NSNumber *newHeight = height == aHeight ? nil : [NSNumber numberWithUnsignedLong:aHeight];
    if (newWidth != nil)
        CFDictionarySetValue(newAttributes, kCVPixelBufferWidthKey, newWidth);
    if (newHeight != nil)
        CFDictionarySetValue(newAttributes, kCVPixelBufferHeightKey, newHeight);
    CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, newAttributes, &_pixelBufferPool);
    CFRelease(newAttributes);
    return _pixelBufferPool;
}

- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2
{
    if (!(aRect2.size.width > 0 && aRect2.size.height > 0) || [self currentFrameImage] == NULL)
        return;
    if (CGImageGetWidth(_currentFrameImage) == 0 || CGImageGetHeight(_currentFrameImage) == 0)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextClipToRect(context, NSRectToCGRect(aRect));
    CGFloat width = aRect.size.width / aRect2.size.width;
    CGFloat height = aRect.size.height / aRect2.size.height;
    CGContextDrawImage(context, CGRectMake(aRect.origin.x - aRect2.origin.x * width, aRect.origin.y - aRect2.origin.y * height, width, height),
                       _currentFrameImage);
}

- (struct CGImage *)currentFrameImage
{
    if (_currentFrameImage == NULL) {
        CVPixelBufferRef buffer = [self currentFrameImageBuffer];
        if (buffer != NULL)
            _currentFrameImage = CGEImageCreateWithPixelBuffer(buffer, 1, NULL, false, kCGRenderingIntentPerceptual);
    }
    return _currentFrameImage;
}

- (void)invalidateCurrentFrame
{
    CGImageRelease(_currentFrameImage);
    _currentFrameImage = NULL;
    [super invalidateCurrentFrame];
}

- (void)didUpdateCurrentFrameImageBuffer:(struct __CVBuffer *)aBuffer
{
    [super didUpdateCurrentFrameImageBuffer:aBuffer];
    if (aBuffer != NULL && CVBufferGetAttachment(aBuffer, kCVImageBufferCGColorSpaceKey, NULL) == NULL)
        CVBufferSetAttachment(aBuffer, kCVImageBufferCGColorSpaceKey, _workingCGColorSpace, kCVAttachmentMode_ShouldPropagate);
}

- (void)dealloc
{
    [_workingColorSpace release];
    CGColorSpaceRelease(_workingCGColorSpace);
    CVPixelBufferPoolRelease(_pixelBufferPool);
    CGImageRelease(_currentFrameImage);
    [super dealloc];
}

- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage
{
    NSDictionary *pixelBufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey,
        kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey,
        kCFBooleanTrue, kCVPixelBufferCGImageCompatibilityKey,
        kCFBooleanTrue, kCVPixelBufferOpenGLCompatibilityKey, nil];
    if (pixelBufferAttributes != nil) {
        _workingCGColorSpace = CGEColorSpaceCreateWithName((CFStringRef)kCGEColorSpaceSRGB);
        if (_workingCGColorSpace != NULL) {
            _workingColorSpace = [[NSColorSpace sRGBColorSpace] retain];
            NSDictionary *options = nil;
            if (_workingColorSpace != nil)
                options = [NSDictionary dictionaryWithObjectsAndKeys:pixelBufferAttributes, kQTVisualContextPixelBufferAttributesKey,
                                        (id)_workingCGColorSpace, kQTVisualContextOutputColorSpaceKey, nil];
            QTVisualContextRef context = NULL;
            if (options != nil && QTPixelBufferContextCreate(kCFAllocatorDefault, (CFDictionaryRef)options, &context) == noErr && context != NULL) {
                self = [super initWithQTMovie:aMovie storage:aStorage visualContext:context];
                // Fix: the original keeps its own reference to the context too.
                QTVisualContextRelease(context);
                return self;
            }
        }
    }
    [super release];
    return nil;
}

- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage visualContext:(struct OpaqueQTVisualContext *)aContext
{
    [super release];
    return nil;
}

@end
