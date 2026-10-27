#import "HyperStudioPrefix.h"
#import "HSFrameManipulationSelectionKnob.h"


@interface HSFrameRotationSelectionKnob : HSFrameManipulationSelectionKnob
{
    NSPoint _trackingKnobPosition;
    BOOL _usesTrackingKnobPosition;
    HSRegion *_boundingRegion;
}
- (BOOL)canBeLocked;
- (BOOL)overridesTrackingLoopCursor;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inView:(id)aView owner:(id)aOwner;
- (BOOL)prefersRegionInvalidation;
- (void)invalidateCachedFrame;
- (void)invalidateBoundingRegion;
- (id)boundingRegionForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView;
- (BOOL)usesTrackingKnobPosition;
- (void)setUsesTrackingKnobPosition:(BOOL)aPosition;
- (NSPoint)trackingKnobPosition;
- (void)setTrackingKnobPosition:(NSPoint)aPosition;
- (void)setBeingTracked:(BOOL)aTracked;
- (void)drawWithFrame:(NSRect)aFrame owner:(id)aOwner inView:(id)aView invalidRect:(NSRect)aRect;
- (NSRect)boundingRectForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView;
- (id)rotationHandlePathWithFrame:(NSRect)aFrame forOwner:(id)aOwner inView:(id)aView;
- (BOOL)getHandleStartPoint:(NSPoint *)aPoint endPoint:(NSPoint *)aPoint2 centerRect:(NSRect *)aRect forOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView;
- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags;
- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView;
- (NSSize)framePositionOffset;
- (NSSize)framePositionFactor;
- (void)dealloc;
@end

