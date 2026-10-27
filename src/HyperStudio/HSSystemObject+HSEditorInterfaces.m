#import "HSSystemObject+HSEditorInterfaces.h"

@implementation HSSystemObject (HSEditorInterfaces)

- (id)querySelectionKnobsProvider
{
    return [[[HSSelectionFrameKnobsProvider alloc] initWithHyperObject:self] autorelease];
}

@end
