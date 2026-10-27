#import "HSNamedSublayersCanvasLayer.h"

@implementation HSNamedSublayersCanvasLayer

- (void)updateSublayersOrder
{
    NSArray *ordered = [_enabledSublayers extraObjectsForKeys:[self supportedIdentifiers] omitAbsent:YES];
    if (![[self allSublayers] isExtraIdenticalToArray:ordered])
        [self setReorderedSublayers:ordered];
}

- (void)enableSublayerForIdentifier:(id)aIdentifier withOrderCheck:(BOOL)aCheck
{
    id sublayer = [_disabledSublayers objectForKey:aIdentifier];
    if (sublayer == nil) {
        sublayer = [self querySublayerWithIdentifier:aIdentifier];
    } else {
        [[sublayer retain] autorelease];
        [_disabledSublayers removeObjectForKey:aIdentifier];
    }
    NSUInteger index = aCheck ? [self indexToInsertSublayerForIdentifier:aIdentifier] : [self numberOfSublayers];
    [[self enabledSublayers] setObject:sublayer forKey:aIdentifier];
    [self addSublayer:sublayer atIndex:index];
}

- (id)sublayerForIdentifier:(id)aIdentifier
{
    id sublayer = [self enabledSublayerForIdentifier:aIdentifier];
    if (sublayer == nil)
        sublayer = [_disabledSublayers objectForKey:aIdentifier];
    if (sublayer == nil) {
        sublayer = [self querySublayerWithIdentifier:aIdentifier];
        [[self disabledSublayers] setObject:sublayer forKey:aIdentifier];
    }
    return sublayer;
}

- (void)enableSublayerForIdentifierIfNeeded:(id)aNeeded
{
    if ([_enabledSublayers objectForKey:aNeeded] == nil)
        [self enableSublayerForIdentifier:aNeeded withOrderCheck:NO];
}

- (NSUInteger)indexToInsertSublayerForIdentifier:(id)aIdentifier
{
    // Number of enabled sublayers whose identifiers precede aIdentifier.
    NSUInteger index = 0;
    NSEnumerator *enumerator = [[self supportedIdentifiers] objectEnumerator];
    id identifier;
    while ((identifier = [enumerator nextObject]) != nil) {
        if ([aIdentifier isEqual:identifier])
            break;
        if ([_enabledSublayers objectForKey:identifier] != nil)
            index++;
    }
    return index;
}

- (id)disabledSublayers
{
    if (_disabledSublayers == nil)
        _disabledSublayers = [NSMutableDictionary new];
    return _disabledSublayers;
}

- (id)enabledSublayers
{
    if (_enabledSublayers == nil)
        _enabledSublayers = [NSMutableDictionary new];
    return _enabledSublayers;
}

- (void)setSublayerIdentifier:(id)aIdentifier isEnabledByDefault:(BOOL)aDefault
{
    if ([self isSublayerIdentifierEnabledByDefault:aIdentifier] == aDefault)
        return;
    NSMutableSet *identifiers = [self mutableDefaultSublayerIdentifiers];
    if (aDefault) {
        [identifiers addObject:aIdentifier];
        if (_isUsingDefaultIdentifierSet)
            [self enableSublayerForIdentifier:aIdentifier];
    } else {
        [identifiers removeObject:aIdentifier];
        if (_isUsingDefaultIdentifierSet)
            [self disableSublayerForIdentifier:aIdentifier];
    }
}

- (BOOL)isSublayerIdentifierEnabledByDefault:(id)aDefault
{
    return [[self defaultSublayerIdentifiers] containsObject:aDefault];
}

- (void)setDefaultSublayerIdentifiers:(id)aIdentifiers
{
    NSEnumerator *enumerator = [_supportedIdentifiers objectEnumerator];
    id identifier;
    while ((identifier = [enumerator nextObject]) != nil)
        [self setSublayerIdentifier:identifier isEnabledByDefault:[aIdentifiers containsObject:identifier]];
}

- (id)defaultSublayerIdentifiers
{
    if (_defaultSublayerIdentifiers == nil)
        return [NSSet set];
    return _defaultSublayerIdentifiers;
}

- (id)mutableDefaultSublayerIdentifiers
{
    if (_defaultSublayerIdentifiers == nil)
        _defaultSublayerIdentifiers = [[NSMutableSet alloc] init];
    return _defaultSublayerIdentifiers;
}

- (id)enabledSublayerIdentifiers
{
    NSArray *keys = [_enabledSublayers allKeys];
    return keys ? [NSSet setWithArray:keys] : [NSSet set];
}

- (void)setEnabledSublayerIdentifiers:(id)aIdentifiers
{
    // nil means "follow the default identifier set".
    id identifiers = aIdentifiers;
    if (identifiers == nil) {
        identifiers = [self defaultSublayerIdentifiers];
        _isUsingDefaultIdentifierSet = YES;
    } else {
        _isUsingDefaultIdentifierSet = NO;
    }

    NSEnumerator *enumerator = [[self enabledSublayerIdentifiers] objectEnumerator];
    id identifier;
    while ((identifier = [enumerator nextObject]) != nil) {
        if (![identifiers containsObject:identifier])
            [self disableSublayerForIdentifier:identifier];
    }
    if ([_enabledSublayers count] != [identifiers count]) {
        enumerator = [identifiers objectEnumerator];
        while ((identifier = [enumerator nextObject]) != nil)
            [self enableSublayerForIdentifierIfNeeded:identifier];
    }
}

- (id)enabledSublayerForIdentifier:(id)aIdentifier
{
    return [_enabledSublayers objectForKey:aIdentifier];
}

- (BOOL)isEnabledSublayerForIdentifier:(id)aIdentifier
{
    return [_enabledSublayers objectForKey:aIdentifier] != nil;
}

- (void)disableSublayerForIdentifier:(id)aIdentifier
{
    id sublayer = [_enabledSublayers objectForKey:aIdentifier];
    [[self disabledSublayers] setObject:sublayer forKey:aIdentifier];
    [_enabledSublayers removeObjectForKey:aIdentifier];
    [self removeSublayer:sublayer];
}

- (void)enableSublayerForIdentifier:(id)aIdentifier
{
    [self enableSublayerForIdentifier:aIdentifier withOrderCheck:YES];
}

- (id)supportedIdentifiers
{
    return _supportedIdentifiers;
}

- (void)dealloc
{
    [_supportedIdentifiers release];
    [_enabledSublayers release];
    [_disabledSublayers release];
    [_defaultSublayerIdentifiers release];
    [_sublayerFactory release];
    [super dealloc];
}

- (id)init
{
    return [self initWithSupportedIdentifiers:nil enabledIdentifiers:nil sublayerFactory:nil];
}

- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory
{
    self = [super init];
    if (self != nil) {
        _supportedIdentifiers = [[NSArray alloc] initWithArray:aIdentifiers];
        _sublayerFactory = [aFactory retain];
        if (aIdentifiers2 == nil) {
            _isUsingDefaultIdentifierSet = YES;
        } else if ([aIdentifiers2 count]) {
            NSEnumerator *enumerator = [_supportedIdentifiers objectEnumerator];
            id identifier;
            while ((identifier = [enumerator nextObject]) != nil) {
                if ([aIdentifiers2 containsObject:identifier])
                    [self enableSublayerForIdentifier:identifier withOrderCheck:NO];
            }
        }
    }
    return self;
}

- (id)initWithSupportedIdentifiers:(id)aIdentifiers sublayerFactory:(id)aFactory
{
    return [self initWithSupportedIdentifiers:aIdentifiers enabledIdentifiers:nil sublayerFactory:aFactory];
}

- (id)initWithSupportedIdentifiers:(id)aIdentifiers
{
    return [self initWithSupportedIdentifiers:aIdentifiers enabledIdentifiers:nil sublayerFactory:nil];
}

- (id)queryAndVerifySublayerWithIdentifier:(id)aIdentifier
{
    return [self querySublayerWithIdentifier:aIdentifier];
}

- (id)sublayerFactory
{
    return _sublayerFactory;
}

- (id)querySublayerWithIdentifier:(id)aIdentifier
{
    // The factory maps identifiers to sublayer classes.
    return [[[[[self sublayerFactory] objectForKey:aIdentifier] alloc] init] autorelease];
}

@end
