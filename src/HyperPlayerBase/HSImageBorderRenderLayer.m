#import "HSImageBorderRenderLayer.h"
// An image object's border: its unit rect path and clip paths, in the
// object's space, stroked at twice the width (half of it inside).
@implementation HSImageBorderRenderLayer
- (id)calculateBoundingRegion
{
    if ([_borderAttributes isBorderless])
        return [HSRegion region];
    return [HSRegion regionWithRect:[_imageAttributes imageRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    id hyperObject = [self hyperObject];
    [aSet addAttribute:@protocol(HSImageRectAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSBorderlessAttribute) forObject:hyperObject];
}
- (BOOL)isEmpty
{
    return [_borderAttributes isBorderless];
}
// Not drawn when the image is cached (the cache has it).
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if ([_borderAttributes isBorderless])
        return;
    if ([[_imageAttributes queryHyperInterface:@protocol(HSImageCacheAttributes)] isEnabledCacheImage])
        return;
    float width = [_borderAttributes borderWidth];
    if (!(width > 0))
        return;
    [(NSColor *)[_borderAttributes borderColor] set];
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextSaveGState(context);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextSetMiterLimit(context, 0.1f);
    CGContextSetShouldAntialias(context, false);
    CGAffineTransform transform = [_mutableClipPathsAttributes relativeToObjectAffineTransform];
    CGContextConcatCTM(context, transform);
    NSArray *clipPaths = [_mutableClipPathsAttributes clipPaths];
    CGPathRef border = [self HSImageBorderRenderLayer_createImageObjectBorderBezierPath];
    CGContextAddPath(context, border);
    for (id path in clipPaths)
        CGContextAddPath(context, (CGPathRef)path);
    CGContextConcatCTM(context, CGAffineTransformInvert(transform));
    CGContextSetLineWidth(context, width + width);
    CGContextStrokePath(context);
    CGPathRelease(border);
    CGContextRestoreGState(context);
}
- (struct CGPath *)HSImageBorderRenderLayer_createImageObjectBorderBezierPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, 1, 1));
    return path;
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id hyperObject = [self hyperObject];
    [aSet addAttribute:@protocol(HSBorderAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSImageRectAttribute) forObject:hyperObject];
}
- (void)dealloc
{
    [_imageAttributes release];
    [_borderAttributes release];
    [_mutableClipPathsAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _imageAttributes = [[aObject queryHyperInterface:@protocol(HSImageAttributes)] retain];
        if (_imageAttributes != nil) {
            _borderAttributes = [[aObject queryHyperInterface:@protocol(HSBorderAttributes)] retain];
            if (_borderAttributes != nil) {
                _mutableClipPathsAttributes = [[aObject queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] retain];
                if (_mutableClipPathsAttributes != nil)
                    return self;
            }
        }
        [self release];
    }
    return nil;
}
@end
