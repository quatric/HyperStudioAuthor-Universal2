#import "HyperStudioPrefix.h"


@interface HSLayoutGuidingProcessor : NSObject
{
    id<HSLayoutGeometryHoldersProvider> _geometryHoldersProvider;
    NSMutableArray *_xAxisRules;
    NSMutableArray *_yAxisRules;
    float _snapDelta;
    NSArray *_snappers;
    unsigned int _disabledRuleTypes;
}
- (id)objectInHyperGeometryHoldersForInterface:(id)aInterface atIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfHyperGeometryHoldersForInterface:(id)aInterface;
- (id)createGridCornerRuleWithCorner:(NSPoint)aCorner rectEdgeMask:(NSInteger)aMask;
- (id)createLayoutRuleWithType:(NSInteger)aType rectSide:(NSInteger)aSide value:(CGFloat)aValue;
- (void)addRule:(id)aRule;
- (BOOL)snapRect:(NSRect *)aRect edges:(NSInteger)aEdges transformationDirectionHint:(NSSize)aHint appliedRules:(id *)aRules;
- (void)setLayoutRulesEnabled:(BOOL)aEnabled forType:(NSInteger)aType;
- (BOOL)areLayoutRulesEnabledForType:(NSInteger)aType;
- (void)setGeometryHoldersProvider:(id)aProvider;
- (id)geometryHoldersProvider;
- (NSRect)applyRules:(id)aRules toRect:(NSRect)aRect changingSize:(BOOL)aSize directionIsPositive:(BOOL)aPositive;
- (void)filterRulesForSnappingRect:(NSRect)aRect edges:(NSInteger)aEdges transformationDirectionHint:(NSSize)aHint;
- (void)filterRules:(id)aRules alongSameAxis:(NSInteger)aAxis forRect:(NSRect)aRect transformationDirectionHint:(CGFloat)aHint otherAxisRules:(id)aRules2;
- (void)calculateClosestDelta:(float *)aDelta rectSide:(int *)aSide forRule:(id)aRule fromRect:(NSRect)aRect alongAxis:(NSInteger)aAxis;
- (void)setSnapDelta:(CGFloat)aDelta;
- (CGFloat)snapDelta;
- (id)prioritizeByTypeRule:(id)aRule vsRule:(id)aRule2;
- (BOOL)shouldUseSnapper:(id)aSnapper;
- (void)dealloc;
- (id)init;
@end

