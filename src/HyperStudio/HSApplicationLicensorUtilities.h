#import "HyperStudioPrefix.h"


@interface HSApplicationLicensorUtilities : NSObject
{
}
+ (int)initializeLicensorWithBytes:(const void *)aBytes bytesSize:(NSUInteger)aSize bundleIdentifier:(id)aIdentifier majorVersion:(id)aMajor minorVersion:(id)aMinor;
+ (id)trialSerialString;
+ (id)currentLicenseIdentifier;
+ (id)oldLicenseIdentifiers;
+ (id)registrationIdentifier;
+ (id)registrationInfoForLicense:(struct SLLicense *)aLicense;
+ (int)loadLicenseForBundle:(id)aBundle licenseType:(int *)aType usageTimeFlags:(int *)aFlags;
+ (id)authorizatonToolArgumentsForBundle:(id)aBundle bundleMajorVersion:(id)aMajor bundleMinorVersion:(id)aMinor;
+ (int)storeApplicationLicenseForBundle:(id)aBundle bundleMajorVersion:(id)aMajor bundleMinorVersion:(id)aMinor;
+ (int)storeWithAuthorizatonTool:(const char *)aTool licenseBytes:(const void *)aBytes licenseBytesSize:(NSUInteger)aSize environment:(const void *)aEnvironment environmentSize:(NSUInteger)aEnvironmentSize additionalParameters:(id)aParameters;
@end
