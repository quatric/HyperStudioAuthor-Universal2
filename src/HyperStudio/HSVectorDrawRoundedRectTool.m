#import "HSVectorDrawRoundedRectTool.h"

@implementation HSVectorDrawRoundedRectTool

- (BOOL)canProvideSelectedShape
{
    return YES;
}

// Builds a rounded rect in a unit-height (or unit-width) box so the corner
// radius from the tool settings survives the oriented rect transform.
- (void)provideSelectionPath:(struct CGPath *)aPath withOrientedRectTransform:(CGAffineTransform)aTransform
{
    id settings = [[[HSToolManager sharedToolManager] toolSettings] settingsForTool:[[HSToolManager sharedToolManager] currentTool]];
    id path = [NSObject objectWithExtraDictionary:[settings objectForKey:@"path"]];
    float radius = 10.0f;
    if (path != nil)
        radius = [path hyperBasePointOfElementAtIndex:0].x * 380.0f + 10.0f;
    float width = fabsf((float)(aTransform.a / aTransform.d)), height;
    if (width > 1.0f) {
        height = 1.0f;
    } else {
        height = fabsf((float)(aTransform.d / aTransform.a));
        width = 1.0f;
    }
    float side = MIN(fabsf((float)aTransform.a), fabsf((float)aTransform.d));
    if (side < radius)
        radius = side * 0.5f;
    CGMutablePathRef shape = CGPathCreateMutable();
    if (shape == NULL)
        return;
    float r = MIN(radius / side, 0.5f);
    CGPathMoveToPoint(shape, NULL, r, 0);
    CGPathAddArcToPoint(shape, NULL, 0, 0, 0, r, r);
    CGPathAddLineToPoint(shape, NULL, 0, height - r);
    CGPathAddArcToPoint(shape, NULL, 0, height, r, height, r);
    CGPathAddLineToPoint(shape, NULL, width - r, height);
    CGPathAddArcToPoint(shape, NULL, width, height, width, height - r, r);
    CGPathAddLineToPoint(shape, NULL, width, r);
    CGPathAddArcToPoint(shape, NULL, width, 0, width - r, 0, r);
    CGPathCloseSubpath(shape);
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0f / width, 1.0f / height), aTransform);
    CGPathAddPath(aPath, &transform, shape);
    // Fix: the original leaked the shape path.
    CGPathRelease(shape);
}

@end
