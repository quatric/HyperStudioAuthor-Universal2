#import "HSANetworkConnection.h"

@implementation HSANetworkConnection

+ (NSUInteger)defaultPort
{
    return 80;
}

+ (id)schemes
{
    return [NSArray arrayWithObjects:@"http", nil];
}

+ (id)localizedErrorForError:(id)aError
{
    return aError;
}

+ (BOOL)removeFileAtURL:(id)aURL error:(id *)aError
{
    BOOL removed = NO;
    if (aURL != nil && ![aURL isFileURL] && [[[self class] schemes] containsObject:[aURL scheme]]) {
        SInt32 errorCode = 0;
        removed = CFURLDestroyResource((CFURLRef)aURL, &errorCode);
        if (errorCode != 0 && aError != NULL) {
            *aError = [NSError errorWithDomain:NSURLErrorDomain code:errorCode userInfo:nil];
        }
    }
    return removed;
}

// Removes the files first and then the directories, deepest first. Stops at the first failure when the caller wants the error.
+ (BOOL)removeResources:(id)aResources removedURLs:(id *)aURLs error:(id *)aError
{
    if ([aResources count] == 0) {
        return NO;
    }
    NSMutableSet *removed = [NSMutableSet set];
    NSMutableArray *directories = [[NSMutableArray alloc] init];
    __block NSError *failure = nil;
    BOOL wantsError = aError != NULL;
    Class connectionClass = self;
    [aResources enumerateObjectsUsingBlock:^(id url, NSUInteger index, BOOL *stop) {
        if (CFURLHasDirectoryPath((CFURLRef)url)) {
            [directories addObject:url];
            return;
        }
        NSError *error = nil;
        BOOL success = [connectionClass removeFileAtURL:url error:&error];
        if (success && error == nil) {
            [removed addObject:url];
        } else if (wantsError && [[url scheme] isEqualToString:@"ftp"] && ![[url lastPathComponent] isEqualToString:@".htaccess"]) {
            failure = [error retain];
            *stop = YES;
        }
    }];
    if (failure == nil && [directories count] != 0) {
        [directories sortUsingComparator:^NSComparisonResult(id first, id second) {
            NSUInteger firstDepth = [[first pathComponents] count];
            NSUInteger secondDepth = [[second pathComponents] count];
            if (firstDepth == secondDepth) {
                return NSOrderedSame;
            }
            return firstDepth < secondDepth ? NSOrderedDescending : NSOrderedAscending;
        }];
        [directories enumerateObjectsUsingBlock:^(id url, NSUInteger index, BOOL *stop) {
            NSError *error = nil;
            BOOL success = [connectionClass removeFileAtURL:url error:&error];
            if (!success || error != nil) {
                if (!wantsError) {
                    [removed addObject:url];
                } else {
                    failure = [error retain];
                    *stop = YES;
                }
            }
        }];
    }
    [directories release];
    if (aError != NULL && failure != nil) {
        *aError = failure;
    }
    [failure autorelease];
    if (aURLs != NULL) {
        *aURLs = removed;
    }
    return failure == nil;
}

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithURL:(id)aURL delegate:(id)aDelegate
{
    if ([aURL isFileURL]) {
        [self release];
        return nil;
    }
    self = [super init];
    if (self != nil) {
        _URL = [aURL retain];
        _delegate = aDelegate;
    }
    return self;
}

- (void)dealloc
{
    [_URL release];
    [_credential release];
    [super dealloc];
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)URL
{
    return _URL;
}

- (id)scheme
{
    return [_URL scheme];
}

- (int)port
{
    return _port;
}

- (void)setPort:(int)aPort
{
    _port = aPort;
}

- (id)userName
{
    return [_credential user];
}

- (id)password
{
    return [_credential password];
}

- (void)useCredential:(id)aCredential
{
    if (_credential != aCredential && [[aCredential user] length] != 0) {
        [_credential release];
        _credential = [aCredential retain];
    }
}

- (void)checkConnection
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)checkReachability
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)removeDirectory
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)resourceExistsAtPath:(id)aPath
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
