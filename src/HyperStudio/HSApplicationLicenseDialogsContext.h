#import "HyperStudioPrefix.h"


@interface HSApplicationLicenseDialogsContext : NSObject
{
    int _licensingReason;
    int _currentLicenseType;
    NSString *_trialRegistrationNumber;
    struct SLLicense *_trialLicense;
    NSString *_encryptedRegistrationNumber;
    NSDictionary *_registrationUserInfo;
    HSSerialNumberDialogController *_serialNumberDialogController;
    HSSubmitInformationDialogController *_submitInformationDialogController;
    BOOL _isSerialNumberDialogCompleted;
    BOOL _isDialogCanceled;
}
- (id)initWithLicensingReason:(int)aReason currentLicenseType:(int)aType;
- (void)dealloc;
- (int)licensingReason;
- (int)currentLicenseType;
- (BOOL)isTrialLicenseExpired;
- (int)trialLicenseState;
- (id)trialRegistrationNumber;
- (id)serialNumberDialogController;
- (id)submitInformationDialogController;
- (id)encryptedRegistrationNumber;
- (void)setEncryptedRegistrationNumber:(id)aNumber;
- (id)registrationUserInfo;
- (void)setRegistrationUserInfo:(id)aInfo;
- (BOOL)isSerialNumberDialogCompleted;
- (void)setIsSerialNumberDialogCompleted:(BOOL)aCompleted;
- (BOOL)isDialogCanceled;
- (void)setIsDialogCanceled:(BOOL)aCanceled;
- (struct SLLicense *)trialLicense;
- (void)setTrialLicense:(struct SLLicense *)aLicense;
@end
