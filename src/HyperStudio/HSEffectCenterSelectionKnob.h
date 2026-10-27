#import "HyperStudioPrefix.h"
#import "HSConcreteKnob.h"


@interface HSEffectCenterSelectionKnob : HSConcreteKnob
{
    int _centerIndex;
    NSSize _positionOffset;
    BOOL _affectedByObjectGeometryChange;
}
+ (id)affectingAttributes;
+ (id)beingTrackedActiveStateImage;
+ (id)activeStateImage;
+ (id)beingTrackedStateImage;
+ (id)normalStateImage;
- (BOOL)canBeLocked;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inView:(id)aView owner:(id)aOwner;
- (BOOL)isEqualToKnob:(id)aKnob;
- (NSInteger)associatedCenterIndex;
- (void)setAssociatedCenterIndex:(NSInteger)aIndex;
- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView;
- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags;
@end

