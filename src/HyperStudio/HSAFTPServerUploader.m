#import "HSAFTPServerUploader.h"
#import "HyperStudioUmbrella.h"

@interface NSError (HSAFTPServerUploaderStreamStatus)
- (NSInteger)streamStatusCode;
@end

@interface NSURL (HSAFTPServerUploaderURLBuilding)
+ (id)URLWithString:(id)aString scheme:(id)aScheme port:(int)aPort user:(id)aUser password:(id)aPassword;
@end

@interface HSError (HSAFTPServerUploaderErrors)
+ (id)errorWithError:(id)aError;
@end

@interface HSAFTPServerUploader (HSAFTPServerUploader_)
- (id)HSAFTPServerUploader_pathForRootURL:(id)aRootURL toURL:(id)aURL;
- (void)HSAFTPServerUploader_uploadFileAtURL:(id)aURL;
- (id)HSAFTPServerUploader_credentialedURLForConnection;
@end


@implementation HSAFTPServerUploader

+ (id)localizedErrorForOutputStreamError:(id)aError
{
    if (aError == nil) {
        return nil;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if ([aError userInfo] != nil) {
        [userInfo addEntriesFromDictionary:[aError userInfo]];
    }
    NSInteger status = [aError streamStatusCode];
    id result;
    switch ((unsigned int)status) {
        case 0xffffffff:
        case 0xfffffc18:
        case 0xfffee6bc:
        case 8:
        case 0x31:
        case 0x41: {
            HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
            [userInfo setObject:[provider localizedStringForKey:@"HSAInvalidFTPServerFileUploadingDescription" value:@"" table:@"Alerts"] forKey:NSLocalizedDescriptionKey];
            provider = [HSExecutableResourceProvider sharedInstance];
            [userInfo setObject:[provider localizedStringForKey:@"HSAInvalidFTPServerFileUploadingRecoverySuggestion" value:@"" table:@"Alerts"] forKey:NSLocalizedRecoverySuggestionErrorKey];
            result = [NSError errorWithDomain:[aError domain] code:[aError code] userInfo:userInfo];
            break;
        }
        default:
            result = [HSAFTPConnection localizedErrorForError:aError];
            break;
    }
    return [HSError errorWithError:result];
}

- (id)HSAFTPServerUploader_credentialedURLForConnection
{
    id connection = _connection;
    return [NSURL URLWithString:[[connection URL] absoluteString] scheme:[connection scheme] port:0x7fffffff user:[connection userName] password:[connection password]];
}

- (id)HSAFTPServerUploader_pathForRootURL:(id)aRootURL toURL:(id)aURL
{
    NSString *root = [[aRootURL URLByResolvingSymlinksInPath] absoluteString];
    NSString *path = [[aURL URLByResolvingSymlinksInPath] absoluteString];
    return [path stringByReplacingOccurrencesOfString:root withString:@""];
}

- (void)HSAFTPServerUploader_uploadFileAtURL:(id)aURL
{
    if (_uploadedResourcesURLs == nil) {
        _uploadedResourcesURLs = [[NSMutableSet alloc] init];
    }
    if (aURL == nil) {
        if ([[self delegate] respondsToSelector:@selector(serverUploaderDidFinish:)]) {
            [[self delegate] serverUploaderDidFinish:self];
        }
        _isUploading = NO;
        return;
    }
    NSString *path = [self HSAFTPServerUploader_pathForRootURL:_fileURL toURL:aURL];
    NSURL *target = [_uploadURL URLByAppendingPathComponent:path];
    if (![_skipUploadPaths containsObject:[target path]]) {
        _fileStream = [[NSInputStream alloc] initWithURL:aURL];
        [_fileStream open];
        HSAFTPConnection *connection = [[HSAFTPConnection alloc] initWithURL:target delegate:self];
        [connection useCredential:[NSURLCredential credentialWithUser:[_connection userName] password:[_connection password] persistence:NSURLCredentialPersistenceForSession]];
        [connection setPort:[_connection port]];
        [connection setIsActive:[(HSAFTPConnection *)_connection isActive]];
        [connection open];
        [_connection release];
        _connection = connection;
        [_uploadedResourcesURLs addObject:[self HSAFTPServerUploader_credentialedURLForConnection]];
    } else {
        [self HSAFTPServerUploader_uploadFileAtURL:[_URLsEnumerator nextObject]];
    }
}

- (BOOL)uploadFileAtURL:(id)aURL removeIfExist:(BOOL)aRemove error:(id *)aError
{
    if (aURL == nil || ![aURL isFileURL] || _isUploading) {
        return NO;
    }
    BOOL result = YES;
    if (aRemove) {
        NSURL *remote = [[_connection URL] URLByAppendingPathComponent:[aURL lastPathComponent]];
        result = [HSAFTPConnection removeFileAtURL:remote error:aError];
        if (!result) {
            _isUploading = NO;
            return result;
        }
    }
    [self HSAFTPServerUploader_uploadFileAtURL:aURL];
    _isUploading = NO;
    return result;
}

- (void)uploadFolderAtURL:(id)aURL removeIfExist:(BOOL)aRemove
{
    if (_isUploading) {
        return;
    }
    [_fileURL release];
    _fileURL = [aURL copy];
    [_uploadURL release];
    _uploadURL = [[_connection URL] retain];
    _isUploading = YES;
    if (aRemove) {
        [_connection removeDirectory];
    } else {
        _URLsEnumerator = [[[NSFileManager defaultManager] enumeratorAtURL:aURL includingPropertiesForKeys:nil options:0 errorHandler:nil] retain];
        [self HSAFTPServerUploader_uploadFileAtURL:aURL];
    }
}

- (void)cancel
{
    [_connection close];
    [_connection release];
    _connection = nil;
    [_fileStream close];
    [_fileStream release];
    _fileStream = nil;
    [_readData release];
    _readData = nil;
    [_fileURL release];
    _fileURL = nil;
    [_URLsEnumerator release];
    _URLsEnumerator = nil;
    _isUploading = NO;
}

- (void)cleanup
{
    [self cancel];
    [HSAFTPConnection removeResources:_uploadedResourcesURLs removedURLs:NULL error:NULL];
    [_uploadedResourcesURLs release];
    _uploadedResourcesURLs = nil;
}

- (void)connection:(id)aConnection didFailWithError:(id)aError
{
    if ([[self delegate] respondsToSelector:@selector(serverUploader:didFailWithError:)]) {
        [_uploadedResourcesURLs removeObject:[self HSAFTPServerUploader_credentialedURLForConnection]];
        [[self delegate] serverUploader:self didFailWithError:[HSError errorWithError:aError]];
    } else {
        [self cancel];
    }
}

- (void)connectionDidCompleteResourceRemoving:(id)aConnection withSkippedResources:(id)aResources
{
    _URLsEnumerator = [[[NSFileManager defaultManager] enumeratorAtURL:_fileURL includingPropertiesForKeys:nil options:0 errorHandler:nil] retain];
    _skipUploadPaths = [[NSSet setWithSet:[aResources valueForKey:@"path"]] retain];
    [self HSAFTPServerUploader_uploadFileAtURL:_fileURL];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)aEvent
{
    NSOutputStream *output = [(HSAFTPConnection *)_connection outputStream];
    if (aEvent == NSStreamEventEndEncountered) {
        [_fileStream close];
        [_fileStream release];
        _fileStream = nil;
        [_uploadedResourcesURLs addObject:[self HSAFTPServerUploader_credentialedURLForConnection]];
        [self HSAFTPServerUploader_uploadFileAtURL:[_URLsEnumerator nextObject]];
        return;
    }
    if (aEvent == NSStreamEventErrorOccurred) {
        if ([[self delegate] respondsToSelector:@selector(serverUploader:didFailWithError:)]) {
            CFErrorRef error = (CFErrorRef)CFWriteStreamCopyError((CFWriteStreamRef)output);
            [_uploadedResourcesURLs removeObject:[self HSAFTPServerUploader_credentialedURLForConnection]];
            [[self delegate] serverUploader:self didFailWithError:[HSAFTPServerUploader localizedErrorForOutputStreamError:(id)error]];
            if (error != NULL) {
                CFRelease(error);
            }
        } else {
            [self cancel];
        }
        return;
    }
    if (aEvent != NSStreamEventHasSpaceAvailable) {
        return;
    }
    [_uploadedResourcesURLs addObject:[self HSAFTPServerUploader_credentialedURLForConnection]];
    NSUInteger offset;
    if ((NSUInteger)_bufferOffset == [_readData length]) {
        uint8_t *buffer = NSZoneMalloc(NULL, 0x80000);
        NSInteger count = [_fileStream read:buffer maxLength:0x80000];
        if (count == 0) {
            NSZoneFree(NULL, buffer);
            [_fileStream close];
            [_fileStream release];
            _fileStream = nil;
            [_readData release];
            _readData = nil;
            _bufferOffset = 0;
            [self HSAFTPServerUploader_uploadFileAtURL:[_URLsEnumerator nextObject]];
            return;
        }
        if (count < 1) {
            NSZoneFree(NULL, buffer);
            if ([[self delegate] respondsToSelector:@selector(serverUploader:didFailWithError:)]) {
                [[self delegate] serverUploader:self didFailWithError:[HSError errorWithError:[_fileStream streamError]]];
            } else {
                [self cancel];
            }
            return;
        }
        [_readData release];
        _readData = [[NSMutableData alloc] initWithBytesNoCopy:buffer length:count freeWhenDone:YES];
        _bufferOffset = 0;
        offset = 0;
    } else {
        offset = _bufferOffset;
    }
    if (offset == [_readData length]) {
        return;
    }
    NSInteger written = [output write:(const uint8_t *)[_readData bytes] + _bufferOffset maxLength:[_readData length] - _bufferOffset];
    if (written >= 0) {
        _bufferOffset += written;
        return;
    }
    [_uploadedResourcesURLs removeObject:[self HSAFTPServerUploader_credentialedURLForConnection]];
    if ([[self delegate] respondsToSelector:@selector(serverUploader:didFailWithError:)]) {
        CFErrorRef error = (CFErrorRef)CFWriteStreamCopyError((CFWriteStreamRef)output);
        [[self delegate] serverUploader:self didFailWithError:[HSAFTPServerUploader localizedErrorForOutputStreamError:(id)error]];
        if (error != NULL) {
            CFRelease(error);
        }
    } else {
        [self cancel];
    }
}

- (void)dealloc
{
    [_uploadURL release];
    [_uploadedResourcesURLs release];
    [_skipUploadPaths release];
    [self cancel];
    [super dealloc];
}

@end


@implementation HSAHTML5FTPServerUploader
@end
