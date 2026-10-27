#import "HSArrowToolCanvasLayer.h"

@implementation HSArrowToolCanvasLayer

+ (id)supportedIdentifiers
{
    return [NSArray arrayWithObjects:@"HSSelectionCanvasLayer", @"HSDragCardViewCanvasLayer", @"HSAuxiliaryIconsCanvasLayer", @"HSLayoutRulesCanvasLayer", nil];
}

- (void)setEnabledSublayerIdentifiers:(id)aIdentifiers
{
    if (_overridingOrderArray == nil) {
        [super setEnabledSublayerIdentifiers:aIdentifiers];
    } else {
        [self setOverridingOrderArray:nil];
        [super setEnabledSublayerIdentifiers:aIdentifiers];
        [self updateSublayersOrder];
    }
}

- (void)setEnabledSublayerIdentifiersWithOrder:(id)aOrder
{
    [self setOverridingOrderArray:aOrder];
    [super setEnabledSublayerIdentifiers:[NSSet setWithArray:aOrder]];
    [self updateSublayersOrder];
}

- (void)setOverridingOrderArray:(id)aArray
{
    [_overridingOrderArray autorelease];
    _overridingOrderArray = nil;
    if (aArray != nil)
        _overridingOrderArray = [[[super supportedIdentifiers] extraReorderedArrayAgainstArray:aArray] retain];
}

- (id)enabledSelectedObjectsLayer
{
    return [[self enabledSelectionLayer] enabledSelectedObjectsLayer];
}

- (id)enabledSelectionLayer
{
    return [self enabledSublayerForIdentifier:@"HSSelectionCanvasLayer"];
}

- (id)enabledLayoutRulesLayer
{
    return [self enabledSublayerForIdentifier:@"HSLayoutRulesCanvasLayer"];
}

- (void)dealloc
{
    [_overridingOrderArray release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithSupportedIdentifiers:[[self class] supportedIdentifiers] enabledIdentifiers:nil sublayerFactory:nil];
    if (self != nil)
        [self setDefaultSublayerIdentifiers:[NSSet setWithArray:[[self class] supportedIdentifiers]]];
    return self;
}

- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory
{
    // Original quirk kept: only -init is supported; the designated initializer is disabled.
    return nil;
}

- (id)sublayerFactory
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [HSAuxiliaryIconsCanvasLayer class], @"HSAuxiliaryIconsCanvasLayer",
        [HSLayoutRulesCanvasLayer class], @"HSLayoutRulesCanvasLayer",
        [HSSelectionCanvasLayer class], @"HSSelectionCanvasLayer",
        [HSDragCardViewCanvasLayer class], @"HSDragCardViewCanvasLayer",
        nil];
}

@end
