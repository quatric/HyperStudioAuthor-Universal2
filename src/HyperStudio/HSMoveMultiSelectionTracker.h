#import "HyperStudioPrefix.h"


@interface HSMoveMultiSelectionTracker : HSCardObjectTracker
{
    NSArray *_trackingObjects;
    NSMutableArray *_geometryAppliers;
    NSMutableArray *_startTransforms;
    NSRect _startSelectionBoundingRect;
    NSRect _currentSelectionBoundingRect;
    BOOL _didStartDragging;
}
- (void)processMouseDragged:(id)aDragged inView:(id)aView;
- (void)mouseUp:(id)aUp inView:(id)aView;
- (void)processMouseDown:(id)aDown inView:(id)aView;
- (void)concludeTracking;
- (void)prepareForTracking;
- (void)moveEvent:(id)aEvent inView:(id)aView;
- (void)moveObjectsByUserDelta:(NSSize)aDelta withKeyboard:(BOOL)aKeyboard;
- (BOOL)adjustDelta:(NSSize *)aDelta keyboardUsed:(BOOL)aUsed;
- (NSRect)currentBoundingRect;
- (void)setTrackingObject:(id)aObject;
- (void)setTrackingObjects:(id)aObjects;
- (void)dealloc;
@end

