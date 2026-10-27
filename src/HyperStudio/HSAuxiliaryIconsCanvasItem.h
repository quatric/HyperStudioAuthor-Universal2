#import "HyperStudioPrefix.h"


@interface HSAuxiliaryIconsCanvasItem : HSHyperImplementation <HSCanvasItem, HyperInterface, NSObject>
{
    HSAuxiliaryUserObjectTraits *_traits;
    NSArray *_traitRects;
    HSRegion *_traitsRegion;
    CGAffineTransform _transformUsedForRectCalculations;
    NSRect _boundsUsedForRectCalculations;
}
- (id)traitIcons;
- (id)traitRectsInView:(id)aView;
- (id)compositeRectsForIcons:(id)aIcons inView:(id)aView;
- (CGAffineTransform)transformForTraitRectsInView:(id)aView;
- (NSRect)boundsForTraitRectsInView:(id)aView;
- (id)userObject;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
- (id)renderingRegionInCanvasLayer:(id)aLayer;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (BOOL)prefersRegionInvalidation;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (BOOL)userTraitsDidChange;
- (void)geometryDidChange;
- (void)invalidateTraitRects;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject;
- (id)initWithNode:(id)aNode;
@end

