#import "KeynoteCoreImageFilterInfo.h"

@implementation KeynoteCoreImageFilterInfo

- (id)filterName
{
    id descriptor = [self filterDescriptorObject];

    if (descriptor == nil)
        descriptor = [[self cache] objectOfType:@"coreImageFilterDescriptor" inCacheForId:[[self keynoteObjectForXMLPath:@"./core-image-filter-descriptor-ref"] nodeIdRef]];
    return [[descriptor nodeAttributes] objectForKey:@"filterClassName"];
}

- (id)filterDescriptorObject
{
    return [self keynoteObjectForXMLPath:@"./core-image-filter-descriptor"];
}

- (CGFloat)floatForName:(id)aName inOverrides:(id)aOverrides
{
    id object = [aOverrides keynoteObjectForXMLPath:[NSString stringWithFormat:@"./%@/number", aName]];
    id number;

    if (object != nil && (number = [[object nodeAttributes] objectForKey:@"number"]) != nil)
        return [number floatValue];
    return 0.0;
}

// Only Keynote's drop shadow filter becomes a shadow.
- (id)shadow
{
    id overrides;
    float opacity, radius, angle, distance;
    NSColor *color;
    SMKShadow *shadow;

    if (![[self filterName] isEqualToString:@"SFIUDropShadow"])
        return nil;
    overrides = [self keynoteObjectForXMLPath:@"./overrides"];
    opacity = [self floatForName:@"inputOpacity" inOverrides:overrides];
    radius = [self floatForName:@"inputRadius" inOverrides:overrides];
    if (!(radius > 0.0f) || !(opacity > 0.0f))
        return nil;
    angle = [KeynoteTools angleWithFloat:[self floatForName:@"inputAngle" inOverrides:overrides]];
    distance = [self floatForName:@"inputDistance" inOverrides:overrides];
    color = [(KeynoteColor *)[overrides keynoteObjectForXMLPath:@"./inputColor/color"] color];
    color = [color colorWithAlphaComponent:opacity * (float)[color alphaComponent]];
    shadow = [[SMKShadow new] autorelease];
    [shadow setShadowColor:color];
    [shadow setShadowOffset:NSMakeSize(distance * cosf(angle), sinf(angle) * distance)];
    [shadow setShadowBlurRadius:radius];
    return shadow;
}

- (void)didInitFromParser
{
    id descriptor;

    [super didInitFromParser];
    descriptor = [self filterDescriptorObject];
    if (descriptor != nil)
        [[self cache] addObject:descriptor type:@"coreImageFilterDescriptor" inCacheForId:[descriptor nodeId]];
}

@end
