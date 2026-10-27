#import "KeynoteLayers.h"

@implementation KeynoteLayers

- (id)drawablesOfLayerAtIndex:(NSUInteger)aIndex
{
    id layers = [self keynoteObjectForXMLPath:@"./layer"];
    if (![layers isKindOfClass:[NSArray class]])
        return nil;
    return [[layers objectAtIndex:aIndex] items];
}

- (id)foregroundLayerItems
{
    return [self drawablesOfLayerAtIndex:1];
}

- (id)backgroundLayerItems
{
    return [self drawablesOfLayerAtIndex:0];
}

@end
