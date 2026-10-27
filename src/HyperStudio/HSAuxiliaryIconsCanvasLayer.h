#import "HyperStudioPrefix.h"


@interface HSAuxiliaryIconsCanvasLayer : HSObservingNodesCanvasSublayer
{
}
- (void)animationDidChange:(id)aChange;
- (void)HSAuxiliaryIconsCanvasLayer_actorDidChange:(id)aChange;
- (void)hiddedAttributeDidChange:(id)aChange;
- (void)masterAttributeDidChange:(id)aChange;
- (void)rootNodeAuxiliaryIconAffectingAttributeDidChange:(id)aChange;
- (void)cardSizeDidChange:(id)aChange;
- (void)updateRootRepresentedNodeCanvasItem;
- (void)itemDidChangeGeometry:(id)aGeometry;
- (void)handleTraitsMightChangeForAllItems;
- (void)stopObservingNotificationsFromRootRepresentedObject:(id)aObject;
- (void)observeNotificationsFromRootRepresentedObject:(id)aObject;
- (void)rootNodeParentDidChange:(id)aChange;
- (void)representedObjectDidChange;
- (void)rootNodeParentWillChange:(id)aChange;
- (void)stopObservingNotificationsFromStack:(id)aStack;
- (void)observeNotificationsFromStack:(id)aStack;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)hasRepresentationForRootNode;
- (id)queryCanvasItemForNode:(id)aNode;
- (BOOL)supportsHitTesting;
- (void)dealloc;
@end

