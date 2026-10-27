#import "HyperStudioPrefix.h"


@interface HSApplicationLicensor : NSObject
{
    NSString *_registrationInfo;
    NSBundle *_applicationBundle;
    NSString *_bundleMajorVersion;
    NSString *_bundleMinorVersion;
    int _licenseStatus;
    int _licenseType;
    int _licenseUsageTimeInfo;
    HSNetworkRegistrar *_applicationRegistrar;
    NSString *_trialSerial;
    NSString *_fisrtTrialExtensionSerial;
    NSString *_secondTrialExtensionSerial;
    NSString *_hiddenTrialExtensionSerial;
    BOOL _isLicensorInitialized;
}
- (id)initWithBundle:(id)aBundle majorVersion:(id)aMajor minorVersion:(id)aMinor;
- (id)init;
- (void)dealloc;
- (void)showLicenseInfoDialog;
- (id)showRegistrationDialog;
- (BOOL)showRegistrationDialogForLicenseType:(int)aType previousLicenseType:(int)aPreviousType;
- (id)showRegistrationDialogWithRegistrationType:(id)aType settingsType:(id)aSettings registrationString:(id)aString isGoBack:(BOOL *)aGoBack;
- (BOOL)validateApplicationLicenseWithInteraction:(BOOL)aInteraction forced:(BOOL)aForced;
- (NSInteger)validateSerialString:(id)aString controller:(id)aController;
- (id)registrationInfo;
- (void)setRegistrationInfo:(id)aInfo;
- (NSInteger)licenseUsageTimeInfo;
- (NSInteger)licenseType;
- (id)applicationRegistrar;
- (void)setApplicationRegistrar:(id)aRegistrar;
- (void)addObservingForRegistrar:(id)aRegistrar;
- (void)removeObservingForRegistrar:(id)aRegistrar;
- (void)networkRegistrarRefused:(id)aRefused;
- (void)registerApplicationOnNetworkForLicenseType:(int)aType;
- (void)showExtensionAlertDialogForTheFirstPeriod:(BOOL)aFirst;
- (BOOL)initialiseHS50Licensor;
- (BOOL)initialiseHSALicensor;
- (void)destroyLicensor;
- (BOOL)loadHSALicense;
- (BOOL)loadHS50License;
- (BOOL)loadHS50LicenseWithHSALicenseLoaded:(BOOL)aLoaded;
- (int)loadLicenseForBundle:(id)aBundle licenseType:(int *)aType usageTimeFlags:(int *)aFlags;
- (int)makeHS50License:(struct SLLicense **)aLicense withSerial:(const char *)aSerial;
- (int)makeHSALicense:(struct SLLicense **)aLicense withSerial:(const char *)aSerial;
- (int)makeLicense:(struct SLLicense **)aLicense withSerial:(const char *)aSerial;
- (BOOL)validateHS50MASReceipt;
- (BOOL)validateMASReceiptForBundleAtPath:(id)aPath;
- (NSInteger)runLicenseDialogsWithNewLicenseForced:(BOOL)aForced licenseChanged:(BOOL *)aChanged registrationUserInfo:(id *)aInfo;
- (NSInteger)runSerialNumberDialogWithContext:(id)aContext;
- (NSInteger)runSubmitInformationDialogWithContext:(id)aContext registrationUserInfo:(id)aInfo registrationNumber:(id)aNumber;
- (NSInteger)didClickCancelInSerialNumberDialogWithContext:(id)aContext;
- (NSInteger)didClickContinueInSerialNumberDialogWithContext:(id)aContext;
- (NSInteger)didClickTrialInSerialNumberDialogWithContext:(id)aContext;
- (NSInteger)didClickMoreTrialDaysInSerialNumberDialogWithContext:(id)aContext;
- (id)HSApplicationLicensor_HS50RegistrationIdentifier;
- (id)HSApplicationLicensor_trialSerial;
- (id)HSApplicationLicensor_fisrtTrialExtensionSerial;
- (id)HSApplicationLicensor_secondTrialExtensionSerial;
- (id)HSApplicationLicensor_hiddenTrialExtensionSerial;
@end

@interface HSSerialValidationContext : NSObject
{
    NSString *_serialString;
    struct SLLicense *_license;
    int _usageTimeFlags;
}
- (id)initWithSerialString:(id)aString license:(struct SLLicense *)aLicense usageTimeFlags:(NSInteger)aFlags;
- (void)dealloc;
- (id)serialString;
- (struct SLLicense *)license;
- (NSInteger)usageTimeFlags;
- (NSInteger)activateLicense;
@end
