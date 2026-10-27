#import "HSAssistantPaneMultiApplier.h"

@implementation HSAssistantPaneMultiApplier

- (BOOL)areSettingsEqual
{
    BOOL equal = YES;
    NSEnumerator *enumerator = [[self appliers] objectEnumerator];
    id applier;
    while ((applier = [enumerator nextObject]) != nil) {
        if (equal && ![applier areSettingsEqual])
            equal = NO;
    }
    return equal;
}

- (id)undoActionName
{
    return [[[self appliers] extraFirstObject] undoActionName];
}

- (void)makeInitialEqualToCurrent
{
    NSEnumerator *enumerator = [[self appliers] objectEnumerator];
    id applier;
    while ((applier = [enumerator nextObject]) != nil)
        [applier makeInitialEqualToCurrent];
}

- (void)makeCurrentEqualToInitial
{
    NSEnumerator *enumerator = [[self appliers] reverseObjectEnumerator];
    id applier;
    while ((applier = [enumerator nextObject]) != nil)
        [applier makeCurrentEqualToInitial];
}

- (void)setInitialSettingsToObject
{
    NSEnumerator *enumerator = [[self appliers] objectEnumerator];
    id applier;
    while ((applier = [enumerator nextObject]) != nil)
        [applier setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    NSEnumerator *enumerator = [[self appliers] objectEnumerator];
    id applier;
    while ((applier = [enumerator nextObject]) != nil)
        [applier setCurrentSettingsToObject];
}

- (void)addApplier:(id)aApplier
{
    if ([[self appliers] indexOfObjectIdenticalTo:aApplier] == NSNotFound)
        [[self appliers] addObject:aApplier];
}

- (id)appliers
{
    if (_appliers == nil)
        _appliers = [NSMutableArray new];
    return _appliers;
}

- (void)dealloc
{
    [_appliers release];
    [super dealloc];
}

@end
