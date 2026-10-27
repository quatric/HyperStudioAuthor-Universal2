#import "HSTextObject+HSEditorInterfaces.h"

@implementation HSTextObject (HSEditorInterfaces)

- (Class)runtimeEditorClass
{
    return [HSTextObjectEditor class];
}

- (id)querySelectionKnobsProvider
{
    HSSelectionFrameKnobsProvider *provider = [[[HSSelectionFrameKnobsProvider alloc] initWithHyperObject:self] autorelease];
    [provider setFrameKnobClass:[HSTextObjectFrameSelectionKnob class]];
    return provider;
}

@end
