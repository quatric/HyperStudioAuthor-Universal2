#import "HyperStudioPrefix.h"


@interface HSApplicationLicensor : NSObject
{
    NSString *_registrationInfo;
    NSBundle *_applicationBundle;
    NSString *_majorVersion;
    NSString *_minorVersion;
    int _licenseStatus;
    int _licenseType;
    int _licenseUsageTimeInfo;
    HSNetworkRegistrar *_applicationRegistrar;
    NSString *_trialSerial;
    NSString *_fisrtTrialExtensionSerial;
    NSString *_secondTrialExtensionSerial;
    NSString *_hiddenTrialExtensionSerial;
}
- (void)showLicenseInfoDialog;
- (id)showRegistrationDialogForceUI:(BOOL)aUI isGoBack:(BOOL *)aBack;
- (void)createRequestWithURLString:(id)aString;
- (NSInteger)validateSerialString:(id)aString controller:(id)aController;
- (BOOL)validateApplicationLicenseWithInteraction:(BOOL)aInteraction forced:(BOOL)aForced;
- (id)registrationInfo;
- (NSInteger)licenseUsageTimeInfo;
- (NSInteger)licenseType;
- (id)initWithLicensorBytes:(void *)aBytes bytesSize:(NSUInteger)aSize bundle:(id)aBundle majorVersion:(id)aVersion minorVersion:(id)aVersion2;
- (id)init;
- (void)dealloc;
- (void)HSApplicationLicensor_registerApplicationOnNetworkForLicenseType:(NSInteger)aType;
- (void)HSApplicationLicensor_networkRegistrarRefused:(id)aRefused;
- (NSInteger)HSApplicationLicensor_licenseApplicationWithReason:(NSInteger)aReason currentLicenseType:(NSInteger)aType isCanceled:(BOOL *)aCanceled isLicenseChanged:(BOOL *)aChanged;
- (id)HSApplicationLicensor_showRegistrationDialog:(id)aDialog registrationString:(id)aString forceUI:(BOOL)aUI isGoBack:(BOOL *)aBack;
- (id)HSApplicationLicensor_hiddenTrialExtensionSerial;
- (id)HSApplicationLicensor_secondTrialExtensionSerial;
- (id)HSApplicationLicensor_fisrtTrialExtensionSerial;
- (id)HSApplicationLicensor_trialSerial;
- (NSInteger)HSApplicationLicensor_storeApplicationLicenseForBundle:(id)aBundle;
- (NSInteger)HSApplicationLicensor_storeWithAuthorizatonTool:(char *)aTool licenseBytes:(void *)aBytes licenseBytesSize:(NSUInteger)aSize environment:(void *)aEnvironment environmentSize:(NSUInteger)aSize2;
- (NSInteger)HSApplicationLicensor_loadLicenseForBundle:(id)aBundle licenseType:(int *)aType usageTimeFlags:(int *)aFlags;
- (id)HSApplicationLicensor_registrationInfoForLicense:(struct SLLicense *)aLicense;
@end

@interface HSSerialValidationContext : NSObject
{
    NSString *_serialString;
    struct SLLicense *_license;
    int _usageTimeFlags;
}
- (NSInteger)activateLicense;
- (NSInteger)usageTimeFlags;
- (struct SLLicense *)license;
- (id)serialString;
- (void)dealloc;
- (id)initWithSerialString:(id)aString license:(struct SLLicense *)aLicense usageTimeFlags:(NSInteger)aFlags;
@end

