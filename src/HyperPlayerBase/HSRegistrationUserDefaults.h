#import "HyperPlayerBasePrefix.h"


@interface HSRegistrationUserDefaults : NSObject
+ (id)objectForKey:(id)aKey;
+ (void)setObject:(id)aObject forKey:(id)aKey;
+ (BOOL)isRegistrationCompleted;
+ (void)setRegistrationCompleted;
+ (BOOL)isRegistrationPostponed;
+ (void)setRegistrationPostponed;
+ (BOOL)isRegistrationRefused;
+ (void)setRegistrationRefused;
+ (BOOL)isRegistrationTypeTrial;
+ (void)setRegistrationTypeTrial;
+ (BOOL)isRegistrationTypeSerial;
+ (void)setRegistrationTypeSerial;
+ (id)registrationUserInfo;
+ (void)setRegistrationUserInfo:(id)aInfo;
+ (id)HS50registrationUserInfo;
@end
