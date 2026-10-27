#import "HyperPlayerBasePrefix.h"
#import "HSHyperImplementation.h"


@interface HSHitTestingCanvasItem : HSHyperImplementation <HSCanvasItem, HyperInterface, NSObject>
{
}
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
- (id)renderingRegionInCanvasLayer:(id)aLayer;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (BOOL)prefersRegionInvalidation;
- (BOOL)hitTestRect:(NSRect)aRect inCanvasLayer:(id)aLayer;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (id)editorHitTester;
- (id)hitTester;
- (id)initWithHyperObject:(id)aObject;
- (id)initWithHitTester:(id)aTester;
@end

