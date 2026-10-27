#import "HSCoreImageRenderCache.h"
@implementation HSCoreImageRenderCache
+ (id)defaultValidnessEvaluator
{
    return [HSBitmapRenderCacheValidnessEvaluator validnessEvaluatorForScaling:YES skewing:YES rotation:YES offset:YES];
}
// The image's rect drawn at the origin through the context's Core Image
// context.
- (void)drawRegion:(id)aRegion
{
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    CGContextRef port = [context CGContext];
    CGContextSaveGState(port);
    CGContextConcatCTM(port, [self drawingAffineTransform]);
    CIContext *ciContext = [context CIContext];
    if (ciContext != nil)
        [ciContext drawImage:_image atPoint:CGPointZero fromRect:_imageRect];
    CGContextRestoreGState(port);
}
- (BOOL)intersectsWithRegion:(id)aRegion
{
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    [region applyAffineTransform:[self affineTransform]];
    return [region intersectsRect:_imageRect];
}
// Containment with a tolerance of 0.05% of the larger extent on each axis.
- (BOOL)containsRegion:(id)aRegion
{
    HSMutableRegion *region = [[aRegion mutableCopy] autorelease];
    [region applyAffineTransform:[self affineTransform]];
    NSRect bounds = [region boundingRect];
    float extentY = fabs(bounds.origin.y) + bounds.size.height;
    float imageExtentY = fabs(_imageRect.origin.y) + _imageRect.size.height;
    imageExtentY = imageExtentY != 0 ? fabsf(imageExtentY) : 1.0f;
    extentY = extentY != 0 ? fabsf(extentY) : 1.0f;
    float toleranceY = MAX(extentY, imageExtentY);
    float extentX = fabs(bounds.origin.x) + bounds.size.width;
    float imageExtentX = fabs(_imageRect.origin.x) + _imageRect.size.width;
    imageExtentX = imageExtentX != 0 ? fabsf(imageExtentX) : 1.0f;
    extentX = extentX != 0 ? fabsf(extentX) : 1.0f;
    float toleranceX = MAX(extentX, imageExtentX);
    return !(bounds.origin.x < _imageRect.origin.x - toleranceX * 0.0005
             || _imageRect.origin.x + _imageRect.size.width + toleranceX * 0.0005 < bounds.origin.x + bounds.size.width
             || bounds.origin.y < _imageRect.origin.y - toleranceY * 0.0005)
        && bounds.origin.y + bounds.size.height <= _imageRect.origin.y + _imageRect.size.height + toleranceY * 0.0005;
}
- (void)dealloc
{
    [_image release];
    [super dealloc];
}
- (id)initWithCoreImage:(id)aImage rect:(NSRect)aRect renderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator
{
    self = [super initWithRenderLayer:aLayer affineTransform:aTransform temporaryValidness:aValidness persistentValidness:aValidness2 validnessEvaluator:aEvaluator];
    if (self != nil) {
        _image = [aImage retain];
        _imageRect = aRect;
    }
    return self;
}
// Not available: use the initializer with an image.
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator
{
    [self release];
    return nil;
}
@end
