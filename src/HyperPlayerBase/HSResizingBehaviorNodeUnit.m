#import "HSResizingBehaviorNodeUnit.h"
// Whether resizing keeps the aspect ratio (undoable).
@implementation HSResizingBehaviorNodeUnit
- (void)setPrefersToMaintainSizeAspectRatio:(BOOL)aRatio
{
    [self notifyChange:1 ofAttribute:@protocol(HSSizeAspectRatioMaintainingPreferenceAttribute) withUserInfo:nil];
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Sizing Kind" value:@"" table:@"UndoManager"]];
    [[undoManager prepareWithInvocationTarget:self] setPrefersToMaintainSizeAspectRatio:_prefersToMaintainSizeAspectRatio];
    _prefersToMaintainSizeAspectRatio = aRatio;
    [self notifyChange:2 ofAttribute:@protocol(HSSizeAspectRatioMaintainingPreferenceAttribute) withUserInfo:nil];
}
- (BOOL)prefersToMaintainSizeAspectRatio
{
    return _prefersToMaintainSizeAspectRatio;
}
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if ([self implementsHyperInterface:aInterface])
        return [HSMutableResizingBehaviorAttributesImplementation class];
    return Nil;
}
- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSResizingBehaviorAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSMutableResizingBehaviorAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSStandaloneResizingBehaviorAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSStandaloneMutableResizingBehaviorAttributes), aInterface);
}
- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSResizingBehaviorAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableResizingBehaviorAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSStandaloneResizingBehaviorAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSStandaloneMutableResizingBehaviorAttributes)], nil];
}
- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocol:@protocol(HSSizeAspectRatioMaintainingPreferenceAttribute)];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"prefersToMaintainSizeAspectRatio"];
}
- (id)copyWithZone:(NSZone *)aZone
{
    HSResizingBehaviorNodeUnit *copy = [[[self class] allocWithZone:aZone] init];
    [copy setPrefersToMaintainSizeAspectRatio:_prefersToMaintainSizeAspectRatio];
    return copy;
}
@end
