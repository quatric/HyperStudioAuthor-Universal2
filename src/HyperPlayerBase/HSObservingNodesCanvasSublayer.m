#import "HSObservingNodesCanvasSublayer.h"

// Bridges the represented-object API of HSObservingCanvasSublayer to nodes:
// the represented objects are the root node (optionally) and its children.
@implementation HSObservingNodesCanvasSublayer

- (id)rootRepresentedNodeChildAtIndex:(NSUInteger)aIndex
{
    return [[self rootRepresentedNode] hyperChildAtIndex:aIndex];
}

- (void)rootRepresentedNodeDidAddNodesInSet:(id)aSet
{
}

- (BOOL)hasRepresentationForRootNode
{
    return NO;
}

- (void)unregisterCanvasItem:(id)aItem forNode:(id)aNode
{
    [super unregisterCanvasItem:aItem forRepresentedObject:aNode];
}

- (void)unregisterCanvasItemForNode:(id)aNode
{
    [super unregisterCanvasItemForRepresentedObject:aNode];
}

- (void)registerCanvasItem:(id)aItem forNode:(id)aNode
{
    [super registerCanvasItem:aItem forRepresentedObject:aNode];
}

- (void)willUnregisterCanvasItem:(id)aItem forNode:(id)aNode
{
    [super willUnregisterCanvasItem:aItem forRepresentedObject:aNode];
}

- (void)didRegisterCanvasItem:(id)aItem forNode:(id)aNode
{
    [super didRegisterCanvasItem:aItem forRepresentedObject:aNode];
}

- (id)queryCanvasItemForNode:(id)aNode
{
    return nil;
}

- (id)canvasItemForNodeIfExists:(id)aExists
{
    return [super canvasItemForRepresentedObjectIfExists:aExists];
}

- (id)canvasItemForNode:(id)aNode
{
    return [super canvasItemForRepresentedObject:aNode];
}

- (void)rootRepresentedNodeDidChangeChildren:(id)aChildren
{
    id added = [[aChildren userInfo] objectForKey:@"HSNodeChildrenForAddition"];
    if (added != nil && [added count])
        [self rootRepresentedNodeDidAddNodesInSet:added];
}

- (void)rootRepresentedNodeWillChangeChildren:(id)aChildren
{
    id removed = [[aChildren userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    if (removed != nil) {
        NSEnumerator *enumerator = [removed objectEnumerator];
        id node;
        while ((node = [enumerator nextObject]) != nil)
            [self unregisterCanvasItemForNode:node];
    }
}

- (void)unregisterCanvasItem:(id)aItem
{
    [super unregisterCanvasItem:aItem];
}

- (void)stopObservingNotificationsFromRootRepresentedObject:(id)aObject
{
    id container = [aObject queryHyperInterface:@protocol(HSNodeContainer)];
    [[container attributeObservingController] removeObserver:self selector:@selector(rootRepresentedNodeWillChangeChildren:)
                                                   ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [[container attributeObservingController] removeObserver:self selector:@selector(rootRepresentedNodeDidChangeChildren:)
                                                   ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
}

- (void)observeNotificationsFromRootRepresentedObject:(id)aObject
{
    id container = [aObject queryHyperInterface:@protocol(HSNodeContainer)];
    [[container attributeObservingController] addObserver:self selector:@selector(rootRepresentedNodeWillChangeChildren:)
                                                ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    [[container attributeObservingController] addObserver:self selector:@selector(rootRepresentedNodeDidChangeChildren:)
                                                ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
}

- (void)unregisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject
{
    [super unregisterCanvasItem:aItem forRepresentedObject:aObject];
}

- (void)unregisterCanvasItemForRepresentedObject:(id)aObject
{
    [super unregisterCanvasItemForRepresentedObject:aObject];
}

- (void)registerCanvasItem:(id)aItem forRepresentedObject:(id)aObject
{
    [super registerCanvasItem:aItem forRepresentedObject:aObject];
}

- (void)willUnregisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject
{
    [self willUnregisterCanvasItem:aItem forNode:aObject];
}

- (void)didRegisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject
{
    [self didRegisterCanvasItem:aItem forNode:aObject];
}

- (id)canvasItemForRepresentedObjectIfExists:(id)aExists
{
    return [super canvasItemForRepresentedObjectIfExists:aExists];
}

- (id)canvasItemForRepresentedObject:(id)aObject
{
    return [super canvasItemForRepresentedObject:aObject];
}

- (id)representedObjectForCanvasItem:(id)aItem
{
    return [aItem queryHyperInterface:@protocol(HSNodeAttributes)];
}

- (id)queryCanvasItemForRepresentedObject:(id)aObject
{
    return [self queryCanvasItemForNode:aObject];
}

- (id)objectInRepresentedObjectsAtIndex:(NSUInteger)aIndex
{
    // Note: the original does not shift child indices when the root itself is represented.
    if ([self hasRepresentationForRootNode] && aIndex == 0)
        return [self rootRepresentedNode];
    return [self rootRepresentedNodeChildAtIndex:aIndex];
}

- (NSUInteger)countOfRepresentedObjects
{
    if ([self rootRepresentedNode] == nil)
        return 0;
    BOOL hasRoot = [self hasRepresentationForRootNode];
    return [[self rootRepresentedNode] hyperCount] + (hasRoot ? 1 : 0);
}

- (id)rootRepresentedNode
{
    return [[self representedObject] queryHyperInterface:@protocol(HSNodeContainer)];
}

@end
