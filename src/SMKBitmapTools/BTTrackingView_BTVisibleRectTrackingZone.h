#import "SMKBitmapToolsPrefix.h"


@interface BTTrackingZone : NSObject
{
}
- (void)discard;
- (NSInteger)trackingRectTag;
- (NSRect)windowTrackingRect;
- (BOOL)isActive;
- (id)owner;
- (id)view;
@end

@interface BTTrackingView_BTTrackingZone : BTTrackingZone
{
    BTTrackingView *_view;
    id _owner;
    NSTrackingRectTag _trackingRectTag;
    NSRect _windowTrackingRect;
    BOOL _isInside;
    NSEventType _eventTypeToPost;
}
- (void)discard;
- (void)mouseExited:(id)aExited;
- (void)mouseEntered:(id)aEntered;
- (void)deactivate;
- (void)reactivateIfNeeded;
- (void)activateAssumeInside:(BOOL)aInside postInitialMouseEntered:(BOOL)aEntered;
- (void)postMouseEnteredExited:(NSUInteger)aExited;
- (void)postMouseEnteredExited;
- (NSRect)calculateTrackingRect;
- (NSInteger)trackingRectTag;
- (NSRect)windowTrackingRect;
- (BOOL)isActive;
- (id)owner;
- (id)view;
- (id)initWithView:(id)aView owner:(id)aOwner;
- (id)init;
@end

@interface BTTrackingView_BTVisibleRectTrackingZone : BTTrackingView_BTTrackingZone
{
}
- (NSRect)calculateTrackingRect;
@end

@interface BTTrackingView : NSView
{
    id _trackingViewProxy;
    NSMutableSet *_trackingZones;
    BOOL _isRegisteredForViewNotifications;
}
- (void)BTTrackingView_removeTrackingZone:(id)aZone;
- (id)addTrackingZoneForVisibleRectWithOwner:(id)aOwner assumeInside:(BOOL)aInside postInitialMouseEntered:(BOOL)aEntered;
- (BOOL)BTTrackingView_addTrackingZone:(id)aZone assumeInside:(BOOL)aInside postInitialMouseEntered:(BOOL)aEntered;
- (void)viewDidMoveToWindow;
- (void)viewWillMoveToWindow:(id)aWindow;
- (void)BTTrackingView_viewDidChangeGeometry:(id)aGeometry;
- (void)BTTrackingView_resetTrackingRects:(BOOL)aRects;
- (BOOL)BTTrackingView_prepareToTrackZones;
- (void)dealloc;
- (void)BTTrackingView_removeViewObservers;
- (void)BTTrackingView_addViewObserversStartingFromView:(id)aView;
@end

