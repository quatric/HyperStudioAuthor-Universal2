#import "HyperStudioPrefix.h"


@interface HSAuxiliaryVisualizationCanvasItem : HSHyperImplementation <HSCanvasItem, HyperInterface, NSObject>
{
}
+ (id)itemWithObject:(id)aObject;
- (id)updateWithChangedRegionBounds:(id)aBounds inCanvasLayer:(id)aLayer;
- (id)viewRegion:(id)aRegion transformedToUserSpaceInCanvasLayer:(id)aLayer;
- (id)userRegion:(id)aRegion transformedToViewSpaceInCanvasLayer:(id)aLayer;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
- (id)renderingRegionInCanvasLayer:(id)aLayer;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (BOOL)prefersRegionInvalidation;
- (BOOL)hitTestRect:(NSRect)aRect inCanvasLayer:(id)aLayer;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (CGAffineTransform)rendererToRootUserSpaceAffineTransform;
- (id)userBoundingRegion;
- (id)renderer;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject;
- (id)initWithRenderer:(id)aRenderer;
@end

