#import "HSLockedKnobsProvider.h"

@implementation HSLockedKnobsProvider

- (id)buildDefaultKnob
{
    return [super buildDefaultKnob];
}

- (id)buildSelectionKnobs
{
    return [super buildSelectionKnobs];
}

- (id)buildSelectionKnobsAndDefaultKnob:(id *)aKnob
{
    id knobs = [self filterKnobsArray:[_provider buildSelectionKnobsAndDefaultKnob:aKnob] withDefaultKnob:aKnob];
    if ([knobs count] == 0) {
        HSSelectionFrameKnobsProvider *provider = [[HSSelectionFrameKnobsProvider alloc] initWithHyperObject:[self hyperObject]];
        [provider setIgnoresKnobAvailability:YES];
        [_provider autorelease];
        // Original quirk kept: the alloc reference is retained once more, so the provider is never freed.
        _provider = [provider retain];
        knobs = [self filterKnobsArray:[_provider buildSelectionKnobsAndDefaultKnob:aKnob] withDefaultKnob:aKnob];
    }
    return knobs;
}

- (id)filterKnobsArray:(id)aArray withDefaultKnob:(id *)aKnob
{
    NSMutableArray *knobs = [NSMutableArray arrayWithCapacity:[aArray count]];
    NSEnumerator *enumerator = [aArray objectEnumerator];
    id originalDefault = aKnob != NULL ? *aKnob : nil;
    id defaultKnob = originalDefault;
    id knob;
    while ((knob = [enumerator nextObject]) != nil) {
        id lockedKnob = nil;
        if ([knob canBeLocked]) {
            lockedKnob = [[HSLockedKnob alloc] initWithOriginalKnob:knob];
            [knobs addObject:lockedKnob];
            [lockedKnob release];
        }
        if (originalDefault != nil && defaultKnob == knob)
            defaultKnob = lockedKnob;
    }
    if (originalDefault != nil && defaultKnob == nil)
        defaultKnob = [knobs lastObject];
    if (aKnob != NULL)
        *aKnob = defaultKnob;
    return knobs;
}

- (id)implementationForHyperObject:(id)aObject
{
    if ([self hyperObject] == aObject)
        return self;
    return [[[[self class] alloc] initWithKnobsProvider:[_provider implementationForHyperObject:aObject]] autorelease];
}

- (void)dealloc
{
    [_provider release];
    [super dealloc];
}

- (id)initWithKnobsProvider:(id)aProvider
{
    self = [super initWithHyperObject:[aProvider hyperObject]];
    if (self != nil)
        _provider = [aProvider retain];
    return self;
}

- (id)initWithHyperObject:(id)aObject
{
    return [self initWithKnobsProvider:nil];
}

@end
