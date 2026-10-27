#import "HSObjectAssistantNullObject.h"

@implementation HSObjectAssistantNullObject

- (BOOL)supportsSettingsOnTheSpotMode
{
    return _supportsSettingsOnTheSpotMode;
}

- (void)setSupportsSettingsOnTheSpotMode:(BOOL)aMode
{
    _supportsSettingsOnTheSpotMode = aMode;
}

- (void)setRootViewController:(id)aController
{
    if (_rootViewController != aController) {
        [_rootViewController release];
        _rootViewController = [aController retain];
    }
}

- (id)rootViewController
{
    return _rootViewController;
}

- (id)initWithRootViewController:(id)aController supportsSettingsOnTheSpotMode:(BOOL)aMode
{
    self = [super init];
    if (self != nil) {
        [self setRootViewController:aController];
        [self setSupportsSettingsOnTheSpotMode:aMode];
    }
    return self;
}

- (id)initWithRootViewController:(id)aController
{
    return [self initWithRootViewController:aController supportsSettingsOnTheSpotMode:YES];
}

@end
