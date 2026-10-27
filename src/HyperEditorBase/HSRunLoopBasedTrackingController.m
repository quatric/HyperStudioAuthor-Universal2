#import "HSRunLoopBasedTrackingController.h"

// A continuous change lasts while the run loop is in event tracking mode:
// observers of the tracking and default modes' entries start and stop it.

// Original quirk kept: one flag for every controller.
static BOOL HSRunLoopBasedTrackingControllerIsTracking;

static void HSRunLoopBasedTrackingControllerEventTrackingEntry(CFRunLoopObserverRef aObserver, CFRunLoopActivity aActivity, void *aController)
{
    if (!HSRunLoopBasedTrackingControllerIsTracking) {
        HSRunLoopBasedTrackingControllerIsTracking = YES;
        [(HSRunLoopBasedTrackingController *)aController startTracking];
    }
}

static void HSRunLoopBasedTrackingControllerDefaultEntry(CFRunLoopObserverRef aObserver, CFRunLoopActivity aActivity, void *aController)
{
    if (HSRunLoopBasedTrackingControllerIsTracking) {
        HSRunLoopBasedTrackingControllerIsTracking = NO;
        [(HSRunLoopBasedTrackingController *)aController stopTracking];
    }
}

@implementation HSRunLoopBasedTrackingController

- (void)stopTracking
{
    if (!_isTracking)
        return;
    CFRunLoopRemoveObserver([[NSRunLoop currentRunLoop] getCFRunLoop], [self eventTrackingRunLoopObserver], (CFStringRef)NSEventTrackingRunLoopMode);
    CFRunLoopRemoveObserver([[NSRunLoop currentRunLoop] getCFRunLoop], [self defaultRunLoopObserver], kCFRunLoopDefaultMode);
    [[[self dataInterface] attributeObservingController] endContinuousChangeOfAttribute:[self attribute]];
    _isTracking = NO;
}

- (void)startTracking
{
    [[[self dataInterface] attributeObservingController] beginContinuousChangeOfAttribute:[self attribute]];
}

- (void)didSetNewValue:(id)aValue
{
}

- (void)willSetNewValue:(id)aValue
{
    if (_isTracking)
        return;
    CFRunLoopAddObserver([[NSRunLoop currentRunLoop] getCFRunLoop], [self eventTrackingRunLoopObserver], (CFStringRef)NSEventTrackingRunLoopMode);
    CFRunLoopAddObserver([[NSRunLoop currentRunLoop] getCFRunLoop], [self defaultRunLoopObserver], kCFRunLoopDefaultMode);
    _isTracking = YES;
}

- (void)dealloc
{
    if (_eventTrackingRunLoopObserver != NULL)
        CFRelease(_eventTrackingRunLoopObserver);
    if (_defaultRunLoopObserver != NULL)
        CFRelease(_defaultRunLoopObserver);
    [super dealloc];
}

- (struct __CFRunLoopObserver *)defaultRunLoopObserver
{
    if (_defaultRunLoopObserver == NULL)
        _defaultRunLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopEntry, true, 0, HSRunLoopBasedTrackingControllerDefaultEntry, [self context]);
    return _defaultRunLoopObserver;
}

- (struct __CFRunLoopObserver *)eventTrackingRunLoopObserver
{
    if (_eventTrackingRunLoopObserver == NULL)
        _eventTrackingRunLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopEntry, true, 0, HSRunLoopBasedTrackingControllerEventTrackingEntry, [self context]);
    return _eventTrackingRunLoopObserver;
}

- (CFRunLoopObserverContext *)context
{
    _context.info = self;
    return &_context;
}

@end
