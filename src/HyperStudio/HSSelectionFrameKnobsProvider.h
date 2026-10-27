#import "HyperStudioPrefix.h"
#import "HSAbstractKnobsProvider.h"


@interface HSSelectionFrameKnobsProvider : HSAbstractKnobsProvider <HSSelectionKnobsProvider, HSKnobsProvider, HyperInterface, NSObject>
{
    BOOL _rotationKnobIsDisabled;
    BOOL _ignoresKnobAvailability;
    BOOL _sidesInverseProportionalResizingPreference;
    Class _frameKnobClass;
}
- (id)buildDefaultKnob;
- (id)buildSelectionKnobs;
- (void)setSidesInverseProportionalResizingPreference:(BOOL)aPreference;
- (BOOL)sidesInverseProportionalResizingPreference;
- (void)setIgnoresKnobAvailability:(BOOL)aAvailability;
- (BOOL)ignoresKnobAvailability;
- (void)setSupportsRotationKnob:(BOOL)aKnob;
- (BOOL)supportsRotationKnob;
- (void)setFrameKnobClass:(Class)aClass;
- (Class)frameKnobClass;
- (id)selectionKnobsArrayAndDefaultKnobIndex:(unsigned int *)aIndex;
- (id)buildSelectionKnobsAndDefaultKnob:(id *)aKnob;
@end

