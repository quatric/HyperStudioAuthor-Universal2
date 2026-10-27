#import "HyperStudioPrefix.h"
#import "HSAbstractKnobsProvider.h"


@interface HSLockedKnobsProvider : HSAbstractKnobsProvider <HSSelectionKnobsProvider, HSKnobsProvider, HyperInterface, NSObject>
{
    id<HSKnobsProvider> _provider;
}
- (id)buildDefaultKnob;
- (id)buildSelectionKnobs;
- (id)buildSelectionKnobsAndDefaultKnob:(id *)aKnob;
- (id)filterKnobsArray:(id)aArray withDefaultKnob:(id *)aKnob;
- (id)implementationForHyperObject:(id)aObject;
- (void)dealloc;
- (id)initWithKnobsProvider:(id)aProvider;
- (id)initWithHyperObject:(id)aObject;
@end

