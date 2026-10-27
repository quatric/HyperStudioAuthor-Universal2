#import "KeynoteTransition.h"

@implementation KeynoteTransition

- (id)transitionAttributes
{
    id attributes = [self keynoteObjectForXMLPath:@"./transition-attributes"];

    if (attributes == nil)
        attributes = [[self cache] objectOfType:@"transitionAttributes" inCacheForId:[[[self keynoteObjectForXMLPath:@"./transition-attributes-ref"] nodeAttributes] objectForKey:@"IDREF"]];
    return attributes;
}

- (double)duration
{
    id object = [self keynoteObjectForXMLPath:@"./../animationDuration/number"];
    id number;

    if (object == nil)
        object = [[self transitionAttributes] keynoteObjectForXMLPath:@"./../animationDuration/decimal-number"];
    if (object == nil)
        object = [[self transitionAttributes] keynoteObjectForXMLPath:@"./animationDuration/number"];
    number = [[object nodeAttributes] objectForKey:@"number"];
    return number != nil ? [number floatValue] : 2.0;
}

- (id)directionCodeString
{
    return [[[[self transitionAttributes] keynoteObjectForXMLPath:@"./direction/number"] nodeAttributes] objectForKey:@"number"];
}

- (id)type
{
    return [[[self transitionAttributes] nodeAttributes] objectForKey:@"type"];
}

- (void)didInitFromParser
{
    id attributes;

    [super didInitFromParser];
    attributes = [self keynoteObjectForXMLPath:@"./transition-attributes"];
    if (attributes != nil)
        [[self cache] addObject:attributes type:@"transitionAttributes" inCacheForId:[attributes nodeId]];
}

@end
