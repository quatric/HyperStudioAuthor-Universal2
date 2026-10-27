#import "HyperStudioPrefix.h"


@interface NSMutableDictionary (HSRegistrationInfo)
+ (id)registrationKeysInfoForRegistrationSettingsType:(id)aType;
+ (id)requiredRegistrationKeysForSettingsType:(id)aType;
+ (id)registrationKeysForSettingsType:(id)aType;
- (void)removeFalseBooleanValues;
- (void)removeNotSupportedValuesForSettingsType:(id)aType;
- (BOOL)containsAllRequiredValuesForSettingsType:(id)aType;
@end
