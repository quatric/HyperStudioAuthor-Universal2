#import "HSGenericVectorRenderLayer.h"
// A vector shape: its fill graphics clipped to the path and/or the path
// stroked. Render styles: 0 fill only, 1 stroke only, 2 fill then stroke,
// 3 stroke then fill.
@implementation HSGenericVectorRenderLayer
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[[_vectorAttributes bezierPath] hyperVisualBounds]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSBezierPathVectorAttribute) forObject:[self hyperObject]];
}
- (BOOL)requiresTransparencyLayer
{
    return YES;
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSBezierPath *path = [_vectorAttributes bezierPath];
    if ([path isEmpty])
        return;
    BOOL strokeAfterFill = _vectorRenderStyle != 0;
    if (_vectorRenderStyle != 0) {
        NSColor *strokeColor = [_vectorAttributes strokeColor];
        if ([strokeColor alphaComponent] > 0) {
            [strokeColor set];
            if (_vectorRenderStyle == 3) {
                [path stroke];
                strokeAfterFill = NO;
            }
        } else
            strokeAfterFill = NO;
    }
    if (_vectorRenderStyle != 1) {
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [path addClip];
        [[_vectorAttributes fillGraphics] hyperDrawInRect:[aRegion boundingRect] ofBounds:[path bounds]];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
    if (strokeAfterFill)
        [path stroke];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSVectorAttribute) forObject:[self hyperObject]];
}
- (void)dealloc
{
    [_vectorAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject withVectorRenderStyle:(NSInteger)aStyle cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _vectorAttributes = [[aObject queryHyperInterface:@protocol(HSVectorAttributes)] retain];
        if (_vectorAttributes == nil) {
            [self release];
            return nil;
        }
        _vectorRenderStyle = (int)aStyle;
    }
    return self;
}
- (id)initWithHyperObject:(id)aObject withVectorRenderStyle:(NSInteger)aStyle
{
    return [self initWithHyperObject:aObject withVectorRenderStyle:aStyle cachingPolicy:0];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    return [self initWithHyperObject:aObject withVectorRenderStyle:2 cachingPolicy:aPolicy];
}
@end
