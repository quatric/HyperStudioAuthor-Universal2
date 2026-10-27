#import "HSStackOptimizer.h"

@implementation HSStackOptimizer

- (void)createOptimizersForStack:(id)aStack
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSMapTable *map = [self newMediaUIDToObjectsMapForStack:aStack];
    NSMapEnumerator enumerator;
    void *uid = NULL, *objects = NULL;

    _optimizers = [[NSMutableArray alloc] initWithCapacity:NSCountMapTable(map)];
    enumerator = NSEnumerateMapTable(map);
    while (NSNextMapEnumeratorPair(&enumerator, &uid, &objects)) {
        id optimizer = [HSObjectsOptimizer optimizerForMediaUID:(id)uid usedInObjects:(id)objects];
        if (optimizer != nil)
            [_optimizers addObject:optimizer];
    }
    NSEndMapTableEnumeration(&enumerator);
    NSFreeMapTable(map);
    [pool release];
}

- (id)newMediaUIDToObjectsMapForStack:(id)aStack
{
    NSMapTable *map = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);

    [self addOptimizableObjectsFromEnumerator:[aStack hyperDeepEnumerator] inMediaUIDToObjectsMap:map];
    [self addOptimizableObjectsFromEnumerator:[[HSSoundsInUseProvider playSoundActionsInUseForStack:aStack] objectEnumerator] inMediaUIDToObjectsMap:map];
    [self addOptimizableObjectsFromEnumerator:[[HSMoviesInUseProvider playMovieActionsInUseForStack:aStack] objectEnumerator] inMediaUIDToObjectsMap:map];
    return (id)map;
}

- (void)addOptimizableObjectsFromEnumerator:(id)aEnumerator inMediaUIDToObjectsMap:(id)aMap
{
    id object;

    while ((object = [aEnumerator nextObject]) != nil) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        id optimizable = [object queryHyperInterface:@protocol(HSCardObjectOptimization)];

        if (optimizable != nil) {
            NSArray *uids = [optimizable mediaUIDsForOptimization];
            if ([uids count] != 0) {
                NSEnumerator *e = [uids objectEnumerator];
                id uid;
                while ((uid = [e nextObject]) != nil) {
                    NSMutableSet *set = NSMapGet((NSMapTable *)aMap, uid);
                    if (set == nil)
                        NSMapInsert((NSMapTable *)aMap, uid, [NSMutableSet setWithObject:optimizable]);
                    else
                        [set addObject:optimizable];
                }
            }
        }
        [pool release];
    }
}

- (void)postprocessAfterOptimization
{
    [_optimizers makeObjectsPerformSelector:@selector(postprocessAfterOptimization)];
}

- (void)optimizeStack:(id)aStack
{
    [self createOptimizersForStack:aStack];
    [_optimizers makeObjectsPerformSelector:@selector(optimize)];
}

- (void)dealloc
{
    [_optimizers release];
    [super dealloc];
}

@end
