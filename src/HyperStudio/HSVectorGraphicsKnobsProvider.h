#import "HyperStudioPrefix.h"
#import "HSAbstractKnobsProvider.h"


@interface HSVectorGraphicsKnobsProvider : HSAbstractKnobsProvider <HSVectorGraphicsKnobsProvider, HSKnobsProvider, HyperInterface, NSObject>
{
}
- (id)buildDefaultKnob;
- (id)buildSelectionKnobs;
- (id)selectionKnobsArrayAndDefaultKnobIndex:(unsigned int *)aIndex;
- (id)buildSelectionKnobsAndDefaultKnob:(id *)aKnob;
@end

