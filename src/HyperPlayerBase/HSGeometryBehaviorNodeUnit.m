#import "HSGeometryBehaviorNodeUnit.h"
// Whether resizing keeps the aspect ratio (undoable).
@implementation HSGeometryBehaviorNodeUnit
- (void)setPrefersToMaintainSizeScaleAspectRatio:(BOOL)aRatio
{
    if (!_prefersToMaintainSizeScaleAspectRatio == !aRatio)
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSSizeScaleAspectRatioMaintainingPreferenceAttribute) withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Scaling Kind" value:@"" table:@"UndoManager"]];
    [[undoManager prepareWithInvocationTarget:self] setPrefersToMaintainSizeScaleAspectRatio:_prefersToMaintainSizeScaleAspectRatio];
    _prefersToMaintainSizeScaleAspectRatio = aRatio;
    [self notifyChange:2 ofAttribute:@protocol(HSSizeScaleAspectRatioMaintainingPreferenceAttribute) withUserInfo:nil];
}
- (BOOL)prefersToMaintainSizeScaleAspectRatio
{
    return _prefersToMaintainSizeScaleAspectRatio;
}
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSGeometryBehaviorAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSMutableGeometryBehaviorAttributes), aInterface))
        return [HSMutableGeometryBehaviorAttributesImplementation class];
    return Nil;
}
- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSGeometryBehaviorAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSMutableGeometryBehaviorAttributes), aInterface);
}
- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSGeometryBehaviorAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableGeometryBehaviorAttributes)], nil];
}
- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocol:@protocol(HSSizeScaleAspectRatioMaintainingPreferenceAttribute)];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"prefersToMaintainSizeScaleAspectRatio"];
}
- (id)copyWithZone:(NSZone *)aZone
{
    HSGeometryBehaviorNodeUnit *copy = [[[self class] allocWithZone:aZone] init];
    [copy setPrefersToMaintainSizeScaleAspectRatio:_prefersToMaintainSizeScaleAspectRatio];
    return copy;
}
@end
