#import "HSGenericImageRenderCache.h"
@implementation HSGenericImageRenderCache
- (void)drawRegion:(id)aRegion
{
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextSaveGState(context);
    CGContextConcatCTM(context, [self drawingAffineTransform]);
    [_imageRep drawAtPoint:HSPixelAlignment_pointAlignPixel(context, CGPointZero)];
    CGContextRestoreGState(context);
}
- (BOOL)intersectsWithRegion:(id)aRegion
{
    id region = [[aRegion mutableCopy] autorelease];
    [region applyAffineTransform:[self affineTransform]];
    return [region intersectsRect:(NSRect){ NSZeroPoint, [_imageRep size] }];
}
// Containment with a tolerance of 0.05% of the larger extent on each axis.
- (BOOL)containsRegion:(id)aRegion
{
    NSSize size = [_imageRep size];
    id region = [[aRegion mutableCopy] autorelease];
    [region applyAffineTransform:[self affineTransform]];
    NSRect bounds = [region boundingRect];
    NSPoint origin = NSZeroPoint;
    float extentY = fabs(bounds.origin.y) + bounds.size.height;
    float imageExtentY = fabs(origin.y) + size.height;
    imageExtentY = imageExtentY != 0 ? fabsf(imageExtentY) : 1.0f;
    extentY = extentY != 0 ? fabsf(extentY) : 1.0f;
    float toleranceY = MAX(extentY, imageExtentY);
    float extentX = fabs(bounds.origin.x) + bounds.size.width;
    float imageExtentX = fabs(origin.x) + size.width;
    imageExtentX = imageExtentX != 0 ? fabsf(imageExtentX) : 1.0f;
    extentX = extentX != 0 ? fabsf(extentX) : 1.0f;
    float toleranceX = MAX(extentX, imageExtentX);
    return !(bounds.origin.x < origin.x - toleranceX * 0.0005
             || origin.x + size.width + toleranceX * 0.0005 < bounds.origin.x + bounds.size.width
             || bounds.origin.y < origin.y - toleranceY * 0.0005)
        && bounds.origin.y + bounds.size.height <= origin.y + size.height + toleranceY * 0.0005;
}
- (void)dealloc
{
    [_imageRep release];
    [super dealloc];
}
- (id)initWithImageRep:(id)aRep renderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator
{
    self = [super initWithRenderLayer:aLayer affineTransform:aTransform temporaryValidness:aValidness persistentValidness:aValidness2 validnessEvaluator:aEvaluator];
    if (self != nil)
        _imageRep = [aRep retain];
    return self;
}
// Not available: use the initializer with an image rep.
- (id)initWithRenderLayer:(id)aLayer affineTransform:(CGAffineTransform)aTransform temporaryValidness:(CGFloat)aValidness persistentValidness:(CGFloat)aValidness2 validnessEvaluator:(id)aEvaluator
{
    [self release];
    return nil;
}
@end
