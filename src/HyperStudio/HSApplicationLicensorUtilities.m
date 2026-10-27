#import "HSApplicationLicensorUtilities.h"
#import <Security/Security.h>
#import "HSMACAdressReader.h"
#import "SLLicensor.h"

static void HSApplicationLicensorUtilitiesRunAuthenticationAlert(id self)
{
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    NSString *title = [provider localizedStringForKey:@"Cannot launch HyperStudio" value:@"" table:@"Alerts"];
    NSString *message = [provider localizedStringForKey:@"You should authenticate with your administrator password to activate HyperStudio" value:@"" table:@"Alerts"];
    NSString *authenticate = [provider localizedStringForKey:@"Authenticate" value:@"" table:@"Alerts"];
    NSString *quit = [provider localizedStringForKey:@"Quit" value:@"" table:@"Alerts"];
    if (NSRunAlertPanel(title, @"%@", authenticate, quit, nil, message) != NSAlertDefaultReturn)
        [NSApp terminate:self];
}

@implementation HSApplicationLicensorUtilities

+ (int)initializeLicensorWithBytes:(const void *)aBytes bytesSize:(NSUInteger)aSize bundleIdentifier:(id)aIdentifier majorVersion:(id)aMajor minorVersion:(id)aMinor
{
    int status = SLLicensor55554InitializeWithBytesNoCopy(aBytes, (unsigned int)aSize, NULL, NULL);
    if (status != 0)
        return status;
    status = SLLicensorAttach("HS500", [aIdentifier UTF8String], [aMajor UTF8String], [aMinor UTF8String]);
    if (status != 0) {
        SLLicensorDestroy();
        return status;
    }
    return 0;
}

+ (id)trialSerialString
{
    if (SLLicensorIsTrialLicenseAvailable() != 0)
        return nil;
    unsigned int size = 0;
    if (SLLicensorGetTrialSerial(NULL, &size) != 0 || size == 0)
        return nil;
    char *buffer = malloc(size);
    if (buffer == NULL)
        return nil;
    NSString *result = nil;
    if (SLLicensorGetTrialSerial(buffer, &size) == 0)
        result = [NSString stringWithUTF8String:buffer];
    free(buffer);
    return result;
}

+ (id)currentLicenseIdentifier
{
    unsigned int size = 0;
    NSString *result = nil;
    if (SLLicenseGetIdentifier(NULL, NULL, &size) == 0 && size != 0) {
        char *buffer = malloc(size);
        if (buffer != NULL) {
            if (SLLicenseGetIdentifier(NULL, buffer, &size) == 0)
                result = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
            free(buffer);
        }
    }
    return result;
}

+ (id)oldLicenseIdentifiers
{
    unsigned int size = 0;
    NSMutableArray *result = nil;
    if (SLLicenseGetOldIdentifiers(NULL, NULL, &size) == 0 && size != 0) {
        unsigned int *buffer = malloc(size);
        if (buffer != NULL) {
            if (SLLicenseGetOldIdentifiers(NULL, buffer, &size) == 0) {
                // A count, then pointers to the identifier strings.
                size_t count = *(size_t *)buffer;
                char **strings = (char **)((size_t *)buffer + 1);
                result = [NSMutableArray array];
                for (size_t i = 0; i < count; i++) {
                    NSString *identifier = [NSString stringWithCString:strings[i] encoding:NSASCIIStringEncoding];
                    if (identifier != nil)
                        [result addObject:identifier];
                }
            }
            free(buffer);
        }
    }
    return result;
}

+ (id)registrationIdentifier
{
    NSData *address = HSMACAdressReaderGetPrimary();
    NSUInteger length = [address length];
    if (length == 0)
        return nil;
    unsigned int size = 0;
    if (SLLicensorGenerateIdentifierWithBytes(NULL, (unsigned char)length, NULL, &size) != 0)
        return nil;
    char *buffer = malloc(size);
    if (buffer == NULL)
        return nil;
    NSString *result = nil;
    if (SLLicensorGenerateIdentifierWithBytes([address bytes], (unsigned char)length, buffer, &size) == 0)
        result = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    free(buffer);
    return result;
}

+ (id)registrationInfoForLicense:(struct SLLicense *)aLicense
{
    unsigned int size = 0;
    NSString *result = nil;
    if (SLLicenseGetRegistrationString((const SLLicense *)aLicense, NULL, &size) == 0 && size != 0) {
        char *buffer = malloc(size);
        if (buffer != NULL) {
            if (SLLicenseGetRegistrationString((const SLLicense *)aLicense, buffer, &size) == 0)
                result = [NSString stringWithUTF8String:buffer];
            free(buffer);
        }
    }
    return result;
}

+ (int)loadLicenseForBundle:(id)aBundle licenseType:(int *)aType usageTimeFlags:(int *)aFlags
{
    int type = SLLicenseGetType(NULL);
    if (type == 0) {
        int status = SLLicensorLoadLicenseInfo([[aBundle bundlePath] fileSystemRepresentation]);
        if (status != 0)
            return status;
    }
    int result = (int)[[LUUserDataValidation sharedInstance] validateLicenseUserData:NULL usageTimeFlags:aFlags licenseType:&type];
    if ((result == 0 || result == 6) && aType != NULL)
        *aType = type;
    return result;
}

+ (id)authorizatonToolArgumentsForBundle:(id)aBundle bundleMajorVersion:(id)aMajor bundleMinorVersion:(id)aMinor
{
    NSMutableArray *arguments = [NSMutableArray array];
    const char *path = [[aBundle bundlePath] fileSystemRepresentation];
    if (path == NULL)
        return nil;
    [arguments addObject:[aBundle bundleIdentifier]];
    [arguments addObject:[NSString stringWithUTF8String:path]];
    if (aMajor != nil) {
        [arguments addObject:@"--short-version"];
        [arguments addObject:aMajor];
    }
    if (aMinor != nil) {
        [arguments addObject:@"--version"];
        [arguments addObject:aMinor];
    }
    return arguments;
}

+ (int)storeApplicationLicenseForBundle:(id)aBundle bundleMajorVersion:(id)aMajor bundleMinorVersion:(id)aMinor
{
    const char *bundlePath = [[aBundle bundlePath] fileSystemRepresentation];
    int status = SLLicensorSaveLicenseInfo(bundlePath);
    if (status != 9)
        return status;
    const char *tool = [[aBundle pathForAuxiliaryExecutable:@".authorizationTool"] fileSystemRepresentation];
    if (tool == NULL)
        return 9;
    HSApplicationLicensorUtilitiesRunAuthenticationAlert(self);
    unsigned int licenseSize = 0;
    status = SLLicensorGetLicenseInfo(NULL, NULL, &licenseSize);
    if (status != 0)
        return status;
    unsigned int environmentSize = 0;
    status = SLLicensorGetStorageEnvironment(NULL, &environmentSize);
    if (status != 0)
        return status;
    unsigned char *buffer = malloc(environmentSize + licenseSize);
    if (buffer == NULL)
        return 1;
    status = SLLicensorGetStorageEnvironment(buffer, &environmentSize);
    if (status == 0) {
        unsigned char *license = buffer + environmentSize;
        status = SLLicensorGetLicenseInfo(NULL, license, &licenseSize);
        if (status == 0) {
            int stored;
            while ((stored = [self storeWithAuthorizatonTool:tool licenseBytes:license licenseBytesSize:licenseSize environment:buffer environmentSize:environmentSize additionalParameters:[self authorizatonToolArgumentsForBundle:aBundle bundleMajorVersion:aMajor bundleMinorVersion:aMinor]]) == -1)
                HSApplicationLicensorUtilitiesRunAuthenticationAlert(self);
            (void)stored;
            status = 0;
        }
    }
    free(buffer);
    return status;
}

// The authorization tool reads the environment and the license as two tagged blocks and answers with a status.
+ (int)storeWithAuthorizatonTool:(const char *)aTool licenseBytes:(const void *)aBytes licenseBytesSize:(NSUInteger)aSize environment:(const void *)aEnvironment environmentSize:(NSUInteger)aEnvironmentSize additionalParameters:(id)aParameters
{
    int result = 1;
    if (aBytes == NULL || aEnvironment == NULL || aEnvironmentSize == 0 || aParameters == nil)
        return result;
    AuthorizationRef authorization = NULL;
    if (AuthorizationCreate(NULL, NULL, kAuthorizationFlagDefaults, &authorization) != errAuthorizationSuccess)
        return result;
    AuthorizationItem item = { kAuthorizationRightExecute, 0, NULL, 0 };
    AuthorizationRights rights = { 1, &item };
    OSStatus status = AuthorizationCopyRights(authorization, &rights, NULL, kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights | kAuthorizationFlagPreAuthorize, NULL);
    if (status == errAuthorizationSuccess) {
        const char *arguments[8] = { NULL };
        NSUInteger count = [aParameters count];
        for (NSUInteger i = 0; i < count && i < 7; i++) {
            id parameter = [aParameters objectAtIndex:i];
            if ([parameter isKindOfClass:[NSString class]])
                arguments[i] = [parameter UTF8String];
        }
        FILE *pipe = NULL;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        status = AuthorizationExecuteWithPrivileges(authorization, aTool, kAuthorizationFlagDefaults, (char *const *)arguments, &pipe);
#pragma clang diagnostic pop
        if (status == errAuthorizationSuccess && pipe != NULL) {
            uint32_t header[2] = { 'ehas', (uint32_t)aEnvironmentSize };
            if (fwrite(header, 1, 8, pipe) == 8 && fwrite(aEnvironment, 1, aEnvironmentSize, pipe) == aEnvironmentSize) {
                header[0] = 'lils';
                header[1] = (uint32_t)aSize;
                if (fwrite(header, 1, 8, pipe) == 8 && fwrite(aBytes, 1, aSize, pipe) == aSize) {
                    int32_t answer = 1;
                    if (fread(&answer, 1, 4, pipe) == 4)
                        result = answer;
                    else
                        result = 0;
                }
            }
        }
    } else if (status == errAuthorizationCanceled) {
        result = -1;
    }
    AuthorizationFree(authorization, kAuthorizationFlagDestroyRights);
    return result;
}

@end
