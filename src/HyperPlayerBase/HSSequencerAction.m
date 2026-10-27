#import "HSSequencerAction.h"
#import "HSShowHideObjectAction.h"
#import "HSUID.h"

// Runs the actions of several objects one after another, each after its own
// delay, and finishes once all of them did.
@implementation HSSequencerAction

- (BOOL)isValid
{
    return [_sequenceItems count] != 0;
}

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    NSArray *children = [aRepresentation children];
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:[children count]];
    for (id child in children) {
        id objectUID = [child attributeForName:@"objectUID"];
        if (objectUID == nil)
            continue;
        float delay = [[[child attributeForName:@"delay"] stringValue] floatValue];
        HSSequenceItem *item = [[HSSequenceItem alloc] initWithUID:[HSUID UIDWithString:[objectUID stringValue]] withDelay:delay];
        [items addObject:item];
        [item release];
    }
    [self setSequenceItems:[[items copy] autorelease]];
    [items release];
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    for (id item in [self sequenceItems]) {
        NSXMLElement *itemElement = [NSXMLElement elementWithName:@"sequenceItem"];
        [itemElement addAttribute:[NSXMLNode attributeWithName:@"objectUID" stringValue:[[item objectUID] stringValue]]];
        [itemElement addAttribute:[NSXMLNode attributeWithName:@"delay" stringValue:[NSString stringWithFormat:@"%.2f", [item delay]]]];
        [element addChild:itemElement];
    }
    return element;
}

- (id)XMLElementName
{
    return @"actSequencer";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    NSMutableArray *items = [NSMutableArray new];
    for (id item in [self sequenceItems]) {
        NSString *delay = [NSString stringWithFormat:@"%.2f", [item delay]];
        NSDictionary *itemDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[[item objectUID] stringValue], @"object", delay, @"delay", nil];
        [items addObject:itemDictionary];
        [itemDictionary release];
    }
    if ([items count] == 0)
        dictionary = nil;
    else
        [dictionary setObject:items forKey:@"sequenceItems"];
    [items release];
    return dictionary;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

// Finishes (later) once the actions of the last object are done.
- (void)actionsForObject:(id)aObject didFinishForEvent:(id)aEvent inActionExecutionManager:(id)aManager
{
    if ([[self objectsWithRunningActions] containsObject:aObject]) {
        NSMutableArray *objects = [[self objectsWithRunningActions] mutableCopy];
        [objects removeObject:aObject];
        [self setObjectsWithRunningActions:[[objects copy] autorelease]];
        [objects release];
    }
    if ([[self objectsWithRunningActions] count] == 0)
        [self performSelector:@selector(notifyDidFinish) withObject:nil afterDelay:0];
}

// A hidden object is skipped unless a show/hide action of an object in the
// sequence (its own, or one running no later) shows or toggles it.
- (BOOL)shouldIgnoreObject:(id)aObject withDelay:(CGFloat)aDelay
{
    BOOL hidden = [[aObject queryHyperInterface:@protocol(HSCardObjectHiddenAttribute)] isHiddenInPlayer];
    if (!hidden)
        return NO;
    id UID = [aObject hyperUID];
    for (id item in [self sequenceItems]) {
        id itemUID = [item objectUID];
        if (UID != itemUID && (float)[item delay] > (float)aDelay)
            continue;
        for (id action in [[[self objectWithUID:itemUID] queryHyperInterface:@protocol(HSActor)] hyperActions]) {
            if (![action isKindOfClass:[HSShowHideObjectAction class]])
                continue;
            if ([[action objectsToShow] containsObject:UID] || [[action objectsToToggle] containsObject:UID])
                return NO;
        }
    }
    return YES;
}

- (void)getObjects:(id *)aObjects delays:(id *)aDelays forSequenceItems:(id)aItems
{
    NSMutableArray *objects = aObjects != NULL ? [NSMutableArray arrayWithCapacity:[aItems count]] : nil;
    NSMutableArray *delays = aDelays != NULL ? [NSMutableArray arrayWithCapacity:[aItems count]] : nil;
    for (id item in aItems) {
        id object = [self objectWithUID:[item objectUID]];
        if (object == nil || [self shouldIgnoreObject:object withDelay:[item delay]])
            continue;
        [objects addObject:object];
        [delays addObject:[NSNumber numberWithDouble:[item delay]]];
    }
    if (aObjects != NULL)
        *aObjects = [[objects copy] autorelease];
    if (aDelays != NULL)
        *aDelays = [[delays copy] autorelease];
}

- (id)objectsWithSequenceItems:(id)aItems
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[aItems count]];
    for (id item in aItems) {
        id object = [self objectWithUID:[item objectUID]];
        if (object != nil)
            [objects addObject:object];
    }
    return [[objects copy] autorelease];
}

- (id)sequenceItemForObjectWithUID:(id)aUID
{
    for (id item in [self sequenceItems])
        if ([[item objectUID] isEqual:aUID])
            return item;
    return nil;
}

- (id)objectWithUID:(id)aUID
{
    id object = [[[self stack] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:aUID];
    return [object queryHyperInterface:@protocol(HSObjectAttributes)];
}

// Old documents kept the delays on the objects themselves.
// Old documents only stored the object UIDs.
- (void)setSequenceItems:(id)aItems
{
    if ([[self sequenceItems] isEqualToArray:aItems])
        return;
    _oldFormat = NO;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Objects" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSequenceItems:[self sequenceItems]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSequenceItemsAttribute) ofObject:self withUserInfo:nil];
    [_sequenceItems release];
    _sequenceItems = [aItems retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSequenceItemsAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)objectUIDsForSequnceItems:(id)aItems
{
    NSMutableArray *UIDs = [NSMutableArray array];
    for (id item in aItems)
        [UIDs addObject:[item objectUID]];
    return [NSArray arrayWithArray:UIDs];
}

- (id)sequenceItems
{
    return _sequenceItems;
}

- (void)setObjectsWithRunningActions:(id)aActions
{
    if ([[self objectsWithRunningActions] isEqualToArray:aActions])
        return;
    [_objectsWithRunningActions release];
    _objectsWithRunningActions = [aActions retain];
}

- (id)objectsWithRunningActions
{
    if (_objectsWithRunningActions == nil)
        _objectsWithRunningActions = [NSArray new];
    return _objectsWithRunningActions;
}

- (void)startInContext:(id)aContext
{
    id objects = nil;
    id delays = nil;
    [self getObjects:&objects delays:&delays forSequenceItems:[self sequenceItems]];
    if ([objects count] == 0 || [delays count] == 0) {
        [self performSelector:@selector(notifyDidFinish) withObject:nil afterDelay:0];
        return;
    }
    [self setObjectsWithRunningActions:objects];
    // Fixed: a previous context was leaked when started again.
    [aContext retain];
    [_context release];
    _context = aContext;
    [aContext startSequencerActionForObjects:objects delays:delays forRequestor:self];
}

- (void)stop:(id)aStop
{
    [super stop:aStop];
}

- (BOOL)canBeStopped
{
    return YES;
}

- (void)notifyDidFinish
{
    [_context release];
    _context = nil;
    [super notifyDidFinish];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObject:[@"sequenceItems" extraKeyForCollection]];
}

// Adds the other action's items whose objects aren't being replaced.
- (void)mergeInSequencerAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    NSMutableArray *items = nil;
    for (id item in [aAction sequenceItems]) {
        if ([aDs containsObject:[item objectUID]])
            continue;
        if (items == nil)
            items = [[self sequenceItems] mutableCopy];
        [items addObject:item];
    }
    if (items != nil) {
        [self setSequenceItems:items];
        [items release];
    }
}

// Items of replaced objects are dropped; nothing is left, no copy.
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    NSArray *items = [self sequenceItems];
    NSUInteger count = [items count];
    NSMutableArray *remainingItems = nil;
    NSUInteger removed = 0;
    for (NSUInteger i = 0; i < count; i++) {
        if (![aDs containsObject:[[items objectAtIndex:i] objectUID]])
            continue;
        if (remainingItems == nil)
            remainingItems = [items mutableCopy];
        [remainingItems removeObjectAtIndex:i - removed];
        removed++;
    }
    if (remainingItems == nil)
        return [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
    id copy = nil;
    if ([remainingItems count] != 0) {
        copy = [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
        [copy setSequenceItems:remainingItems];
    }
    [remainingItems release];
    return copy;
}

- (void)dealloc
{
    [_sequenceItems release];
    [_objectsWithRunningActions release];
    // Fixed: the context wasn't released when deallocated while running.
    [_context release];
    [super dealloc];
}

- (BOOL)ignoreHyperActionDelay
{
    return NO;
}

@end

// An object of the sequence and the delay before its actions run.
@implementation HSSequenceItem

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"delay", @"objectUID", nil];
}

- (CGFloat)delay
{
    return _delay;
}

- (void)setDelay:(CGFloat)aDelay
{
    _delay = aDelay;
}

- (id)objectUID
{
    return _objectUID;
}

- (void)setObjectUID:(id)aUID
{
    if (_objectUID == aUID)
        return;
    [_objectUID release];
    _objectUID = [aUID retain];
}

- (void)dealloc
{
    [_objectUID release];
    [super dealloc];
}

- (id)initWithUID:(id)aUID withDelay:(CGFloat)aDelay
{
    self = [super init];
    if (self != nil) {
        [self setObjectUID:aUID];
        [self setDelay:aDelay];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[HSSequenceItem allocWithZone:aZone] initWithExtraDictionary:[self extraDictionaryRepresentation]];
}

@end
