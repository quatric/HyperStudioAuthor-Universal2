#import "HSImageObject+HSEditorInterfaces.h"

@implementation HSImageObject (HSEditorInterfaces)

- (id)querySelectionKnobsProvider
{
    HSSelectionFrameKnobsProvider *provider = [[[HSSelectionFrameKnobsProvider alloc] initWithHyperObject:self] autorelease];
    [provider setFrameKnobClass:[HSImageObjectFrameSelectionKnob class]];
    [provider setSidesInverseProportionalResizingPreference:YES];
    return provider;
}

@end
