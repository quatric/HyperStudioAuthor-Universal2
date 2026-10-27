#import "HyperStudioPrefix.h"
#import "HSAbstractKnobsProvider.h"


@interface HSSelectionCombinedVectorKnobsProvider : HSAbstractKnobsProvider <HSSelectionKnobsProvider, HSKnobsProvider, HyperInterface, NSObject>
{
    id _lineKnobsProvider;
    id _frameKnobsProvider;
}
- (void)setSidesInverseProportionalResizingPreference:(BOOL)aPreference;
- (BOOL)sidesInverseProportionalResizingPreference;
- (id)buildDefaultKnob;
- (id)buildSelectionKnobs;
- (id)buildSelectionKnobsAndDefaultKnob:(id *)aKnob;
- (id)frameKnobsProvider;
- (id)lineKnobsProvider;
- (void)dealloc;
@end

