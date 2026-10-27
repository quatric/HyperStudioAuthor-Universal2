#import "HSBitmapDrawRoundedRectToolWrapper.h"

@implementation HSBitmapDrawRoundedRectToolWrapper

- (BOOL)canProvideSelectedShape
{
    return YES;
}

// Corners are quadratic curves in the unit square, sized so the radius from
// the tool settings survives the oriented rect transform.
- (void)provideSelectionPath:(struct CGPath *)aPath withOrientedRectTransform:(CGAffineTransform)aTransform
{
    id settings = [[[HSToolManager sharedToolManager] toolSettings] settingsForTool:[[HSToolManager sharedToolManager] currentTool]];
    id path = [NSObject objectWithExtraDictionary:[settings objectForKey:@"path"]];
    float radius = 10.0f;
    if (path != nil) {
        float value = [path hyperBasePointOfElementAtIndex:0].x;
        radius = (value + value) * 190.0f + 10.0f;
    }
    float width = fabsf((float)aTransform.a), height = fabsf((float)aTransform.d);
    radius = MIN(radius, MIN(width, height) * 0.5f);
    CGMutablePathRef shape = CGPathCreateMutable();
    if (shape == NULL)
        return;
    float rx = MIN(radius / width, 0.5f);
    float ry = MIN(radius / height, 0.5f);
    CGPathMoveToPoint(shape, NULL, rx, 0);
    CGPathAddQuadCurveToPoint(shape, NULL, 0, 0, 0, ry);
    CGPathAddLineToPoint(shape, NULL, 0, 1.0f - ry);
    CGPathAddQuadCurveToPoint(shape, NULL, 0, 1, rx, 1);
    CGPathAddLineToPoint(shape, NULL, 1.0f - rx, 1);
    CGPathAddQuadCurveToPoint(shape, NULL, 1, 1, 1, 1.0f - ry);
    CGPathAddLineToPoint(shape, NULL, 1, ry);
    CGPathAddQuadCurveToPoint(shape, NULL, 1, 0, 1.0f - rx, 0);
    CGPathCloseSubpath(shape);
    CGPathAddPath(aPath, &aTransform, shape);
    // Fix: the original leaked the shape path.
    CGPathRelease(shape);
}

// Original quirk kept: logs every initialization.
- (id)initWithBTTool:(id)aTool
{
    NSLog(@"initWithBTTool");
    return [super initWithBTTool:aTool];
}

@end
