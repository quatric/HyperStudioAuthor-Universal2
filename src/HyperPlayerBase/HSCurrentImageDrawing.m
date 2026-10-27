#import "HSCurrentImageDrawing.h"
#import "CGEBitmapContext.h"
#import "CGEImage.h"
#import "HSImageCropApplier.h"
#import "HSMutableRegion.h"
#import "NSImage+HSImageSize.h"

// Renders the current look of an image object (crop and effects included) into pixel buffers, CGImages or PNG data.
@implementation HSCurrentImageDrawing
+ (id)pngRepresentationOfImage:(struct CGImage *)aImage
{
    if (aImage == NULL)
        return nil;
    CFMutableDataRef data = CFDataCreateMutable(NULL, 0);
    if (data == NULL)
        return nil;
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(data, kUTTypePNG, 1, NULL);
    if (destination != NULL) {
        CGImageDestinationAddImage(destination, aImage, NULL);
        if (!CGImageDestinationFinalize(destination)) {
            CFRelease(data);
            data = NULL;
        }
        CFRelease(destination);
    }
    return [(id)data autorelease];
}
+ (id)drawingForImageObject:(id)aObject
{
    return [[[self alloc] initWithImageObject:aObject] autorelease];
}
- (id)optimizedCurrentImagePNGRepresentationOfSize:(NSSize *)aSize
{
    NSSize size = [self requiredSizeForOptimizedImage];
    id png = [[self class] pngRepresentationOfImage:[self currentCGImageWithPixelSize:NSMakeSize(ceilf(size.width), ceilf(size.height))]];
    if (png != nil && aSize != NULL)
        *aSize = size;
    return png;
}
- (id)currentImagePNGRepresentationOfSize:(NSSize *)aSize
{
    return [[self class] pngRepresentationOfImage:[self currentCGImageOfSize:aSize]];
}
- (id)currentImagePNGRepresentationWithPixelSize:(NSSize)aSize
{
    return [[self class] pngRepresentationOfImage:[self currentCGImageWithPixelSize:aSize]];
}
- (struct CGImage *)currentCGImageOfSize:(NSSize *)aSize isFlippedHorizontally:(BOOL)aHorizontally isFlippedVertically:(BOOL)aVertically
{
    CVPixelBufferRef buffer = [self currentCVPixelBufferOfSize:aSize isFlippedHorizontally:aHorizontally isFlippedVertically:aVertically];
    CGImageRef image = CGEImageCreateWithPixelBuffer(buffer, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
    return (CGImageRef)[(id)image autorelease];
}
- (struct CGImage *)currentCGImageOfSize:(NSSize *)aSize
{
    return [self currentCGImageOfSize:aSize isFlippedHorizontally:NO isFlippedVertically:NO];
}
- (struct CGImage *)currentCGImageWithPixelSize:(NSSize)aSize
{
    CVPixelBufferRef buffer = [self currentCVPixelBufferWithPixelSize:aSize];
    CGImageRef image = CGEImageCreateWithPixelBuffer(buffer, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
    return (CGImageRef)[(id)image autorelease];
}
// *aSize receives the size of the drawn area in user space.
- (struct __CVBuffer *)currentCVPixelBufferOfSize:(NSSize *)aSize isFlippedHorizontally:(BOOL)aHorizontally isFlippedVertically:(BOOL)aVertically
{
    CVPixelBufferRef buffer = [self currentCVPixelBufferWithPixelSize:[self requiredSizeForNotOptimizedImage] isFlippedHorizontally:aHorizontally isFlippedVertically:aVertically];
    if (buffer == NULL)
        return NULL;
    if (aSize != NULL)
        *aSize = [self currentImageAndObjectBoundsUnionRect].size;
    return buffer;
}
- (struct __CVBuffer *)currentCVPixelBufferOfSize:(NSSize *)aSize
{
    return [self currentCVPixelBufferOfSize:aSize isFlippedHorizontally:NO isFlippedVertically:NO];
}
// Draws the union of the image and object bounds scaled to aSize pixels into an autoreleased ARGB buffer.
- (struct __CVBuffer *)currentCVPixelBufferWithPixelSize:(NSSize)aSize isFlippedHorizontally:(BOOL)aHorizontally isFlippedVertically:(BOOL)aVertically
{
    NSRect bounds = [self currentImageAndObjectBoundsUnionRect];
    if (NSIsEmptyRect(bounds))
        return NULL;
    HSRegion *region = [HSRegion regionWithRect:bounds];
    if (region == nil)
        return NULL;
    size_t width = aSize.width > 0.0 ? lroundf(ceilf(aSize.width)) : 0;
    size_t height = aSize.height > 0.0 ? lroundf(ceilf(aSize.height)) : 0;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (id)kCFBooleanTrue, (id)kCVPixelBufferCGBitmapContextCompatibilityKey,
                                (id)kCFBooleanTrue, (id)kCVPixelBufferCGImageCompatibilityKey,
                                [NSNumber numberWithInt:16], (id)kCVPixelBufferBytesPerRowAlignmentKey, nil];
    CVPixelBufferRef buffer = NULL;
    if (CVPixelBufferCreate(kCFAllocatorDefault, width, height, k32ARGBPixelFormat, (CFDictionaryRef)attributes, &buffer) != kCVReturnSuccess)
        return NULL;
    [(id)buffer autorelease];
    CVBufferSetAttachment(buffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, [NSNumber numberWithInt:kCGImageAlphaPremultipliedFirst], kCVAttachmentMode_ShouldNotPropagate);
    CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(buffer, 0);
    if (context == NULL)
        return buffer;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:YES];
    if (graphicsContext != nil) {
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:graphicsContext];
        if ([[self delegate] respondsToSelector:@selector(imageObjectDrawing:willDrawImageInContext:)])
            [[self delegate] imageObjectDrawing:self willDrawImageInContext:context];
        CGRect pixelRect = CGRectIntegral(CGRectMake(CGPointZero.x, CGPointZero.y, aSize.width, aSize.height));
        CGContextClearRect(context, CGRectInset(pixelRect, -1.0, -1.0));
        CGFloat scaleX = bounds.size.width != 0.0 ? aSize.width / bounds.size.width : 1.0;
        CGFloat scaleY = bounds.size.height != 0.0 ? aSize.height / bounds.size.height : 1.0;
        CGAffineTransform transform = CGAffineTransformMake(scaleX, 0.0, 0.0, scaleY,
                                                            CGPointZero.x - scaleX * bounds.origin.x,
                                                            CGPointZero.y - scaleY * bounds.origin.y);
        if (aHorizontally) {
            transform.a = -transform.a;
            transform.tx = aSize.width - transform.tx;
        }
        if (aVertically) {
            transform.d = -transform.d;
            transform.ty = aSize.height - transform.ty;
        }
        CGContextConcatCTM(context, transform);
        [[self renderer] drawRegion:region withDelegate:nil];
        [NSGraphicsContext restoreGraphicsState];
    }
    [pool release];
    CGContextRelease(context);
    return buffer;
}
- (struct __CVBuffer *)currentCVPixelBufferWithPixelSize:(NSSize)aSize
{
    return [self currentCVPixelBufferWithPixelSize:aSize isFlippedHorizontally:NO isFlippedVertically:NO];
}
// Vector images draw at the larger of their pixel size and the bounds size.
- (NSSize)requiredSizeForNotOptimizedImage
{
    NSSize size = [self requiredSizeForNotOptimizedNotVectorImage];
    if ([[[self imageObjectAttributes] image] isHyperVectorImage]) {
        NSSize boundsSize = [self currentImageAndObjectBoundsUnionRect].size;
        if (size.width * size.height <= boundsSize.width * boundsSize.height)
            size = boundsSize;
    }
    return size;
}
// Bitmaps draw at the smaller of their pixel size and the bounds size.
- (NSSize)requiredSizeForOptimizedImage
{
    NSSize size = [self currentImageAndObjectBoundsUnionRect].size;
    if (![[[self imageObjectAttributes] image] isHyperVectorImage]) {
        NSSize pixelSize = [self requiredSizeForNotOptimizedNotVectorImage];
        if (pixelSize.width * pixelSize.height <= size.width * size.height)
            size = pixelSize;
    }
    return size;
}
// The image's pixel size relative to its visible (cropped) part, grown by the effect extent.
- (NSSize)requiredSizeForNotOptimizedNotVectorImage
{
    NSSize pixelSize = [[[self imageObjectAttributes] image] hyperPixelsSize];
    NSRect relativeRect;
    if ([[self imageObjectAttributes] isEnabledCacheImage])
        relativeRect = NSMakeRect(0.0, 0.0, 1.0, 1.0);
    else
        relativeRect = [[self imageObjectAttributes] relativeImageRect];
    NSSize extent = [self currentEffectRelativeExtent];
    return NSMakeSize(extent.width * (pixelSize.width / relativeRect.size.width),
                      extent.height * (pixelSize.height / relativeRect.size.height));
}
- (NSSize)currentEffectRelativeExtent
{
    NSRect imageRect = [self imageBoundingRect];
    NSRect objectRect = [self objectBoundingRect];
    CGFloat width = imageRect.size.width / objectRect.size.width;
    if (width <= 1.0)
        width = 1.0;
    CGFloat height = imageRect.size.height / objectRect.size.height;
    if (height <= 1.0)
        height = 1.0;
    return NSMakeSize(width, height);
}
- (NSRect)currentImageAndObjectBoundsUnionRect
{
    NSRect rect = NSUnionRect([self objectBoundingRect], [self imageBoundingRect]);
    if ([[self delegate] respondsToSelector:@selector(imageObjectDrawing:imageBoundsForObjectBoundingRect:)])
        rect = [[self delegate] imageObjectDrawing:self imageBoundsForObjectBoundingRect:rect];
    return rect;
}
- (NSRect)objectBoundingRect
{
    return [[[self imageObjectAttributes] queryHyperInterface:@protocol(HSGeometryAttributes)] boundingRect];
}
- (NSRect)imageBoundingRect
{
    return [[[self renderer] boundingRegion] boundingRect];
}
- (id)renderer
{
    if (_renderer == nil) {
        id visualization = [[self imageObjectAttributes] queryHyperInterface:@protocol(HSImageObjectCropVisualization)];
        if (visualization == nil)
            visualization = [[self imageObjectAttributes] queryHyperInterface:@protocol(HSVisualization)];
        _renderer = [[visualization queryRenderer] retain];
    }
    return _renderer;
}
- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}
- (id)delegate
{
    return _delegate;
}
- (void)setImageObjectAtributes:(id)aAtributes
{
    if (_imageObjectAttributes == aAtributes)
        return;
    [_imageObjectAttributes release];
    _imageObjectAttributes = [aAtributes retain];
}
- (id)imageObjectAttributes
{
    return _imageObjectAttributes;
}
- (void)dealloc
{
    [_imageObjectAttributes release];
    [_renderer release];
    [super dealloc];
}
- (id)initWithImageObject:(id)aObject
{
    self = [super init];
    if (self != nil)
        _imageObjectAttributes = [aObject retain];
    return self;
}
@end
