#import "HyperPlayerBasePrefix.h"


@interface HSRestrictionsManager : NSObject
{
}
+ (BOOL)restrictionState:(id)aState;
+ (void)unregisterRestrictionsForIdentifier:(id)aIdentifier;
+ (void)registerRestrictions:(id)aRestrictions forIdentifier:(id)aIdentifier;
- (id)init;
@end

