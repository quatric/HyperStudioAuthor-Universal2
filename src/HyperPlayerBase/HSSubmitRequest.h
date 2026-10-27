#import "HyperPlayerBasePrefix.h"


@interface HSSubmitRequest : NSObject
{
    NSData *mReportEncodingData;
    NSData *mRegistrationEncodingData;
    NSData *mOnlineActivationEncodingData;
    NSString *mReportVersion;
    NSString *mEmailPrefix;
    struct __CFBundle *mFrameworkBundle;
    NSMutableDictionary *mUIDStringToDidSubmitInvocationDictionary;
    NSString *mStorageFolderPath;
}
+ (id)sharedInstance;
- (void)informationSubmissionDidEndWithResult:(NSInteger)aResult informationUID:(id)aUID;
- (void)removeSubmitInformationStatusDelegate:(id)aDelegate;
- (BOOL)submitInformationDictionary:(id)aDictionary delegate:(id)aDelegate didEndSelector:(SEL)aSelector;
- (id)uidStringToDidSubmitInvocationDictionary;
- (BOOL)submitInformationDictionary:(id)aDictionary encodingData:(id)aData;
- (BOOL)submitInformation:(id)aInformation baseEmail:(id)aEmail;
- (id)uniqueEmailAddressFromBase:(id)aBase;
- (struct __CFBundle *)loadSubmitInfoBundle:(BOOL)aBundle;
- (void)unscheduleWithRunLoop:(struct __CFRunLoop *)aLoop inMode:(struct __CFString *)aMode;
- (void)scheduleWithRunLoop:(struct __CFRunLoop *)aLoop inMode:(struct __CFString *)aMode;
- (BOOL)setClientCallback:(void *)aCallback;
- (BOOL)storeUnsentRequests:(id)aRequests;
- (void)setRequestsQueueLimit:(NSUInteger)aLimit;
- (BOOL)submitInformation:(id)aInformation encodingData:(id)aData applicationVersion:(id)aVersion applicationIdentifier:(id)aIdentifier overflowFlags:(NSUInteger)aFlags;
- (BOOL)isSubmitInformationSizeAcceptable:(id)aAcceptable encodingData:(id)aData;
- (struct __CFDictionary *)createUserInformation;
- (BOOL)submitInformationDictionary:(id)aDictionary;
- (BOOL)submitInformation:(id)aInformation;
- (BOOL)storeUnsentRequests;
- (id)registrationEncodingData;
- (void)dealloc;
- (id)initWithSubmitInfoSettings:(id)aSettings;
@end

