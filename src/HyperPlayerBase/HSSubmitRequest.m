#import "HSSubmitRequest.h"

// Sends reports and registration data through the private SMKSubmitInfo
// framework, whose entry points are looked up by name on first use.

typedef void (*HSSubmitRequestRunLoopFunction)(CFRunLoopRef, CFStringRef);
typedef BOOL (*HSSubmitRequestSetClientCallbackFunction)(id, void *);
typedef BOOL (*HSSubmitRequestStoreUnsentRequestsFunction)(id);
typedef void (*HSSubmitRequestSetRequestsQueueLimitFunction)(NSUInteger);
typedef int (*HSSubmitRequestSubmitFunction)(id, id, id, id, NSUInteger);
typedef BOOL (*HSSubmitRequestSizeAcceptableFunction)(id, id);
typedef CFDictionaryRef (*HSSubmitRequestCreateUserInformationFunction)(void);

static HSSubmitRequest *sSharedSubmitRequest;
static HSSubmitRequestCreateUserInformationFunction sCreateUserInformation;
static HSSubmitRequestSizeAcceptableFunction sIsSubmitInformationSizeAcceptable;
static HSSubmitRequestSubmitFunction sSubmitInformationLast;
static HSSubmitRequestSetRequestsQueueLimitFunction sSetRequestsQueueLimit;
static HSSubmitRequestStoreUnsentRequestsFunction sStoreUnsentRequests;
static HSSubmitRequestSetClientCallbackFunction sSetClientCallback;
static HSSubmitRequestRunLoopFunction sScheduleWithRunLoop;
static HSSubmitRequestRunLoopFunction sUnscheduleFromRunLoop;

// Client callback the framework calls when a submission finishes.
static void HSSubmitRequest_didEndCallback(id aClient, id aUID, NSInteger aResult)
{
    if (aClient)
        [aClient informationSubmissionDidEndWithResult:aResult informationUID:aUID];
}

@implementation HSSubmitRequest
+ (id)sharedInstance
{
    if (sSharedSubmitRequest == nil)
        sSharedSubmitRequest = [[HSSubmitRequest alloc] initWithSubmitInfoSettings:[[NSBundle mainBundle] pathForResource:@"SubmitInfo" ofType:@""]];
    return sSharedSubmitRequest;
}
- (void)informationSubmissionDidEndWithResult:(NSInteger)aResult informationUID:(id)aUID
{
    NSInteger result = aResult;
    NSInvocation *invocation = [mUIDStringToDidSubmitInvocationDictionary objectForKey:aUID];
    if (invocation == nil)
        return;
    [invocation setArgument:&result atIndex:2];
    [invocation invoke];
    [mUIDStringToDidSubmitInvocationDictionary removeObjectForKey:aUID];
    if ([mUIDStringToDidSubmitInvocationDictionary count] == 0) {
        [self unscheduleWithRunLoop:CFRunLoopGetCurrent() inMode:(struct __CFString *)kCFRunLoopCommonModes];
        [self setClientCallback:NULL];
    }
}
- (void)removeSubmitInformationStatusDelegate:(id)aDelegate
{
    if ([mUIDStringToDidSubmitInvocationDictionary count] == 0)
        return;
    if (aDelegate == nil) {
        [mUIDStringToDidSubmitInvocationDictionary removeAllObjects];
    } else {
        NSMutableArray *keys = [NSMutableArray array];
        for (id key in mUIDStringToDidSubmitInvocationDictionary) {
            if ([(NSInvocation *)[mUIDStringToDidSubmitInvocationDictionary objectForKey:key] target] == aDelegate)
                [keys addObject:key];
        }
        if ([keys count])
            [mUIDStringToDidSubmitInvocationDictionary removeObjectsForKeys:keys];
    }
    if ([mUIDStringToDidSubmitInvocationDictionary count] == 0) {
        [self unscheduleWithRunLoop:CFRunLoopGetCurrent() inMode:(struct __CFString *)kCFRunLoopCommonModes];
        [self setClientCallback:NULL];
    }
}
- (BOOL)submitInformationDictionary:(id)aDictionary delegate:(id)aDelegate didEndSelector:(SEL)aSelector
{
    if ([aDictionary count] == 0 || mOnlineActivationEncodingData == nil)
        return NO;
    id dictionary = aDictionary;
    if (aDelegate && aSelector) {
        NSMethodSignature *signature = [aDelegate methodSignatureForSelector:aSelector];
        if (signature == nil)
            return NO;
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:aDelegate];
        [invocation setSelector:aSelector];
        if (invocation == nil)
            return NO;
        if ([mUIDStringToDidSubmitInvocationDictionary count] == 0) {
            if (![self setClientCallback:(void *)HSSubmitRequest_didEndCallback])
                return NO;
            [self scheduleWithRunLoop:CFRunLoopGetCurrent() inMode:(struct __CFString *)kCFRunLoopCommonModes];
        }
        dictionary = [[aDictionary mutableCopy] autorelease];
        NSString *UIDString = [NSString hyperUIDString];
        [dictionary setObject:UIDString forKey:@"InfoUID"];
        [[self uidStringToDidSubmitInvocationDictionary] setObject:invocation forKey:UIDString];
    }
    return [self submitInformationDictionary:dictionary encodingData:mOnlineActivationEncodingData];
}
- (id)uidStringToDidSubmitInvocationDictionary
{
    if (mUIDStringToDidSubmitInvocationDictionary == nil)
        mUIDStringToDidSubmitInvocationDictionary = [NSMutableDictionary new];
    return mUIDStringToDidSubmitInvocationDictionary;
}
- (BOOL)submitInformationDictionary:(id)aDictionary encodingData:(id)aData
{
    if (aDictionary && [aDictionary count] == 0)
        return NO;
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *version = [[NSBundle mainBundle] HS_buildVersion];
    return [self submitInformation:aDictionary encodingData:aData applicationVersion:version applicationIdentifier:identifier overflowFlags:2];
}
// Wraps a report in the user information (name, email, ...) and sends it.
- (BOOL)submitInformation:(id)aInformation baseEmail:(id)aEmail
{
    if (mReportEncodingData == nil || mReportVersion == nil)
        return NO;
    if ([self loadSubmitInfoBundle:YES] == NULL)
        return NO;
    NSMutableDictionary *information = nil;
    NSString *buildVersion = nil;
    if (aInformation) {
        CFDictionaryRef userInformation = [self createUserInformation];
        if (userInformation == NULL)
            return NO;
        information = [(NSDictionary *)userInformation mutableCopy];
        NSString *email = aEmail;
        if (information == nil || [information count] == 0
            || (email == nil && (email = [information objectForKey:@"email"]) == nil)) {
            CFRelease(userInformation);
            [information release];
            return NO;
        }
        NSString *uniqueEmail = [self uniqueEmailAddressFromBase:email];
        if (uniqueEmail)
            [information setObject:uniqueEmail forKey:@"email"];
        NSBundle *mainBundle = [NSBundle mainBundle];
        buildVersion = [mainBundle HS_buildVersion];
        [information setObject:aInformation forKey:@"report"];
        [information setObject:buildVersion forKey:@"build number"];
        [information setObject:mReportVersion forKey:@"report version"];
        [information setObject:[[NSCalendarDate calendarDate] description] forKey:@"date"];
        id shortVersion = [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        if (shortVersion)
            [information setObject:shortVersion forKey:(NSString *)kCFBundleVersionKey];
        CFRelease(userInformation);
    }
    BOOL result = [self submitInformation:information encodingData:mReportEncodingData applicationVersion:buildVersion
                    applicationIdentifier:[[NSBundle mainBundle] bundleIdentifier] overflowFlags:2];
    [information release];
    return result;
}
// Prefixes the address with a per-installation UUID kept in the defaults.
- (id)uniqueEmailAddressFromBase:(id)aBase
{
    if (mEmailPrefix == nil) {
        id storedPrefix = [[NSUserDefaults standardUserDefaults] stringForKey:@"HSSubmitRequestPrefix"];
        CFUUIDRef UUID = NULL;
        if (storedPrefix && [storedPrefix isKindOfClass:[NSString class]])
            UUID = CFUUIDCreateFromString(NULL, (CFStringRef)storedPrefix);
        if (UUID == NULL)
            UUID = CFUUIDCreate(NULL);
        if (UUID) {
            mEmailPrefix = (NSString *)CFUUIDCreateString(NULL, UUID);
            CFRelease(UUID);
            if (mEmailPrefix)
                [[NSUserDefaults standardUserDefaults] setObject:mEmailPrefix forKey:@"HSSubmitRequestPrefix"];
        }
    }
    if (mEmailPrefix == nil)
        return nil;
    return [NSString stringWithFormat:@"%@.%@", mEmailPrefix, aBase];
}
- (struct __CFBundle *)loadSubmitInfoBundle:(BOOL)aBundle
{
    if (mFrameworkBundle || !aBundle)
        return mFrameworkBundle;
    NSString *frameworksPath = [[NSBundle mainBundle] privateFrameworksPath];
    if (frameworksPath == nil)
        return NULL;
    NSString *path = [frameworksPath stringByAppendingPathComponent:@"SMKSubmitInfo.framework"];
    CFURLRef URL = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)path, kCFURLPOSIXPathStyle, true);
    if (URL == NULL)
        return NULL;
    mFrameworkBundle = CFBundleCreate(NULL, URL);
    if (mFrameworkBundle && !CFBundleLoadExecutable(mFrameworkBundle)) {
        CFRelease(mFrameworkBundle);
        mFrameworkBundle = NULL;
    }
    CFRelease(URL);
    return mFrameworkBundle;
}
- (void)unscheduleWithRunLoop:(struct __CFRunLoop *)aLoop inMode:(struct __CFString *)aMode
{
    CFBundleRef bundle;
    if (sUnscheduleFromRunLoop == NULL && (bundle = [self loadSubmitInfoBundle:NO]) != NULL)
        sUnscheduleFromRunLoop = (HSSubmitRequestRunLoopFunction)CFBundleGetFunctionPointerForName(bundle, CFSTR("SIUnscheduleFromRunLoop"));
    if (sUnscheduleFromRunLoop)
        sUnscheduleFromRunLoop(aLoop, aMode);
}
- (void)scheduleWithRunLoop:(struct __CFRunLoop *)aLoop inMode:(struct __CFString *)aMode
{
    CFBundleRef bundle;
    if (sScheduleWithRunLoop == NULL && (bundle = [self loadSubmitInfoBundle:YES]) != NULL)
        sScheduleWithRunLoop = (HSSubmitRequestRunLoopFunction)CFBundleGetFunctionPointerForName(bundle, CFSTR("SIScheduleWithRunLoop"));
    if (sScheduleWithRunLoop)
        sScheduleWithRunLoop(aLoop, aMode);
}
- (BOOL)setClientCallback:(void *)aCallback
{
    CFBundleRef bundle;
    if (sSetClientCallback == NULL && (bundle = [self loadSubmitInfoBundle:YES]) != NULL)
        sSetClientCallback = (HSSubmitRequestSetClientCallbackFunction)CFBundleGetFunctionPointerForName(bundle, CFSTR("SISetClientCallback"));
    return sSetClientCallback ? sSetClientCallback(self, aCallback) : NO;
}
- (BOOL)storeUnsentRequests:(id)aRequests
{
    BOOL result = NO;
    if (sStoreUnsentRequests == NULL) {
        CFBundleRef bundle = [self loadSubmitInfoBundle:NO];
        if (bundle)
            sStoreUnsentRequests = (HSSubmitRequestStoreUnsentRequestsFunction)CFBundleGetFunctionPointerForName(bundle, CFSTR("SIStoreUnsentRequests"));
        else
            result = YES; // Nothing loaded means nothing is pending.
    }
    if (sStoreUnsentRequests)
        result = sStoreUnsentRequests(aRequests);
    return result;
}
- (void)setRequestsQueueLimit:(NSUInteger)aLimit
{
    CFBundleRef bundle;
    if (sSetRequestsQueueLimit == NULL && (bundle = [self loadSubmitInfoBundle:YES]) != NULL)
        sSetRequestsQueueLimit = (HSSubmitRequestSetRequestsQueueLimitFunction)CFBundleGetFunctionPointerForName(bundle, CFSTR("SISetRequestsQueueLimit"));
    if (sSetRequestsQueueLimit)
        sSetRequestsQueueLimit(aLimit);
}
- (BOOL)submitInformation:(id)aInformation encodingData:(id)aData applicationVersion:(id)aVersion applicationIdentifier:(id)aIdentifier overflowFlags:(NSUInteger)aFlags
{
    CFBundleRef bundle;
    if (sSubmitInformationLast == NULL && (bundle = [self loadSubmitInfoBundle:YES]) != NULL)
        sSubmitInformationLast = (HSSubmitRequestSubmitFunction)CFBundleGetFunctionPointerForName(bundle, CFSTR("SISubmitInformationLast"));
    if (sSubmitInformationLast == NULL)
        return NO;
    return sSubmitInformationLast(aInformation, aData, aVersion, aIdentifier, aFlags) == 0;
}
- (BOOL)isSubmitInformationSizeAcceptable:(id)aAcceptable encodingData:(id)aData
{
    CFBundleRef bundle;
    if (sIsSubmitInformationSizeAcceptable == NULL && (bundle = [self loadSubmitInfoBundle:YES]) != NULL)
        sIsSubmitInformationSizeAcceptable = (HSSubmitRequestSizeAcceptableFunction)CFBundleGetFunctionPointerForName(bundle, CFSTR("SIIsSubmitInformationSizeAcceptable"));
    return sIsSubmitInformationSizeAcceptable ? sIsSubmitInformationSizeAcceptable(aAcceptable, aData) : NO;
}
- (struct __CFDictionary *)createUserInformation
{
    CFBundleRef bundle;
    if (sCreateUserInformation == NULL && (bundle = [self loadSubmitInfoBundle:YES]) != NULL)
        sCreateUserInformation = (HSSubmitRequestCreateUserInformationFunction)CFBundleGetFunctionPointerForName(bundle, CFSTR("SICreateUserInformation"));
    return sCreateUserInformation ? (struct __CFDictionary *)sCreateUserInformation() : NULL;
}
- (void)HSSubmitRequest_createStorageFolder
{
    NSString *path = mStorageFolderPath;
    if ([path length]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path])
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}
- (BOOL)submitInformationDictionary:(id)aDictionary
{
    if (mRegistrationEncodingData == nil)
        return NO;
    if (aDictionary)
        [self HSSubmitRequest_createStorageFolder];
    return [self submitInformationDictionary:aDictionary encodingData:mRegistrationEncodingData];
}
- (BOOL)submitInformation:(id)aInformation
{
    if (aInformation)
        [self HSSubmitRequest_createStorageFolder];
    return [self submitInformation:aInformation baseEmail:@"hs5autoreport@postman.mackiev.com"];
}
- (BOOL)storeUnsentRequests
{
    [self HSSubmitRequest_createStorageFolder];
    return [self storeUnsentRequests:nil];
}
- (id)registrationEncodingData
{
    return mRegistrationEncodingData;
}
- (void)dealloc
{
    [mReportEncodingData release];
    [mRegistrationEncodingData release];
    [mOnlineActivationEncodingData release];
    [mReportVersion release];
    [mEmailPrefix release];
    if (mFrameworkBundle)
        CFRelease(mFrameworkBundle);
    [mUIDStringToDidSubmitInvocationDictionary release];
    [mStorageFolderPath release];
    [super dealloc];
}
static NSData *HSSubmitRequest_nonEmptyData(id aObject)
{
    return ([aObject isKindOfClass:[NSData class]] && [aObject length]) ? [aObject retain] : nil;
}
- (id)initWithSubmitInfoSettings:(id)aSettings
{
    self = [super init];
    if (self == nil || aSettings == nil) {
        [self release];
        return nil;
    }
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:aSettings];
    if ([settings count] == 0) {
        [self release];
        return nil;
    }
    mReportEncodingData = HSSubmitRequest_nonEmptyData([settings objectForKey:@"encode"]);
    mOnlineActivationEncodingData = HSSubmitRequest_nonEmptyData([settings objectForKey:@"oaencode"]);
    mRegistrationEncodingData = HSSubmitRequest_nonEmptyData([settings objectForKey:@"uencode"]);
    mReportVersion = [[NSString alloc] initWithFormat:@"%@", [settings objectForKey:@"ReportVersion"]];
    const char path[] = "~/Library/Application Support/Software MacKiev/HyperStudio";
    mStorageFolderPath = [[[[NSFileManager defaultManager] stringWithFileSystemRepresentation:path length:sizeof(path) - 1] stringByExpandingTildeInPath] retain];
    return self;
}
@end
