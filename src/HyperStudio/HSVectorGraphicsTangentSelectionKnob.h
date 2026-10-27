#import "HyperStudioPrefix.h"
#import "HSVectorGraphicsSelectionKnob.h"


@interface HSVectorGraphicsTangentSelectionKnob : HSVectorGraphicsSelectionKnob
{
    BOOL _isFirstControlPoint;
    HSRegion *_boundingRegion;
}
- (BOOL)canBeLocked;
- (BOOL)isEqualToKnob:(id)aKnob;
- (BOOL)prefersRegionInvalidation;
- (void)invalidateCachedFrame;
- (void)invalidateBoundingRegion;
- (id)boundingRegionForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView;
- (BOOL)getTangentPathStart:(NSPoint *)aStart end:(NSPoint *)aEnd forOwner:(id)aOwner inView:(id)aView;
- (void)setIsFirstControlPoint:(BOOL)aPoint;
- (BOOL)isFirstControlPoint;
- (void)setAssociatedElementIndex:(NSUInteger)aIndex owner:(id)aOwner;
- (void)drawWithFrame:(NSRect)aFrame owner:(id)aOwner inView:(id)aView invalidRect:(NSRect)aRect;
- (NSRect)boundingRectForOwner:(id)aOwner frame:(NSRect)aFrame inView:(id)aView;
- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView;
- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags;
@end

