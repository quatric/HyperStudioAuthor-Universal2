#import "HyperPlayerBasePrefix.h"
#import "HSObservingCanvasSublayer.h"


@interface HSObservingNodesCanvasSublayer : HSObservingCanvasSublayer
{
}
- (id)rootRepresentedNodeChildAtIndex:(NSUInteger)aIndex;
- (void)rootRepresentedNodeDidAddNodesInSet:(id)aSet;
- (BOOL)hasRepresentationForRootNode;
- (void)unregisterCanvasItem:(id)aItem forNode:(id)aNode;
- (void)unregisterCanvasItemForNode:(id)aNode;
- (void)registerCanvasItem:(id)aItem forNode:(id)aNode;
- (void)willUnregisterCanvasItem:(id)aItem forNode:(id)aNode;
- (void)didRegisterCanvasItem:(id)aItem forNode:(id)aNode;
- (id)queryCanvasItemForNode:(id)aNode;
- (id)canvasItemForNodeIfExists:(id)aExists;
- (id)canvasItemForNode:(id)aNode;
- (void)rootRepresentedNodeDidChangeChildren:(id)aChildren;
- (void)rootRepresentedNodeWillChangeChildren:(id)aChildren;
- (void)unregisterCanvasItem:(id)aItem;
- (void)stopObservingNotificationsFromRootRepresentedObject:(id)aObject;
- (void)observeNotificationsFromRootRepresentedObject:(id)aObject;
- (void)unregisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject;
- (void)unregisterCanvasItemForRepresentedObject:(id)aObject;
- (void)registerCanvasItem:(id)aItem forRepresentedObject:(id)aObject;
- (void)willUnregisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject;
- (void)didRegisterCanvasItem:(id)aItem forRepresentedObject:(id)aObject;
- (id)canvasItemForRepresentedObjectIfExists:(id)aExists;
- (id)canvasItemForRepresentedObject:(id)aObject;
- (id)representedObjectForCanvasItem:(id)aItem;
- (id)queryCanvasItemForRepresentedObject:(id)aObject;
- (id)objectInRepresentedObjectsAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfRepresentedObjects;
- (id)rootRepresentedNode;
@end

