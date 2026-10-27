#import "HyperEditorBasePrefix.h"
#import "HSTrackingController.h"


@interface HSTimerBasedTrackingController : HSTrackingController
{
    NSTimer *_idleTimer;
}
- (void)idleTime:(id)aTime;
- (void)didSetNewValue:(id)aValue;
- (void)willSetNewValue:(id)aValue;
- (void)dealloc;
@end

