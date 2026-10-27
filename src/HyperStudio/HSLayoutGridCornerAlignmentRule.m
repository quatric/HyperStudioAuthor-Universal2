#import "HSLayoutGridCornerAlignmentRule.h"

@implementation HSLayoutGridCornerAlignmentRule

- (NSPoint)directionSnapsRectTo:(NSRect)aTo
{
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    if (_rectEdgeMask & 1)
        x = aTo.origin.x;
    if (_rectEdgeMask & 4)
        x = aTo.origin.x + aTo.size.width;
    if (_rectEdgeMask & 2)
        y = aTo.origin.y;
    if (_rectEdgeMask & 8)
        y = aTo.origin.y + aTo.size.height;
    return NSMakePoint(_gridCorner.x - x, _gridCorner.y - y);
}

- (id)description
{
    return [[super description] stringByAppendingFormat:@"(%@)", NSStringFromPoint(_gridCorner)];
}

- (BOOL)canSnapTo
{
    return !_snapDisabled;
}

- (BOOL)scalesRectWithPositiveDirection:(BOOL *)aDirection
{
    return NO;
}

- (NSInteger)ruleType
{
    return 0;
}

- (id)geometryHoldersSortedByOppositeCoordinate
{
    return nil;
}

- (id)geometryHoldersUsed
{
    return nil;
}

- (NSRect)scaleRect:(NSRect)aRect
{
    return aRect;
}

- (NSRect)translateRect:(NSRect)aRect
{
    return HSLayoutRuleTranslateRect(self, aRect);
}

- (BOOL)isEqual:(id)aEqual
{
    return HSLayoutRuleIsEqual(self, aEqual);
}

- (CGFloat)layoutRuleFloatValueForRectSide:(NSInteger)aSide
{
    switch (aSide) {
    case 0:
    case 2:
        return _gridCorner.x;
    case 1:
    case 3:
        return _gridCorner.y;
    default:
        return 0.0f;
    }
}

- (NSInteger)affectedRectSideAtIndex:(NSUInteger)aIndex alongAxis:(NSInteger)aAxis
{
    if (aAxis == 0)
        return ((_rectEdgeMask & 1) == 0) * 2;
    return ((_rectEdgeMask & 2) == 0) * 2 + 1;
}

- (NSUInteger)countOfAffectedRectSidesAlongAxis:(NSInteger)aAxis
{
    return 1;
}

- (BOOL)affectsRectSide:(NSInteger)aSide
{
    switch (aSide) {
    case 0:
        return (_rectEdgeMask & 1) != 0;
    case 1:
        return (_rectEdgeMask & 2) != 0;
    case 2:
        return (_rectEdgeMask & 4) != 0;
    case 3:
        return (_rectEdgeMask >> 3) & 1;
    default:
        return NO;
    }
}

- (NSInteger)affectedRectSideAtIndex:(NSUInteger)aIndex
{
    if (aIndex == 0)
        return ((_rectEdgeMask & 1) == 0) * 2;
    return ((_rectEdgeMask & 2) == 0) * 2 + 1;
}

- (NSUInteger)affectedRectSidesCount
{
    return 2;
}

- (BOOL)appliesToAxis:(NSInteger)aAxis
{
    return YES;
}

- (BOOL)appliesToYAxis
{
    return YES;
}

- (BOOL)appliesToXAxis
{
    return YES;
}

- (void)setCanSnapTo:(BOOL)aTo
{
    _snapDisabled = !aTo;
}

- (id)initWithGridCorner:(NSPoint)aCorner rectEdgeMask:(NSInteger)aMask
{
    self = [super init];
    if (self) {
        _gridCorner = aCorner;
        _rectEdgeMask = (int)aMask;
    }
    return self;
}

@end
