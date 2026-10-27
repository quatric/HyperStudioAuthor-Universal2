#import "HyperPlayerBasePrefix.h"
#import "HSConcreteCardObject.h"


@interface HSWebObject : HSConcreteCardObject <HSDefaultSizeSubattributes, HSAttributes, HyperInterface, NSObject, HSGeometryBehaviorSubattributes>
{
}
+ (id)defaultUnitClassNames;
- (void)storeLocalPropertiesInXMLElementRepresentation:(id)aRepresentation context:(id)aContext;
- (id)HTML5UnsupportedFunctionalityDescription;
- (BOOL)canBeDraggable;
- (BOOL)canBeResizable;
- (BOOL)canBeRotatable;
- (BOOL)canMoveVertically;
- (BOOL)canMoveHorizontally;
- (BOOL)canRotate;
- (BOOL)canSkew;
- (BOOL)canFlipVertically;
- (BOOL)canFlipHorizontally;
- (BOOL)canScaleVertically;
- (BOOL)canScaleHorizontally;
- (BOOL)canBreakSizeScaleAspectRatio;
- (BOOL)prefersResizingToScaling;
- (NSSize)defaultSize;
- (id)queryInteractivePlayerItem;
- (id)queryNewHyperInterface:(id)aInterface;
@end

