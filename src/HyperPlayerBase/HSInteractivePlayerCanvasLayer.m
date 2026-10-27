#import "HSInteractivePlayerCanvasLayer.h"
@implementation HSInteractivePlayerCanvasLayer
+ (id)supportedIdentifiers
{
    return [NSArray arrayWithObjects:HSInteractiveObjectsLayerIdentifier, nil];
}
- (id)interactiveObjectsLayer
{
    return [self sublayerForIdentifier:HSInteractiveObjectsLayerIdentifier];
}
// All the supported layers, enabled by default; the factory comes from
// -sublayerFactory.
- (id)init
{
    self = [super initWithSupportedIdentifiers:[[self class] supportedIdentifiers] enabledIdentifiers:nil sublayerFactory:nil];
    if (self != nil)
        [self setDefaultSublayerIdentifiers:[NSSet setWithArray:[[self class] supportedIdentifiers]]];
    return self;
}
// Not available: use -init. (The original returned nil without releasing the
// allocated instance; it's released here.)
- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory
{
    [self release];
    return nil;
}
- (id)sublayerFactory
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[HSInteractiveObjectsLayer class], HSInteractiveObjectsLayerIdentifier, nil];
}
@end
