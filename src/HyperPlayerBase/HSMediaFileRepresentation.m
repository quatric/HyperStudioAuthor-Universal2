#import "HSMediaFileRepresentation.h"
// A medium backed by a file on disk. The file's data is loaded lazily and can
// be purged again; an FSRef is kept so the path follows the file if it is
// moved, and temporary files are registered with HSTemporaryFilesManager.
@implementation HSMediaFileRepresentation

- (void)purge
{
    if (_filePath) {
        [_data release];
        _data = nil;
        [[HSPurgableObjectRegistry sharedRegistry] purgableObjectDidPurgeOrDie:self];
    }
}

- (void)prepareToPurge
{
}

- (NSUInteger)purgableSize
{
    return [_data length];
}

- (id)debugDescription
{
    return [NSString stringWithFormat:@"%@ path='%@' removeWhenDone=%@",
            [self description], [self path], _removeWhenDone ? @"YES" : @"NO"];
}

- (void)updatePathFromFSRefIfNeeded
{
    if (!_fsRefValid || [self isFilePathValid])
        return;
    CFURLRef url = CFURLCreateFromFSRef(kCFAllocatorDefault, &_fsRef);
    if (!url)
        return;
    [HSTemporaryFilesManager unregisterTempFileAtPath:_filePath];
    [_filePath release];
    _filePath = [[(NSURL *)url path] retain];
    if (_removeWhenDone || [HSTemporaryFilesManager containsTempFileAtPath:_filePath])
        [HSTemporaryFilesManager registerTempFileAtPath:_filePath];
    CFRelease(url);
}

- (BOOL)isFilePathValid
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!_filePath || ![fileManager fileExistsAtPath:_filePath]
        || ![fileManager isReadableFileAtPath:_filePath])
        return NO;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:[_filePath stringByResolvingSymlinksInPath] error:NULL];
    return [attributes fileSize] != 0;
}

- (id)GPSDictionary
{
    // (The original first asked a QuickTime graphics importer for the GPS
    // metadata and only fell back to ImageIO; QuickTime isn't available to
    // 64-bit code, so ImageIO is used directly.)
    NSString *path = [self resolvedPath];
    if (!path)
        return nil;
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path,
                                                 kCFURLPOSIXPathStyle, false);
    if (!url)
        return nil;
    id result = nil;
    CGImageSourceRef source = CGImageSourceCreateWithURL(url, NULL);
    CFRelease(url);
    if (source) {
        if (CGImageSourceGetCount(source) != 0) {
            CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
            if (properties) {
                result = [[[(NSDictionary *)properties objectForKey:(id)kCGImagePropertyGPSDictionary]
                           retain] autorelease];
                CFRelease(properties);
            }
        }
        // (The original leaked the image source.)
        CFRelease(source);
    }
    return result;
}

- (BOOL)isValid
{
    if (_data)
        return YES;
    [self updatePathFromFSRefIfNeeded];
    return [self isFilePathValid];
}

- (id)mediaType
{
    if (!_mediaType) {
        NSString *path = [self path];
        NSString *type = [[NSFileManager defaultManager] hyperFileTypeAtPath:path];
        if (![[HSNewMediaAccessor supportedMediaTypes] containsObject:type])
            type = [[path pathExtension] lowercaseString];
        _mediaType = [type retain];
    }
    return _mediaType;
}

- (id)mediaData
{
    if (!_data) {
        [self updatePathFromFSRefIfNeeded];
        if ([self isFilePathValid])
            _data = [[NSData allocWithZone:[self zone]] initWithContentsOfFile:_filePath
                                                                       options:NSDataReadingMappedIfSafe
                                                                         error:NULL];
    }
    if (!_data)
        return nil;
    [[HSPurgableObjectRegistry sharedRegistry] purgableObjectDidUseData:self];
    return _data;
}

- (id)resolvedPath
{
    [self updatePathFromFSRefIfNeeded];
    return _filePath;
}

- (id)path
{
    return _filePath;
}

- (void)dealloc
{
    [[HSPurgableObjectRegistry sharedRegistry] purgableObjectDidPurgeOrDie:self];
    // A representation sharing another's temp file leaves its removal to that one.
    if (!_fileRepresentation)
        [HSTemporaryFilesManager unregisterTempFileAtPath:_filePath];
    [_fileRepresentation release];
    [_filePath release];
    [_data release];
    [_mediaType release];
    [super dealloc];
}

- (id)initWithRepresentation:(id)aRepresentation mediaType:(id)aType
{
    HSMediaFileRepresentation *representation = aRepresentation;
    self = [self initWithPath:[representation path]];
    if (self) {
        _mediaType = [aType copy];
        if (representation->_removeWhenDone)
            _fileRepresentation = [representation retain];
    }
    return self;
}

- (id)initWithPath:(id)aPath
{
    return [self initWithPath:aPath removeWhenDone:NO];
}

- (id)initWithPath:(id)aPath removeWhenDone:(BOOL)aDone
{
    self = [super init];
    if (!self)
        return nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:aPath]
        || ![fileManager hyperIsReadableFileAtPath:aPath showAlert:YES error:NULL]) {
        [self release];
        return nil;
    }
    _filePath = [aPath retain];
    _removeWhenDone = aDone;
    if (aDone || [HSTemporaryFilesManager containsTempFileAtPath:_filePath])
        [HSTemporaryFilesManager registerTempFileAtPath:_filePath];
    _fsRefValid = CFURLGetFSRef((CFURLRef)[NSURL fileURLWithPath:_filePath], &_fsRef);
    return self;
}

@end
