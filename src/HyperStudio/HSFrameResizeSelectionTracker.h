#import "HyperStudioPrefix.h"
#import "HSSelectionKnobTracker.h"


@interface HSFrameResizeSelectionTracker : HSSelectionKnobTracker
{
    NSSize _startSize;
    CGAffineTransform _startAffineTransform;
    NSPoint _untransformedStartPoint;
    NSSize _deltaFactor;
    NSSize _resizingCenterPositionFactor;
    int _modifyingEdges;
    int _aspectRatioMaintainingRule;
    int _aspectRatioMaintainingRequest;
    unsigned int _invertsProportionalResizePreferences:1;
    unsigned int _resizesAboutCenter:1;
    unsigned int _isCrop:1;
}
+ (id)alternateProportionsTrackerWithModifyingEdges:(NSInteger)aEdges;
+ (id)trackerWithModifyingEdges:(NSInteger)aEdges;
- (void)mouseUp:(id)aUp inView:(id)aView;
- (void)processMouseDragged:(id)aDragged inView:(id)aView;
- (void)processMouseDown:(id)aDown inView:(id)aView;
- (void)flagsChanged:(id)aChanged inView:(id)aView;
- (void)mouseEvent:(id)aEvent inView:(id)aView;
- (BOOL)isCropForEvent:(id)aEvent;
- (BOOL)isCropForModifierFlags:(NSUInteger)aFlags;
- (void)HSFrameResizeSelectionTracker_processWithLocation:(NSPoint)aLocation modifierFlags:(NSUInteger)aFlags inView:(id)aView;
- (void)didResizeCardObject;
- (void)willResizeCardObject;
- (BOOL)adjustSize:(NSSize *)aSize;
- (BOOL)isResizesAboutCenter;
- (BOOL)isCrop;
- (NSPoint)untransformedStartPoint;
- (NSSize)startSize;
- (NSSize)resizingCenterPositionFactorForModifierFlags:(NSUInteger)aFlags;
- (NSSize)resizingCenterPositionFactor;
- (NSInteger)aspectRatioMaintainingRequestForModifierFlags:(NSUInteger)aFlags;
- (BOOL)invertsProportionalResizePreferences;
- (NSInteger)aspectRatioMaintainingRuleForModifierFlags:(NSUInteger)aFlags;
- (NSInteger)aspectRatioMaintainingRule;
- (NSInteger)modifyingEdges;
- (NSSize)deltaFactorForModifierFlags:(NSUInteger)aFlags;
- (NSSize)deltaFactor;
- (id)initWithModifyingEdges:(NSInteger)aEdges invertsProportionalResizePreferences:(BOOL)aPreferences;
- (id)init;
@end

