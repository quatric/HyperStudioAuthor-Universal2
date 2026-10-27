#import "HSVectorGraphicsObject+HSEditorInterfaces.h"

@implementation HSVectorGraphicsObject (HSEditorInterfaces)

- (Class)runtimeEditorClass
{
    return nil;
}

- (id)querySelectionKnobsProvider
{
    HSSelectionCombinedVectorKnobsProvider *provider = [[[HSSelectionCombinedVectorKnobsProvider alloc] initWithHyperObject:self] autorelease];
    [provider setSidesInverseProportionalResizingPreference:YES];
    return provider;
}

@end
