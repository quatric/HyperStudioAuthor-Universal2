#import "HSObjectListControllerNodeSelection.h"

@implementation HSObjectListControllerNodeSelection

- (void)notifySelectionDidChangeOwnerAndNotificationCenterWasExpanded:(BOOL)aExpanded
{
    [[self owner] selectionDidChange:self wasExpanded:aExpanded];
}

@end
