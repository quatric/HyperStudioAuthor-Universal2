#import "HSSizeNodeUnit.h"
// An object's size, rounded to whole points when the object wants integral
// sizes. Width and height changes are notified separately.
@implementation HSSizeNodeUnit
- (NSSize)roundSizeIfNeeded:(NSSize)aNeeded
{
    id host = [[self hostNodes] anyObject];
    if (host != nil && [[host queryHyperInterface:@protocol(HSSizeAdditionalAttributes)] isIntegralSize])
        return NSMakeSize(roundf(aNeeded.width), roundf(aNeeded.height));
    return aNeeded;
}
static BOOL HSSizeNodeUnitChanged(CGFloat aOld, CGFloat aNew)
{
    CGFloat epsilon = aOld != 0 ? aOld * 0.0001f : FLT_MIN;
    return aNew < aOld - epsilon || aOld + epsilon < aNew;
}
// Undoable; nothing happens when neither dimension changes.
- (void)setSize:(NSSize)aSize
{
    NSSize size = [self roundSizeIfNeeded:aSize];
    NSEMutableProtocolSet *changed = [NSEMutableProtocolSet protocolSet];
    if (changed != nil) {
        if (HSSizeNodeUnitChanged(_size.width, size.width))
            [changed addProtocol:@protocol(HSWidthAttribute)];
        if (HSSizeNodeUnitChanged(_size.height, size.height))
            [changed addProtocol:@protocol(HSHeightAttribute)];
        if ([changed count] == 0)
            return;
        [self notifyChange:1 ofAttributeSet:changed withUserInfo:nil];
    }
    NSUndoManager *undoManager = [self undoManager];
    [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Size" value:@"" table:@"UndoManager"]];
    [(HSSizeNodeUnit *)[undoManager prepareWithInvocationTarget:self] setSize:_size];
    _size = size;
    if (changed != nil)
        [self notifyChange:2 ofAttributeSet:changed withUserInfo:nil];
}
- (NSSize)size
{
    return _size;
}
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSSizeAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSStandaloneSizeAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSMutableSizeAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSStandaloneMutableSizeAttributes), aInterface))
        return [HSMutableSizeAttributesImplementation class];
    return Nil;
}
- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSSizeAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSStandaloneSizeAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSMutableSizeAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSStandaloneMutableSizeAttributes), aInterface);
}
- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSSizeAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableSizeAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSStandaloneSizeAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSStandaloneMutableSizeAttributes)], nil];
}
- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocols:@protocol(HSWidthAttribute), @protocol(HSHeightAttribute), nil];
}
// Stored as a string; loading doesn't notify or register undo.
- (void)setSizeAsString:(id)aString
{
    _size = [self roundSizeIfNeeded:NSSizeFromString(aString)];
}
- (id)sizeAsString
{
    return NSStringFromSize(_size);
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:@"sizeAsString"];
}
- (id)copyWithZone:(NSZone *)aZone
{
    HSSizeNodeUnit *copy = [[[self class] allocWithZone:aZone] init];
    [copy setSize:_size];
    return copy;
}
@end
