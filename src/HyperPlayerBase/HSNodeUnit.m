#import "HSNodeUnit.h"

// Base class of the data units shared by one or more nodes (weakly
// referenced). Change notifications are forwarded to every host node.
@implementation HSNodeUnit
- (BOOL)supportsSharingBetweenGroupObjects
{
    return YES;
}
- (id)undoManager
{
    for (id node in (NSSet *)_nodes) {
        id undoManager = [node undoManager];
        if (undoManager)
            return undoManager;
    }
    return nil;
}
- (void)notifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet withUserInfo:(id)aInfo
{
    for (id node in (NSSet *)_nodes) {
        [node disableGroupCardObjectsNotificationPatchForNodeData];
        [node notifyChange:aChange ofAttributeSet:aSet withUserInfo:aInfo];
        [node enableGroupCardObjectsNotificationPatchForNodeData];
    }
}
- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo
{
    for (id node in (NSSet *)_nodes) {
        [node disableGroupCardObjectsNotificationPatchForNodeData];
        [node notifyChange:aChange ofAttribute:aAttribute withUserInfo:aInfo];
        [node enableGroupCardObjectsNotificationPatchForNodeData];
    }
}
- (void)willRemoveFromDocument
{
}
- (void)didAddToDocument
{
}
// The unit joins the document with its first host node and leaves it with the last.
- (void)nodeDidAddToDocument:(id)aDocument
{
    if (_nodes == NULL)
        return;
    for (id node in (NSSet *)_nodes) {
        if (node != aDocument && [node support])
            return;
    }
    [self didAddToDocument];
}
- (void)nodeWillRemoveFromDocument:(id)aDocument
{
    if (_nodes == NULL)
        return;
    for (id node in (NSSet *)_nodes) {
        if (node != aDocument && [node support])
            return;
    }
    [self willRemoveFromDocument];
}
- (id)hostNodes
{
    return _nodes ? (id)_nodes : [NSSet set];
}
- (void)registerEjectionFromNode:(void *)aNode
{
    if (_nodes)
        CFSetRemoveValue(_nodes, aNode);
}
- (void)registerInjectionIntoNode:(id)aNode
{
    if (_nodes == NULL) {
        _nodes = CFSetCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerSetCallBacks);
        if (_nodes == NULL)
            return;
    }
    CFSetAddValue(_nodes, aNode);
}
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    return Nil;
}
- (BOOL)implementsHyperInterface:(id)aInterface
{
    return NO;
}
- (id)implementedHyperInterfaces
{
    return [NSSet set];
}
- (id)attributes
{
    return [NSEProtocolSet protocolSet];
}
- (id)mediaUIDs
{
    return [NSSet set];
}
- (void)setUID:(id)aUID
{
    if (_UID != aUID) {
        [aUID retain];
        [_UID release];
        _UID = aUID;
    }
}
- (id)UID
{
    return _UID;
}
- (BOOL)isHyperEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    NSMutableDictionary *mine = [NSMutableDictionary dictionaryWithDictionary:[self extraDictionaryRepresentation]];
    [mine removeObjectForKey:@"UID"];
    NSMutableDictionary *theirs = [NSMutableDictionary dictionaryWithDictionary:[aEqual extraDictionaryRepresentation]];
    [theirs removeObjectForKey:@"UID"];
    return [mine isEqualToDictionary:theirs];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObject:@"UID"];
}
- (id)copyWithZone:(NSZone *)aZone
{
    id representation = [self extraDictionaryRepresentation];
    if (representation == nil)
        return nil;
    id copy = [[[self class] allocWithZone:aZone] init];
    [copy loadExtraDictionaryRepresentation:representation];
    return copy;
}
- (void)dealloc
{
    if (_nodes)
        CFRelease(_nodes);
    [_UID release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        _UID = [[HSUID UID] retain];
        if (_UID == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}
@end
