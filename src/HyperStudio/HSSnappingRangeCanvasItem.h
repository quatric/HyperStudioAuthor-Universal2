#import "HyperStudioPrefix.h"


@interface HSSnappingRangeCanvasItem : NSObject <HSCanvasItem, HyperInterface, NSObject>
{
    id<HSSnappingCanvasItemDelegate> _delegate;
}
+ (id)animationPathFillColor;
+ (id)animationPathStrokeColor;
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
- (id)renderingRegionInCanvasLayer:(id)aLayer;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (BOOL)prefersRegionInvalidation;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (NSRect)boundingRectForPrototypeObject:(id)aObject;
- (id)bezierPath:(id)aPath inCanvasLayer:(id)aLayer;
- (NSRect)rect:(NSRect)aRect inCanvasLayer:(id)aLayer;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
@end

