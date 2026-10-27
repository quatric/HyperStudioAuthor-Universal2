#import "HSMediaDataRepresentation.h"
// Media kept as data of a type ("pdf" for PDF data whatever it's called),
// purgeable: when memory runs short the data is written to a temporary file
// (on the save queue's thread) and dropped, then read back on the next use.
@implementation HSMediaDataRepresentation
- (void)writeDataToFileInSeparateThread
{
    [_fileNameLock lock];
    if (_fileName == nil && _data != nil) {
        NSString *path = [HSSaveOperationQueue createUniqueFileInTempFolder];
        if ([_data writeToFile:path atomically:NO])
            _fileName = [path retain];
    }
    [_fileNameLock unlock];
    [self HSImageMediaRepresentation_purgeIfNeeded];
}
- (void)purge
{
    _isPurgePending = 1;
    [self HSImageMediaRepresentation_purgeIfNeeded];
}
// Drops the data once it's in a file and a purge is still wanted.
- (void)HSImageMediaRepresentation_purgeIfNeeded
{
    [_dataLock lock];
    if (_fileName != nil && _isPurgePending) {
        [_data release];
        _data = nil;
        [[HSPurgableObjectRegistry sharedRegistry] purgableObjectDidPurgeOrDie:self];
    }
    [_dataLock unlock];
}
// The queue sends writeDataToFileInSeparateThread and releases it (the object
// is passed as a number so it isn't proxied).
- (void)prepareToPurge
{
    [[HSSaveOperationQueue sharedQueue] saveObjectOnSeparateThread:(NSUInteger)[self retain]];
}
- (NSUInteger)purgableSize
{
    return [_data length];
}
// From the image's properties. The original first asks a QuickTime graphics
// importer for the GPS user data (dropped: no QuickTime).
- (id)GPSDictionary
{
    NSData *data = [self mediaData];
    if (data == nil)
        return nil;
    NSDictionary *result = nil;
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)_mediaType, kUTTypeImage);
    if (type != NULL) {
        const void *keys[] = {kCGImageSourceTypeIdentifierHint};
        const void *values[] = {type};
        CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault, keys, values, 1, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFRelease(type);
        if (options != NULL) {
            CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, options);
            CFRelease(options);
            if (source != NULL) {
                if (CGImageSourceGetCount(source) != 0) {
                    CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
                    if (properties != NULL) {
                        result = [[(id)CFDictionaryGetValue(properties, kCGImagePropertyGPSDictionary) retain] autorelease];
                        CFRelease(properties);
                    }
                }
                // not released in the original
                CFRelease(source);
            }
        }
    }
    return result;
}
- (id)mediaType
{
    return _mediaType;
}
// Read back (mapped) when purged; using it cancels a pending purge.
- (id)mediaData
{
    [_dataLock lock];
    if (_data == nil && _fileName != nil)
        _data = [[NSData allocWithZone:[self zone]] initWithContentsOfFile:_fileName options:NSDataReadingMappedIfSafe error:NULL];
    _isPurgePending = 0;
    [_dataLock unlock];
    [[HSPurgableObjectRegistry sharedRegistry] purgableObjectDidUseData:self];
    return _data;
}
- (void)dealloc
{
    [[HSPurgableObjectRegistry sharedRegistry] purgableObjectDidPurgeOrDie:self];
    if (_fileName != nil)
        [[HSSaveOperationQueue sharedQueue] removeFileAtPath:_fileName];
    [_dataLock release];
    [_fileNameLock release];
    [_data release];
    [_mediaType release];
    [_fileName release];
    [super dealloc];
}
- (id)initWithRepresentation:(id)aRepresentation mediaType:(id)aType
{
    return [self initWithData:[aRepresentation mediaData] mediaType:aType];
}
// The original never creates the locks (messages to nil, so no locking);
// they're created here.
- (id)initWithData:(id)aData mediaType:(id)aType
{
    self = [super init];
    if (self != nil) {
        _data = [aData retain];
        _mediaType = [([NSPDFImageRep canInitWithData:aData] ? @"pdf" : aType) retain];
        _dataLock = [NSRecursiveLock new];
        _fileNameLock = [NSRecursiveLock new];
        [[HSPurgableObjectRegistry sharedRegistry] purgableObjectDidUseData:self];
    }
    return self;
}
@end
