#import "HyperStudioPrefix.h"
#import "HSSelectionKnob.h"


@interface HSLockedKnob : HSSelectionKnob
{
    HSSelectionKnob *_originalKnob;
}
+ (id)normalStateImage;
- (id)affectingAttributes;
- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView;
- (BOOL)hitTest:(NSPoint)aTest forOwner:(id)aOwner inView:(id)aView;
- (id)querySelectionTrackerForModifierFlags:(NSUInteger)aFlags;
- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags;
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer;
- (void)dealloc;
- (id)init;
- (id)initWithOriginalKnob:(id)aKnob;
@end

