#import "HSHighlightRenderLayer.h"
@implementation HSHighlightRenderLayer
// While highlighted the sublayers are always drawn through a cache (see the
// bitmap cache below), shared unless the delegate wants it exclusive.
- (void)drawRenderSublayersInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if (![_highlightAttributes isHighlightedInInteractiveMode]) {
        [super drawRenderSublayersInRegion:aRegion withDelegate:aDelegate];
        return;
    }
    id cache = nil;
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    BOOL exclusive = [[[aDelegate renderLayerWillCacheDrawingInRegion:aRegion] objectForKey:@"HSExclusiveRenderCacheKey"] boolValue];
    CGAffineTransform ctm = CGContextGetCTM([context CGContext]);
    [self cacheRenderingInRegion:aRegion forAffineTransform:ctm withTransformationIntent:NULL acceptableValidnessLimit:1.0
                        delegate:aDelegate force:YES share:!exclusive resultCache:&cache];
    [aDelegate renderLayerDidCacheDrawingInRegion:aRegion intoRenderCache:cache];
    [cache drawRegion:aRegion];
}
// The highlighted look: the sublayers are drawn into an ARGB pixel buffer
// (with the destination's colour space and profile), then the buffer's own
// alpha is used as a mask to tint the drawing with the control tint at half
// opacity. The result is a pixel buffer render cache.
- (id)createBitmapRenderCacheWithAffineTransform:(CGAffineTransform)aTransform cacheRect:(NSRect)aRect temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator delegate:(id)aDelegate share:(BOOL)aShare
{
    if (![_highlightAttributes isHighlightedInInteractiveMode])
        return [super createBitmapRenderCacheWithAffineTransform:aTransform cacheRect:aRect temporaryValidness:aValidness
                                             persistentValidness:aValidness2 validnessEvaluator:aEvaluator delegate:aDelegate share:aShare];
    CVPixelBufferRef pixelBuffer = NULL;
    id cache = nil;
    NSRect bounds = { NSZeroPoint, aRect.size };
    if (NSIsEmptyRect(bounds))
        return nil;
    aTransform.tx -= aRect.origin.x;
    aTransform.ty -= aRect.origin.y;
    HSMutableRegion *region = [HSMutableRegion regionWithRect:bounds];
    if (region == nil)
        return nil;
    [region applyAffineTransform:CGAffineTransformInvert(aTransform)];
    CGContextRef destination = [[NSGraphicsContext currentContext] CGContext];
    CFTypeRef profile = CGEContextGetAttachmentForKey(destination, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey);
    CFTypeRef colorSpace = CGEContextGetAttachmentForKey(destination, (CFStringRef)kCGEContextColorSpaceAttachmentKey);
    size_t width = aRect.size.width > 0 ? lroundf(ceilf(aRect.size.width)) : 0;
    size_t height = aRect.size.height > 0 ? lroundf(ceilf(aRect.size.height)) : 0;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (id)kCFBooleanTrue, (id)kCVPixelBufferCGBitmapContextCompatibilityKey,
                                (id)kCFBooleanTrue, (id)kCVPixelBufferCGImageCompatibilityKey, nil];
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, k32ARGBPixelFormat, (CFDictionaryRef)attributes, &pixelBuffer);
    if (pixelBuffer == NULL)
        return nil;
    CVBufferSetAttachment(pixelBuffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, [NSNumber numberWithInt:kCGImageAlphaPremultipliedFirst], kCVAttachmentMode_ShouldNotPropagate);
    if (colorSpace != NULL)
        CVBufferSetAttachment(pixelBuffer, kCVImageBufferCGColorSpaceKey, colorSpace, kCVAttachmentMode_ShouldPropagate);
    CGContextRef bitmap = CGEBitmapContextCreateWithPixelBuffer(pixelBuffer, 0);
    if (bitmap == NULL) {
        CVPixelBufferRelease(pixelBuffer);
        return nil;
    }
    CFTypeRef savedProfile = CGEContextGetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey);
    if (savedProfile != NULL)
        CFRetain(savedProfile);
    CGEContextSetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey, profile);
    CFTypeRef savedColorSpace = CGEContextGetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSpaceAttachmentKey);
    if (savedColorSpace != NULL)
        CFRetain(savedColorSpace);
    CGEContextSetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSpaceAttachmentKey, colorSpace);
    CGContextClearRect(bitmap, bounds);
    CGContextConcatCTM(bitmap, aTransform);
    [NSGraphicsContext saveGraphicsState];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithCGContext:bitmap flipped:YES];
    if (context != nil) {
        [NSGraphicsContext setCurrentContext:context];
        [super drawRenderSublayersInRegion:region withDelegate:aDelegate];
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, CVPixelBufferGetBaseAddress(pixelBuffer), CVPixelBufferGetDataSize(pixelBuffer), NULL);
        if (provider != NULL) {
            // 32-bit pixels, 8-bit samples: the mask reads each pixel's
            // alpha byte, inverted so the drawn parts get the tint.
            CGFloat decode[2] = { 1.0, 0.0 };
            CGImageRef mask = CGImageMaskCreate(width, height, 8, 32, CVPixelBufferGetBytesPerRow(pixelBuffer), provider, decode, true);
            CGDataProviderRelease(provider);
            if (mask != NULL) {
                [[[NSColor colorForControlTint:[NSColor currentControlTint]] colorWithAlphaComponent:0.5] setFill];
                CGContextConcatCTM(bitmap, CGAffineTransformInvert(aTransform));
                CGContextDrawImage(bitmap, bounds, mask);
                CGImageRelease(mask);
            }
        }
    }
    [pool release];
    [NSGraphicsContext restoreGraphicsState];
    CGEContextSetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSpaceAttachmentKey, savedColorSpace);
    if (savedColorSpace != NULL)
        CFRelease(savedColorSpace);
    CGEContextSetAttachmentForKey(bitmap, (CFStringRef)kCGEContextColorSyncProfileAttachmentKey, savedProfile);
    if (savedProfile != NULL)
        CFRelease(savedProfile);
    CGContextRelease(bitmap);
    cache = [[HSPixelBufferRenderCache alloc] initWithPixelBuffer:pixelBuffer renderLayer:self affineTransform:aTransform
                                             temporaryValidness:aValidness persistentValidness:aValidness2 validnessEvaluator:aEvaluator];
    if (aShare && cache != nil)
        [self shareRenderCache:cache withValidationAttributes:[self validationAttributesForBitmapRenderCache]];
    CVPixelBufferRelease(pixelBuffer);
    return cache;
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    if (aForce)
        return YES;
    return [_highlightAttributes isHighlightedInInteractiveMode];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    [super fillVisualizationAttributesSet:aSet];
    [aSet addAttribute:@protocol(HSInteractiveHighlightAttribute) forObject:[self hyperObject]];
}
- (void)dealloc
{
    [_highlightAttributes release];
    [_sizeAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _highlightAttributes = [[aObject queryHyperInterface:@protocol(HSHighlightAttributes)] retain];
        if (_highlightAttributes != nil) {
            _sizeAttributes = [[aObject queryHyperInterface:@protocol(HSSizeAttributes)] retain];
            if (_sizeAttributes != nil)
                return self;
        }
    }
    [self release];
    return nil;
}
@end
