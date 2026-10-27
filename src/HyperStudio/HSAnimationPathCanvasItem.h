#import "HyperStudioPrefix.h"


@interface HSAnimationPathCanvasItem : NSObject <HSCanvasItem, HyperInterface, NSObject>
{
    HSAnimationEditModePathObject *_pathObject;
    NSRange _selectedSegments;
}
+ (id)animationPathStrokeColor;
+ (void)setSelectedSegmentHighlightColor:(id)aColor;
+ (id)selectedSegmentHighlightColor;
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
- (id)renderingRegionInCanvasLayer:(id)aLayer;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (BOOL)prefersRegionInvalidation;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (id)bezierPathInCanvasLayer:(id)aLayer;
- (void)animationPathDidChange:(id)aChange;
- (void)animationPathWillChange:(id)aChange;
- (void)setPathObject:(id)aObject;
- (id)pathObject;
- (void)setSelectedSegments:(NSRange)aSegments;
- (NSRange)selectedSegments;
- (id)queryHyperInterface:(id)aInterface;
- (id)geometryAttributes;
- (id)vectorGraphicsAttributes;
- (void)dealloc;
@end

