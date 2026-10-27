#import "HSRegistrationUserDefaults.h"

static NSString *const HSRegistrationDefaultsKeyRegistrationChoice = @"HSRegistrationDefaultsKeyRegistrationChoice";
static NSString *const HSRegistrationDefaultsKeyStoredPanelOptions = @"HSRegistrationDefaultsKeyStoredPanelOptions";
static NSString *const HSRegistrationDefaultsValRegistered = @"HSRegistrationDefaultsValRegistered";
static NSString *const HSRegistrationDefaultsValRegisterLater = @"HSRegistrationDefaultsValRegisterLater";
static NSString *const HSRegistrationDefaultsValDontRegister = @"HSRegistrationDefaultsValDontRegister";
static NSString *const HSRegistrationType = @"HSRegistrationType";
static NSString *const HSRegistrationTrial = @"HSRegistrationTrial";
static NSString *const HSRegistrationSerial = @"HSRegistrationSerial";

@implementation HSRegistrationUserDefaults

+ (id)objectForKey:(id)aKey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:aKey];
}

+ (void)setObject:(id)aObject forKey:(id)aKey
{
    [[NSUserDefaults standardUserDefaults] setObject:aObject forKey:aKey];
}

+ (BOOL)isRegistrationCompleted
{
    return [[self objectForKey:HSRegistrationDefaultsKeyRegistrationChoice] isEqualToString:HSRegistrationDefaultsValRegistered];
}

+ (void)setRegistrationCompleted
{
    [self setObject:HSRegistrationDefaultsValRegistered forKey:HSRegistrationDefaultsKeyRegistrationChoice];
}

+ (BOOL)isRegistrationPostponed
{
    return [[self objectForKey:HSRegistrationDefaultsKeyRegistrationChoice] isEqualToString:HSRegistrationDefaultsValRegisterLater];
}

+ (void)setRegistrationPostponed
{
    [self setObject:HSRegistrationDefaultsValRegisterLater forKey:HSRegistrationDefaultsKeyRegistrationChoice];
}

+ (BOOL)isRegistrationRefused
{
    return [[self objectForKey:HSRegistrationDefaultsKeyRegistrationChoice] isEqualToString:HSRegistrationDefaultsValDontRegister];
}

+ (void)setRegistrationRefused
{
    [self setObject:HSRegistrationDefaultsValDontRegister forKey:HSRegistrationDefaultsKeyRegistrationChoice];
}

+ (BOOL)isRegistrationTypeTrial
{
    return [[self objectForKey:HSRegistrationType] isEqualToString:HSRegistrationTrial];
}

+ (void)setRegistrationTypeTrial
{
    [self setObject:HSRegistrationTrial forKey:HSRegistrationType];
}

+ (BOOL)isRegistrationTypeSerial
{
    return [[self objectForKey:HSRegistrationType] isEqualToString:HSRegistrationSerial];
}

+ (void)setRegistrationTypeSerial
{
    [self setObject:HSRegistrationSerial forKey:HSRegistrationType];
}

+ (id)registrationUserInfo
{
    return [self objectForKey:HSRegistrationDefaultsKeyStoredPanelOptions];
}

+ (void)setRegistrationUserInfo:(id)aInfo
{
    [self setObject:aInfo forKey:HSRegistrationDefaultsKeyStoredPanelOptions];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// The registration that HyperStudio 5 stored in its own preference domain.
+ (id)HS50registrationUserInfo
{
    CFStringRef domain = CFSTR("com.mackiev.hyperstudio");
    id choice = [(id)CFPreferencesCopyValue((CFStringRef)HSRegistrationDefaultsKeyRegistrationChoice, domain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease];
    if (![choice isEqualToString:HSRegistrationDefaultsValRegistered]) {
        return nil;
    }
    return [(id)CFPreferencesCopyValue((CFStringRef)HSRegistrationDefaultsKeyStoredPanelOptions, domain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease];
}

@end
