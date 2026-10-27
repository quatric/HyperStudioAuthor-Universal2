#import "HyperEditorBasePrefix.h"
#import "HSTrackingController.h"


@interface HSRunLoopBasedTrackingController : HSTrackingController
{
    struct __CFRunLoopObserver *_eventTrackingRunLoopObserver;
    struct __CFRunLoopObserver *_defaultRunLoopObserver;
    BOOL _isTracking;
    CFRunLoopObserverContext _context;
}
- (void)stopTracking;
- (void)startTracking;
- (void)didSetNewValue:(id)aValue;
- (void)willSetNewValue:(id)aValue;
- (void)dealloc;
- (struct __CFRunLoopObserver *)defaultRunLoopObserver;
- (struct __CFRunLoopObserver *)eventTrackingRunLoopObserver;
- (CFRunLoopObserverContext *)context;
@end

