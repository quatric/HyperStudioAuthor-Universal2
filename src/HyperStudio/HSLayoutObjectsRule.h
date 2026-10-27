#import "HyperStudioPrefix.h"
#import "HSLayoutSimpleRule.h"


@interface HSLayoutObjectsRule : HSLayoutSimpleRule
{
    NSMutableSet *_usedObjects;
    id<HSLayoutInfluencingObjectGeometry> _ownGeometryHolder;
}
- (id)geometryHoldersSortedByOppositeCoordinate;
- (id)ownGeometryHolder;
- (void)setOwnGeometryHolder:(id)aHolder;
- (id)geometryHoldersUsed;
- (id)usedObjects;
- (void)dealloc;
- (id)initWithRectSide:(NSInteger)aSide value:(CGFloat)aValue type:(NSInteger)aType;
@end

