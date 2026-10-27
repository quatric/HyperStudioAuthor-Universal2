#import "HSApplicationLicensor.h"
#import <CommonCrypto/CommonDigest.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/network/IOEthernetController.h>
#import <Security/Security.h>
#import "HSApplicationLicensorData.h"

static HSLicenseInfoDialogController *sLicenseInfoDialogController;

static NSString *HSApplicationLicensorLocalized(NSString *aKey)
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:aKey value:@"" table:@"Alerts"];
}

static void HSApplicationLicensorRunAuthenticationAlert(id self)
{
    NSString *title = HSApplicationLicensorLocalized(@"Cannot launch HyperStudio");
    NSString *message = HSApplicationLicensorLocalized(@"You should authenticate with your administrator password to activate HyperStudio");
    NSString *authenticate = HSApplicationLicensorLocalized(@"Authenticate");
    NSString *quit = HSApplicationLicensorLocalized(@"Quit");
    if (NSRunAlertPanel(title, @"%@", authenticate, quit, nil, message) != NSAlertDefaultReturn)
        [NSApp terminate:self];
}

// The fields of a receipt, as the decoded attribute numbers: 2 bundle identifier, 3 version, 4 opaque value, 5 hash.
static NSDictionary *HSApplicationLicensorCopyReceiptAttributes(NSData *aReceipt);

@implementation HSApplicationLicensor

- (id)initWithBundle:(id)aBundle majorVersion:(id)aMajor minorVersion:(id)aMinor
{
    self = [super init];
    if (self != nil) {
        _bundleMajorVersion = [aMajor copy];
        _bundleMinorVersion = [aMinor copy];
        _applicationBundle = [aBundle retain];
        _licenseType = 0;
        _licenseUsageTimeInfo = 0;
        _licenseStatus = 1;
        [[LUUserDataValidation sharedInstance] updateApplicationSessionInfo];
    }
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

- (void)dealloc
{
    [self removeObservingForRegistrar:_applicationRegistrar];
    [_applicationRegistrar release];
    [[LUUserDataValidation sharedInstance] updateApplicationSessionInfo];
    [self destroyLicensor];
    [_registrationInfo release];
    [_applicationBundle release];
    [_bundleMajorVersion release];
    [_bundleMinorVersion release];
    [_trialSerial release];
    [_fisrtTrialExtensionSerial release];
    [_secondTrialExtensionSerial release];
    [_hiddenTrialExtensionSerial release];
    [super dealloc];
}

- (void)showLicenseInfoDialog
{
    if (sLicenseInfoDialogController == nil)
        sLicenseInfoDialogController = [[HSLicenseInfoDialogController alloc] initWithInfo:[[LUUserDataValidation sharedInstance] licenseDescription:NULL]];
    else
        [sLicenseInfoDialogController setLicenseInfo:[[LUUserDataValidation sharedInstance] licenseDescription:NULL]];
    [sLicenseInfoDialogController run];
}

- (id)registrationInfo
{
    return [[_registrationInfo retain] autorelease];
}

- (void)setRegistrationInfo:(id)aInfo
{
    if (_registrationInfo != aInfo) {
        [_registrationInfo release];
        _registrationInfo = [aInfo copy];
    }
}

- (NSInteger)licenseUsageTimeInfo
{
    return _licenseUsageTimeInfo;
}

- (NSInteger)licenseType
{
    return _licenseType;
}

- (id)applicationRegistrar
{
    return _applicationRegistrar;
}

- (void)setApplicationRegistrar:(id)aRegistrar
{
    if (_applicationRegistrar != aRegistrar) {
        [_applicationRegistrar release];
        _applicationRegistrar = [aRegistrar retain];
    }
}

#pragma mark - Trial serials

- (id)HSApplicationLicensor_trialSerial
{
    if (_trialSerial == nil)
        _trialSerial = [[NSString alloc] initWithCString:"HSDEM-OHS50-0TRIA-LTRIA-LTRI" encoding:NSUTF8StringEncoding];
    return _trialSerial;
}

- (id)HSApplicationLicensor_fisrtTrialExtensionSerial
{
    if (_fisrtTrialExtensionSerial == nil)
        _fisrtTrialExtensionSerial = [[NSString alloc] initWithCString:"PJKH8-4TBGB-M3V49-LRG9K-P2DA" encoding:NSUTF8StringEncoding];
    return _fisrtTrialExtensionSerial;
}

- (id)HSApplicationLicensor_secondTrialExtensionSerial
{
    if (_secondTrialExtensionSerial == nil)
        _secondTrialExtensionSerial = [[NSString alloc] initWithCString:"NJMH9-5UAGB-M3V49-LPF9K-P4CA" encoding:NSUTF8StringEncoding];
    return _secondTrialExtensionSerial;
}

- (id)HSApplicationLicensor_hiddenTrialExtensionSerial
{
    if (_hiddenTrialExtensionSerial == nil)
        _hiddenTrialExtensionSerial = [[NSString alloc] initWithCString:"PJKH9-D2DYM-M3U28-LQF6L-P4DA" encoding:NSUTF8StringEncoding];
    return _hiddenTrialExtensionSerial;
}

#pragma mark - Licensors

- (BOOL)initialiseHS50Licensor
{
    [self destroyLicensor];
    int status = [HSApplicationLicensorUtilities initializeLicensorWithBytes:sLicensorHS50SettingsData bytesSize:sizeof(sLicensorHS50SettingsData) bundleIdentifier:@"com.mackiev.hyperstudio" majorVersion:@"5.0" minorVersion:nil];
    if (status == 0)
        _isLicensorInitialized = YES;
    return status == 0;
}

- (BOOL)initialiseHSALicensor
{
    [self destroyLicensor];
    return [self loadHSALicense];
}

- (void)destroyLicensor
{
    if (_isLicensorInitialized) {
        SLLicensorDestroy();
        _isLicensorInitialized = NO;
    }
}

- (BOOL)loadHSALicense
{
    if (_isLicensorInitialized)
        return _licenseStatus == 0;
    int status = [HSApplicationLicensorUtilities initializeLicensorWithBytes:sLicensorSettingsData bytesSize:sizeof(sLicensorSettingsData) bundleIdentifier:[[NSBundle mainBundle] bundleIdentifier] majorVersion:@"1.0" minorVersion:nil];
    if (status != 0)
        return NO;
    _isLicensorInitialized = YES;
    _licenseStatus = [self loadLicenseForBundle:_applicationBundle licenseType:&_licenseType usageTimeFlags:&_licenseUsageTimeInfo];
    return _licenseStatus == 0;
}

- (BOOL)loadHS50License
{
    if (![self initialiseHS50Licensor])
        return NO;
    int type = 0, flags = 0;
    int status = [self loadLicenseForBundle:_applicationBundle licenseType:&type usageTimeFlags:&flags];
    if (status == 0 && (flags & 1) == 0) {
        _licenseStatus = 0;
        _licenseType = type;
        _licenseUsageTimeInfo = flags;
        return YES;
    }
    [self destroyLicensor];
    return NO;
}

- (BOOL)loadHS50LicenseWithHSALicenseLoaded:(BOOL)aLoaded
{
    if (!aLoaded || (_licenseUsageTimeInfo & 1) != 0) {
        if (![self loadHS50License]) {
            [self loadHSALicense];
            if ([self validateHS50MASReceipt]) {
                _licenseType = 1;
                _licenseUsageTimeInfo = 0;
                _licenseStatus = 0;
            }
        }
    }
    return _licenseStatus == 0;
}

- (int)loadLicenseForBundle:(id)aBundle licenseType:(int *)aType usageTimeFlags:(int *)aFlags
{
    int status = [HSApplicationLicensorUtilities loadLicenseForBundle:aBundle licenseType:aType usageTimeFlags:aFlags];
    if (status == 0)
        [self setRegistrationInfo:[HSApplicationLicensorUtilities registrationInfoForLicense:NULL]];
    return status;
}

- (int)makeHS50License:(struct SLLicense **)aLicense withSerial:(const char *)aSerial
{
    int status = 1;
    if ([self initialiseHS50Licensor])
        status = SLLicensorMakeLicenseForSerial(aSerial, (SLLicense **)aLicense);
    [self initialiseHSALicensor];
    return status;
}

- (int)makeHSALicense:(struct SLLicense **)aLicense withSerial:(const char *)aSerial
{
    return SLLicensorMakeLicenseForSerial(aSerial, (SLLicense **)aLicense);
}

- (int)makeLicense:(struct SLLicense **)aLicense withSerial:(const char *)aSerial
{
    int status = [self makeHSALicense:aLicense withSerial:aSerial];
    if (status != 0)
        status = [self makeHS50License:aLicense withSerial:aSerial];
    return status;
}

- (id)HSApplicationLicensor_HS50RegistrationIdentifier
{
    [self initialiseHS50Licensor];
    id identifier = [HSApplicationLicensorUtilities registrationIdentifier];
    [self initialiseHSALicensor];
    return identifier;
}

#pragma mark - Mac App Store receipts

- (BOOL)validateHS50MASReceipt
{
    NSString *path = [[NSUserDefaults standardUserDefaults] objectForKey:@"HS50MASBundlePath"];
    if ([self validateMASReceiptForBundleAtPath:path] == 0)
        return YES;
    NSArray *candidates = [NSArray arrayWithObjects:@"/Applications/HyperStudio.app", [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.mackiev.hyperstudio"], nil];
    for (NSString *candidate in candidates) {
        if ([self validateMASReceiptForBundleAtPath:candidate] == 0) {
            [[NSUserDefaults standardUserDefaults] setObject:candidate forKey:@"HS50MASBundlePath"];
            return YES;
        }
    }
    return NO;
}

// Answers 0 when the receipt of the bundle is valid for this computer.
- (BOOL)validateMASReceiptForBundleAtPath:(id)aPath
{
    NSBundle *bundle = [NSBundle bundleWithPath:aPath];
    if (bundle == nil)
        return YES;
    NSData *receipt = [NSData dataWithContentsOfURL:[bundle appStoreReceiptURL]];
    NSDictionary *attributes = receipt != nil ? HSApplicationLicensorCopyReceiptAttributes(receipt) : nil;
    if (![[attributes objectForKey:@"BundleIdentifier"] isEqualToString:@"com.mackiev.hyperstudio"])
        return YES;
    NSString *version = [[bundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (![[attributes objectForKey:@"Version"] isEqualToString:version])
        return YES;

    // The receipt hash is the SHA-1 of the computer identifier, the opaque value and the bundle identifier.
    NSMutableData *input = [NSMutableData data];
    NSData *address = nil;
    mach_port_t masterPort;
    io_iterator_t iterator;
    if (IOMasterPort(MACH_PORT_NULL, &masterPort) == KERN_SUCCESS) {
        CFMutableDictionaryRef matching = IOBSDNameMatching(masterPort, 0, "en0");
        if (matching != NULL && IOServiceGetMatchingServices(masterPort, matching, &iterator) == KERN_SUCCESS) {
            io_object_t interface;
            while ((interface = IOIteratorNext(iterator)) != 0) {
                io_object_t controller;
                if (IORegistryEntryGetParentEntry(interface, kIOServicePlane, &controller) == KERN_SUCCESS) {
                    if (address != nil)
                        CFRelease(address);
                    address = (NSData *)IORegistryEntryCreateCFProperty(controller, CFSTR(kIOMACAddress), kCFAllocatorDefault, 0);
                    IOObjectRelease(controller);
                }
                IOObjectRelease(interface);
            }
            IOObjectRelease(iterator);
            [address autorelease];
        }
    }
    [input appendData:address];
    [input appendData:[attributes objectForKey:@"OpaqueValue"]];
    [input appendData:[attributes objectForKey:@"BundleIdentifierData"]];
    NSMutableData *digest = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([input bytes], (CC_LONG)[input length], [digest mutableBytes]);
    return ![digest isEqualToData:[attributes objectForKey:@"Hash"]];
}

#pragma mark - Registration

- (void)addObservingForRegistrar:(id)aRegistrar
{
    if (aRegistrar != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSApplicationLicensor_networkRegistrarRefused:) name:HSNetworkRegistrarRefusedNotification object:aRegistrar];
}

- (void)removeObservingForRegistrar:(id)aRegistrar
{
    if (aRegistrar != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSNetworkRegistrarRefusedNotification object:aRegistrar];
}

- (void)registerApplicationOnNetworkForLicenseType:(int)aType
{
    NSString *identifier = [HSApplicationLicensorUtilities currentLicenseIdentifier];
    if (identifier == nil)
        return;
    [self removeObservingForRegistrar:[self applicationRegistrar]];
    [self setApplicationRegistrar:nil];
    HSNetworkRegistrar *registrar = [[[HSNetworkRegistrar alloc] initWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier] licenseType:aType] autorelease];
    if (registrar == nil)
        return;
    [self addObservingForRegistrar:registrar];
    if ([registrar registerWithIdentifier:identifier allowedCount:SLLicenseGetCodeLimit(NULL)] == 0) {
        for (NSString *oldIdentifier in [HSApplicationLicensorUtilities oldLicenseIdentifiers])
            [registrar registerBlockingIdentifier:oldIdentifier];
        [self setApplicationRegistrar:registrar];
    }
}

- (void)networkRegistrarRefused:(id)aRefused
{
    NSDictionary *info = [aRefused userInfo];
    int code = [[info objectForKey:HSNetworkRegistrarRefusedErrorCodeKey] intValue];
    if (code == 0)
        return;
    NSString *title = nil, *message;
    if (code == 3) {
        message = HSApplicationLicensorLocalized(@"The quota of users that can use the same registration number has been reached. Please contact with your system administrator");
    } else if (code == 2) {
        title = [[aRefused userInfo] objectForKey:HSNetworkRegistrarRefusedCutomErrorTitleKey];
        message = [[aRefused userInfo] objectForKey:HSNetworkRegistrarRefusedCutomErrorExplanationKey];
        if (message == nil)
            message = HSApplicationLicensorLocalized(@"The registration number you have entered has already been used to register another copy of the application. Please contact with your system administrator");
    } else {
        message = HSApplicationLicensorLocalized(@"Application network registration is denied");
    }
    if (message != nil) {
        if (title == nil)
            title = HSApplicationLicensorLocalized(@"HyperStudio will quit now");
        NSRunAlertPanel(title, @"%@", HSApplicationLicensorLocalized(@"Quit"), nil, nil, message);
        [NSApp terminate:self];
    }
}

// The observer is registered under the prefixed name, so the handler answers to it as well.
- (void)HSApplicationLicensor_networkRegistrarRefused:(id)aRefused
{
    [self networkRegistrarRefused:aRefused];
}

- (void)showExtensionAlertDialogForTheFirstPeriod:(BOOL)aFirst
{
    [[HSExtensionAlertController sharedInstance] runModalForMode:aFirst ? 0 : 1];
}

- (id)showRegistrationDialog
{
    NSString *settings = _licenseType == 3 ? HSRegistrationFormSettingsTrialReduced : HSRegistrationFormSettingsSerial;
    return [self showRegistrationDialogWithRegistrationType:HSRegistrationTypeOptional settingsType:settings registrationString:[self registrationInfo] isGoBack:NULL];
}

- (BOOL)showRegistrationDialogForLicenseType:(int)aType previousLicenseType:(int)aPreviousType
{
    NSString *type, *settings;
    if (aType == 3 || aPreviousType != 3) {
        if (![HSRegistrationUserDefaults isRegistrationPostponed]) {
            if ([HSRegistrationUserDefaults isRegistrationCompleted] || [HSRegistrationUserDefaults isRegistrationRefused] || aType == 3)
                return YES;
            type = (_licenseUsageTimeInfo & 4) != 0 ? HSRegistrationTypeForcedWithQuit : HSRegistrationTypeOptional;
            settings = HSRegistrationFormSettingsSerial;
        } else {
            settings = aType == 3 ? HSRegistrationFormSettingsTrialReduced : HSRegistrationFormSettingsSerial;
            type = HSRegistrationTypeOptional;
        }
    } else {
        settings = HSRegistrationFormSettingsSerial;
        type = HSRegistrationTypeForcedWithQuit;
    }
    if (type != nil && settings != nil) {
        BOOL goBack = NO;
        NSDictionary *userInfo = [self showRegistrationDialogWithRegistrationType:type settingsType:settings registrationString:[self registrationInfo] isGoBack:&goBack];
        if (goBack)
            return NO;
        if ([userInfo count] != 0)
            [[HSSubmitRequest sharedInstance] submitInformationDictionary:userInfo];
    }
    return YES;
}

- (id)showRegistrationDialogWithRegistrationType:(id)aType settingsType:(id)aSettings registrationString:(id)aString isGoBack:(BOOL *)aGoBack
{
    if (aString == nil)
        return nil;
    NSDictionary *result = [NSDictionary dictionary];
    HSRegistrationFormController *controller = [[HSRegistrationFormController alloc] initWithRegistrationType:aType settings:aSettings];
    NSInteger modalResult = [controller runModal];
    BOOL goBack = NO;
    if (modalResult == 1)
        goBack = YES;
    else if (modalResult == 0)
        result = [HSRegistrationFormController registrationInfoWithSerialNumber:aString settingsType:aSettings];
    [controller release];
    if (aGoBack != NULL)
        *aGoBack = goBack;
    return result;
}

#pragma mark - Validation

- (BOOL)validateApplicationLicenseWithInteraction:(BOOL)aInteraction forced:(BOOL)aForced
{
    BOOL valid = _licenseStatus == 0;
    if (!valid)
        valid = [self loadHSALicense];
    id registrationUserInfo = nil;
    if (!aForced)
        valid = [self loadHS50LicenseWithHSALicenseLoaded:valid];
    if (!aInteraction)
        return valid;
    int previousType = _licenseType;
    BOOL licenseChanged = NO;
    if (aForced || !valid)
        valid = [self runLicenseDialogsWithNewLicenseForced:aForced licenseChanged:&licenseChanged registrationUserInfo:&registrationUserInfo];
    if (!valid)
        return NO;
    if (!licenseChanged || [HSApplicationLicensorUtilities storeApplicationLicenseForBundle:_applicationBundle bundleMajorVersion:_bundleMajorVersion bundleMinorVersion:_bundleMinorVersion] == 0)
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HSActivationSucceced"];
    if (_licenseType == 2 || (_licenseType == 1 && (_licenseUsageTimeInfo & 8) != 0))
        [self registerApplicationOnNetworkForLicenseType:_licenseType];
    if (registrationUserInfo == nil)
        valid = [self showRegistrationDialogForLicenseType:_licenseType previousLicenseType:previousType];
    return valid;
}

- (NSInteger)validateSerialString:(id)aString controller:(id)aController
{
    struct SLLicense *license = NULL;
    NSInteger result = 1;
    id trial = [self HSApplicationLicensor_trialSerial];
    id first = [self HSApplicationLicensor_fisrtTrialExtensionSerial];
    id second = [self HSApplicationLicensor_secondTrialExtensionSerial];
    id hidden = [self HSApplicationLicensor_hiddenTrialExtensionSerial];
    if (trial != nil && first != nil && second != nil && hidden != nil) {
        BOOL isTrial = [aString isEqualToString:_trialSerial] || [aString isEqualToString:_fisrtTrialExtensionSerial] || [aString isEqualToString:_secondTrialExtensionSerial];
        int status = [self makeLicense:&license withSerial:[aString UTF8String]];
        if (status == 0) {
            if (license == NULL)
                return 1;
            if (isTrial) {
                result = 3;
            } else if (((_licenseStatus != 6 || _licenseType == 3) || (_licenseUsageTimeInfo & 2) != 0) && [aString isEqualToString:_hiddenTrialExtensionSerial]) {
                result = 3;
            } else {
                int flags = 0;
                NSInteger validation = [[LUUserDataValidation sharedInstance] validateLicenseUserData:license usageTimeFlags:&flags licenseType:NULL];
                if (validation != 6) {
                    result = 1;
                    if (validation == 0) {
                        HSSerialValidationContext *context = [[HSSerialValidationContext alloc] initWithSerialString:aString license:license usageTimeFlags:flags];
                        if (context != nil) {
                            [aController setValidationContext:context];
                            [context release];
                            return 0;
                        }
                    }
                } else {
                    result = 2;
                }
            }
        } else if (status == 7) {
            if (isTrial || [aString isEqualToString:_hiddenTrialExtensionSerial])
                result = 2;
        } else if (status == 10) {
            result = 2;
            if (_licenseStatus != 6 && !isTrial)
                result = [aString isEqualToString:_hiddenTrialExtensionSerial] ? 2 : 0;
        }
    }
    if (license != NULL)
        SLLicensorDestroyLicense((SLLicense *)license);
    return result;
}

#pragma mark - Dialogs

- (NSInteger)runLicenseDialogsWithNewLicenseForced:(BOOL)aForced licenseChanged:(BOOL *)aChanged registrationUserInfo:(id *)aInfo
{
    int reason = 4;
    if (!aForced) {
        reason = 0;
        if (_licenseStatus == 6) {
            reason = 1;
            if (_licenseType != 3)
                reason = ((_licenseUsageTimeInfo >> 1) & 1) ^ 3;
        }
    }
    HSApplicationLicenseDialogsContext *context = [[HSApplicationLicenseDialogsContext alloc] initWithLicensingReason:reason currentLicenseType:_licenseType];
    _licenseStatus = (int)[self runSerialNumberDialogWithContext:context];
    if ([context encryptedRegistrationNumber] != nil)
        [self setRegistrationInfo:[context encryptedRegistrationNumber]];
    BOOL accepted = YES;
    if (aForced)
        accepted = ![context isDialogCanceled];
    if (_licenseStatus == 0 && accepted) {
        _licenseStatus = (int)[[LUUserDataValidation sharedInstance] validateLicenseUserData:NULL usageTimeFlags:&_licenseUsageTimeInfo licenseType:&_licenseType];
        if (_licenseStatus == 6 && (reason | 4) != 4)
            _licenseStatus = 0;
    }
    if (aChanged != NULL)
        *aChanged = [context encryptedRegistrationNumber] != nil;
    if (aInfo != NULL)
        *aInfo = [[[context registrationUserInfo] retain] autorelease];
    [context release];
    return _licenseStatus == 0 && accepted;
}

- (NSInteger)runSerialNumberDialogWithContext:(id)aContext
{
    HSSerialNumberDialogController *controller = [aContext serialNumberDialogController];
    [controller setDelegate:self];
    NSInteger result = 1;
    while (![aContext isSerialNumberDialogCompleted]) {
        SEL action;
        switch ([controller runModal]) {
        case 0:
            action = @selector(didClickCancelInSerialNumberDialogWithContext:);
            break;
        case 1:
            action = @selector(didClickContinueInSerialNumberDialogWithContext:);
            break;
        case 2:
            action = @selector(didClickTrialInSerialNumberDialogWithContext:);
            break;
        case 3:
            action = @selector(didClickMoreTrialDaysInSerialNumberDialogWithContext:);
            break;
        default:
            continue;
        }
        result = (NSInteger)[self performSelector:action withObject:aContext];
    }
    return result;
}

- (NSInteger)runSubmitInformationDialogWithContext:(id)aContext registrationUserInfo:(id)aInfo registrationNumber:(id)aNumber
{
    if ([aInfo count] == 0)
        return 2;
    NSInteger result = 1;
    NSString *identifier = [self HSApplicationLicensor_HS50RegistrationIdentifier];
    if ([identifier length] != 0) {
        HSSubmitInformationDialogController *controller = [aContext submitInformationDialogController];
        NSInteger modalResult = [controller runModalWithInformationDictionary:aInfo applicationRegistrationIdentifier:identifier];
        if (modalResult == 3) {
            result = 0;
            if ([controller trialLicenseState] == 1) {
                [aContext setIsSerialNumberDialogCompleted:NO];
                if ([aContext licensingReason] != 0)
                    result = [self didClickMoreTrialDaysInSerialNumberDialogWithContext:aContext];
                else
                    result = [self didClickTrialInSerialNumberDialogWithContext:aContext];
            }
        } else if (modalResult == 1) {
            if ([aContext licensingReason] == 4)
                [aContext setIsDialogCanceled:YES];
        } else if (modalResult == 0) {
            result = [[[aContext serialNumberDialogController] validationContext] activateLicense];
            if (result == 0)
                [aContext setEncryptedRegistrationNumber:aNumber];
        }
    }
    return result;
}

- (NSInteger)didClickCancelInSerialNumberDialogWithContext:(id)aContext
{
    [aContext setIsSerialNumberDialogCompleted:YES];
    if ([aContext licensingReason] == 4)
        [aContext setIsDialogCanceled:YES];
    return 1;
}

- (NSInteger)didClickContinueInSerialNumberDialogWithContext:(id)aContext
{
    [aContext setIsSerialNumberDialogCompleted:YES];
    HSSerialValidationContext *validation = [[aContext serialNumberDialogController] validationContext];
    NSString *info = [HSApplicationLicensorUtilities registrationInfoForLicense:[validation license]];
    if (info == nil)
        return 1;
    NSInteger result;
    if (![[self HSApplicationLicensor_hiddenTrialExtensionSerial] isEqualToString:[validation serialString]]) {
        NSInteger flags = [validation usageTimeFlags];
        BOOL goBack = NO;
        NSString *type = (flags & 4) != 0 ? HSRegistrationTypeForcedWithGoBack : HSRegistrationTypeOptional;
        NSDictionary *userInfo = [self showRegistrationDialogWithRegistrationType:type settingsType:HSRegistrationFormSettingsSerial registrationString:info isGoBack:&goBack];
        [aContext setRegistrationUserInfo:userInfo];
        if ((flags & 4) != 0) {
            if (!goBack)
                return [self runSubmitInformationDialogWithContext:aContext registrationUserInfo:[aContext registrationUserInfo] registrationNumber:info];
            [aContext setIsSerialNumberDialogCompleted:NO];
            return 1;
        }
        if ([[aContext registrationUserInfo] count] != 0)
            [[HSSubmitRequest sharedInstance] submitInformationDictionary:[aContext registrationUserInfo]];
        result = [validation activateLicense];
    } else {
        NSRunAlertPanel(HSApplicationLicensorLocalized(@"The trial period has been extended"), @"%@", HSApplicationLicensorLocalized(@"OK"), nil, nil, HSApplicationLicensorLocalized(@"You now have an additional 10 days to try HyperStudio on a single computer. To continue using the product after the trial period is over, you will need to register it with a non-expiring license."));
        result = [validation activateLicense];
    }
    if (result == 0)
        [aContext setEncryptedRegistrationNumber:info];
    return result;
}

- (NSInteger)didClickTrialInSerialNumberDialogWithContext:(id)aContext
{
    [aContext setIsSerialNumberDialogCompleted:YES];
    NSString *trial = [aContext trialRegistrationNumber];
    if ([trial length] == 0)
        return 1;
    NSInteger result = 1;
    BOOL proceed = YES;
    if ([aContext trialLicense] == NULL) {
        struct SLLicense *license = NULL;
        result = [self makeLicense:&license withSerial:[trial UTF8String]];
        if (result != 0)
            proceed = NO;
        else
            [aContext setTrialLicense:license];
    }
    if (proceed) {
        NSString *info = [HSApplicationLicensorUtilities registrationInfoForLicense:[aContext trialLicense]];
        if (info == nil) {
            SLLicensorDestroyLicense((SLLicense *)[aContext trialLicense]);
            [aContext setTrialLicense:NULL];
            return 1;
        }
        BOOL goBack = NO;
        NSDictionary *userInfo = [self showRegistrationDialogWithRegistrationType:HSRegistrationTypeForcedWithGoBack settingsType:HSRegistrationFormSettingsTrialReduced registrationString:info isGoBack:&goBack];
        [aContext setRegistrationUserInfo:userInfo];
        [aContext setIsSerialNumberDialogCompleted:!goBack];
        if (!goBack) {
            if ([[aContext registrationUserInfo] count] != 0)
                [[HSSubmitRequest sharedInstance] submitInformationDictionary:[aContext registrationUserInfo]];
            result = SLLicensorSetLicense((SLLicense *)[aContext trialLicense]);
            if (result == 0) {
                [aContext setEncryptedRegistrationNumber:info];
                [aContext setTrialLicense:NULL];
            }
        }
    }
    if ([aContext trialLicense] != NULL) {
        SLLicensorDestroyLicense((SLLicense *)[aContext trialLicense]);
        [aContext setTrialLicense:NULL];
    }
    return result;
}

- (NSInteger)didClickMoreTrialDaysInSerialNumberDialogWithContext:(id)aContext
{
    [aContext setIsSerialNumberDialogCompleted:YES];
    int type = SLLicenseGetType(NULL);
    NSInteger result = 1;
    BOOL proceed = YES;
    if ([aContext trialLicense] == NULL) {
        const char *serial = type == 3 ? "PJKH8-4TBGB-M3V49-LRG9K-P2DA" : "NJMH9-5UAGB-M3V49-LPF9K-P4CA";
        struct SLLicense *license = NULL;
        result = [self makeLicense:&license withSerial:serial];
        if (result != 0)
            proceed = NO;
        else
            [aContext setTrialLicense:license];
    }
    if (proceed) {
        result = 1;
        NSString *info = [HSApplicationLicensorUtilities registrationInfoForLicense:[aContext trialLicense]];
        if (info != nil) {
            result = SLLicensorSetLicense((SLLicense *)[aContext trialLicense]);
            if (result == 0) {
                [aContext setEncryptedRegistrationNumber:info];
                [aContext setTrialLicense:NULL];
                [self showExtensionAlertDialogForTheFirstPeriod:type == 3];
            }
        }
    }
    if ([aContext trialLicense] != NULL) {
        SLLicensorDestroyLicense((SLLicense *)[aContext trialLicense]);
        [aContext setTrialLicense:NULL];
    }
    return result;
}

@end

#pragma mark - Receipts

// The receipt is a PKCS #7 signed message whose content is a set of attributes, each a sequence of a type, a
// version and an octet string. Only the structure is read here.
static BOOL HSApplicationLicensorReadASN1(const unsigned char **aCursor, const unsigned char *aEnd, int *aTag, long *aLength)
{
    const unsigned char *cursor = *aCursor;
    if (cursor >= aEnd)
        return NO;
    int tag = *cursor++ & 0x1f;
    if (cursor >= aEnd)
        return NO;
    long length = *cursor++;
    if (length & 0x80) {
        int count = (int)(length & 0x7f);
        if (count > 4 || cursor + count > aEnd)
            return NO;
        length = 0;
        while (count-- > 0)
            length = (length << 8) | *cursor++;
    }
    if (length < 0 || cursor + length > aEnd)
        return NO;
    *aCursor = cursor;
    *aTag = tag;
    *aLength = length;
    return YES;
}

static NSDictionary *HSApplicationLicensorCopyReceiptAttributes(NSData *aReceipt)
{
    CMSDecoderRef decoder = NULL;
    CFDataRef content = NULL;
    if (CMSDecoderCreate(&decoder) != errSecSuccess)
        return nil;
    NSDictionary *result = nil;
    if (CMSDecoderUpdateMessage(decoder, [aReceipt bytes], [aReceipt length]) == errSecSuccess && CMSDecoderFinalizeMessage(decoder) == errSecSuccess && CMSDecoderCopyContent(decoder, &content) == errSecSuccess && content != NULL) {
        const unsigned char *cursor = CFDataGetBytePtr(content);
        const unsigned char *end = cursor + CFDataGetLength(content);
        int tag;
        long length;
        if (HSApplicationLicensorReadASN1(&cursor, end, &tag, &length) && tag == 0x11) {
            const unsigned char *setEnd = cursor + length;
            NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
            while (cursor < setEnd) {
                if (!HSApplicationLicensorReadASN1(&cursor, setEnd, &tag, &length) || tag != 0x10)
                    break;
                const unsigned char *sequenceEnd = cursor + length;
                int type = 0;
                if (!HSApplicationLicensorReadASN1(&cursor, sequenceEnd, &tag, &length))
                    break;
                if (tag == 2 && length == 1)
                    type = *cursor;
                cursor += length;
                if (!HSApplicationLicensorReadASN1(&cursor, sequenceEnd, &tag, &length))
                    break;
                cursor += length;
                if (type >= 2 && type <= 5) {
                    if (!HSApplicationLicensorReadASN1(&cursor, sequenceEnd, &tag, &length))
                        break;
                    if (tag == 4) {
                        if (type == 2 || type == 4 || type == 5) {
                            NSString *key = type == 5 ? @"Hash" : (type == 4 ? @"OpaqueValue" : @"BundleIdentifierData");
                            [attributes setObject:[NSData dataWithBytes:cursor length:length] forKey:key];
                        }
                        if (type == 2 || type == 3) {
                            const unsigned char *inner = cursor;
                            int innerTag;
                            long innerLength;
                            if (HSApplicationLicensorReadASN1(&inner, cursor + length, &innerTag, &innerLength) && innerTag == 0xc) {
                                NSString *string = [[[NSString alloc] initWithBytes:inner length:innerLength encoding:NSUTF8StringEncoding] autorelease];
                                [attributes setObject:string forKey:type == 3 ? @"Version" : @"BundleIdentifier"];
                            }
                        }
                    }
                    cursor += length;
                }
                cursor = sequenceEnd;
            }
            result = attributes;
        }
    }
    if (content != NULL)
        CFRelease(content);
    CFRelease(decoder);
    return result;
}

@implementation HSSerialValidationContext

- (id)initWithSerialString:(id)aString license:(struct SLLicense *)aLicense usageTimeFlags:(NSInteger)aFlags
{
    self = [super init];
    if (self != nil) {
        _serialString = [aString copy];
        _license = aLicense;
        _usageTimeFlags = (int)aFlags;
    }
    return self;
}

- (void)dealloc
{
    if (_license != NULL)
        SLLicensorDestroyLicense((SLLicense *)_license);
    [_serialString release];
    [super dealloc];
}

- (id)serialString
{
    return _serialString;
}

- (struct SLLicense *)license
{
    return _license;
}

- (NSInteger)usageTimeFlags
{
    return _usageTimeFlags;
}

- (NSInteger)activateLicense
{
    if (_license == NULL)
        return 1;
    int status = SLLicensorSetLicense((SLLicense *)_license);
    if (status == 0)
        _license = NULL;
    return status;
}

@end
