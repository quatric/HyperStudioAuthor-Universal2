#import "HyperStudioPrefix.h"


@interface NSUndoManager (HSExtensions)
- (void)hyperRemoveAllRedoActions;
- (void)hyperCancelLastOperation;
@end

