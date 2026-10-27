#import "KeynoteSlide.h"

@implementation KeynoteSlide

- (id)eventTypeForMediaId:(id)aId
{
    return [[self keynoteObjectForXMLPath:@"./events"] eventTypeForMediaId:aId];
}

// Background layer, then the master slide's drawables, then the foreground layer.
- (id)items
{
    NSMutableArray *items = [NSMutableArray array];
    id layers = [self keynoteObjectForXMLPath:@"./page/layers"];
    NSArray *array = [layers backgroundLayerItems];

    if (array != nil)
        [items addObjectsFromArray:array];
    id masterId = [[[self keynoteObjectForXMLPath:@"./master-ref"] nodeAttributes] objectForKey:@"IDREF"];
    id master = [[[self rootNode] masterSlides] objectForKey:masterId];
    array = [[master keynoteObjectForXMLPath:@"./page/layers/layer/drawables"] children];
    if (array != nil)
        [items addObjectsFromArray:array];
    array = [layers foregroundLayerItems];
    if (array != nil)
        [items addObjectsFromArray:array];
    return items;
}

- (id)texturedFill
{
    return [self keynoteObjectForXMLPath:@"./stylesheet/styles/slide-style/property-map/fill/textured-fill"];
}

- (id)angleGradient
{
    return [self keynoteObjectForXMLPath:@"./stylesheet/styles/slide-style/property-map/fill/angle-gradient"];
}

- (id)fillColor
{
    return [(KeynoteColor *)[self keynoteObjectForXMLPath:@"./stylesheet/styles/slide-style/property-map/fill/color"] color];
}

- (id)graphicStyle
{
    return [self keynoteObjectForXMLPath:@"./stylesheet/styles/slide-style"];
}

- (id)slideStylesheet
{
    return [self keynoteObjectForXMLPath:@"./stylesheet"];
}

@end
