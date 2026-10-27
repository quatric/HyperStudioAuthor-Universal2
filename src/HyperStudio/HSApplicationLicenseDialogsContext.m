#import "HSApplicationLicenseDialogsContext.h"

@implementation HSApplicationLicenseDialogsContext

- (id)initWithLicensingReason:(int)aReason currentLicenseType:(int)aType
{
    self = [super init];
    if (self != nil) {
        _licensingReason = aReason;
        _currentLicenseType = aType;
    }
    return self;
}

- (void)dealloc
{
    [_trialRegistrationNumber release];
    [_encryptedRegistrationNumber release];
    [_serialNumberDialogController release];
    [_submitInformationDialogController release];
    [_registrationUserInfo release];
    [super dealloc];
}

- (int)licensingReason
{
    return _licensingReason;
}

- (int)currentLicenseType
{
    return _currentLicenseType;
}

- (BOOL)isTrialLicenseExpired
{
    if ([self currentLicenseType] == 3)
        return YES;
    return [[self trialRegistrationNumber] length] == 0;
}

- (int)trialLicenseState
{
    int reason = [self licensingReason];
    if (reason == 1 || reason == 2)
        return 1;
    if (reason == 4)
        return 2;
    if (reason == 3)
        return 3;
    return [self isTrialLicenseExpired] ? 3 : 1;
}

- (id)trialRegistrationNumber
{
    if (_trialRegistrationNumber == nil && [self licensingReason] == 0)
        _trialRegistrationNumber = [[HSApplicationLicensorUtilities trialSerialString] retain];
    return _trialRegistrationNumber;
}

- (id)serialNumberDialogController
{
    if (_serialNumberDialogController == nil) {
        NSString *type;
        switch ([self licensingReason]) {
        case 1:
            type = HSSerialNumberDialogControllerTypeTrialFirstExtended;
            break;
        case 2:
            type = HSSerialNumberDialogControllerTypeTrialLastExtended;
            break;
        case 3:
            type = HSSerialNumberDialogControllerTypeTrial;
            break;
        case 4:
            type = HSSerialNumberDialogControllerTypeActivate;
            break;
        default:
            type = [self isTrialLicenseExpired] ? HSSerialNumberDialogControllerTypeCommonWOTrial
                                                : HSSerialNumberDialogControllerTypeCommon;
        }
        _serialNumberDialogController = [[HSSerialNumberDialogController alloc] initWithType:type];
    }
    return _serialNumberDialogController;
}

- (id)submitInformationDialogController
{
    if (_submitInformationDialogController == nil) {
        _submitInformationDialogController = [[HSSubmitInformationDialogController alloc] initWithWindowNibName:@"SubmitInformationDialog"];
        [_submitInformationDialogController setTrialLicenseState:[self trialLicenseState]];
    }
    return _submitInformationDialogController;
}

- (id)encryptedRegistrationNumber
{
    return _encryptedRegistrationNumber;
}

- (void)setEncryptedRegistrationNumber:(id)aNumber
{
    if (_encryptedRegistrationNumber != aNumber) {
        [_encryptedRegistrationNumber release];
        _encryptedRegistrationNumber = [aNumber retain];
    }
}

- (id)registrationUserInfo
{
    return _registrationUserInfo;
}

- (void)setRegistrationUserInfo:(id)aInfo
{
    if (_registrationUserInfo != aInfo) {
        [_registrationUserInfo release];
        _registrationUserInfo = [aInfo retain];
    }
}

- (BOOL)isSerialNumberDialogCompleted
{
    return _isSerialNumberDialogCompleted;
}

- (void)setIsSerialNumberDialogCompleted:(BOOL)aCompleted
{
    _isSerialNumberDialogCompleted = aCompleted;
}

- (BOOL)isDialogCanceled
{
    return _isDialogCanceled;
}

- (void)setIsDialogCanceled:(BOOL)aCanceled
{
    _isDialogCanceled = aCanceled;
}

- (struct SLLicense *)trialLicense
{
    return _trialLicense;
}

- (void)setTrialLicense:(struct SLLicense *)aLicense
{
    _trialLicense = aLicense;
}

@end
