#import "HSSelectionFrameKnobsProvider.h"

@implementation HSSelectionFrameKnobsProvider

- (id)buildDefaultKnob
{
    return [super buildDefaultKnob];
}

- (id)buildSelectionKnobs
{
    return [super buildSelectionKnobs];
}

- (void)setSidesInverseProportionalResizingPreference:(BOOL)aPreference
{
    _sidesInverseProportionalResizingPreference = aPreference;
}

- (BOOL)sidesInverseProportionalResizingPreference
{
    return _sidesInverseProportionalResizingPreference;
}

- (void)setIgnoresKnobAvailability:(BOOL)aAvailability
{
    _ignoresKnobAvailability = aAvailability;
}

- (BOOL)ignoresKnobAvailability
{
    return _ignoresKnobAvailability;
}

- (void)setSupportsRotationKnob:(BOOL)aKnob
{
    _rotationKnobIsDisabled = !aKnob;
}

- (BOOL)supportsRotationKnob
{
    return !_rotationKnobIsDisabled;
}

- (void)setFrameKnobClass:(Class)aClass
{
    _frameKnobClass = aClass;
}

- (Class)frameKnobClass
{
    if (_frameKnobClass == Nil)
        return [HSFrameSelectionKnob class];
    return _frameKnobClass;
}

- (id)selectionKnobsArrayAndDefaultKnobIndex:(unsigned int *)aIndex
{
    NSMutableArray *knobs = [NSMutableArray arrayWithCapacity:9];
    id geometry = [[self hyperObject] queryHyperInterface:@protocol(HSGeometryBehaviorAttributes)];
    BOOL resizeH = [geometry canResizeHorizontally];
    BOOL resizeV = [geometry canResizeVertically];
    BOOL move = [geometry canMoveHorizontally] || [geometry canMoveVertically];
    BOOL scaleH = [geometry canScaleHorizontally];
    BOOL scaleV = [geometry canScaleVertically];
    BOOL horizontal = resizeH || scaleH;
    BOOL vertical = resizeV || scaleV;
    BOOL corner = horizontal && vertical;
    BOOL movableCorner = corner && move;
    BOOL all = _ignoresKnobAvailability;
    BOOL invert = _sidesInverseProportionalResizingPreference;
    Class knobClass = [self frameKnobClass];
    id knob;

    if (movableCorner || all)
        [knobs addObject:[knobClass topLeftSelectionKnob]];
    if (vertical || all) {
        knob = [knobClass topCenterSelectionKnob];
        if (invert)
            [knob setInvertsProportionalResizePreference:YES];
        [knobs addObject:knob];
    }
    if ((move && horizontal) || all) {
        knob = [knobClass centerLeftSelectionKnob];
        if (invert)
            [knob setInvertsProportionalResizePreference:YES];
        [knobs addObject:knob];
    }
    if (movableCorner || all)
        [knobs addObject:[knobClass bottomLeftSelectionKnob]];
    if (corner || all)
        [knobs addObject:[knobClass topRightSelectionKnob]];
    if ((move && vertical) || all) {
        knob = [knobClass bottomCenterSelectionKnob];
        if (invert)
            [knob setInvertsProportionalResizePreference:YES];
        [knobs addObject:knob];
    }
    if (horizontal || all) {
        knob = [knobClass centerRightSelectionKnob];
        if (invert)
            [knob setInvertsProportionalResizePreference:YES];
        [knobs addObject:knob];
    }

    unsigned int defaultIndex = 0x7fffffff;
    if (movableCorner || all) {
        defaultIndex = (unsigned int)[knobs count];
        [knobs addObject:[knobClass bottomRightSelectionKnob]];
    }
    else if ([knobs count] != 0) {
        defaultIndex = (unsigned int)[knobs count] - 1;
    }
    if (aIndex != NULL)
        *aIndex = defaultIndex;

    if (!_rotationKnobIsDisabled && [geometry canRotate]) {
        knob = [[[HSFrameRotationSelectionKnob alloc] init] autorelease];
        if (knob != nil)
            [knobs addObject:knob];
    }
    return knobs;
}

- (id)buildSelectionKnobsAndDefaultKnob:(id *)aKnob
{
    unsigned int index = 0x7fffffff;
    NSArray *knobs = [self selectionKnobsArrayAndDefaultKnobIndex:&index];
    if (aKnob != NULL)
        *aKnob = index < [knobs count] ? [knobs objectAtIndex:index] : nil;
    return knobs;
}

@end
