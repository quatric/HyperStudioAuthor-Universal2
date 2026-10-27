#import "HSMovieObject+HSEditorInterfaces.h"

@implementation HSMovieObject (HSEditorInterfaces)

- (Class)runtimeEditorClass
{
    return nil;
}

- (id)querySelectionKnobsProvider
{
    HSSelectionFrameKnobsProvider *provider = [[[HSSelectionFrameKnobsProvider alloc] initWithHyperObject:self] autorelease];
    [provider setFrameKnobClass:[HSMovieObjectFrameSelectionKnob class]];
    [provider setSidesInverseProportionalResizingPreference:YES];
    return provider;
}

@end
