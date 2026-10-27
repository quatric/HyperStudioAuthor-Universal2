#import "HSSystemViewManager.h"
// Owns a system view (from the delegate) and its duplicates; setters go to
// all of them at once through a combined proxy.
@implementation HSSystemViewManager
// A deep copy through keyed archiving, optionally decoding some classes as
// others.
+ (id)duplicateObject:(id)aObject withSubstituteClasses:(id)aClasses
{
    if ([aClasses count] == 0)
        return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:aObject]];
    NSMutableData *data = [[NSMutableData new] autorelease];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    for (id class in aClasses)
        [archiver setClassName:NSStringFromClass([aClasses objectForKey:class]) forClass:class];
    [archiver encodeObject:aObject forKey:@"myObject"];
    [archiver finishEncoding];
    NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
    id object = [unarchiver decodeObjectForKey:@"myObject"];
    [unarchiver finishDecoding];
    return object;
}
- (void)removeDuplicateHyperSystemView:(id)aView
{
    NSSet *views = nil;
    if ([_duplicateSystemViews count] == 1)
        [_duplicateSystemViews release];
    else {
        NSMutableSet *remaining = [NSMutableSet setWithSet:_duplicateSystemViews];
        [remaining removeObject:aView];
        [_duplicateSystemViews release];
        views = [[NSSet alloc] initWithSet:remaining];
    }
    _duplicateSystemViews = views;
    [_synchronizedSystemView release];
    _synchronizedSystemView = nil;
}
// The delegate may provide the duplicate; otherwise it's archived and
// unarchived.
- (id)addDuplicateHyperSystemView
{
    id view = [self systemViewCreateIfNeeded:YES];
    id duplicate = nil;
    if ([_delegate respondsToSelector:@selector(duplicatedViewForSystemManager:)])
        duplicate = [_delegate duplicatedViewForSystemManager:self];
    if (duplicate == nil)
        duplicate = [[self class] duplicateObject:view withSubstituteClasses:nil];
    if (_duplicateSystemViews == nil)
        _duplicateSystemViews = [[NSSet alloc] initWithObjects:&duplicate count:1];
    else {
        NSMutableSet *views = [NSMutableSet setWithSet:_duplicateSystemViews];
        [views addObject:duplicate];
        [_duplicateSystemViews release];
        _duplicateSystemViews = [[NSSet alloc] initWithSet:views];
    }
    [_synchronizedSystemView release];
    _synchronizedSystemView = nil;
    return duplicate;
}
- (id)systemViewForSetAccessor
{
    if (_synchronizedSystemView == nil) {
        id view = [self systemViewCreateIfNeeded:YES];
        if (view != nil && [_duplicateSystemViews count] != 0)
            view = [[[_duplicateSystemViews allObjects] arrayByAddingObject:view] hyperObjectForAllInterfaces];
        _synchronizedSystemView = [view retain];
    }
    return _synchronizedSystemView;
}
- (id)systemViewForGetAccessor
{
    return [self systemViewCreateIfNeeded:YES];
}
- (id)hyperSystemView
{
    return [self systemViewCreateIfNeeded:YES];
}
- (id)systemViewCreateIfNeeded:(BOOL)aNeeded
{
    return [_delegate systemViewManager:self viewCreateIfNeeded:aNeeded];
}
- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}
- (id)delegate
{
    return _delegate;
}
- (void)dealloc
{
    [_duplicateSystemViews release];
    [_synchronizedSystemView release];
    [super dealloc];
}
@end
