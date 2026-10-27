#import "HyperStudioPrefix.h"


@interface HSObjectAssistantNullObject : NSObject <HSObjectAssistantNullObjectInterface, HyperInterface, NSObject>
{
    HSObjectAssistantPane *_rootViewController;
    BOOL _supportsSettingsOnTheSpotMode;
}
- (BOOL)supportsSettingsOnTheSpotMode;
- (void)setSupportsSettingsOnTheSpotMode:(BOOL)aMode;
- (void)setRootViewController:(id)aController;
- (id)rootViewController;
- (id)initWithRootViewController:(id)aController supportsSettingsOnTheSpotMode:(BOOL)aMode;
- (id)initWithRootViewController:(id)aController;
@end

