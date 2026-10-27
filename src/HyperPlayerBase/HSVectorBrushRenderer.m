#import "HSVectorBrushRenderer.h"
static void HSVectorBrushRendererReleaseData(void *aInfo, const void *aData, size_t aSize)
{
    free((void *)aData);
}

// Whether a transform's scale (sx, then sy) is 1 within 0.05%.
static BOOL HSVectorBrushRendererIsUnitScale(CGFloat aScale)
{
    CGFloat magnitude = aScale != 0 ? fabs(aScale) : 1.0;
    return fabs(aScale - 1.0) <= MAX(magnitude, 1.0) * 0.0005;
}

// Draws a vector brush node's tool; unscaled, from a cached bitmap.
@implementation HSVectorBrushRenderer
- (void)HSVectorBrushRenderer_drawInContext:(struct CGContext *)aContext
{
    NSRect bounds = [_owner toolBoundingRect];
    [[_owner tool] drawWithTouchProvider:[_owner touchProvider] inContext:aContext withBounds:NSRectToCGRect(bounds)];
}
- (void)drawInRegion:(id)aRegion
{
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGAffineTransform ctm = CGContextGetCTM(context);
    CGFloat scaleX = hypot(ctm.a, ctm.b);
    if (HSVectorBrushRendererIsUnitScale(scaleX)) {
        CGFloat scaleY = (ctm.a != 0 || ctm.b != 0) ? fabs(ctm.a * ctm.d - ctm.b * ctm.c) / scaleX : hypot(ctm.c, ctm.d);
        if (HSVectorBrushRendererIsUnitScale(scaleY)) {
            CGImageRef image = [self cacheImage];
            if (image != NULL)
                CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
            return;
        }
    }
    [self HSVectorBrushRenderer_drawInContext:context];
}
- (void)invalidateCache
{
    CGImageRelease(_cacheImage);
    _cacheImage = NULL;
}
- (void)setCacheImage:(struct CGImage *)aImage
{
    if (_cacheImage != aImage) {
        CGImageRelease(_cacheImage);
        _cacheImage = aImage;
        CGImageRetain(aImage);
    }
}
- (struct CGImage *)cacheImage
{
    if (_cacheImage == NULL) {
        NSRect bounds = [_owner toolBoundingRect];
        size_t width = (size_t)ceil(bounds.size.width);
        size_t height = (size_t)ceil(bounds.size.height);
        size_t bytesPerRow = (width * 4 + 15) & ~(size_t)15;
        size_t size = bytesPerRow * height;
        void *data = malloc(size);
        if (data == NULL)
            return NULL;
        memset(data, 0, size);
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, size, HSVectorBrushRendererReleaseData);
        if (provider == NULL) {
            free(data);
            return NULL;
        }
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace != NULL) {
            CGContextRef context = CGBitmapContextCreate(data, width, height, 8, bytesPerRow, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
            CGColorSpaceRelease(colorSpace);
            if (context != NULL) {
                [self HSVectorBrushRenderer_drawInContext:context];
                _cacheImage = CGEImageCreateAsBitmapContext(context, provider, NULL, true, kCGRenderingIntentDefault);
                CGContextRelease(context);
            }
        }
        CGDataProviderRelease(provider);
    }
    return _cacheImage;
}
- (void)dealloc
{
    CGImageRelease(_cacheImage);
    [super dealloc];
}
- (id)initWithOwner:(id)aOwner
{
    if (aOwner == nil) {
        [self release];
        return nil;
    }
    self = [super init];
    if (self != nil)
        _owner = aOwner;
    return self;
}
@end
