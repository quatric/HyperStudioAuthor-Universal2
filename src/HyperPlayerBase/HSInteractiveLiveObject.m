#import "HSInteractiveLiveObject.h"
@implementation HSInteractiveLiveObject
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    // clicks pass through objects with no click actions
    HSActionEvent *event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
    return [[[[self hyperObject] actor] hyperActionsForEvent:event] count] == 0;
}
@end
