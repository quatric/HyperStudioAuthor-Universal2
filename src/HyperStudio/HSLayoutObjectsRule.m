#import "HSLayoutObjectsRule.h"

// Orders geometry holders by their transformed min, then max, along the axis opposite the rule's.
static NSInteger HSCompareByOppositeCoordinate(id aFirst, id aSecond, void *aContext)
{
    CGRect first = CGRectApplyAffineTransform([aFirst hyperLayoutInfluencingBoundingRect], [aFirst hyperLayoutInfluencingTransform]);
    CGRect second = CGRectApplyAffineTransform([aSecond hyperLayoutInfluencingBoundingRect], [aSecond hyperLayoutInfluencingTransform]);
    CGFloat firstMin, firstMax, secondMin, secondMax;

    if ((intptr_t)aContext == 0) {
        firstMin = first.origin.y;
        firstMax = first.origin.y + first.size.height;
        secondMin = second.origin.y;
        secondMax = second.origin.y + second.size.height;
    } else {
        firstMin = first.origin.x;
        firstMax = first.origin.x + first.size.width;
        secondMin = second.origin.x;
        secondMax = second.origin.x + second.size.width;
    }
    if (secondMin > firstMin)
        return NSOrderedAscending;
    if (secondMin < firstMin)
        return NSOrderedDescending;
    if (secondMax > firstMax)
        return NSOrderedAscending;
    return secondMax < firstMax ? NSOrderedDescending : NSOrderedSame;
}

@implementation HSLayoutObjectsRule

- (id)geometryHoldersSortedByOppositeCoordinate
{
    if (_usedObjects == nil)
        return [NSArray array];
    if ([_usedObjects count] < 2)
        return [_usedObjects allObjects];

    NSMutableArray *holders = [[NSMutableArray alloc] initWithCapacity:[_usedObjects count]];
    NSEnumerator *e = [_usedObjects objectEnumerator];
    id holder;

    while ((holder = [e nextObject]) != nil)
        [holders addObject:holder];
    [holders sortUsingFunction:HSCompareByOppositeCoordinate context:(void *)(intptr_t)_axisType];
    return [holders autorelease];
}

- (id)ownGeometryHolder
{
    return _ownGeometryHolder;
}

- (void)setOwnGeometryHolder:(id)aHolder
{
    if (_ownGeometryHolder != aHolder) {
        [_ownGeometryHolder release];
        _ownGeometryHolder = [aHolder retain];
    }
}

- (id)geometryHoldersUsed
{
    return _usedObjects;
}

- (id)usedObjects
{
    if (_usedObjects == nil)
        _usedObjects = [NSMutableSet new];
    return _usedObjects;
}

- (void)dealloc
{
    [_usedObjects release];
    [_ownGeometryHolder release];
    [super dealloc];
}

// Sides 0, 2, 4 and 6 lie on the horizontal axis.
- (id)initWithRectSide:(NSInteger)aSide value:(CGFloat)aValue type:(NSInteger)aType
{
    int axis = ((NSUInteger)aSide < 7 && ((0x55u >> (aSide & 0x1f)) & 1)) ? 0 : 1;

    return [super initWithAxisType:axis rectSide:aSide value:aValue type:aType];
}

@end
