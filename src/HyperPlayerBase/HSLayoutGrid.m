#import "HSLayoutGrid.h"
// The editor's layout grid: square spacing (30 by default), major steps
// only, snapping corners on moves.
@implementation HSLayoutGrid
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"gridSpacingAsString", nil];
}
- (void)setGridSpacingAsString:(id)aString
{
    [self setGridSpacing:NSSizeFromString(aString)];
}
- (id)gridSpacingAsString
{
    return NSStringFromSize([self gridSpacing]);
}
// Equal within 0.05 % counts as unchanged.
static BOOL HSLayoutGridNearlyEqual(float a, float b)
{
    float magnitude = fmaxf(a != 0 ? fabsf(a) : 1.0f, b != 0 ? fabsf(b) : 1.0f);
    return fabsf(a - b) <= magnitude * 0.0005f;
}
- (void)setGridSpacing:(NSSize)aSpacing
{
    if (HSLayoutGridNearlyEqual(_gridSpacing.width, aSpacing.width) && HSLayoutGridNearlyEqual(_gridSpacing.height, aSpacing.height))
        return;
    [_undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Grid Spacing Change" value:@"" table:@"UndoManager"]];
    [[_undoManager prepareWithInvocationTarget:self] setGridSpacing:_gridSpacing];
    _gridSpacing = aSpacing;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSLayoutGridDidChangeNotification" object:self userInfo:nil];
}
- (NSSize)gridSpacing
{
    return _gridSpacing;
}
- (BOOL)isHyperInfluencingLayout
{
    return YES;
}
- (BOOL)snapToCornersOnMove
{
    return YES;
}
- (BOOL)snapToNegativeValues
{
    return NO;
}
- (BOOL)hyperGridUseMajorSteps
{
    return YES;
}
- (BOOL)hyperGridUseMinorSteps
{
    return NO;
}
- (CGFloat)yHyperGridMajorStep
{
    return [self gridSpacing].height;
}
- (CGFloat)xHyperGridMajorStep
{
    return [self gridSpacing].width;
}
- (CGFloat)yHyperGridMinorStep
{
    return [self yHyperGridMajorStep];
}
- (CGFloat)xHyperGridMinorStep
{
    return [self xHyperGridMajorStep];
}
- (void)setUndoManager:(id)aManager
{
    if (_undoManager == aManager)
        return;
    [_undoManager release];
    _undoManager = [aManager retain];
}
- (void)dealloc
{
    [_undoManager release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _gridSpacing = NSMakeSize(30, 30);
    return self;
}
@end
