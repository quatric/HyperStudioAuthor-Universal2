#import "HSSystemObject.h"

@implementation HSSystemObject
+ (Class)nodeDataClass
{
    return [HSSystemObjectData class];
}
+ (id)defaultUnitClassNames
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"HSSizeNodeUnit", @"Size Unit", @"HSGeometryNodeUnit", @"Geometry Unit", @"HSResizingBehaviorNodeUnit", @"Resizing Behavior Unit", @"HSGeometryBehaviorNodeUnit", @"Geometry Behavior Unit", @"HSShowHideTransitionNodeUnit", @"Transition Unit", nil];
}
- (id)hyperSizeMaxValue
{
    float width = [[[HSValueConstraints sharedConstraints] constraintForKey:@"HSSystemObjectWidthMaxValue"] floatValue];
    float height = [[[HSValueConstraints sharedConstraints] constraintForKey:@"HSSystemObjectHeightMaxValue"] floatValue];
    return NSStringFromSize(NSMakeSize(width, height));
}
- (BOOL)canMoveVertically
{
    return YES;
}
- (BOOL)canMoveHorizontally
{
    return YES;
}
- (BOOL)canRotate
{
    return YES;
}
- (BOOL)canSkew
{
    return NO;
}
- (BOOL)canFlipVertically
{
    return YES;
}
- (BOOL)canFlipHorizontally
{
    return YES;
}
- (BOOL)canScaleVertically
{
    return NO;
}
- (BOOL)canScaleHorizontally
{
    return NO;
}
- (BOOL)canBreakSizeScaleAspectRatio
{
    return NO;
}
- (BOOL)prefersResizingToScaling
{
    return YES;
}
- (void)removeDuplicateHyperSystemView:(id)aView
{
    [[[self nodeData] viewManager] removeDuplicateHyperSystemView:aView];
}
- (id)addDuplicateHyperSystemView
{
    return [[[self nodeData] viewManager] addDuplicateHyperSystemView];
}
- (id)placeholderSystemView
{
    return nil;
}
- (id)hyperSystemView
{
    return [[[self nodeData] viewManager] hyperSystemView];
}
- (void)didCreateSystemView
{
}
- (id)initUserObject
{
    self = [super initUserObject];
    if (self && [self hyperSystemView])
        [self didCreateSystemView];
    return self;
}
@end
