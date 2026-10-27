#import "HSImageMediaRepresentation.h"
// An image medium that can be purged from memory: before purging, the image
// is written to a temporary TIFF (on the save queue's thread) and read back
// from it when it's next used.
@implementation HSImageMediaRepresentation
- (void)writeDataToFileInSeparateThread
{
    [_fileNameLock lock];
    if (_fileName == nil && _image != nil) {
        id path = [HSSaveOperationQueue createUniqueFileInTempFolder];
        if ([[_image TIFFRepresentation] writeToFile:path atomically:YES])
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
// Only once the image is safely on disk.
- (void)HSImageMediaRepresentation_purgeIfNeeded
{
    [_imageLock lock];
    if (_fileName != nil && _isPurgePending) {
        [_image release];
        _image = nil;
        [[HSPurgableObjectRegistry sharedRegistry] purgableObjectDidPurgeOrDie:self];
    }
    [_imageLock unlock];
}
// The save queue releases the object after writing it.
- (void)prepareToPurge
{
    [[HSSaveOperationQueue sharedQueue] saveObjectOnSeparateThread:(NSUInteger)[self retain]];
}
// Memory held by the representations. The original estimates other kinds as
// bitsPerSample·width·height / 2 (kept).
- (NSUInteger)purgableSize
{
    NSUInteger size = 0;
    for (NSImageRep *rep in [_image representations]) {
        if ([rep isKindOfClass:[NSBitmapImageRep class]])
            size += [(NSBitmapImageRep *)rep bytesPerRow] * [rep pixelsHigh];
        else if ([rep isKindOfClass:[NSEPSImageRep class]])
            size += [[(NSEPSImageRep *)rep EPSRepresentation] length];
        else if ([rep isKindOfClass:[NSPDFImageRep class]])
            size += [[(NSPDFImageRep *)rep PDFRepresentation] length];
        else if ([rep isKindOfClass:[NSPICTImageRep class]])
            size += [[(NSPICTImageRep *)rep PICTRepresentation] length];
        else
            size += ((NSUInteger)[rep bitsPerSample] * [rep pixelsWide] * [rep pixelsHigh]) >> 1;
    }
    return size;
}
- (id)mediaType
{
    return @"png";
}
- (id)mediaData
{
    if ([[self mediaType] isEqualToString:@"png"])
        return [[self image] hyperPNGRepresentation];
    return [[self image] hyperTIFFRepresentation];
}
- (id)image
{
    [_imageLock lock];
    if (_image == nil && _fileName != nil)
        _image = [[NSImage alloc] initWithContentsOfFile:_fileName];
    _isPurgePending = 0;
    [_imageLock unlock];
    [[HSPurgableObjectRegistry sharedRegistry] purgableObjectDidUseData:self];
    return _image;
}
- (void)dealloc
{
    [[HSPurgableObjectRegistry sharedRegistry] purgableObjectDidPurgeOrDie:self];
    if (_fileName != nil)
        [[HSSaveOperationQueue sharedQueue] removeFileAtPath:_fileName];
    [_imageLock release];
    [_fileNameLock release];
    [_image release];
    [_fileName release];
    [super dealloc];
}
- (id)initWithImage:(id)aImage
{
    self = [super init];
    if (self != nil) {
        _image = [aImage retain];
        _imageLock = [[NSRecursiveLock alloc] init];
        _fileNameLock = [[NSRecursiveLock alloc] init];
        [[HSPurgableObjectRegistry sharedRegistry] purgableObjectDidUseData:self];
    }
    return self;
}
@end
