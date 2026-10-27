#import "HSConcreteCardObject+HSEditorInterfaces.h"

@implementation HSConcreteCardObject (HSEditorInterfaces)

- (Class)runtimeEditorClass
{
    return nil;
}

- (id)querySelectionKnobsProvider
{
    return [[[HSSelectionFrameKnobsProvider alloc] initWithHyperObject:self] autorelease];
}

// Locked objects get their knobs wrapped so they cannot be dragged.
- (id)queryNewEditorInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(aInterface, @protocol(HSSelectionKnobsProvider))) {
        id knobs = [self querySelectionKnobsProvider];
        if (![self isLocked])
            return knobs;
        if (knobs == nil) {
            knobs = [[[HSSelectionFrameKnobsProvider alloc] initWithHyperObject:self] autorelease];
            [knobs setIgnoresKnobAvailability:YES];
        }
        return [[[HSLockedKnobsProvider alloc] initWithKnobsProvider:knobs] autorelease];
    }
    if (HSProtocolsAreEqual(aInterface, @protocol(HSRunTimeEditor)))
        return [self queryRuntimeEditor];
    if (HSProtocolsAreEqual(aInterface, @protocol(HSVectorGraphicsKnobsProvider))
        && [self implementsHyperInterface:@protocol(HSVectorGraphicsAttributes)])
        return [[[HSVectorGraphicsKnobsProvider alloc] initWithHyperObject:self] autorelease];
    return nil;
}

- (id)queryRuntimeEditor
{
    return [[[[self runtimeEditorClass] alloc] initWithHyperObject:self] autorelease];
}

@end
