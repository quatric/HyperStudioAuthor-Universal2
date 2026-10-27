#import "HSAFTPConnection.h"
#import "HyperStudioUmbrella.h"

@interface NSError (HSAFTPConnectionStreamStatus)
- (NSInteger)streamStatusCode;
@end

@interface NSURL (HSAFTPConnectionURLBuilding)
+ (id)URLWithString:(id)aString scheme:(id)aScheme port:(int)aPort user:(id)aUser password:(id)aPassword;
- (id)hyperHost;
@end

@interface HSAFTPConnection (HSAFTPConnection_)
+ (id)HSAFTPConnection_localizedErrorForInputStreamError:(id)aError;
- (id)HSAFTPConnection_directories;
- (id)HSAFTPConnection_timeoutTimer;
- (void)HSAFTPConnection_invalidateTimer;
- (void)HSAFTPConnection_timeoutIsUp;
- (void)HSAFTPConnection_closeInputStream;
- (void)HSAFTPConnection_closeOutputStream;
- (void)HSAFTPConnection_stopEnumerating;
- (void)HSAFTPConnection_enumerateNextURL;
- (BOOL)HSAFTPConnection_openInputStreamForURL:(id)aURL;
- (void)HSAFTPConnection_parseReadData;
- (id)HSAFTPConnection_transcodedResourceInformation:(CFDictionaryRef)aInformation byEncoding:(NSStringEncoding)aEncoding;
- (void)HSAFTPConnection_checkingConnectionDidEnd;
- (void)HSAFTPConnection_checkingReachabilityDidEnd;
- (void)HSAFTPConnection_checkingResourceExistingDidEnd;
- (void)HSAFTPConnection_removeAllResources;
@end


static NSString *HSAFTPLocalized(NSString *aKey)
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:aKey value:@"" table:@"Alerts"];
}

@implementation HSAFTPConnection

+ (NSUInteger)defaultPort
{
    return 21;
}

+ (id)schemes
{
    return [NSArray arrayWithObject:@"ftp"];
}

+ (id)anonymousUser
{
    return @"anonymous";
}

+ (id)localizedErrorForError:(id)aError
{
    if (aError == nil) {
        return nil;
    }
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    if ([aError userInfo] != nil) {
        [userInfo addEntriesFromDictionary:[aError userInfo]];
    }
    NSString *description = nil;
    NSString *suggestion = nil;
    BOOL localized = YES;
    NSInteger status = [aError streamStatusCode];
    switch ((unsigned int)status) {
        case 0xffffffff:
        case 0xfffffc18:
        case 0xfffee6bc:
        case 8:
        case 0x31:
        case 0x41:
            description = @"HSAInvalidFTPServerConnectDescription";
            suggestion = @"HSAInvalidFTPServerAddressRecoverySuggestion";
            break;
        case 0xfffff444:
            description = @"HSAInvalidFTPServerFileRemovingDescription";
            suggestion = @"HSAInvalidFTPServerFileRemovingRecoverySuggestion";
            break;
        case 0x39:
            description = @"HSAInvalidFTPServerFileUploadingDescription";
            suggestion = @"HSAInvalidFTPServerFileUploadingRecoverySuggestion";
            break;
        case 0x3c:
            description = @"HSAInvalidFTPServerTimeoutDescription";
            suggestion = @"HSAInvalidFTPServerTimeoutRecoverySuggestion";
            break;
        case 0x3d:
            description = @"HSAInvalidFTPServerConnectDescription";
            suggestion = @"HSAInvalidFTPServerInalidPortSuggestion";
            break;
        case 0x212:
            description = @"HSAInvalidFTPServerConnectDescription";
            suggestion = @"HSAInvalidFTPServerAuthenticationRecoverySuggestion";
            break;
        case 0x226:
            description = @"HSAInvalidFTPServerCannotPublishDescription";
            suggestion = @"HSAInvalidFTPServerPrivilegesRecoverySuggestion";
            break;
        default:
            localized = NO;
            break;
    }
    if (localized) {
        [userInfo setObject:HSAFTPLocalized(description) forKey:NSLocalizedDescriptionKey];
        [userInfo setObject:HSAFTPLocalized(suggestion) forKey:NSLocalizedRecoverySuggestionErrorKey];
    }
    NSError *result = [NSError errorWithDomain:[aError domain] code:[aError code] userInfo:userInfo];
    [userInfo release];
    return result;
}

+ (id)HSAFTPConnection_localizedErrorForInputStreamError:(id)aError
{
    if (aError == nil) {
        return nil;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if ([aError userInfo] != nil) {
        [userInfo addEntriesFromDictionary:[aError userInfo]];
    }
    if ([aError streamStatusCode] == 0x226) {
        [userInfo setObject:HSAFTPLocalized(@"HSAInvalidFTPServerCannotPublishDescription") forKey:NSLocalizedDescriptionKey];
        [userInfo setObject:HSAFTPLocalized(@"HSAInvalidFTPServerFolderUnavailableRecoverySuggestion") forKey:NSLocalizedRecoverySuggestionErrorKey];
    } else {
        aError = [HSAFTPConnection localizedErrorForError:aError];
        if ([aError userInfo] != nil) {
            [userInfo setDictionary:[aError userInfo]];
        }
    }
    return [NSError errorWithDomain:[aError domain] code:[aError code] userInfo:userInfo];
}

- (id)initWithURL:(id)aURL delegate:(id)aDelegate
{
    NSString *host = [aURL hyperHost];
    return [super initWithURL:[host hasPrefix:@"/"] ? nil : aURL delegate:aDelegate];
}

- (void)dealloc
{
    [self HSAFTPConnection_closeInputStream];
    [self close];
    [_readData release];
    [_URLs release];
    [_directories release];
    [super dealloc];
}

- (BOOL)isActive
{
    return _isActive;
}

- (void)setIsActive:(BOOL)aIsActive
{
    _isActive = aIsActive ? 1 : 0;
}

- (id)outputStream
{
    return _outputStream;
}

- (BOOL)open
{
    if (_outputStream != nil) {
        return YES;
    }
    if ([self URL] != nil) {
        _outputStream = (NSOutputStream *)CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, (CFURLRef)[self URL]);
        if (_outputStream != nil) {
            BOOL ok = YES;
            if ([[self userName] length] != 0) {
                ok = [_outputStream setProperty:[self userName] forKey:(NSString *)kCFStreamPropertyFTPUserName];
                if (ok && [[self password] length] != 0) {
                    ok = [_outputStream setProperty:[self password] forKey:(NSString *)kCFStreamPropertyFTPPassword];
                }
            }
            if (ok) {
                if (![self isActive]) {
                    ok = [_outputStream setProperty:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamPropertyFTPUsePassiveMode];
                }
                if (ok) {
                    if ([self HSAFTPConnection_timeoutTimer] != nil) {
                        [_outputStream setDelegate:[self delegate]];
                        [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                        [_outputStream open];
                        return YES;
                    }
                    [_outputStream release];
                    _outputStream = nil;
                    return ok;
                }
            }
        }
    }
    [_outputStream release];
    _outputStream = nil;
    return NO;
}

- (void)close
{
    [self HSAFTPConnection_closeOutputStream];
    [self HSAFTPConnection_invalidateTimer];
}

- (void)HSAFTPConnection_closeInputStream
{
    [_inputStream setDelegate:nil];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream close];
    [_inputStream release];
    _inputStream = nil;
}

- (void)HSAFTPConnection_closeOutputStream
{
    [_outputStream setDelegate:nil];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream close];
    [_outputStream release];
    _outputStream = nil;
}

- (id)HSAFTPConnection_directories
{
    if (_directories == nil) {
        _directories = [[NSMutableArray alloc] init];
    }
    return _directories;
}

- (id)HSAFTPConnection_timeoutTimer
{
    if (_timeoutTimer == nil) {
        _timeoutTimer = [[NSTimer scheduledTimerWithTimeInterval:30.0 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(HSAFTPConnection_timeoutIsUp) userInfo:nil repeats:NO] retain];
        [[NSRunLoop currentRunLoop] addTimer:_timeoutTimer forMode:NSDefaultRunLoopMode];
    }
    return _timeoutTimer;
}

- (void)HSAFTPConnection_invalidateTimer
{
    [_timeoutTimer invalidate];
    [_timeoutTimer release];
    _timeoutTimer = nil;
}

- (void)HSAFTPConnection_timeoutIsUp
{
    [self close];
    if ([[self delegate] respondsToSelector:@selector(connection:didFailWithError:)]) {
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:60 userInfo:nil];
        [[self delegate] connection:self didFailWithError:[[self class] localizedErrorForError:error]];
    }
}

- (void)HSAFTPConnection_stopEnumerating
{
    [self HSAFTPConnection_closeInputStream];
    [self HSAFTPConnection_invalidateTimer];
    [_readData release];
    _readData = nil;
}

- (void)HSAFTPConnection_enumerateNextURL
{
    if (_currentIndex < (int)[[self HSAFTPConnection_directories] count] - 1) {
        _currentIndex++;
        [self HSAFTPConnection_openInputStreamForURL:[[self HSAFTPConnection_directories] objectAtIndex:_currentIndex]];
    } else {
        [self HSAFTPConnection_stopEnumerating];
        _currentIndex = -1;
        if (_didEndSelector != NULL) {
            [self performSelector:_didEndSelector];
        }
    }
}

- (BOOL)HSAFTPConnection_openInputStreamForURL:(id)aURL
{
    if (_inputStream != nil) {
        return YES;
    }
    if (aURL != nil) {
        _inputStream = (NSInputStream *)CFReadStreamCreateWithFTPURL(kCFAllocatorDefault, (CFURLRef)[[self HSAFTPConnection_directories] objectAtIndex:_currentIndex]);
        if (_inputStream != nil) {
            BOOL ok = YES;
            if ([[self userName] length] != 0) {
                ok = [_inputStream setProperty:[self userName] forKey:(NSString *)kCFStreamPropertyFTPUserName];
                if (ok && [[self password] length] != 0) {
                    ok = [_inputStream setProperty:[self password] forKey:(NSString *)kCFStreamPropertyFTPPassword];
                }
            }
            if (ok) {
                if (![self isActive]) {
                    ok = [_inputStream setProperty:[NSNumber numberWithBool:YES] forKey:(NSString *)kCFStreamPropertyFTPUsePassiveMode];
                }
                if (ok) {
                    ok = [_inputStream setProperty:[NSNumber numberWithBool:NO] forKey:(NSString *)kCFStreamPropertyFTPAttemptPersistentConnection];
                    if (ok) {
                        if ([self HSAFTPConnection_timeoutTimer] == nil) {
                            return ok;
                        }
                        [_inputStream setDelegate:self];
                        [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                        [_inputStream open];
                        return YES;
                    }
                }
            }
        }
    }
    [_inputStream release];
    _inputStream = nil;
    return NO;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)aEvent
{
    if (aEvent == NSStreamEventEndEncountered) {
        [self HSAFTPConnection_enumerateNextURL];
        return;
    }
    if (aEvent == NSStreamEventErrorOccurred) {
        if (_inputStream == nil) {
            return;
        }
        NSError *error = [_inputStream streamError];
        if ([error streamStatusCode] == 0x40) {
            return;
        }
        [self HSAFTPConnection_stopEnumerating];
        error = [[self class] HSAFTPConnection_localizedErrorForInputStreamError:error];
        if ([[self delegate] respondsToSelector:@selector(connection:didFailWithError:)]) {
            [[self delegate] connection:self didFailWithError:error];
        }
        return;
    }
    if (aEvent != NSStreamEventHasBytesAvailable) {
        return;
    }
    uint8_t *buffer = NSZoneMalloc(NULL, 0x80000);
    NSInteger count = [_inputStream read:buffer maxLength:0x80000];
    if (count == 0) {
        [self HSAFTPConnection_stopEnumerating];
        [self HSAFTPConnection_enumerateNextURL];
    } else if (count > 0) {
        if (_readData == nil) {
            _readData = [[NSMutableData alloc] init];
        }
        [_readData appendBytes:buffer length:count];
        [self HSAFTPConnection_parseReadData];
    }
    NSZoneFree(NULL, buffer);
}

- (void)HSAFTPConnection_parseReadData
{
    CFStringRef typeKey = kCFFTPResourceType;
    CFStringRef nameKey = kCFFTPResourceName;
    CFIndex consumed = 0;
    while (YES) {
        CFDictionaryRef parsed = NULL;
        CFIndex used = CFFTPCreateParsedResourceListing(NULL, (const UInt8 *)[_readData bytes] + consumed, (CFIndex)[_readData length] - consumed, &parsed);
        if (used < 1) {
            break;
        }
        if (parsed != NULL) {
            NSDictionary *info = [self HSAFTPConnection_transcodedResourceInformation:parsed byEncoding:NSUTF8StringEncoding];
            NSString *name = [info objectForKey:(NSString *)nameKey];
            if (![name isEqualToString:@"."] && ![name isEqualToString:@".."]) {
                int type = [[info objectForKey:(NSString *)typeKey] intValue];
                NSURL *base = [[self HSAFTPConnection_directories] objectAtIndex:_currentIndex];
                NSURL *url = [base URLByAppendingPathComponent:[info objectForKey:(NSString *)nameKey] isDirectory:(type == 4)];
                [_URLs addObject:url];
                if (type == 4 && [_URLs count] != 0) {
                    [[self HSAFTPConnection_directories] addObject:url];
                }
            }
            CFRelease(parsed);
        }
        consumed += used;
    }
    if (consumed != 0) {
        [_readData resetBytesInRange:NSMakeRange(0, consumed)];
    }
}

- (id)HSAFTPConnection_transcodedResourceInformation:(CFDictionaryRef)aInformation byEncoding:(NSStringEncoding)aEncoding
{
    CFStringRef nameKey = kCFFTPResourceName;
    NSString *name = (NSString *)CFDictionaryGetValue(aInformation, nameKey);
    if ([name length] != 0) {
        NSString *decoded = [[NSString alloc] initWithData:[name dataUsingEncoding:NSISOLatin1StringEncoding] encoding:aEncoding];
        if ([decoded length] != 0) {
            NSMutableDictionary *copy = [(NSDictionary *)aInformation mutableCopy];
            [copy setObject:decoded forKey:(NSString *)nameKey];
            [decoded release];
            return [copy autorelease];
        }
    }
    return (id)aInformation;
}

- (void)HSAFTPConnection_checkingConnectionDidEnd
{
    if ([[self delegate] respondsToSelector:@selector(connectionDidSucceed:)]) {
        [[self delegate] connectionDidSucceed:self];
    }
}

- (void)HSAFTPConnection_checkingReachabilityDidEnd
{
    if ([[self delegate] respondsToSelector:@selector(connection:didFinishChecking:)]) {
        [[self delegate] connection:self didFinishChecking:nil];
    }
}

- (void)HSAFTPConnection_checkingResourceExistingDidEnd
{
    if ([[self delegate] respondsToSelector:@selector(connection:didFinishChecking:)]) {
        [[self delegate] connection:self didFinishChecking:(id)(NSUInteger)1];
    }
}

- (void)checkConnection
{
    [self HSAFTPConnection_stopEnumerating];
    _currentIndex = -1;
    [[self HSAFTPConnection_directories] addObject:[self URL]];
    _didEndSelector = @selector(HSAFTPConnection_checkingConnectionDidEnd);
    [self HSAFTPConnection_enumerateNextURL];
}

- (void)checkReachability
{
    [self HSAFTPConnection_stopEnumerating];
    _currentIndex = -1;
    [[self HSAFTPConnection_directories] addObject:[self URL]];
    _didEndSelector = @selector(HSAFTPConnection_checkingReachabilityDidEnd);
    [self HSAFTPConnection_enumerateNextURL];
}

- (void)resourceExistsAtPath:(id)aPath
{
    if ([aPath length] == 0) {
        if ([[self delegate] respondsToSelector:@selector(connection:didFailWithError:)]) {
            NSError *error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:-1000 userInfo:nil];
            [[self delegate] connection:self didFailWithError:[[self class] localizedErrorForError:error]];
            return;
        }
    }
    [self HSAFTPConnection_stopEnumerating];
    _currentIndex = -1;
    [[self HSAFTPConnection_directories] addObject:[[self URL] URLByAppendingPathComponent:aPath]];
    _didEndSelector = @selector(HSAFTPConnection_checkingResourceExistingDidEnd);
    [self HSAFTPConnection_enumerateNextURL];
}

- (void)removeDirectory
{
    [self HSAFTPConnection_stopEnumerating];
    _currentIndex = -1;
    if (_URLs == nil) {
        _URLs = [[NSMutableSet alloc] initWithObjects:[self URL], nil];
    }
    [[self HSAFTPConnection_directories] addObject:[self URL]];
    _didEndSelector = @selector(HSAFTPConnection_removeAllResources);
    [self HSAFTPConnection_enumerateNextURL];
}

- (void)HSAFTPConnection_removeAllResources
{
    NSString *scheme = [[[self class] schemes] objectAtIndex:0];
    NSMutableSet *resources = [[NSMutableSet alloc] init];
    NSMutableSet *directories = [[NSMutableSet alloc] init];
    HSAFTPConnection *connection = self;
    [_URLs enumerateObjectsUsingBlock:^(id url, BOOL *stop) {
        NSURL *credentialed = [NSURL URLWithString:[url absoluteString] scheme:scheme port:0x7fffffff user:[connection userName] password:[connection password]];
        NSArray *components = [[credentialed absoluteString] pathComponents];
        if ([[components lastObject] isEqualToString:@"/"]) {
            [directories addObject:credentialed];
        } else {
            [resources addObject:credentialed];
        }
        if ([[components lastObject] isEqualToString:@"/"] && [[components objectAtIndex:[components count] - 2] isEqualToString:@"data"]) {
            [resources addObject:[credentialed URLByAppendingPathComponent:@".htaccess" isDirectory:NO]];
        }
    }];
    NSArray *removed = nil;
    NSError *failure = nil;
    [[self class] removeResources:resources removedURLs:&removed error:&failure];
    [resources release];
    [directories release];
    [_URLs release];
    _URLs = nil;
    [self close];
    if (failure != nil && [[self delegate] respondsToSelector:@selector(connection:didFailWithError:)]) {
        NSError *error = [NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:-3004 userInfo:nil];
        [[self delegate] connection:self didFailWithError:[[self class] localizedErrorForError:error]];
        return;
    }
    if ([[self delegate] respondsToSelector:@selector(connectionDidCompleteResourceRemoving:withSkippedResources:)]) {
        [[self delegate] connectionDidCompleteResourceRemoving:self withSkippedResources:removed];
    }
}

@end
