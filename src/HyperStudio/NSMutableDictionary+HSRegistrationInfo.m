#import "NSMutableDictionary+HSRegistrationInfo.h"

@implementation NSMutableDictionary (HSRegistrationInfo)

+ (id)registrationKeysInfoForRegistrationSettingsType:(id)aType
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"registrationKeys" ofType:@"plist"];
    if (path == nil)
        return nil;
    return [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:aType];
}

+ (id)requiredRegistrationKeysForSettingsType:(id)aType
{
    return [[self registrationKeysInfoForRegistrationSettingsType:aType] objectForKey:@"required"];
}

+ (id)registrationKeysForSettingsType:(id)aType
{
    NSMutableArray *keys = [NSMutableArray array];
    NSDictionary *info = [self registrationKeysInfoForRegistrationSettingsType:aType];
    [keys addObjectsFromArray:[info objectForKey:@"required"]];
    [keys addObjectsFromArray:[info objectForKey:@"acceptable"]];
    return keys;
}

- (void)removeFalseBooleanValues
{
    NSArray *keys = [NSArray arrayWithObjects:kHSUsersDefaultsRegistrationSchoolPricesKey, kHSUsersDefaultsRegistrationENewsEmailsKey, kHSUsersDefaultsRegistrationReceiveHSMailKey, kHSUsersDefaultsRegistrationReceiveAllMailKey, kHSUsersDefaultsRegistrationReceiveSchoolMailKey, nil];
    for (NSString *key in keys) {
        if ([[self objectForKey:key] intValue] == 0)
            [self removeObjectForKey:key];
    }
}

- (void)removeNotSupportedValuesForSettingsType:(id)aType
{
    NSArray *supported = [[self class] registrationKeysForSettingsType:aType];
    for (NSString *key in [self allKeys]) {
        if (![supported containsObject:key])
            [self removeObjectForKey:key];
    }
}

- (BOOL)containsAllRequiredValuesForSettingsType:(id)aType
{
    for (NSString *key in [[self class] requiredRegistrationKeysForSettingsType:aType]) {
        if ([self objectForKey:key] == nil)
            return NO;
    }
    return YES;
}

@end
