#import "HyperStudioPrefix.h"


@interface HSSelectedObjectCanvasItem : HSHyperImplementation <HSCanvasItem, HyperInterface, NSObject>
{
    BOOL _frameRenderingDisabled;
    HSVisualBoundsHitTester *_boundsHitTester;
}
+ (CGFloat)cardObjectBoundingFrameThickness;
+ (id)cardObjectBoundingFrameColor;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
- (id)boundingFrameRegionInView:(id)aView;
- (id)boundingFramePathInView:(id)aView;
- (id)boundsHitTester;
- (void)setRendersBoundingFrame:(BOOL)aFrame;
- (BOOL)rendersBoundingFrame;
- (id)renderingRegionInCanvasLayer:(id)aLayer;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (BOOL)prefersRegionInvalidation;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (void)dealloc;
- (void)drawPath:(struct CGPath *)aPath;
@end

