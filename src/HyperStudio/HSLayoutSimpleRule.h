#import "HyperStudioPrefix.h"


@interface HSLayoutSimpleRule : NSObject <HSLayoutRule, NSObject>
{
    int _axisType;
    int _rectSide;
    float _layoutRuleFloatValue;
    int _ruleType;
    BOOL _snapDisabled;
    int _scalingMask;
}
- (NSPoint)directionSnapsRectTo:(NSRect)aTo;
- (NSRect)scaleRect:(NSRect)aRect;
- (NSRect)translateRect:(NSRect)aRect;
- (id)geometryHoldersSortedByOppositeCoordinate;
- (id)geometryHoldersUsed;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (CGFloat)layoutRuleFloatValue;
- (CGFloat)layoutRuleFloatValueForRectSide:(NSInteger)aSide;
- (BOOL)affectsRectSide:(NSInteger)aSide;
- (NSInteger)affectedRectSideAtIndex:(NSUInteger)aIndex alongAxis:(NSInteger)aAxis;
- (NSUInteger)countOfAffectedRectSidesAlongAxis:(NSInteger)aAxis;
- (NSInteger)affectedRectSideAtIndex:(NSUInteger)aIndex;
- (NSUInteger)affectedRectSidesCount;
- (NSInteger)rectSide;
- (NSInteger)axisType;
- (BOOL)appliesToAxis:(NSInteger)aAxis;
- (BOOL)appliesToYAxis;
- (BOOL)appliesToXAxis;
- (BOOL)scalesRectWithPositiveDirection:(BOOL *)aDirection;
- (void)setScalesBySide:(NSInteger)aSide;
- (void)setCanSnapTo:(BOOL)aTo;
- (BOOL)canSnapTo;
- (NSInteger)ruleType;
- (id)initWithAxisType:(NSInteger)aType rectSide:(NSInteger)aSide value:(CGFloat)aValue type:(NSInteger)aType2;
@end

