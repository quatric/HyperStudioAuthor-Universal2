#import "HyperPlayerBasePrefix.h"


@interface HSCardGroupController : NSObject <HSNodeDataOwner, HSNodeDataProvider>
{
    id<HSCardGroupControllerOwner> _owner;
    NSMutableDictionary *_oldUIDsToNewUIDsMap;
    NSMutableArray *_ownedNodeDataArray;
}
- (id)oldUIDsToNewUIDsMap;
- (id)allGroupedObjectsUIDs;
- (id)allActorsForGroupUID:(id)aUID;
- (id)allCardsForGroupUID:(id)aUID;
- (void)injectNodeUnitsFrom:(id)aFrom to:(id)aTo;
- (void)HSCardGroupController_copyUnitsOfNode:(id)aNode;
- (void)HSCardGroupController_unshareUnitsOfNode:(id)aNode withCardGroup:(id)aGroup;
- (void)HSCardGroupController_shareUnitsOfNode:(id)aNode withCardGroup:(id)aGroup;
- (void)unshareActionsOfActor:(id)aActor withActors:(id)aActors;
- (void)shareActionsOfActor:(id)aActor withActor:(id)aActor2;
- (void)postProcessObject:(id)aObject createdFrom:(id)aFrom;
- (void)removeNodeData:(id)aData fromCardGroup:(id)aGroup;
- (void)addNodeData:(id)aData toCardGroup:(id)aGroup;
- (void)removeGroupObject:(id)aObject fromCard:(id)aCard;
- (void)addGroupObject:(id)aObject toCard:(id)aCard atIndex:(NSUInteger)aIndex;
- (void)makeObject:(id)aObject useLocalData:(id)aData;
- (void)makeObject:(id)aObject useSharedData:(id)aData;
- (void)moveDataFromGroupToObject:(id)aObject cardGroup:(id)aGroup;
- (void)moveDataToGroupFromObject:(id)aObject cardGroup:(id)aGroup;
- (void)setGroupObjectFlag:(BOOL)aFlag forObject:(id)aObject;
- (void)removeCards:(id)aCards atIndexes:(id)aIndexes;
- (void)addCards:(id)aCards atIndexes:(id)aIndexes;
- (void)removeCard:(id)aCard fromGroup:(id)aGroup;
- (void)addCard:(id)aCard toGroup:(id)aGroup;
- (void)removeGroupCard:(id)aCard withGroupObjects:(id)aObjects afterCard:(id)aCard2;
- (void)addGroupCard:(id)aCard withGroupObjects:(id)aObjects afterCard:(id)aCard2;
- (void)addGroupCardAfterCard:(id)aCard;
- (void)setCardGroupUID:(id)aUID forCard:(id)aCard;
- (void)removeGroup:(id)aGroup;
- (void)addGroup:(id)aGroup;
- (id)anyCardWithSameGroup:(id)aGroup forCard:(id)aCard;
- (NSUInteger)cardCountInGroup:(id)aGroup;
- (id)groups;
- (id)undoManager;
- (id)objectsWithNodeDataUID:(id)aUID;
- (id)anyOwningObjectForNodeData:(id)aData;
- (id)nodeDataWithUID:(id)aUID;
- (id)nodeUnitWithUID:(id)aUID;
- (id)cardGroupCursorForCard:(id)aCard;
- (void)setCardGroupCursor:(id)aCursor forCard:(id)aCard;
- (void)removeGroupCards:(id)aCards;
- (void)removeGroupCard:(id)aCard;
- (void)removeGroupObject:(id)aObject;
- (void)makeNonGroupObject:(id)aObject;
- (void)makeGroupObject:(id)aObject;
- (void)makeNonGroupCard:(id)aCard;
- (void)makeNewGroupCard:(id)aCard;
- (void)makeGroupCard:(id)aCard groupUID:(id)aUID;
- (id)cardGroupWithUID:(id)aUID;
- (void)setOwner:(id)aOwner forNodeData:(id)aData;
- (id)ownedNodeDataArray;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (void)dealloc;
@end

