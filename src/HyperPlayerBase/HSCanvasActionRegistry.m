#import "HSCanvasActionRegistry.h"
// Registry of the action selectors a canvas supports and which of them are
// currently available. Availability is cached per action until
// invalidated, and asked of the information source when not known.

@implementation HSCanvasActionRegistry

- (void)setAvailability:(BOOL)aAvailability forAction:(id)aAction
{
    if (aAvailability)
        [[self availableActionSelectors] addObject:aAction];
    else
        [_availableActionSelectors removeObject:aAction];
}

- (void)confirmAvailabilityInformationIsValidForAction:(id)aAction
{
    [[self availableActionSelectorsValidity] addObject:aAction];
}

- (BOOL)ensureAvailabilityInformationIsValidForAction:(id)aAction
{
    if ([self isAvailabilityInformationValidForAction:aAction])
        return YES;
    if (!_availabilityInformationSource)
        return NO;
    BOOL available = [_availabilityInformationSource canvasActionRegistry:self isAvailableActionSelector:[aAction selector]];
    [self confirmAvailabilityInformationIsValidForAction:aAction];
    [self setAvailability:available forAction:aAction];
    return YES;
}

- (BOOL)isAvailableAction:(id)aAction
{
    return [_availableActionSelectors containsObject:aAction];
}

- (BOOL)isAvailabilityInformationValidForAction:(id)aAction
{
    return [_availableActionSelectorsValidity containsObject:aAction];
}

- (BOOL)isRegisteredAction:(id)aAction
{
    return [_registeredActionSelectors containsObject:aAction];
}

- (id)availabilityInformationSource
{
    return _availabilityInformationSource;
}

- (void)setAvailabilityInformationSource:(id)aSource
{
    _availabilityInformationSource = aSource;
}

- (void)invalidateActionSelectorAvailability
{
    [_availableActionSelectorsValidity removeAllObjects];
}

- (void)setActionSelector:(SEL)aSelector isAvailable:(BOOL)aAvailable
{
    id action = [HSCanvasActionIdentifier identifierWithActionSelector:aSelector];
    if ([self isRegisteredAction:action]) {
        [self confirmAvailabilityInformationIsValidForAction:action];
        [self setAvailability:aAvailable forAction:action];
    }
}

- (BOOL)isActionSelectorAvailable:(SEL)aAvailable
{
    id action = [HSCanvasActionIdentifier identifierWithActionSelector:aAvailable];
    if ([self isRegisteredAction:action] && [self ensureAvailabilityInformationIsValidForAction:action])
        return [self isAvailableAction:action];
    return NO;
}

- (void)registerSupportedActionSelector:(SEL)aSelector
{
    [[self registeredActionSelectors] addObject:[HSCanvasActionIdentifier identifierWithActionSelector:aSelector]];
}

- (id)availableActionSelectorsValidity
{
    if (!_availableActionSelectorsValidity)
        _availableActionSelectorsValidity = [NSMutableSet new];
    return _availableActionSelectorsValidity;
}

- (id)availableActionSelectors
{
    if (!_availableActionSelectors)
        _availableActionSelectors = [NSMutableSet new];
    return _availableActionSelectors;
}

- (id)registeredActionSelectors
{
    if (!_registeredActionSelectors)
        _registeredActionSelectors = [NSMutableSet new];
    return _registeredActionSelectors;
}

- (void)dealloc
{
    [_registeredActionSelectors release];
    [_availableActionSelectors release];
    [_availableActionSelectorsValidity release];
    [super dealloc];
}

@end
