#import "NSUndoManager+HSExtensions.h"

@implementation NSUndoManager (HSExtensions)

// Registering a throwaway undo group clears the redo stack.
- (void)hyperRemoveAllRedoActions
{
    if ([self canRedo]) {
        [self beginUndoGrouping];
        [[self prepareWithInvocationTarget:@"dummy"] characterAtIndex:0];
        [self endUndoGrouping];
        [self removeAllActionsWithTarget:@"dummy"];
    }
}

- (void)hyperCancelLastOperation
{
    [self undo];
    [self hyperRemoveAllRedoActions];
}

@end
