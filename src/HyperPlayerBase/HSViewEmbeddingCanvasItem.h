#import "HyperPlayerBasePrefix.h"


@interface HSViewEmbeddingCanvasItem : NSObject <HSCanvasItem, HyperInterface, NSObject, HSCanvasItemActivation>
{
    id _view;
    id<HSCanvasLayer> _activeParentCanvasLayer;
}
- (void)removeViewFromSuperview;
- (void)invalidateParentCanvasLayer;
- (void)deactivate;
- (void)activateInCanvasLayer:(id)aLayer;
- (id)renderingRegionInCanvasLayer:(id)aLayer;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (BOOL)prefersRegionInvalidation;
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (id)createView;
- (void)setupViewFrameInCanvasLayer:(id)aLayer;
- (id)activeParentCanvasLayer;
- (BOOL)isActive;
- (id)view;
- (void)dereferenceView:(id)aView;
- (void)willDisposeView:(id)aView;
- (void)setupView:(id)aView;
- (void)invalidateView;
- (id)viewCreateIfNeeded:(BOOL)aNeeded;
- (void)dealloc;
@end

