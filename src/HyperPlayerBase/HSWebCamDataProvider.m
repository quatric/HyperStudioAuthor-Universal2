#import "HSWebCamDataProvider.h"

// Error returned when the service cannot be reached.
#define HSWebCamDataProviderServiceUnavailableError 0x900d3

static HSWebCamDataProvider *HSSharedWebCamDataProvider = nil;

@implementation HSWebCamDataProvider

+ (CGFloat)safariApplicationVersion
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.Safari"]];
    if (bundle == nil)
        return 0.0;
    return [[[bundle infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
}

+ (id)sharedWebCamDataProvider
{
    if (HSSharedWebCamDataProvider == nil)
        [[self class] new];
    return HSSharedWebCamDataProvider;
}

- (void)terminateUpdate:(id)aUpdate
{
    @try {
        [[self proxyToService] terminateUpdate:aUpdate];
    } @catch (NSException *exception) {
    }
}

- (void)update:(id)aUpdate
{
    @try {
        [[self proxyToService] update:aUpdate];
    } @catch (NSException *exception) {
    }
}

- (void)terminateUpdatesChecking:(id)aChecking
{
    @try {
        [[self proxyToService] terminateUpdatesChecking:aChecking];
    } @catch (NSException *exception) {
    }
}

- (void)checkForUpdates:(id)aUpdates
{
    @try {
        [[self proxyToService] checkForUpdates:aUpdates];
    } @catch (NSException *exception) {
    }
}

- (id)databaseVersionError:(id *)aError
{
    id version = nil;
    NSError *error = nil;
    id proxy = nil;
    @try {
        proxy = [self proxyToService];
        version = [proxy databaseVersionError:&error];
    } @catch (NSException *exception) {
    }
    if (proxy == nil)
        error = [NSError errorWithDomain:@"WebCamDataProviderErrorDomain" code:HSWebCamDataProviderServiceUnavailableError userInfo:nil];
    if (error != nil) {
        if (aError != NULL)
            *aError = error;
        version = nil;
    }
    return version;
}

- (void)validateClipForWebCam:(id)aCam
{
    @try {
        [[self proxyToService] validateClipRectForWebCam:aCam application:_appIDStr];
    } @catch (NSException *exception) {
    }
}

- (void)webCamsForFilterPredicate:(id)aPredicate sortDescriptors:(id)aDescriptors category:(id)aCategory error:(id *)aError
{
    NSError *error = nil;
    id proxy = nil;
    @try {
        proxy = [self proxyToService];
        [proxy webCamsForFilterPredicate:aPredicate sortDescriptors:aDescriptors category:aCategory application:_appIDStr];
    } @catch (NSException *exception) {
    }
    if (proxy == nil)
        error = [NSError errorWithDomain:@"WebCamDataProviderErrorDomain" code:HSWebCamDataProviderServiceUnavailableError userInfo:nil];
    if (error != nil && aError != NULL)
        *aError = error;
}

- (id)attributes:(id)aAttributes forWebCam:(id)aCam error:(id *)aError
{
    id result = nil;
    NSError *error = nil;
    if ([aAttributes count] != 0) {
        id proxy = nil;
        @try {
            proxy = [self proxyToService];
            result = [proxy webCam:aCam attributes:aAttributes application:_appIDStr error:&error];
        } @catch (NSException *exception) {
        }
        if (proxy == nil)
            error = [NSError errorWithDomain:@"WebCamDataProviderErrorDomain" code:HSWebCamDataProviderServiceUnavailableError userInfo:nil];
    }
    if (error != nil) {
        if (aError != NULL)
            *aError = error;
        result = nil;
    }
    return result;
}

- (id)attributes:(id)aAttributes forCategory:(id)aCategory error:(id *)aError
{
    id result = nil;
    NSError *error = nil;
    if ([aAttributes count] != 0) {
        id proxy = nil;
        @try {
            proxy = [self proxyToService];
            result = [proxy category:aCategory attributes:aAttributes application:_appIDStr error:&error];
        } @catch (NSException *exception) {
        }
        if (proxy == nil)
            error = [NSError errorWithDomain:@"WebCamDataProviderErrorDomain" code:HSWebCamDataProviderServiceUnavailableError userInfo:nil];
    }
    if (error != nil) {
        if (aError != NULL)
            *aError = error;
        result = nil;
    }
    return result;
}

- (id)childrenOfWebCamCategory:(id)aCategory error:(id *)aError
{
    id children = nil;
    NSError *error = nil;
    id proxy = nil;
    @try {
        proxy = [self proxyToService];
        children = [proxy childrenOfCategory:aCategory application:_appIDStr error:&error];
    } @catch (NSException *exception) {
    }
    if (proxy == nil)
        error = [NSError errorWithDomain:@"WebCamDataProviderErrorDomain" code:HSWebCamDataProviderServiceUnavailableError userInfo:nil];
    if (error != nil) {
        if (aError != NULL)
            *aError = error;
        children = nil;
    }
    return children;
}

- (BOOL)isWebCamCategoryExpandable:(id)aExpandable error:(id *)aError
{
    BOOL expandable = NO;
    NSError *error = nil;
    id proxy = nil;
    @try {
        proxy = [self proxyToService];
        expandable = [proxy isCategoryExpandable:aExpandable application:_appIDStr error:&error];
    } @catch (NSException *exception) {
    }
    if (proxy == nil)
        error = [NSError errorWithDomain:@"WebCamDataProviderErrorDomain" code:HSWebCamDataProviderServiceUnavailableError userInfo:nil];
    if (error != nil) {
        if (aError != NULL)
            *aError = error;
        expandable = NO;
    }
    return expandable;
}

- (id)proxyToService
{
    id proxy = [[self connectionToService] rootProxy];
    @try {
        if (proxy == nil) {
            // Launch the service and give it up to 10 s to register its connection.
            NSTask *task = [NSTask launchedTaskWithLaunchPath:[self serviceApplicationBundlePath] arguments:[NSArray array]];
            if (task != nil) {
                NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:10.0];
                while (proxy == nil && [task isRunning]) {
                    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0.5];
                    [[NSRunLoop currentRunLoop] runUntilDate:date];
                    proxy = [[self connectionToService] rootProxy];
                    if ([date compare:deadline] == NSOrderedDescending)
                        break;
                }
                if (proxy == nil && [task isRunning])
                    [task terminate];
            }
        }
    } @catch (NSException *exception) {
        proxy = nil;
    }
    return proxy;
}

- (id)serviceApplicationBundlePath
{
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Services/WebCamDataProvider.service/Contents/MacOS/WebCamDataProvider"];
}

- (id)connectionToService
{
    NSConnection *connection = [NSConnection connectionWithRegisteredName:@"WebCamDataProviderService" host:nil];
    if (connection == nil)
        return nil;

    [connection enableMultipleThreads];
    [connection addRequestMode:NSModalPanelRunLoopMode];
    [connection addRequestMode:NSEventTrackingRunLoopMode];
    [connection setReplyTimeout:30.0];
    [connection setRequestTimeout:1.0];
    if ([connection isValid]) {
        @try {
            id proxy = [connection rootProxy];
            [proxy setProtocolForProxy:@protocol(HSWebCamDataProviderServiceProtocol)];
            [proxy ping];
        } @catch (NSException *exception) {
            [connection invalidate];
            connection = nil;
        }
    }
    return connection;
}

- (void)dealloc
{
    [_appIDStr release];
    [super dealloc];
}

- (void)setApplicationIdentifier:(id)aIdentifier
{
    if (![_appIDStr isEqualToString:aIdentifier]) {
        [_appIDStr release];
        _appIDStr = [aIdentifier copy];
    }
}

- (id)init
{
    // Singleton: a second instance is thrown away in favor of the shared one.
    if (HSSharedWebCamDataProvider != nil) {
        [self dealloc];
        return HSSharedWebCamDataProvider;
    }
    HSSharedWebCamDataProvider = [super init];
    return HSSharedWebCamDataProvider;
}

@end
