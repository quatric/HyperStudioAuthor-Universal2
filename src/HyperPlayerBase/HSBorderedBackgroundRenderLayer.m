#import "HSBorderedBackgroundRenderLayer.h"
// Render layer for a shaped button's background: the background graphics
// clipped to the border path, which is centered in the object (flipped).
// Subclasses draw the border itself.

@implementation HSBorderedBackgroundRenderLayer

- (void)drawBorderIfNeededInRegion:(id)aRegion withDelegate:(id)aDelegate
{
}

// Solid colors are cheap enough to draw directly.
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    if (aForce)
        return YES;
    id graphics = [_backgroundAttributes backgroundGraphics];
    if (!graphics)
        return NO;
    if (![graphics isKindOfClass:[HSColor class]])
        return YES;
    return ![graphics isHyperSolid];
}

- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_geometryAttributes boundingRect]];
}

- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:[self hyperObject]];
}

- (BOOL)requiresTransparencyLayer
{
    return YES;
}

- (BOOL)isEmpty
{
    return [_backgroundAttributes backgroundGraphics] == nil;
}

- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    NSBezierPath *path = [_borderAttributes borderPath];
    NSRect bounds = [path bounds];
    NSSize size = [_geometryAttributes size];
    float offsetX = ((NSZeroPoint.x - bounds.origin.x) + size.width - bounds.size.width) * 0.5f;
    float offsetY = ((NSZeroPoint.y - bounds.origin.y) + size.height - bounds.size.height) * 0.5f;
    float flipY = (float)((double)NSZeroPoint.y + (double)NSZeroPoint.y + (double)size.height) - offsetY;
    CGContextConcatCTM(context, CGAffineTransformMake(1, -0.0, 0, -1, offsetX, flipY));
    if ([_backgroundAttributes backgroundGraphics]) {
        [path addClip];
        [[[_buttonAttributes background] queryHyperInterface:@protocol(HSBackgroundAttributesContainerPrimitives)] hyperDrawBackgroundInROI:bounds ofBounds:bounds];
    }
    [self drawBorderIfNeededInRegion:aRegion withDelegate:aDelegate];
}

- (void)fillVisualizationAttributesSet:(id)aSet
{
    id hyperObject = [self hyperObject];
    [aSet addAttribute:@protocol(HSBackgroundAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSBorderAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSButtonObjectBackgroundStyleAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSButtonObjectShapeButtonTypeAttribute) forObject:hyperObject];
}

- (id)cardObjectAttributes
{
    return _cardObjectAttributes;
}

- (id)buttonAttributes
{
    return _buttonAttributes;
}

- (id)geometryAttributes
{
    return _geometryAttributes;
}

- (id)borderAttributes
{
    return _borderAttributes;
}

- (id)backgroundAttributes
{
    return _backgroundAttributes;
}

- (void)dealloc
{
    [_backgroundAttributes release];
    [_borderAttributes release];
    [_geometryAttributes release];
    [_buttonAttributes release];
    [_cardObjectAttributes release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (!self)
        return nil;
    _backgroundAttributes = [[aObject queryHyperInterface:@protocol(HSBackgroundAttributes)] retain];
    if (_backgroundAttributes) {
        _borderAttributes = [[aObject queryHyperInterface:@protocol(HSButtonObjectBorderAttributes)] retain];
        if (_borderAttributes) {
            _geometryAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
            if (_geometryAttributes) {
                _buttonAttributes = [[aObject queryHyperInterface:@protocol(HSButtonObjectAttributes)] retain];
                if (_buttonAttributes) {
                    _cardObjectAttributes = [[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] retain];
                    if (_cardObjectAttributes)
                        return self;
                }
            }
        }
    }
    [self release];
    return nil;
}

@end
