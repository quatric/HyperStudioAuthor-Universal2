#import "HSLiveObject+HSEditorInterfaces.h"

@implementation HSLiveObject (HSEditorInterfaces)

- (id)querySelectionKnobsProvider
{
    HSSelectionFrameKnobsProvider *provider = [[[HSSelectionFrameKnobsProvider alloc] initWithHyperObject:self] autorelease];
    [provider setSidesInverseProportionalResizingPreference:YES];
    return provider;
}

@end
