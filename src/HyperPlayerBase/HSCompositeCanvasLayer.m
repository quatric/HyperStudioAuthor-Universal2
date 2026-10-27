#import "HSCompositeCanvasLayer.h"
// A canvas layer holding sublayers.
@implementation HSCompositeCanvasLayer
// Sublayers from the first one whose position changed are redisplayed.
- (void)setReorderedSublayers:(id)aSublayers
{
    NSArray *previous = [NSArray arrayWithArray:_sublayers];
    [_sublayers removeAllObjects];
    [_sublayers addObjectsFromArray:aSublayers];
    NSUInteger count = [_sublayers count];
    NSUInteger index;
    for (index = 0; index < count; index++)
        if ([previous objectAtIndex:index] != [_sublayers objectAtIndex:index])
            break;
    for (; index < count; index++)
        [[_sublayers objectAtIndex:index] invalidateDisplay];
}
- (void)removeSublayerFromStorage:(id)aStorage atIndex:(NSUInteger)aIndex
{
    [[self sublayers] removeObjectAtIndex:aIndex];
}
- (void)insertSublayerInStorage:(id)aStorage atIndex:(NSUInteger)aIndex
{
    NSMutableArray *sublayers = [self sublayers];
    if (aIndex < [sublayers count])
        [sublayers insertObject:aStorage atIndex:aIndex];
    else if (aIndex == [sublayers count])
        [sublayers addObject:aStorage];
}
- (NSUInteger)indexOfSublayer:(id)aSublayer
{
    return [[self sublayers] indexOfObject:aSublayer];
}
- (id)sublayerAtIndex:(NSUInteger)aIndex
{
    return [[self sublayers] objectAtIndex:aIndex];
}
- (NSUInteger)numberOfSublayers
{
    return [[self sublayers] count];
}
- (id)allSublayers
{
    return _sublayers;
}
- (id)sublayers
{
    if (_sublayers == nil)
        _sublayers = [NSMutableArray new];
    return _sublayers;
}
- (void)dealloc
{
    [_sublayers makeObjectsPerformSelector:@selector(setParentLayer:) withObject:nil];
    [_sublayers release];
    [super dealloc];
}
@end
