#import "HyperStudioPrefix.h"
#import "HSAnimationSetupDrawPathCanvasItem.h"


@interface HSAnimationSetupEditPathCanvasItem : HSAnimationSetupDrawPathCanvasItem
{
}
+ (NSRect)pathBoundsWithKnobOffset:(id)aOffset;
+ (NSPoint)knobOffset;
+ (id)selectedKnobImage;
+ (id)knobImage;
+ (id)selectedLastKnobImage;
+ (id)lastKnobImage;
+ (id)selectedFirstKnobImage;
+ (id)firstKnobImage;
- (void)drawImage:(id)aImage forKnob:(NSInteger)aKnob path:(id)aPath;
- (void)drawKnob:(NSInteger)aKnob path:(id)aPath;
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer;
- (NSRect)contentPathBounds;
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer;
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive;
- (NSUInteger)knobAtViewPoint:(NSPoint)aPoint;
- (NSRect)rectForKnob:(NSInteger)aKnob path:(id)aPath;
- (void)setDelegate:(id)aDelegate;
@end

