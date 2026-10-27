#import "HyperStudioPrefix.h"


@interface LUUserDataValidation : NSObject
{
    NSString *_dateStoragePath;
    NSDictionary *_dateStoragePermissions;
    double _lastSessionDate;
}
+ (id)sharedInstance;
- (void)updateApplicationSessionInfo;
- (id)licenseDescription:(struct SLLicense *)aDescription;
- (NSInteger)validateLicenseUserData:(struct SLLicense *)aData usageTimeFlags:(int *)aFlags licenseType:(int *)aType;
- (NSInteger)license:(struct SLLicense *)aLicense expirationTime:(double *)aTime creationTime:(double *)aTime2 usageTimeFlags:(int *)aFlags type:(int *)aType;
- (NSInteger)LUUserDataValidation_validateUserBytes:(void *)aBytes bytesSize:(NSUInteger)aSize licenseCreationTime:(double)aTime expirationTime:(double *)aTime2 usageTimeFlags:(int *)aFlags;
- (void)saveCurrentApplicationSessionDateForKey:(double)aKey;
- (BOOL)loadLastApplicationSessionDateForKey:(double)aKey;
- (id)LUUserDataValidation_initWithDateStoragePath:(id)aPath;
- (id)init;
- (void)dealloc;
@end

