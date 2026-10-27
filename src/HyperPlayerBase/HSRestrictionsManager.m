#import "HSRestrictionsManager.h"

@interface NSObject (HSRestrictionsProvider)
- (BOOL)boolRestrictionState:(id)aState;
@end

@implementation HSRestrictionsManager
static NSMutableDictionary *sRestrictionsByIdentifier;
+ (BOOL)restrictionState:(id)aState
{
    id restrictions = [sRestrictionsByIdentifier objectForKey:[[NSBundle mainBundle] bundleIdentifier]];
    if (restrictions == nil)
        return [[NSUserDefaults standardUserDefaults] boolForKey:aState];
    return [restrictions boolRestrictionState:aState];
}
+ (void)unregisterRestrictionsForIdentifier:(id)aIdentifier
{
    if (aIdentifier != nil)
        [sRestrictionsByIdentifier removeObjectForKey:aIdentifier];
}
+ (void)registerRestrictions:(id)aRestrictions forIdentifier:(id)aIdentifier
{
    if (aRestrictions != nil && aIdentifier != nil) {
        if (sRestrictionsByIdentifier == nil)
            sRestrictionsByIdentifier = [NSMutableDictionary new];
        [sRestrictionsByIdentifier setObject:aRestrictions forKey:aIdentifier];
    }
}
- (id)init
{
    // Class-only API; instances are refused.
    [super release];
    return nil;
}
@end
