#import "HyperStudioPrefix.h"


@interface HSNodeSelection : NSObject <HSSelectionInterface, NSObject, HSNodeSelectionInterface>
{
    id<HSSelectionOwner> _owner;
    NSMutableSet *_nodes;
    id _selectedObject;
    id _anySelectedObject;
    unsigned int _selectionChangeNotificationDelayCount;
    BOOL _ownerValidatesNodes;
    BOOL _selectionChangeNotificationsPending;
    BOOL _hadAnyChangesOtherThanRemovingObjectsSinceLastNotification;
    BOOL _shouldDisplaySelectionKnobs;
}
- (void)setShouldDisplaySelectionKnobs:(BOOL)aKnobs;
- (BOOL)shouldDisplaySelectionKnobs;
- (void)selectionDidChange;
- (void)setAnySelectedObject:(id)aObject;
- (void)setSelectedObject:(id)aObject;
- (void)ensureSelectionContainsOnlyAllowedNodes;
- (id)localizedSelectionName;
- (void)endSelectionChanging;
- (void)beginSelectionChanging;
- (void)selectNodesInEnumerator:(id)aEnumerator;
- (void)selectNode:(id)aNode;
- (void)removeAllNodes;
- (void)removeAllNodesExcept:(id)aExcept;
- (void)toggleNode:(id)aNode;
- (void)removeNodesIfExist:(id)aExist;
- (void)removeNode:(id)aNode;
- (void)addNodesInEnumerator:(id)aEnumerator;
- (void)objectParentDidChange:(id)aChange;
- (void)removeObserverForNodes:(id)aNodes;
- (void)removeObserverForNode:(id)aNode;
- (void)addNode:(id)aNode;
- (BOOL)containsNode:(id)aNode;
- (id)anySelectedNode;
- (id)selectedNode;
- (id)nodesEnumerator;
- (id)nodes;
- (id)nodesArray;
- (NSUInteger)nodesCount;
- (BOOL)containsObject:(id)aObject;
- (id)anySelectedObject;
- (id)selectedObject;
- (id)objectEnumerator;
- (id)objectsArray;
- (NSUInteger)objectsCount;
- (BOOL)shouldIncludeNode:(id)aNode;
- (void)notifySelectionDidChangeOwnerAndNotificationCenterWasExpanded:(BOOL)aExpanded;
- (void)notifySelectionDidChange;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (void)dealloc;
- (id)init;
@end

