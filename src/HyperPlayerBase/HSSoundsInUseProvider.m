#import "HSSoundsInUseProvider.h"
@implementation HSSoundsInUseProvider
+ (id)soundsInUseWithMediaUID:(id)aUID forStack:(id)aStack
{
    NSMutableArray *sounds = [NSMutableArray new];
    for (id action in [[self class] playSoundActionsInUseForStack:aStack]) {
        NSMutableArray *matching = [NSMutableArray new];
        for (id sound in [action sounds])
            if ([aUID isEqual:[sound mediaUID]])
                [matching addObject:sound];
        [sounds addObjectsFromArray:matching];
        [matching release];
    }
    NSArray *result = [NSArray arrayWithArray:sounds];
    [sounds release];
    return result;
}
+ (id)soundsInUseForStack:(id)aStack
{
    // one sound per medium
    NSMutableArray *sounds = [NSMutableArray new];
    NSEnumerator *actions = [[self playSoundActionsInUseForStack:aStack] objectEnumerator];
    id action;
    while ((action = [actions nextObject]) != nil) {
        NSEnumerator *enumerator = [[action sounds] objectEnumerator];
        id sound;
        while ((sound = [enumerator nextObject]) != nil) {
            BOOL known = NO;
            NSEnumerator *known_ = [sounds objectEnumerator];
            id other;
            while ((other = [known_ nextObject]) != nil)
                if ([[other media] isEqual:[sound media]]) {
                    known = YES;
                    break;
                }
            if (!known)
                [sounds addObject:sound];
        }
    }
    NSArray *result = [[[NSSet setWithArray:sounds] allObjects] copy];
    [sounds release];
    return [result autorelease];
}
+ (id)playSoundActionsInUseForStack:(id)aStack
{
    // the play sound actions of every object of the stack and of its
    // objects' hypertext links
    NSMutableArray *actions = [NSMutableArray array];
    NSEnumerator *objects = [aStack hyperDeepEnumerator];
    id object;
    while ((object = [objects nextObject]) != nil) {
        [actions addObjectsFromArray:[(id<HSActor>)[object queryHyperInterface:@protocol(HSActor)]
            hyperActionsOfType:[HSPlaySoundAction actionType]]];
        NSEnumerator *links = [[(id<HSHypertextLinkContainerAttributes>)[object queryHyperInterface:
            @protocol(HSHypertextLinkContainerAttributes)] allLinks] objectEnumerator];
        id link;
        while ((link = [links nextObject]) != nil)
            [actions addObjectsFromArray:[(id<HSActor>)[link queryHyperInterface:@protocol(HSActor)]
                hyperActionsOfType:[HSPlaySoundAction actionType]]];
    }
    return actions;
}
@end
