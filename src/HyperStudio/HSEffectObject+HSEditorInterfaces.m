#import "HSEffectObject+HSEditorInterfaces.h"

@implementation HSEffectObject (HSEditorInterfaces)

- (id)querySelectionKnobsProvider
{
    return [[[HSSelectionEffectKnobsProvider alloc] initWithHyperObject:self] autorelease];
}

@end
