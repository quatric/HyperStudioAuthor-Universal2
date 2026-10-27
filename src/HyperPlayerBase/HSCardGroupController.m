#import "HSCardGroupController.h"
#import "HSCard.h"
#import "HSCardGroup.h"
#import "HSNode.h"
#import "NSMutableArray+EXMutableArray.h"

// Group cards share their group objects' node data and shareable node units
// through an HSCardGroup. Every change registers its inverse with the owner's
// undo manager.
@implementation HSCardGroupController

- (id)oldUIDsToNewUIDsMap
{
    if (_oldUIDsToNewUIDsMap == nil)
        _oldUIDsToNewUIDsMap = [NSMutableDictionary new];
    return _oldUIDsToNewUIDsMap;
}

- (id)allGroupedObjectsUIDs
{
    NSMutableSet *UIDs = [NSMutableSet set];
    NSEnumerator *groupEnumerator = [[_owner groupsForCardGroupController:self] objectEnumerator];
    id group;
    while ((group = [groupEnumerator nextObject]) != nil) {
        NSEnumerator *dataEnumerator = [group dataEnumerator];
        id nodeData;
        while ((nodeData = [dataEnumerator nextObject]) != nil) {
            id UID = [[self anyOwningObjectForNodeData:nodeData] hyperUID];
            if (UID != nil)
                [UIDs addObject:UID];
        }
    }
    return UIDs;
}

- (id)allActorsForGroupUID:(id)aUID
{
    NSMutableArray *actors = nil;
    NSEnumerator *enumerator = [[_owner cardsForCardGroupController:self] objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        if ([[card cardGroupUID] isEqual:aUID] && [card actor] != nil) {
            if (actors == nil)
                actors = [NSMutableArray arrayWithCapacity:0];
            [actors addObject:[card actor]];
        }
    }
    return actors;
}

- (id)allCardsForGroupUID:(id)aUID
{
    NSMutableArray *cards = nil;
    NSEnumerator *enumerator = [[_owner cardsForCardGroupController:self] objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        if ([[card cardGroupUID] isEqual:aUID]) {
            if (cards == nil)
                cards = [NSMutableArray arrayWithCapacity:0];
            [cards addObject:card];
        }
    }
    return cards;
}

- (void)injectNodeUnitsFrom:(id)aFrom to:(id)aTo
{
    NSEnumerator *enumerator = [aFrom unitRoleEnumerator];
    id role;
    while ((role = [enumerator nextObject]) != nil) {
        id unit = [aFrom unitForRole:role];
        if ([unit supportsSharingBetweenGroupObjects])
            [aTo injectUnit:unit forRole:role];
    }
}

- (void)HSCardGroupController_copyUnitsOfNode:(id)aNode
{
    NSEnumerator *enumerator = [aNode unitRoleEnumerator];
    id role;
    while ((role = [enumerator nextObject]) != nil) {
        id unit = [[[aNode unitForRole:role] copyWithZone:NULL] autorelease];
        if (unit != nil)
            [aNode injectUnit:unit forRole:role];
    }
}

- (void)HSCardGroupController_unshareUnitsOfNode:(id)aNode withCardGroup:(id)aGroup
{
    [[[self undoManager] prepareWithInvocationTarget:self] HSCardGroupController_shareUnitsOfNode:aNode withCardGroup:aGroup];
    NSEnumerator *enumerator = [aNode unitEnumerator];
    id unit;
    while ((unit = [enumerator nextObject]) != nil)
        [aGroup removeNodeUnit:unit];
}

- (void)HSCardGroupController_shareUnitsOfNode:(id)aNode withCardGroup:(id)aGroup
{
    [[[self undoManager] prepareWithInvocationTarget:self] HSCardGroupController_unshareUnitsOfNode:aNode withCardGroup:aGroup];
    NSEnumerator *enumerator = [aNode unitRoleEnumerator];
    id role;
    while ((role = [enumerator nextObject]) != nil) {
        id unit = [aNode unitForRole:role];
        if ([unit supportsSharingBetweenGroupObjects])
            [aGroup addNodeUnit:unit forRole:role];
    }
}

// The actions move to another actor of the group.
- (void)unshareActionsOfActor:(id)aActor withActors:(id)aActors
{
    NSArray *actions = [[aActor hyperActions] retain];
    [aActor setHyperActions:nil];
    if ([aActors count] != 0)
        [actions makeObjectsPerformSelector:@selector(setOwner:) withObject:[aActors extraFirstObject]];
    [actions release];
}

- (void)shareActionsOfActor:(id)aActor withActor:(id)aActor2
{
    [aActor2 setHyperActions:[aActor hyperActions]];
}

- (void)postProcessObject:(id)aObject createdFrom:(id)aFrom
{
    [aObject postProcessAfterCreationFromGroupObject:aFrom];
}

- (void)removeNodeData:(id)aData fromCardGroup:(id)aGroup
{
    [[[self undoManager] prepareWithInvocationTarget:self] addNodeData:aData toCardGroup:aGroup];
    if ([aData owner] == self)
        [self setOwner:nil forNodeData:aData];
    [aGroup removeData:aData];
}

- (void)addNodeData:(id)aData toCardGroup:(id)aGroup
{
    [[[self undoManager] prepareWithInvocationTarget:self] removeNodeData:aData fromCardGroup:aGroup];
    [self setOwner:self forNodeData:aData];
    [aGroup addData:aData];
}

- (void)removeGroupObject:(id)aObject fromCard:(id)aCard
{
    NSUInteger index = [[aCard hyperChildren] indexOfObject:aObject];
    [[[self undoManager] prepareWithInvocationTarget:self] addGroupObject:aObject toCard:aCard atIndex:index];
    [[self undoManager] disableUndoRegistration];
    [aCard removeHyperChild:aObject];
    [[self undoManager] enableUndoRegistration];
}

- (void)addGroupObject:(id)aObject toCard:(id)aCard atIndex:(NSUInteger)aIndex
{
    [[[self undoManager] prepareWithInvocationTarget:self] removeGroupObject:aObject fromCard:aCard];
    [[self undoManager] disableUndoRegistration];
    [aCard insertHyperChild:aObject atIndex:aIndex];
    [[self undoManager] enableUndoRegistration];
}

- (void)makeObject:(id)aObject useLocalData:(id)aData
{
    [[[self undoManager] prepareWithInvocationTarget:self] makeObject:aObject useSharedData:[aObject nodeData]];
    [aObject setLocalNodeData:aData];
    [aObject setSharedNodeDataUID:nil];
    [self setOwner:aObject forNodeData:[aObject nodeData]];
    [aObject disassociateImplementation:self fromInterface:@protocol(HSActor)];
}

- (void)makeObject:(id)aObject useSharedData:(id)aData
{
    [[[self undoManager] prepareWithInvocationTarget:self] makeObject:aObject useLocalData:[aObject nodeData]];
    [aObject setSharedNodeDataUID:[aData nodeDataUID]];
    [aObject setLocalNodeData:nil];
    [self setOwner:self forNodeData:[aObject nodeData]];
}

- (void)moveDataFromGroupToObject:(id)aObject cardGroup:(id)aGroup
{
    id nodeData = [aGroup nodeDataWithUID:[aObject sharedNodeDataUID]];
    [aObject setLocalNodeData:nodeData];
    [aObject setSharedNodeDataUID:nil];
    [aGroup removeData:nodeData];
    [self setOwner:aObject forNodeData:[aObject nodeData]];
    [[[self undoManager] prepareWithInvocationTarget:self] moveDataToGroupFromObject:aObject cardGroup:aGroup];
}

- (void)moveDataToGroupFromObject:(id)aObject cardGroup:(id)aGroup
{
    [aGroup addData:[aObject localNodeData]];
    [aObject setSharedNodeDataUID:[[aObject localNodeData] nodeDataUID]];
    [aObject setLocalNodeData:nil];
    [self setOwner:self forNodeData:[aObject nodeData]];
    [[[self undoManager] prepareWithInvocationTarget:self] moveDataFromGroupToObject:aObject cardGroup:aGroup];
}

- (void)setGroupObjectFlag:(BOOL)aFlag forObject:(id)aObject
{
    [[[self undoManager] prepareWithInvocationTarget:self] setGroupObjectFlag:[[aObject nodeData] groupObjectFlag] forObject:aObject];
    [[aObject nodeData] setGroupObjectFlag:aFlag];
}

- (void)removeCards:(id)aCards atIndexes:(id)aIndexes
{
    [[[self undoManager] prepareWithInvocationTarget:self] addCards:aCards atIndexes:aIndexes];
    [aCards makeObjectsPerformSelector:@selector(notifyWillChangeCardGroupAttribute)];
    [[self undoManager] disableUndoRegistration];
    [_owner cardGroupController:self removeCardsAtIndexes:aIndexes];
    [[self undoManager] enableUndoRegistration];
    [aCards makeObjectsPerformSelector:@selector(notifyDidChangeCardGroupAttribute)];
}

- (void)addCards:(id)aCards atIndexes:(id)aIndexes
{
    [[[self undoManager] prepareWithInvocationTarget:self] removeCards:aCards atIndexes:aIndexes];
    [[self undoManager] disableUndoRegistration];
    [_owner cardGroupController:self addCards:aCards atIndexes:aIndexes];
    [[self undoManager] enableUndoRegistration];
}

- (void)removeCard:(id)aCard fromGroup:(id)aGroup
{
    [[[self undoManager] prepareWithInvocationTarget:self] addCard:aCard toGroup:aGroup];
    [aCard setCardGroupUID:nil];
}

- (void)addCard:(id)aCard toGroup:(id)aGroup
{
    [[[self undoManager] prepareWithInvocationTarget:self] removeCard:aCard fromGroup:aGroup];
    [aCard setCardGroupUID:[aGroup groupUID]];
}

- (void)removeGroupCard:(id)aCard withGroupObjects:(id)aObjects afterCard:(id)aCard2
{
    [[self undoManager] disableUndoRegistration];
    NSUInteger index = [[_owner cardsForCardGroupController:self] indexOfObject:aCard2];
    [aCard setCardGroupUID:nil];
    [_owner cardGroupController:self removeCardsAtIndexes:[NSIndexSet indexSetWithIndex:index + 1]];
    [aCard removeHyperAllChildren];
    [[self undoManager] enableUndoRegistration];
    [[[self undoManager] prepareWithInvocationTarget:self] addGroupCard:aCard withGroupObjects:aObjects afterCard:aCard2];
}

- (void)addGroupCard:(id)aCard withGroupObjects:(id)aObjects afterCard:(id)aCard2
{
    [[self undoManager] disableUndoRegistration];
    [aCard setChildren:nil];
    NSUInteger index = [[_owner cardsForCardGroupController:self] indexOfObject:aCard2];
    [self injectNodeUnitsFrom:aCard2 to:aCard];
    [aCard setCardGroupUID:[aCard2 cardGroupUID]];
    NSUInteger selectedIndex = [aCard2 indexOfHyperChild:[[[aCard2 document] mainWindowController] selectedUserObject]];
    [_owner cardGroupController:self addCards:[NSArray arrayWithObject:aCard] atIndexes:[NSIndexSet indexSetWithIndex:index + 1]];
    NSEnumerator *enumerator = [aObjects objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil)
        [aCard addHyperChild:object];
    // Keep the same object selected on the new card.
    if (selectedIndex != NSNotFound && selectedIndex < [aCard hyperCount])
        [[[aCard document] cardView] selectHyperObject:[aCard hyperChildAtIndex:selectedIndex]];
    [self shareActionsOfActor:[aCard2 actor] withActor:[aCard actor]];
    [[self undoManager] enableUndoRegistration];
    [[[self undoManager] prepareWithInvocationTarget:self] removeGroupCard:aCard withGroupObjects:aObjects afterCard:aCard2];
}

- (void)addGroupCardAfterCard:(id)aCard
{
    id card = [HSCard node];
    NSMutableArray *groupObjects = [[NSMutableArray new] autorelease];
    NSUInteger index;
    for (index = 0; index < [[aCard hyperChildren] count]; index++) {
        id child = [aCard hyperChildAtIndex:index];
        if (![child isGroupObject])
            continue;
        id object = [[[[child class] alloc] initWithExplicitNodeDataProvider:self sharedNodeDataUID:[child sharedNodeDataUID]] autorelease];
        [self injectNodeUnitsFrom:child to:object];
        [self postProcessObject:object createdFrom:child];
        [groupObjects addObject:object];
    }
    [self addGroupCard:card withGroupObjects:groupObjects afterCard:aCard];
}

- (void)setCardGroupUID:(id)aUID forCard:(id)aCard
{
    [[[self undoManager] prepareWithInvocationTarget:self] setCardGroupUID:[aCard cardGroupUID] forCard:aCard];
    [aCard setCardGroupUID:aUID];
}

- (void)removeGroup:(id)aGroup
{
    [[[self undoManager] prepareWithInvocationTarget:self] addGroup:aGroup];
    [[self groups] removeObject:aGroup];
}

- (void)addGroup:(id)aGroup
{
    [[[self undoManager] prepareWithInvocationTarget:self] removeGroup:aGroup];
    [[self groups] addObject:aGroup];
}

- (id)anyCardWithSameGroup:(id)aGroup forCard:(id)aCard
{
    NSEnumerator *enumerator = [[_owner cardsForCardGroupController:self] objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        if (card != aCard && [card cardGroupUID] != nil && [[card cardGroupUID] isEqual:[aGroup groupUID]])
            return card;
    }
    return nil;
}

- (NSUInteger)cardCountInGroup:(id)aGroup
{
    NSUInteger count = 0;
    NSEnumerator *enumerator = [[_owner cardsForCardGroupController:self] objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        if ([card cardGroupUID] != nil && [[card cardGroupUID] isEqual:[aGroup groupUID]])
            count++;
    }
    return count;
}

- (id)groups
{
    return [_owner groupsForCardGroupController:self];
}

- (id)undoManager
{
    return [_owner undoManagerForCardGroupController:self];
}

// The group objects (one per card) sharing the node data with this UID.
- (id)objectsWithNodeDataUID:(id)aUID
{
    NSEnumerator *groupEnumerator = [[self groups] objectEnumerator];
    id group;
    while ((group = [groupEnumerator nextObject]) != nil) {
        if ([group nodeDataWithUID:aUID] != nil)
            break;
    }

    NSMutableArray *objects = [[NSMutableArray new] autorelease];
    NSEnumerator *cardEnumerator = [[_owner cardsForCardGroupController:self] objectEnumerator];
    id card;
    while ((card = [cardEnumerator nextObject]) != nil) {
        if ([card cardGroupUID] == nil || ![[card cardGroupUID] isEqual:[group groupUID]])
            continue;
        NSEnumerator *childEnumerator = [[card hyperChildren] objectEnumerator];
        id child;
        while ((child = [childEnumerator nextObject]) != nil) {
            if ([child isGroupObject] && [[child sharedNodeDataUID] isEqual:aUID]) {
                [objects addObject:child];
                break;
            }
        }
    }
    return objects;
}

- (id)anyOwningObjectForNodeData:(id)aData
{
    NSArray *objects = [self objectsWithNodeDataUID:[aData nodeDataUID]];
    if ([objects count] == 0)
        return nil;
    return [objects objectAtIndex:0];
}

- (id)nodeDataWithUID:(id)aUID
{
    NSEnumerator *enumerator = [[self groups] objectEnumerator];
    id group;
    while ((group = [enumerator nextObject]) != nil) {
        id nodeData = [group nodeDataWithUID:aUID];
        if (nodeData != nil)
            return nodeData;
    }
    return nil;
}

- (id)nodeUnitWithUID:(id)aUID
{
    NSEnumerator *enumerator = [[self groups] objectEnumerator];
    id group;
    while ((group = [enumerator nextObject]) != nil) {
        id unit = [group nodeUnitWithUID:aUID];
        if (unit != nil)
            return unit;
    }
    return nil;
}

- (id)cardGroupCursorForCard:(id)aCard
{
    return [[self cardGroupWithUID:[aCard cardGroupUID]] cursor];
}

- (void)setCardGroupCursor:(id)aCursor forCard:(id)aCard
{
    [[self cardGroupWithUID:[aCard cardGroupUID]] setCursor:aCursor];
}

- (void)removeGroupCards:(id)aCards
{
    NSMutableSet *groupUIDs = [[NSMutableSet alloc] init];
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    NSEnumerator *enumerator = [aCards objectEnumerator];
    id card;
    while ((card = [enumerator nextObject]) != nil) {
        [groupUIDs addObject:[card cardGroupUID]];
        [indexes addIndex:[[_owner cardsForCardGroupController:self] indexOfObject:card]];
        id otherActors = [card otherActorsFromGroup:[card actor]];
        [self setCardGroupUID:nil forCard:card];
        [self unshareActionsOfActor:[card actor] withActors:otherActors];
    }
    [self removeCards:aCards atIndexes:indexes];

    // A group left with a single card is dissolved.
    enumerator = [groupUIDs objectEnumerator];
    id groupUID;
    while ((groupUID = [enumerator nextObject]) != nil) {
        NSArray *cards = [self allCardsForGroupUID:groupUID];
        if ([cards count] == 1)
            [self makeNonGroupCard:[cards lastObject]];
    }
    [indexes release];
    [groupUIDs release];
}

- (void)removeGroupCard:(id)aCard
{
    [self removeGroupCards:[NSArray arrayWithObject:aCard]];
}

- (void)removeGroupObject:(id)aObject
{
    id group = [self cardGroupWithUID:[[aObject card] cardGroupUID]];
    [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Remove Item" value:@"" table:@"UndoManager"]];
    id nodeData = [[aObject nodeData] retain];
    NSEnumerator *enumerator = [[self objectsWithNodeDataUID:[nodeData nodeDataUID]] objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil)
        [self removeGroupObject:object fromCard:[object card]];
    [self removeNodeData:nodeData fromCardGroup:group];
    [self HSCardGroupController_unshareUnitsOfNode:aObject withCardGroup:group];
    [nodeData release];
}

- (void)makeNonGroupObject:(id)aObject
{
    id objectCard = [aObject card];
    [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Make Non Group Object" value:@"" table:@"UndoManager"]];
    if ([objectCard cardGroupUID] != nil) {
        id group = [self cardGroupWithUID:[objectCard cardGroupUID]];
        // Remove the copies on the other cards of the group.
        NSEnumerator *cardEnumerator = [[_owner cardsForCardGroupController:self] objectEnumerator];
        id card;
        while ((card = [cardEnumerator nextObject]) != nil) {
            if (card == objectCard || [card cardGroupUID] == nil || ![[card cardGroupUID] isEqual:[objectCard cardGroupUID]])
                continue;
            NSEnumerator *childEnumerator = [[card hyperChildren] objectEnumerator];
            id child;
            while ((child = [childEnumerator nextObject]) != nil) {
                if ([child isGroupObject] && [[child sharedNodeDataUID] isEqual:[aObject sharedNodeDataUID]]) {
                    [self removeGroupObject:child fromCard:card];
                    break;
                }
            }
        }
        [self moveDataFromGroupToObject:aObject cardGroup:group];
        [self HSCardGroupController_unshareUnitsOfNode:aObject withCardGroup:group];
    }
    [self setGroupObjectFlag:NO forObject:aObject];
}

- (void)makeGroupObject:(id)aObject
{
    id objectCard = [aObject card];
    [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Make Group Object" value:@"" table:@"UndoManager"]];
    [self setGroupObjectFlag:YES forObject:aObject];
    if ([objectCard cardGroupUID] == nil)
        return;

    id group = [self cardGroupWithUID:[objectCard cardGroupUID]];
    [self moveDataToGroupFromObject:aObject cardGroup:group];
    [self HSCardGroupController_shareUnitsOfNode:aObject withCardGroup:group];
    // Insert a copy on every other card of the group, before the same next group object.
    id nextNodeData = [[aObject nextGroupNode] nodeData];
    NSEnumerator *cardEnumerator = [[_owner cardsForCardGroupController:self] objectEnumerator];
    id card;
    while ((card = [cardEnumerator nextObject]) != nil) {
        if (card == objectCard || [card cardGroupUID] == nil || ![[card cardGroupUID] isEqual:[objectCard cardGroupUID]])
            continue;
        id object = [[aObject class] nodeWithDictionary:[aObject extraDictionaryRepresentation] explicitNodeDataProvider:[aObject nodeDataProvider]];
        [self postProcessObject:object createdFrom:aObject];
        NSUInteger index;
        if (nextNodeData != nil)
            index = [card indexOfHyperChild:[card childNodeWithNodeData:nextNodeData]];
        else
            index = [card hyperCount];
        [self addGroupObject:object toCard:card atIndex:index];
    }
}

- (void)makeNonGroupCard:(id)aCard
{
    [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Make Non Group Card" value:@"" table:@"UndoManager"]];
    [aCard notifyWillChangeCardGroupAttribute];
    id group = [self cardGroupWithUID:[aCard cardGroupUID]];
    NSEnumerator *enumerator = [[aCard hyperChildren] objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        if (![child isGroupObject])
            continue;
        // Other cards still use the shared data: take a copy.
        if ([self cardCountInGroup:group] >= 2)
            [self makeObject:child useLocalData:[[[child nodeData] localCopy] autorelease]];
        else
            [self moveDataFromGroupToObject:child cardGroup:group];
        [self HSCardGroupController_copyUnitsOfNode:child];
    }
    if ([self cardCountInGroup:group] > 1)
        [self HSCardGroupController_copyUnitsOfNode:aCard];

    id otherActors = [aCard otherActorsFromGroup:[aCard actor]];
    [self removeCard:aCard fromGroup:group];
    if ([self cardCountInGroup:group] != 0)
        [self unshareActionsOfActor:[aCard actor] withActors:otherActors];
    [aCard notifyDidChangeCardGroupAttribute];

    NSUInteger count = [self cardCountInGroup:group];
    if (count == 0) {
        [self removeGroup:group];
    } else if (count == 1) {
        // The last card of the group stops being a group card too.
        enumerator = [[_owner cardsForCardGroupController:self] objectEnumerator];
        id card;
        while ((card = [enumerator nextObject]) != nil) {
            if ([card cardGroupUID] != nil && [[card cardGroupUID] isEqual:[group groupUID]])
                break;
        }
        [self makeNonGroupCard:card];
    }
}

- (void)makeNewGroupCard:(id)aCard
{
    [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Make Group Card" value:@"" table:@"UndoManager"]];
    if ([aCard cardGroupUID] == nil) {
        [aCard notifyWillChangeCardGroupAttribute];
        id group = [[HSCardGroup new] autorelease];
        [self addGroup:group];
        [self setCardGroupUID:[group groupUID] forCard:aCard];
        [self HSCardGroupController_shareUnitsOfNode:aCard withCardGroup:group];
        NSEnumerator *enumerator = [[aCard hyperChildren] objectEnumerator];
        id child;
        while ((child = [enumerator nextObject]) != nil) {
            if ([child isGroupObject]) {
                [self moveDataToGroupFromObject:child cardGroup:group];
                [self HSCardGroupController_shareUnitsOfNode:child withCardGroup:group];
            }
        }
        [aCard notifyDidChangeCardGroupAttribute];
    }
    [self addGroupCardAfterCard:aCard];
    [self setCardGroupCursor:[aCard hyperCursor] forCard:aCard];
}

- (void)makeGroupCard:(id)aCard groupUID:(id)aUID
{
    [[self undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Make Group Card" value:@"" table:@"UndoManager"]];
    [aCard notifyWillChangeCardGroupAttribute];
    id group = [self cardGroupWithUID:aUID];
    if (group == nil) {
        group = [[HSCardGroup new] autorelease];
        [group setGroupUID:aUID];
        [self addGroup:group];
        [self HSCardGroupController_shareUnitsOfNode:aCard withCardGroup:group];
        NSEnumerator *enumerator = [[aCard hyperChildren] objectEnumerator];
        id child;
        while ((child = [enumerator nextObject]) != nil) {
            if ([child isGroupObject]) {
                [self moveDataToGroupFromObject:child cardGroup:group];
                [self HSCardGroupController_shareUnitsOfNode:child withCardGroup:group];
            }
        }
    } else {
        // Joining an existing group: replace the card's group objects with
        // the group's, keeping the texts of matching text objects.
        id groupCard = [self anyCardWithSameGroup:group forCard:aCard];
        [self injectNodeUnitsFrom:groupCard to:aCard];
        NSMutableDictionary *texts = [[NSMutableDictionary alloc] init];
        NSEnumerator *enumerator = [[aCard hyperChildren] objectEnumerator];
        id child;
        while ((child = [enumerator nextObject]) != nil) {
            if (![child isGroupObject])
                continue;
            if ([child implementsHyperInterface:@protocol(HSSystemTextViewAttributes)])
                [texts setObject:[[child queryHyperInterface:@protocol(HSSystemTextViewAttributes)] hyperText] forKey:[child hyperUID]];
            [aCard removeHyperChild:child];
        }
        enumerator = [[groupCard hyperChildren] objectEnumerator];
        while ((child = [enumerator nextObject]) != nil) {
            if (![child isGroupObject])
                continue;
            id object = [[[[child class] alloc] initWithExplicitNodeDataProvider:self sharedNodeDataUID:[child sharedNodeDataUID]] autorelease];
            [self injectNodeUnitsFrom:child to:object];
            if ([object implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]) {
                id text = [texts objectForKey:[object hyperUID]];
                if (text != nil)
                    [[object queryHyperInterface:@protocol(HSSystemTextViewAttributes)] setHyperText:text];
            }
            [aCard addHyperChild:object];
        }
        [texts release];
        [self shareActionsOfActor:[groupCard actor] withActor:[aCard actor]];
    }
    [self addCard:aCard toGroup:group];
    [aCard notifyDidChangeCardGroupAttribute];
}

- (id)cardGroupWithUID:(id)aUID
{
    NSEnumerator *enumerator = [[self groups] objectEnumerator];
    id group;
    while ((group = [enumerator nextObject]) != nil) {
        if ([[group groupUID] isEqual:aUID])
            return group;
    }
    return nil;
}

- (void)setOwner:(id)aOwner forNodeData:(id)aData
{
    if (aData == nil)
        return;
    [aData setOwner:aOwner];
    if (aOwner == self)
        [[self ownedNodeDataArray] addObject:aData];
    else
        [[self ownedNodeDataArray] removeObject:aData];
}

- (id)ownedNodeDataArray
{
    if (_ownedNodeDataArray == nil)
        _ownedNodeDataArray = [NSMutableArray new];
    return _ownedNodeDataArray;
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

- (void)dealloc
{
    [_oldUIDsToNewUIDsMap release];
    [_ownedNodeDataArray makeObjectsPerformSelector:@selector(setOwner:) withObject:nil];
    [_ownedNodeDataArray release];
    [super dealloc];
}

@end
