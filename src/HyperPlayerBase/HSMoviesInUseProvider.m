#import "HSMoviesInUseProvider.h"
@implementation HSMoviesInUseProvider
// The stack's movie objects plus the movies its Play Movie actions use.
+ (id)moviesInUseForStack:(id)aStack
{
    NSMutableArray *movies = [NSMutableArray array];
    NSEnumerator *actions = [[self playMovieActionsInUseForStack:aStack] objectEnumerator];
    id action;
    while ((action = [actions nextObject]) != nil)
        [movies addObjectsFromArray:[self availableMovieObjectsForPlayMovieAction:action]];
    return [[HSMoviesInUseProvider mergePlayableObjects:[self playMovieObjectsInStack:aStack] withPlayableObjects:movies] allObjects];
}
+ (id)playMovieObjectsInStack:(id)aStack
{
    return [HSMoviesInUseProvider availableObjectsInStack:aStack forProtocol:@protocol(HSMovieObjectAttributes)];
}
// Play Movie actions of every object in the stack and of their hypertext
// links.
+ (id)playMovieActionsInUseForStack:(id)aStack
{
    NSMutableArray *actions = [NSMutableArray array];
    NSEnumerator *objects = [aStack hyperDeepEnumerator];
    id object;
    while ((object = [objects nextObject]) != nil) {
        [actions addObjectsFromArray:[[object queryHyperInterface:@protocol(HSActor)] hyperActionsOfType:[HSPlayMovieAction actionType]]];
        NSEnumerator *links = [[[object queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] allLinks] objectEnumerator];
        id link;
        while ((link = [links nextObject]) != nil)
            [actions addObjectsFromArray:[[link queryHyperInterface:@protocol(HSActor)] hyperActionsOfType:[HSPlayMovieAction actionType]]];
    }
    return actions;
}
// The union by UID, preferring the second list's objects. Original quirk
// kept: an object of the first list without object attributes ends the
// first pass.
+ (id)mergePlayableObjects:(id)aObjects withPlayableObjects:(id)aObjects2
{
    NSMutableSet *merged = [NSMutableSet set];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSMutableDictionary *byUID = [NSMutableDictionary dictionary];
    NSUInteger count = [aObjects count];
    NSUInteger count2 = [aObjects2 count];
    for (NSUInteger i = 0; i < count2; i++) {
        id attributes = [[aObjects2 objectAtIndex:i] queryHyperInterface:@protocol(HSObjectAttributes)];
        if (attributes != nil)
            [byUID setObject:attributes forKey:[attributes hyperUID]];
    }
    for (NSUInteger i = 0; i < count; i++) {
        id attributes = [[aObjects objectAtIndex:i] queryHyperInterface:@protocol(HSObjectAttributes)];
        if (attributes == nil)
            break;
        id other = [byUID objectForKey:[attributes hyperUID]];
        if (other != nil) {
            [merged addObject:other];
            [byUID removeObjectForKey:[attributes hyperUID]];
        } else
            [merged addObject:attributes];
    }
    for (NSUInteger i = 0; i < count2; i++) {
        id attributes = [[aObjects2 objectAtIndex:i] queryHyperInterface:@protocol(HSObjectAttributes)];
        if ([byUID objectForKey:[attributes hyperUID]] != nil)
            [merged addObject:attributes];
    }
    [pool release];
    return merged;
}
// The objects of the stack's cards implementing the protocol, an object
// with shared node data counted once: its first instance, or on a group
// card the one on the current card.
+ (id)availableObjectsInStack:(id)aStack forProtocol:(id)aProtocol
{
    NSMutableArray *objects = [NSMutableArray array];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSMutableSet *seen = [NSMutableSet set];
    id currentCard = [[aStack document] currentCard];
    NSArray *cards = [aStack hyperChildren];
    NSUInteger cardCount = [cards count];
    for (NSUInteger i = 0; i < cardCount; i++) {
        id card = [cards objectAtIndex:i];
        NSArray *children = [card hyperChildren];
        NSUInteger childCount = [children count];
        BOOL groupCard = [card isGroupCard];
        for (NSUInteger j = 0; j < childCount; j++) {
            id child = [children objectAtIndex:j];
            if (![child implementsHyperInterface:aProtocol] || [seen containsObject:child])
                continue;
            if ([child sharedNodeDataUID] == nil) {
                [objects addObject:child];
                continue;
            }
            id nodeData = [child nodeData];
            NSArray *instances = [[nodeData owner] objectsWithNodeDataUID:[nodeData nodeDataUID]];
            NSUInteger instanceCount = [instances count];
            if (instanceCount == 0)
                continue;
            id chosen = nil;
            if (!groupCard) {
                if ([seen containsObject:[instances objectAtIndex:0]])
                    continue;
                chosen = [instances objectAtIndex:0];
            } else {
                for (NSUInteger k = 0; k < instanceCount && chosen == nil; k++) {
                    id instance = [instances objectAtIndex:k];
                    if (instance != nil && [instance hyperParent] == currentCard)
                        chosen = instance;
                }
                if (chosen == nil)
                    chosen = [instances objectAtIndex:0];
            }
            [objects addObject:chosen];
            [seen addObjectsFromArray:instances];
        }
    }
    [pool release];
    return objects;
}
// The movie objects (any card) of a Play Movie action's movies.
+ (id)availableMovieObjectsForPlayMovieAction:(id)aAction
{
    NSMutableArray *objects = [NSMutableArray new];
    if ([aAction queryHyperInterface:@protocol(HSPlaybackItemSupport)] != nil) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        NSEnumerator *movies = [[aAction movies] objectEnumerator];
        id movie;
        while ((movie = [movies nextObject]) != nil) {
            id object = [movie movieObjectForCard:nil];
            if (object != nil)
                [objects addObject:object];
        }
        [pool release];
    }
    return [objects autorelease];
}
@end
