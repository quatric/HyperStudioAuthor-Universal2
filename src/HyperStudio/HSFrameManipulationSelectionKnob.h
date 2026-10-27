#import "HyperStudioPrefix.h"
#import "HSConcreteKnob.h"


@interface HSFrameManipulationSelectionKnob : HSConcreteKnob <HSFrameManipulationSelectionKnobAttributes>
{
}
+ (id)affectingAttributes;
+ (id)beingTrackedActiveStateImage;
+ (id)activeStateImage;
+ (id)beingTrackedStateImage;
+ (id)normalStateImage;
- (BOOL)proportionalScaleForModifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inView:(id)aView owner:(id)aOwner;
- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView;
- (NSSize)framePositionOffset;
- (NSSize)framePositionFactor;
@end

