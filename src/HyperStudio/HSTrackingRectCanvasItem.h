#import "HyperStudioPrefix.h"


@interface HSTrackingRectCanvasItem : NSObject <HSCanvasItem, HyperInterface, NSObject>
{
    NSRect _rect;
    NSPoint _startingPoint;
    HSRegion *_cachedRegion;
    BOOL _drawsOutlineOnly;
}
+ (void)systemColorsDidChange:(id)aChange;
+ (id)trackingRectFillColor;
+ (id)trackingRectColor;
+ (id)trackingRectCanvasItemWithStartingPoint:(NSPoint)aPoint;
- (id)cachedRegion;
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
- (id)renderingRegionInCanvasLayer:(id)aLayer;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (BOOL)prefersRegionInvalidation;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (void)setDrawsOutlineOnly:(BOOL)aOnly;
- (BOOL)drawsOutlineOnly;
- (void)updateWithEndPoint:(NSPoint)aPoint inParentLayer:(id)aLayer;
- (void)updateWithRect:(NSRect)aRect inParentLayer:(id)aLayer;
- (NSRect)rectForUpdatingWithEndPoint:(NSPoint)aPoint inParentLayer:(id)aLayer;
- (void)setRect:(NSRect)aRect inParentLayer:(id)aLayer;
- (NSRect)rect;
- (void)dealloc;
- (id)init;
- (id)initWithStartingPoint:(NSPoint)aPoint;
@end

