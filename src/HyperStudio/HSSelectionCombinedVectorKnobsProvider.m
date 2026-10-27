#import "HSSelectionCombinedVectorKnobsProvider.h"

@implementation HSSelectionCombinedVectorKnobsProvider

- (void)setSidesInverseProportionalResizingPreference:(BOOL)aPreference
{
    [[self frameKnobsProvider] setSidesInverseProportionalResizingPreference:aPreference];
}

- (BOOL)sidesInverseProportionalResizingPreference
{
    return [[self frameKnobsProvider] sidesInverseProportionalResizingPreference];
}

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
    id vector = [[self hyperObject] queryHyperInterface:@protocol(HSVectorGraphicsAttributes)];
    unsigned int defaultIndex = 0x7fffffff;
    id provider = vector != nil && [[vector hyperBezierPath] isHyperStraightLine] ? [self lineKnobsProvider] : [self frameKnobsProvider];
    id knobs = [provider selectionKnobsArrayAndDefaultKnobIndex:&defaultIndex];
    if (aKnob != NULL)
        *aKnob = defaultIndex < [knobs count] ? [knobs objectAtIndex:defaultIndex] : nil;
    id object = [self hyperObject];
    id geometry = [object queryHyperInterface:@protocol(HSGeometryAttributes)];
    id behavior = [object queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
    if (geometry != nil && (behavior == nil || [behavior canRotate]))
        [knobs addObject:[[[HSFrameRotationSelectionKnob alloc] init] autorelease]];
    return knobs;
}

- (id)frameKnobsProvider
{
    if (_frameKnobsProvider == nil) {
        _frameKnobsProvider = [[HSSelectionFrameKnobsProvider alloc] initWithHyperObject:[self hyperObject]];
        [_frameKnobsProvider setSupportsRotationKnob:NO];
    }
    return _frameKnobsProvider;
}

- (id)lineKnobsProvider
{
    if (_lineKnobsProvider == nil)
        _lineKnobsProvider = [[HSVectorGraphicsKnobsProvider alloc] initWithHyperObject:[self hyperObject]];
    return _lineKnobsProvider;
}

- (void)dealloc
{
    [_lineKnobsProvider release];
    [_frameKnobsProvider release];
    [super dealloc];
}

@end
