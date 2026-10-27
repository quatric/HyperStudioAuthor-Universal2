#import "HyperPlayerBasePrefix.h"


@interface HSCanvasActionRegistry : NSObject
{
    NSMutableSet *_registeredActionSelectors;
    NSMutableSet *_availableActionSelectors;
    NSMutableSet *_availableActionSelectorsValidity;
    id _availabilityInformationSource;
}
- (void)setAvailability:(BOOL)aAvailability forAction:(id)aAction;
- (void)confirmAvailabilityInformationIsValidForAction:(id)aAction;
- (BOOL)ensureAvailabilityInformationIsValidForAction:(id)aAction;
- (BOOL)isAvailableAction:(id)aAction;
- (BOOL)isAvailabilityInformationValidForAction:(id)aAction;
- (BOOL)isRegisteredAction:(id)aAction;
- (id)availabilityInformationSource;
- (void)setAvailabilityInformationSource:(id)aSource;
- (void)invalidateActionSelectorAvailability;
- (void)setActionSelector:(SEL)aSelector isAvailable:(BOOL)aAvailable;
- (BOOL)isActionSelectorAvailable:(SEL)aAvailable;
- (void)registerSupportedActionSelector:(SEL)aSelector;
- (id)availableActionSelectorsValidity;
- (id)availableActionSelectors;
- (id)registeredActionSelectors;
- (void)dealloc;
@end

