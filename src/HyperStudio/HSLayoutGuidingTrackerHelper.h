#import "HyperStudioPrefix.h"


@interface HSLayoutGuidingTrackerHelper : NSObject <HSLayoutGuidingContext, NSObject>
{
    HSView *_hostView;
    HSCard *_card;
    id<HSLayoutGuidingRulesRenderer> _layoutGuidingRulesRenderer;
    HSLayoutGuidingProcessor *_layoutGuidingProcessor;
    NSArray *_appliedRules;
    NSRect _rectRulesApplyTo;
    BOOL _isSnapToObjectsEnabled;
    float _gridSnapDelta;
    BOOL _gridSnapDeltaIsSet;
}
+ (id)helperWithHostView:(id)aView;
- (id)filterSnapRules:(id)aRules madeForRect:(NSRect)aRect byMoveDirection:(NSPoint)aDirection;
- (void)setGridSnapDelta:(CGFloat)aDelta;
- (CGFloat)gridSnapDelta;
- (void)setCommonSnapDelta:(CGFloat)aDelta;
- (CGFloat)commonSnapDelta;
- (void)hideInfoTag;
- (void)showInfoTagWithCoordinate:(CGFloat)aCoordinate horizontal:(BOOL)aHorizontal;
- (void)showInfoTagWithPoint:(NSPoint)aPoint;
- (void)showInfoTagWithSize:(NSSize)aSize;
- (void)showInfoTagWithString:(id)aString;
- (NSPoint)topLeftForInfoTag;
- (void)cancelAppliedLayoutGuidingRulesClearing;
- (void)showAppliedLayoutGuidingRules;
- (void)clearAppliedLayoutGuidingRules;
- (void)setAppliedLayoutGuidingRules:(id)aRules forSnappingRect:(NSRect)aRect;
- (id)appliedLayoutGuidingRules;
- (void)setRulesRenderer:(id)aRenderer;
- (void)setCard:(id)aCard;
- (BOOL)isSnapToGridEnabled;
- (BOOL)isSnappingEnabled;
- (void)setSnapToObjectsEnabled:(BOOL)aEnabled;
- (void)setSnapToGridEnabled:(BOOL)aEnabled;
- (id)layoutGuidingProcessor;
- (void)dealloc;
- (id)initWithHostView:(id)aView;
@end

