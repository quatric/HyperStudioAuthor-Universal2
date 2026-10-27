#import "HyperStudioPrefix.h"


@interface HSLayoutGridCornerAlignmentRule : NSObject <HSLayoutRule, NSObject>
{
    NSPoint _gridCorner;
    BOOL _snapDisabled;
    int _rectEdgeMask;
}
- (NSPoint)directionSnapsRectTo:(NSRect)aTo;
- (id)description;
- (BOOL)canSnapTo;
- (BOOL)scalesRectWithPositiveDirection:(BOOL *)aDirection;
- (NSInteger)ruleType;
- (id)geometryHoldersSortedByOppositeCoordinate;
- (id)geometryHoldersUsed;
- (NSRect)scaleRect:(NSRect)aRect;
- (NSRect)translateRect:(NSRect)aRect;
- (BOOL)isEqual:(id)aEqual;
- (CGFloat)layoutRuleFloatValueForRectSide:(NSInteger)aSide;
- (NSInteger)affectedRectSideAtIndex:(NSUInteger)aIndex alongAxis:(NSInteger)aAxis;
- (NSUInteger)countOfAffectedRectSidesAlongAxis:(NSInteger)aAxis;
- (BOOL)affectsRectSide:(NSInteger)aSide;
- (NSInteger)affectedRectSideAtIndex:(NSUInteger)aIndex;
- (NSUInteger)affectedRectSidesCount;
- (BOOL)appliesToAxis:(NSInteger)aAxis;
- (BOOL)appliesToYAxis;
- (BOOL)appliesToXAxis;
- (void)setCanSnapTo:(BOOL)aTo;
- (id)initWithGridCorner:(NSPoint)aCorner rectEdgeMask:(NSInteger)aMask;
@end

