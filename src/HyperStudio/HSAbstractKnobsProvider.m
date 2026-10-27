#import "HSAbstractKnobsProvider.h"

@implementation HSAbstractKnobsProvider

- (id)buildDefaultKnob
{
    id knob = nil;
    if ([self conformsToProtocol:@protocol(HSKnobsProvider)])
        [(id<HSKnobsProvider>)self buildSelectionKnobsAndDefaultKnob:&knob];
    else
        [self doesNotRecognizeSelector:_cmd];
    return knob;
}

- (id)buildSelectionKnobs
{
    if (![self conformsToProtocol:@protocol(HSKnobsProvider)]) {
        [self doesNotRecognizeSelector:_cmd];
        return nil;
    }
    return [(id<HSKnobsProvider>)self buildSelectionKnobsAndDefaultKnob:NULL];
}

@end
