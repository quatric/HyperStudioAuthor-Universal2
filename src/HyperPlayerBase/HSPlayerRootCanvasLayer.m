#import "HSPlayerRootCanvasLayer.h"
// The player's canvas: a card in an interactive layer.
@implementation HSPlayerRootCanvasLayer
+ (id)supportedIdentifiers
{
    return [NSArray arrayWithObjects:HSInteractivePlayerCanvasLayerIdentifier, nil];
}
- (void)setRepresentedObject:(id)aObject
{
    [self setCard:aObject];
}
- (void)setCard:(id)aCard
{
    [super setRepresentedObject:aCard];
}
- (id)card
{
    return [self representedObject];
}
- (id)interactiveObjectsLayer
{
    return [[self interactivePlayerCanvasLayer] interactiveObjectsLayer];
}
- (id)interactivePlayerCanvasLayer
{
    return [self sublayerForIdentifier:HSInteractivePlayerCanvasLayerIdentifier];
}
- (id)init
{
    return [super initWithSupportedIdentifiers:[[self class] supportedIdentifiers] enabledIdentifiers:nil sublayerFactory:nil];
}
- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory
{
    return nil;
}
- (id)sublayerFactory
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[HSInteractivePlayerCanvasLayer class], HSInteractivePlayerCanvasLayerIdentifier, nil];
}
@end
