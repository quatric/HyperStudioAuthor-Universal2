#import "HSWebPageObject+HSEditorInterfaces.h"

@implementation HSWebPageObject (HSEditorInterfaces)

- (id)querySelectionKnobsProvider
{
    HSSelectionFrameKnobsProvider *provider = [[[HSSelectionFrameKnobsProvider alloc] initWithHyperObject:self] autorelease];
    [provider setSidesInverseProportionalResizingPreference:YES];
    return provider;
}

@end
