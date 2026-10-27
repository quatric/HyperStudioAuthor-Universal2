#import "HSAFTPServerExportPanelController.h"
#import "HyperStudioUmbrella.h"
#import <Security/Security.h>

@interface NSURL (HSAFTPServerExportPanelURLBuilding)
+ (id)URLWithString:(id)aString scheme:(id)aScheme port:(int)aPort user:(id)aUser password:(id)aPassword;
- (id)hyperHost;
@end

@interface HSAFTPServerExportPanelController (HSAFTPServerExportPanelController_)
- (void)HSAFTPServerExportPanelController_validateUI;
- (void)HSAFTPServerExportPanelController_loadBookmarks;
- (void)HSAFTPServerExportPanelController_saveBookmarks;
- (id)HSAFTPServerExportPanelController_connectionURL;
- (id)HSAFTPServerExportPanelController_userCredential;
- (id)HSAFTPServerExportPanelController_newConnection;
- (BOOL)HSAFTPServerExportPanelController_checkConnectionURL:(id)aURL;
- (void)HSAFTPServerExportPanelController_showAlertForError:(id)aError;
- (void)HSAFTPServerExportPanelController_publish;
@end

static NSString *HSAFTPExportLocalized(NSString *aKey, NSString *aTable)
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:aKey value:@"" table:aTable];
}

static const UInt32 HSAFTPKeychainProtocol = 0x66747020;
static const UInt32 HSAFTPKeychainAuthType = 0x746c6664;


@implementation HSAFTPServerExportPanelController

- (id)windowNibName
{
    return @"ExportToFTPServerPanel";
}

- (void)awakeFromNib
{
    id document = [[NSDocumentController sharedDocumentController] currentDocument];
    NSURL *fileURL = [document fileURL];
    NSString *name;
    if (fileURL != nil) {
        name = [[fileURL lastPathComponent] stringByDeletingPathExtension];
    } else {
        name = [document displayName];
    }
    [_stackNameTextField setStringValue:name];
    [self HSAFTPServerExportPanelController_loadBookmarks];
    [self HSAFTPServerExportPanelController_validateUI];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_ftpHostTextField];
    [center addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_httpHostTextField];
    [center addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_stackNameTextField];
    [center addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:_userTextField];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_connection setDelegate:nil];
    [_connection release];
    [super dealloc];
}

- (void)HSAFTPServerExportPanelController_validateUI
{
    if ([self connection] == nil) {
        [_anonymousUserCheckBox setEnabled:YES];
        [_addPasswordToKeyChainCheckBox setEnabled:YES];
        BOOL canTest = NO;
        BOOL canPublish = NO;
        if ([[_ftpHostTextField stringValue] length] != 0) {
            canTest = [[[[self HSAFTPServerExportPanelController_userCredential] user] copy] length] != 0;
            canPublish = canTest && [[_stackNameTextField stringValue] length] != 0;
        }
        [_testConnectionButton setEnabled:canTest];
        [_publishButton setEnabled:canPublish];
        [_ftpHostTextField setEnabled:YES];
        [_directoryPathTextField setEnabled:YES];
        [_httpHostTextField setEnabled:YES];
        BOOL anonymous = [_anonymousUserCheckBox state] == NSOnState;
        [_userTextField setEnabled:!anonymous];
        [_passwordTextField setEnabled:!anonymous];
        [_stackNameTextField setEnabled:YES];
        [_portTextField setEnabled:YES];
    } else {
        [[self window] makeFirstResponder:nil];
        [_anonymousUserCheckBox setEnabled:NO];
        [_addPasswordToKeyChainCheckBox setEnabled:NO];
        [_publishButton setEnabled:NO];
        [_testConnectionButton setEnabled:NO];
        [_ftpHostTextField setEnabled:NO];
        [_directoryPathTextField setEnabled:NO];
        [_httpHostTextField setEnabled:NO];
        [_userTextField setEnabled:NO];
        [_passwordTextField setEnabled:NO];
        [_stackNameTextField setEnabled:NO];
        [_portTextField setEnabled:NO];
    }
}

- (void)controlTextDidChange:(id)aNotification
{
    [self HSAFTPServerExportPanelController_validateUI];
}

- (IBAction)anonymousUserChanged:(id)aSender
{
    [self HSAFTPServerExportPanelController_validateUI];
}

- (id)HSAFTPServerExportPanelController_newConnection
{
    NSURL *url = [self HSAFTPServerExportPanelController_connectionURL];
    HSAFTPConnection *connection = [[HSAFTPConnection alloc] initWithURL:url delegate:self];
    [connection useCredential:[self HSAFTPServerExportPanelController_userCredential]];
    [connection setPort:(int)[[url port] integerValue]];
    return connection;
}

- (id)HSAFTPServerExportPanelController_connectionURL
{
    NSString *host = [_ftpHostTextField stringValue];
    NSString *directory = [_directoryPathTextField stringValue];
    if (![directory hasPrefix:@"/"]) {
        directory = [@"/" stringByAppendingFormat:@"%@", directory];
    }
    if (![directory hasSuffix:@"/"]) {
        directory = [directory stringByAppendingFormat:@"/"];
    }
    host = [host stringByAppendingFormat:@"%@", directory];
    NSURL *url = [NSURL URLWithString:host];
    NSInteger port = [[_portTextField stringValue] length] != 0 ? [_portTextField intValue] : [HSAFTPConnection defaultPort];
    return [NSURL URLWithString:[url absoluteString] scheme:[[HSAFTPConnection schemes] objectAtIndex:0] port:(int)port user:nil password:nil];
}

- (id)HSAFTPServerExportPanelController_userCredential
{
    NSString *user = [_userTextField stringValue];
    NSString *password = [_passwordTextField stringValue];
    if ([_anonymousUserCheckBox state] == NSOnState) {
        user = [HSAFTPConnection anonymousUser];
        password = @"";
    }
    return [NSURLCredential credentialWithUser:user password:password persistence:NSURLCredentialPersistenceForSession];
}

- (void)setConnection:(id)aConnection
{
    if (_connection != aConnection) {
        [_connection setDelegate:nil];
        [_connection release];
        _connection = [aConnection retain];
        [self HSAFTPServerExportPanelController_validateUI];
    }
}

- (id)connection
{
    return _connection;
}

- (BOOL)HSAFTPServerExportPanelController_checkConnectionURL:(id)aURL
{
    if (aURL == nil) {
        NSError *error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:-1000 userInfo:nil];
        [self HSAFTPServerExportPanelController_showAlertForError:[HSAFTPConnection localizedErrorForError:error]];
    }
    return aURL != nil;
}

- (void)HSAFTPServerExportPanelController_showAlertForError:(id)aError
{
    NSBeginAlertSheet([aError localizedDescription], HSAFTPExportLocalized(@"OK", @"Alerts"), nil, nil, [self window], nil, NULL, NULL, NULL, @"%@", [aError localizedRecoverySuggestion]);
}

- (void)HSAFTPServerExportPanelController_loadBookmarks
{
    NSDictionary *bookmark = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSAFTPServerExportBookmark"];
    if (bookmark == nil) {
        return;
    }
    id value = [bookmark objectForKey:@"HSAFTPServerExportFTPAddress"];
    if ([value isKindOfClass:[NSString class]]) {
        [_ftpHostTextField setStringValue:value];
    }
    value = [bookmark objectForKey:@"HSAFTPServerExportDirectoryPath"];
    if ([value isKindOfClass:[NSString class]]) {
        [_directoryPathTextField setStringValue:value];
    }
    value = [bookmark objectForKey:@"HSAFTPServerExportPort"];
    if ([value isKindOfClass:[NSNumber class]]) {
        [_portTextField setIntegerValue:[value integerValue]];
    }
    value = [bookmark objectForKey:@"HSAFTPServerExportHTTPAddress"];
    if ([value isKindOfClass:[NSString class]]) {
        [_httpHostTextField setStringValue:value];
    }
    value = [bookmark objectForKey:@"HSAFTPServerExportUser"];
    if ([value isKindOfClass:[NSString class]]) {
        [_userTextField setStringValue:value];
    }
    value = [self loadPasswordFromKeyChain];
    if ([value isKindOfClass:[NSString class]]) {
        [_passwordTextField setStringValue:value];
    }
    [_anonymousUserCheckBox setState:[[bookmark valueForKey:@"HSAFTPServerAnonymousLogin"] boolValue] ? NSOnState : NSOffState];
}

- (void)HSAFTPServerExportPanelController_saveBookmarks
{
    NSMutableDictionary *bookmark = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[_ftpHostTextField stringValue], @"HSAFTPServerExportFTPAddress", nil];
    [bookmark setObject:[[_httpHostTextField stringValue] length] == 0 ? @"" : [_httpHostTextField stringValue] forKey:@"HSAFTPServerExportHTTPAddress"];
    if ([[_directoryPathTextField stringValue] length] != 0) {
        [bookmark setObject:[_directoryPathTextField stringValue] forKey:@"HSAFTPServerExportDirectoryPath"];
    }
    if ([[_userTextField stringValue] length] != 0) {
        [bookmark setObject:[_userTextField stringValue] forKey:@"HSAFTPServerExportUser"];
    }
    [bookmark setObject:[NSNumber numberWithBool:[_anonymousUserCheckBox state] == NSOnState] forKey:@"HSAFTPServerAnonymousLogin"];
    if ([[_passwordTextField stringValue] length] != 0 && [_addPasswordToKeyChainCheckBox state] == NSOnState) {
        [self savePasswordToKeyChain:[_passwordTextField stringValue]];
    }
    if ([[_portTextField stringValue] length] != 0) {
        [bookmark setObject:[NSNumber numberWithInteger:[_portTextField integerValue]] forKey:@"HSAFTPServerExportPort"];
    }
    [[NSUserDefaults standardUserDefaults] setObject:bookmark forKey:@"HSAFTPServerExportBookmark"];
    [bookmark release];
}

- (id)loadPasswordFromKeyChain
{
    NSString *user = [_userTextField stringValue];
    NSURL *url = [self HSAFTPServerExportPanelController_connectionURL];
    NSUInteger port = [[url port] unsignedIntegerValue];
    NSString *host = [url host];
    UInt32 passwordLength = 0;
    void *passwordData = NULL;
    SecKeychainItemRef item = NULL;
    OSStatus status = SecKeychainFindInternetPassword(NULL, (UInt32)[host length], [host UTF8String], 0, NULL, (UInt32)[user length], [user UTF8String], 0, NULL, (UInt16)port, HSAFTPKeychainProtocol, HSAFTPKeychainAuthType, &passwordLength, &passwordData, &item);
    if (status != noErr) {
        return nil;
    }
    NSString *password = [[[NSString alloc] initWithBytes:passwordData length:passwordLength encoding:NSUTF8StringEncoding] autorelease];
    SecKeychainItemFreeContent(NULL, passwordData);
    if (item != NULL) {
        CFRelease(item);
    }
    return password;
}

- (BOOL)savePasswordToKeyChain:(id)aPassword
{
    NSString *user = [_userTextField stringValue];
    NSURL *url = [self HSAFTPServerExportPanelController_connectionURL];
    NSUInteger port = [[url port] unsignedIntegerValue];
    NSString *host = [url host];
    SecKeychainItemRef item = NULL;
    const char *password = [[_passwordTextField stringValue] UTF8String];
    UInt32 passwordLength = (UInt32)[[_passwordTextField stringValue] length];
    OSStatus status = SecKeychainFindInternetPassword(NULL, (UInt32)[host length], [host UTF8String], 0, NULL, (UInt32)[user length], [user UTF8String], 0, NULL, (UInt16)port, HSAFTPKeychainProtocol, HSAFTPKeychainAuthType, NULL, NULL, &item);
    if (status == noErr) {
        status = SecKeychainItemModifyAttributesAndData(item, NULL, (UInt32)strlen(password), password);
    } else {
        status = SecKeychainAddInternetPassword(NULL, (UInt32)[host length], [host UTF8String], 0, NULL, (UInt32)[user length], [user UTF8String], 0, NULL, (UInt16)port, HSAFTPKeychainProtocol, HSAFTPKeychainAuthType, passwordLength, password, NULL);
    }
    if (item != NULL) {
        CFRelease(item);
    }
    return status == noErr;
}

- (IBAction)onTestConnection:(id)aSender
{
    NSURL *url = [self HSAFTPServerExportPanelController_connectionURL];
    if ([self HSAFTPServerExportPanelController_checkConnectionURL:url]) {
        [self setConnection:[self HSAFTPServerExportPanelController_newConnection]];
        [[self connection] checkConnection];
    }
}

- (IBAction)onPublish:(id)aSender
{
    NSURL *url = [self HSAFTPServerExportPanelController_connectionURL];
    if ([self HSAFTPServerExportPanelController_checkConnectionURL:url]) {
        [self setConnection:[self HSAFTPServerExportPanelController_newConnection]];
        [[self connection] checkReachability];
    }
}

- (IBAction)cancel:(id)aSender
{
    [_publisher terminatePublish];
    [self setConnection:nil];
    [super cancel:aSender];
}

- (void)HSAFTPServerExportPanelController_publish
{
    id publisher = _publisher;
    NSString *stackName = [_stackNameTextField stringValue];
    NSURL *url = [[self connection] URL];
    if ([stackName length] != 0) {
        url = [url URLByAppendingPathComponent:stackName isDirectory:YES];
    }
    HSAFTPConnection *connection = [[HSAFTPConnection alloc] initWithURL:url delegate:nil];
    [connection useCredential:[self HSAFTPServerExportPanelController_userCredential]];
    [connection setPort:[(HSANetworkConnection *)[self connection] port]];
    [connection setIsActive:NO];
    [self setConnection:nil];
    [publisher setStorePath:[NSTemporaryDirectory() stringByAppendingPathComponent:stackName]];
    [publisher setConnection:connection];
    [connection release];
    NSString *httpHost = [_httpHostTextField stringValue];
    NSString *host = [[NSURL URLWithString:httpHost] hyperHost];
    if ([host length] != 0) {
        NSURL *location = [NSURL URLWithString:host scheme:[[HSANetworkConnection schemes] objectAtIndex:0] port:0x7fffffff user:nil password:nil];
        location = [location URLByAppendingPathComponent:stackName isDirectory:YES];
        location = [location URLByAppendingPathComponent:@"index.html" isDirectory:NO];
        [publisher setPublishLocation:[location absoluteString]];
    }
    [super ok:nil];
}

- (void)connectionDidSucceed:(id)aConnection
{
    [self HSAFTPServerExportPanelController_saveBookmarks];
    NSBeginAlertSheet(HSAFTPExportLocalized(@"HSSuccessFTPServerConnectionSucceededTitle", @"Alerts"), HSAFTPExportLocalized(@"OK", @"Alerts"), nil, nil, [self window], nil, NULL, NULL, NULL, @"%@", HSAFTPExportLocalized(@"HSSuccessFTPServerConnectionSucceededDescription", @"Alerts"));
    [self setConnection:nil];
}

- (void)connection:(id)aConnection didFinishChecking:(id)aResult
{
    [self HSAFTPServerExportPanelController_saveBookmarks];
    NSString *stackName = [_stackNameTextField stringValue];
    NSUInteger result = (NSUInteger)aResult;
    if (result == 1) {
        _isResourceExistsChecking = 0;
        HSAlert *alert = [HSAlert new];
        [alert setMessageText:[NSString stringWithFormat:HSAFTPExportLocalized(@"HSAFTPServerPublishResourceExistsMessageText", @"Export"), stackName]];
        [alert setInformativeText:[NSString stringWithFormat:HSAFTPExportLocalized(@"HSAFTPServerPublishResourceExistsInformativeText", @"Export"), stackName]];
        [alert addButtonWithTitle:HSAFTPExportLocalized(@"HSAFTPServerPublishResourceExistsReplace", @"Export")];
        [alert addButtonWithTitle:HSAFTPExportLocalized(@"HSAFTPServerPublishResourceExistsCancel", @"Export")];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(resourceExistsAlertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
        [alert release];
    } else if (result == 0) {
        if (![[[stackName pathComponents] lastObject] isEqualToString:@"/"]) {
            stackName = [NSString stringWithFormat:@"%@/", stackName];
        }
        [[self connection] resourceExistsAtPath:stackName];
        _isResourceExistsChecking = 1;
    }
}

- (void)connection:(id)aConnection didFailWithError:(id)aError
{
    NSInteger status = [[[aError userInfo] objectForKey:(id)kCFFTPStatusCodeKey] integerValue];
    if (!_isResourceExistsChecking) {
        if (status == 0x226 && [[[aConnection URL] pathComponents] count] > 2) {
            NSMutableDictionary *userInfo = [[aError userInfo] mutableCopy];
            [userInfo setObject:HSAFTPExportLocalized(@"HSAInvalidFTPServerCannotPublishDescription", @"Alerts") forKey:NSLocalizedDescriptionKey];
            [userInfo setObject:HSAFTPExportLocalized(@"HSAInvalidFTPServerNoDirectoryRecoverySuggestion", @"Alerts") forKey:NSLocalizedRecoverySuggestionErrorKey];
            aError = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:0x226 userInfo:userInfo];
            [userInfo release];
        }
        [self HSAFTPServerExportPanelController_showAlertForError:aError];
        [self setConnection:nil];
    } else if (status == 0x226) {
        [self HSAFTPServerExportPanelController_publish];
    }
    _isResourceExistsChecking = 0;
}

- (void)resourceExistsAlertDidEnd:(id)aAlert returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    if (aCode == NSAlertFirstButtonReturn) {
        [_publisher setFileShouldBeRemoved:YES];
        [self HSAFTPServerExportPanelController_publish];
    } else {
        [self setConnection:nil];
    }
}

@end
