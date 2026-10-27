#import "HSUpdater.h"

static HSUpdater *HSUpdaterShared = nil;
static BOOL HSUpdaterDidAutomaticCheck = NO;

// Product updates come from SMKCheckForUpdates through distributed
// notifications; webcam database updates from HSWebCamDataProvider. Both are
// filtered by this updater's unique identifier.
@implementation HSUpdater
+ (id)sharedUpdater
{
    if (!HSUpdaterShared)
        HSUpdaterShared = [HSUpdater new];
    return HSUpdaterShared;
}
- (void)cancelWebCamProgressPanel:(id)aPanel
{
    [NSApp stopModalWithCode:0];
}
// The estimate extrapolates the elapsed time over the remaining bytes.
- (void)webCamUpdateNotificationProgress:(id)aProgress
{
    if (![[aProgress object] isEqualToString:[self uniqueIdentifier]])
        return;
    unsigned int expected = [[[aProgress userInfo] objectForKey:@"WCDPExpectedContentLength"] unsignedIntValue];
    unsigned int received = [[[aProgress userInfo] objectForKey:@"WCDPReceivedContentLength"] unsignedIntValue];
    NSString *progress;
    if (received < expected) {
        [_webCamProgressBar setIndeterminate:NO];
        [_webCamProgressBar setMaxValue:expected];
        [_webCamProgressBar setDoubleValue:received];
        [_webCamStatusTextField setStringValue:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Downloading data..." value:@"" table:@"HyperPlayerBase"]];
        double elapsed = [[NSDate date] timeIntervalSince1970] - _webCamProgressStartTime;
        double remaining = elapsed * ((double)(expected - received) / (double)received);
        double receivedMB = (float)received * 9.536743e-07f;
        double expectedMB = (float)expected * 9.536743e-07f;
        if (remaining >= 60.0) {
            // Nothing received yet makes the estimate infinite; clamp it.
            double minutes = rint(remaining / 60.0);
            unsigned int wholeMinutes = minutes < 4294967295.0 ? (unsigned int)minutes : UINT_MAX;
            if (wholeMinutes == 1)
                progress = [NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"%.2f MB of %.2f MB - About 1 minute" value:@"" table:@"HyperPlayerBase"], receivedMB, expectedMB];
            else
                progress = [NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"%.2f MB of %.2f MB - About %i minutes" value:@"" table:@"HyperPlayerBase"], receivedMB, expectedMB, wholeMinutes];
        } else {
            progress = [NSString stringWithFormat:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"%.2f MB of %.2f MB - Less than a minute" value:@"" table:@"HyperPlayerBase"], receivedMB, expectedMB];
        }
    } else {
        [_webCamProgressBar setIndeterminate:YES];
        [_webCamStatusTextField setStringValue:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Updating..." value:@"" table:@"HyperPlayerBase"]];
        progress = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Less than a minute" value:@"" table:@"HyperPlayerBase"];
    }
    [_webCamProgressTextField setStringValue:progress];
}
- (void)webCamUpdateNotificationTerminated:(id)aTerminated
{
    if ([[aTerminated object] isEqualToString:[self uniqueIdentifier]])
        [NSApp stopModalWithCode:1];
}
// Try Again restarts the update.
- (void)webCamUpdateNotificationFailed:(id)aFailed
{
    if (![[aFailed object] isEqualToString:[self uniqueIdentifier]])
        return;
    [NSApp stopModalWithCode:1];
    [_webCamProgressPanel orderOut:self];
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot update Webcam database" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"An error occurred updating webcam database. Click try Again to start updating again. If this does not help, submit a Tech Support request. To do this, select the HyperStudio Tech Support from the Help menu." value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Try Again" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    [alert setIcon:_webCamServiceImage];
    NSInteger result = [alert runModal];
    [alert release];
    if (result == NSAlertFirstButtonReturn)
        [self performSelector:@selector(startWebCamUpdate) withObject:nil afterDelay:0.0];
}
- (void)webCamUpdateNotificationComplete:(id)aComplete
{
    if (![[aComplete object] isEqualToString:[self uniqueIdentifier]])
        return;
    [NSApp stopModalWithCode:1];
    [_webCamProgressPanel orderOut:self];
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Webcam database was updated successfully" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Your copy of Webcam database is up to date." value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    [alert setIcon:_webCamServiceImage];
    [alert runModal];
    [alert release];
}
// Runs the progress panel modally while the provider downloads; a cancel
// (code 0) terminates the update.
- (void)startWebCamUpdate
{
    if (!_webCamProgressPanel)
        [EXBundleID loadNibNamed:@"WebcamProgressPanel" owner:self];
    [_webCamProgressBar setIndeterminate:YES];
    [_webCamStatusTextField setStringValue:[[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Preparing to download..." value:@"" table:@"HyperPlayerBase"]];
    [_webCamProgressTextField setStringValue:@""];
    _webCamProgressStartTime = [[NSDate date] timeIntervalSince1970];
    NSModalSession session = [NSApp beginModalSessionForWindow:_webCamProgressPanel];
    [[HSWebCamDataProvider sharedWebCamDataProvider] update:[self uniqueIdentifier]];
    NSInteger result;
    do {
        result = [NSApp runModalSession:session];
    } while (result == NSModalResponseContinue);
    [NSApp endModalSession:session];
    [_webCamProgressPanel orderOut:self];
    if (result == 0)
        [[HSWebCamDataProvider sharedWebCamDataProvider] terminateUpdate:[self uniqueIdentifier]];
}
- (void)webCamUpdateCheckingNotificationCompleteWithUpdatePresent:(id)aPresent
{
    if (![[aPresent object] isEqualToString:[self uniqueIdentifier]])
        return;
    id size = [[aPresent userInfo] objectForKey:@"WCDPUpdateSize"];
    NSString *informative;
    if (size)
        informative = [NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"An update for the Webcam Workshop database has been found. HyperStudio will download and install it for you. The size of the download is %@." value:@"" table:@"Alerts"], size];
    else
        informative = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"There is an update available from Software MacKiev that you can download for this edition of Webcam Workshop." value:@"" table:@"Alerts"];
    HSAlert *alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"A new update is available" value:@"" table:@"Alerts"]];
    [alert setInformativeText:informative];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Update Now" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Update Later" value:@"" table:@"Alerts"]];
    [alert setIcon:_webCamServiceImage];
    NSInteger result = [alert runModal];
    [alert release];
    if (result == NSAlertFirstButtonReturn)
        [self performSelector:@selector(startWebCamUpdate) withObject:nil afterDelay:0.0];
}
// An automatic check offers to turn itself off; Update Now opens the
// download page (a format taking the bundle version).
- (void)showUpdatesPanelWithDictionary:(id)aDictionary
{
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HyperStudio update available" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"There is an update available from Software MacKiev that you can download for this edition of HyperStudio." value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Update Now" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Update Later" value:@"" table:@"Alerts"]];
    BOOL automatic = [[aDictionary objectForKey:HSAutomaticProductUpdateMode] boolValue];
    NSButton *checkbox = nil;
    if (automatic) {
        checkbox = [[NSButton alloc] initWithFrame:NSZeroRect];
        [checkbox setButtonType:NSSwitchButton];
        [checkbox setTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Don't show this message again" value:@"" table:@"Alerts"]];
        [alert setCustomView:checkbox];
    }
    NSInteger result = [alert runModal];
    NSInteger state = [checkbox state];
    [alert close];
    [checkbox release];
    [alert release];
    if (automatic && state)
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:HSAutomaticProductUpdateMode];
    if (result == NSAlertFirstButtonReturn) {
        NSString *page = [[[aDictionary objectForKey:@"HSAllUpdates"] objectForKey:@"HSProductUpdates"] objectForKey:@"HSDownloadPage"];
        NSString *url = [NSString stringWithFormat:page, [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    }
}
// Keeps the download page and the products newer than this build.
- (id)checkedProductUpdatesDictionary:(id)aDictionary
{
    NSMutableDictionary *checked = [[aDictionary mutableCopy] autorelease];
    int build = [[[NSBundle mainBundle] HS_buildVersion] intValue];
    NSArray *keys = [aDictionary allKeys];
    NSUInteger count = [aDictionary count];
    NSUInteger i;
    for (i = 0; i < count; i++) {
        id key = [keys objectAtIndex:i];
        if ([key isEqualToString:@"HSDownloadPage"])
            continue;
        id product = [aDictionary valueForKey:key];
        if ([[product allKeys] containsObject:@"HSVersion"] && build < [[product valueForKey:@"HSVersion"] intValue])
            continue;
        [checked removeObjectForKey:key];
    }
    return checked;
}
// Drops the product updates unless something besides the download page remains.
- (id)checkedDictionary:(id)aDictionary
{
    NSMutableDictionary *checked = [[aDictionary mutableCopy] autorelease];
    if ([[checked allKeys] containsObject:@"HSProductUpdates"]) {
        [checked removeObjectForKey:@"HSProductUpdates"];
        id products = [self checkedProductUpdatesDictionary:[aDictionary objectForKey:@"HSProductUpdates"]];
        if (products && [products count] > 1)
            [checked setObject:products forKey:@"HSProductUpdates"];
    }
    return checked;
}
- (void)updateCheckingNotificationTerminated:(id)aTerminated
{
    if (![[aTerminated object] isEqualToString:[self uniqueIdentifier]])
        return;
    _isInAutoUpdate = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kCFUCheckForUpdatesTerminatedNotificationName object:nil];
}
// A manual check offers Retry; an automatic one fails silently.
- (void)updateCheckingNotificationFailed:(id)aFailed
{
    if (![[aFailed object] isEqualToString:[self uniqueIdentifier]])
        return;
    if (_isInAutoUpdate) {
        _isInAutoUpdate = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kCFUCheckForUpdatesFailedNotificationName object:nil];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kCFUCheckForUpdatesFailedNotificationName object:nil];
    NSString *cancel = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"];
    NSString *retry = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Retry" value:@"" table:@"Alerts"];
    NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"The search for updates could not be completed. Please make sure you are connected to the internet and try again." value:@"" table:@"Alerts"];
    NSString *title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Update search failed" value:@"" table:@"Alerts"];
    if (NSRunAlertPanel(title, @"%@", retry, cancel, nil, message) != NSAlertDefaultReturn)
        return;
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kCFUCheckForUpdatesStartedNotificationName object:nil];
    [self checkForUpdates];
}
// A manual check without updates says so; an automatic one stays quiet.
- (void)updateCheckingNotificationComplete:(id)aComplete
{
    if (![[aComplete object] isEqualToString:[self uniqueIdentifier]])
        return;
    if ([aComplete userInfo]) {
        id checked = [self checkedDictionary:[aComplete userInfo]];
        if (!checked)
            return;
        if ([checked count] && [[checked allKeys] containsObject:@"HSProductUpdates"]) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:checked, @"HSAllUpdates", [NSNumber numberWithBool:_isInAutoUpdate], HSAutomaticProductUpdateMode, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kCFUCheckForUpdatesCompletedNotificationName object:nil];
            [self showUpdatesPanelWithDictionary:dictionary];
            return;
        }
    }
    if (_isInAutoUpdate) {
        _isInAutoUpdate = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kCFUCheckForUpdatesCompletedNotificationName object:nil];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kCFUCheckForUpdatesCompletedNotificationName object:nil];
    NSString *ok = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
    NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Your copy of Hyper Studio is up to date!" value:@"" table:@"Alerts"];
    NSString *title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"No updates found" value:@"" table:@"Alerts"];
    NSRunAlertPanel(title, @"%@", ok, nil, nil, message);
}
- (void)terminateUpdatesChecking
{
    CFUTerminateCheckForUpdates();
}
- (void)checkForUpdates
{
    [self performSelector:@selector(startCheckForProductUpdates) withObject:nil afterDelay:0.0];
}
// Once per launch, when either automatic mode is on.
- (void)automaticCheckForUpdates
{
    NSInteger product = [[NSUserDefaults standardUserDefaults] integerForKey:HSAutomaticProductUpdateMode];
    NSInteger webcam = [[NSUserDefaults standardUserDefaults] integerForKey:HSAutomaticWebcamUpdateMode];
    if (HSUpdaterDidAutomaticCheck || (!webcam && !product))
        return;
    _isInAutoUpdate = YES;
    HSUpdaterDidAutomaticCheck = YES;
    if (product)
        [self performSelector:@selector(startCheckForProductUpdates) withObject:nil afterDelay:0.0];
}
- (id)uniqueIdentifier
{
    if (!_uniqueIdentifier)
        _uniqueIdentifier = [[NSString alloc] initWithFormat:@"%@ %@", HSUpdatesUniqueIdentifierBase, [[HSUID UID] stringValue]];
    return _uniqueIdentifier;
}
- (void)startCheckForProductUpdates
{
    NSString *url = [[[NSBundle mainBundle] objectForInfoDictionaryKey:HSUpdatesDownloadURL] copy];
    NSString *identifier = [[self uniqueIdentifier] copy];
    CFUCheckForUpdates((CFStringRef)url, (CFStringRef)identifier);
    [identifier autorelease];
    [url autorelease];
}
- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [_uniqueIdentifier release];
    [_webCamServiceImage release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(updateCheckingNotificationComplete:) name:(NSString *)kCFUCheckForUpdatesCompletedNotificationName object:[self uniqueIdentifier] suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
        [center addObserver:self selector:@selector(updateCheckingNotificationFailed:) name:(NSString *)kCFUCheckForUpdatesFailedNotificationName object:[self uniqueIdentifier] suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
        [center addObserver:self selector:@selector(updateCheckingNotificationTerminated:) name:(NSString *)kCFUCheckForUpdatesTerminatedNotificationName object:[self uniqueIdentifier] suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
        [center addObserver:self selector:@selector(webCamUpdateCheckingNotificationCompleteWithUpdatePresent:) name:@"WCDPCheckForUpdatesCompletedUpdatePresentNotification" object:[self uniqueIdentifier] suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
        [center addObserver:self selector:@selector(webCamUpdateNotificationComplete:) name:@"WCDPUpdateCompletedNotification" object:[self uniqueIdentifier] suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
        [center addObserver:self selector:@selector(webCamUpdateNotificationFailed:) name:@"WCDPUpdateFailedNotification" object:[self uniqueIdentifier] suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
        [center addObserver:self selector:@selector(webCamUpdateNotificationTerminated:) name:@"WCDPUpdateTerminatedNotification" object:[self uniqueIdentifier] suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
        [center addObserver:self selector:@selector(webCamUpdateNotificationProgress:) name:@"WCDPUpdateProgressNotification" object:[self uniqueIdentifier] suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
        _webCamServiceImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"WebCamServiceIcon" ofType:@"icns"]];
    }
    return self;
}
@end
