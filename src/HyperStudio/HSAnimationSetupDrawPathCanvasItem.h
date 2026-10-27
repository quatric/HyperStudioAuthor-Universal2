#import "HyperStudioPrefix.h"


@interface HSAnimationSetupDrawPathCanvasItem : NSObject <HSCanvasItem, HyperInterface, NSObject>
{
    id _delegate;
}
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
- (id)renderingRegionInCanvasLayer:(id)aLayer;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (BOOL)prefersRegionInvalidation;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (id)pathForLayer:(id)aLayer;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
@end

