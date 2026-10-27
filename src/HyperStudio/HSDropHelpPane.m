#import "HSDropHelpPane.h"

@implementation HSDropHelpPane

- (void)setUseDragPreferences:(BOOL)aPreferences
{
    _useDragPreferences = aPreferences;
}

- (BOOL)useDragPreferences
{
    return _useDragPreferences;
}

- (void)setDropDelegate:(id)aDelegate
{
    _dropDelegate = aDelegate;
}

- (id)dropDelegate
{
    return _dropDelegate;
}

// Abstract.
- (id)dropHelpPaneIdentifier
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)shouldDismissWhenDisappearedByDefault
{
    return NO;
}

@end
