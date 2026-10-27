#import "HyperStudioPrefix.h"
#import "HSConcreteKnob.h"


@interface HSVectorGraphicsSelectionKnob : HSConcreteKnob
{
    unsigned int _associatedElementIndex;
    BOOL _isValid;
}
+ (id)affectingAttributes;
+ (id)beingTrackedActiveStateImage;
+ (id)activeStateImage;
+ (id)beingTrackedStateImage;
+ (id)normalStateImage;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (BOOL)isEqualToKnob:(id)aKnob;
- (void)setValid:(BOOL)aValid;
- (BOOL)isValid;
- (NSUInteger)associatedElementIndex;
- (void)setAssociatedElementIndex:(NSUInteger)aIndex owner:(id)aOwner;
- (void)drawWithFrame:(NSRect)aFrame owner:(id)aOwner inView:(id)aView invalidRect:(NSRect)aRect;
- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView;
- (BOOL)isVisible;
- (void)dealloc;
- (id)init;
- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags;
@end

