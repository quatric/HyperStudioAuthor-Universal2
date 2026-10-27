#import "HyperEditorBasePrefix.h"
#import "HSTrackingController.h"


@interface HSEventBasedTrackingController : HSTrackingController
{
    BOOL _isTracking;
}
- (void)didSetNewValue:(id)aValue;
- (void)willSetNewValue:(id)aValue;
@end

