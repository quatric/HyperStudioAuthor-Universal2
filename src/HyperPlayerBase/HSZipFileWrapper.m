#import "HSZipFileWrapper.h"
// A file wrapper of a file's contents, read when needed; a temporary file
// is removed with the wrapper.
@implementation HSZipFileWrapper
- (id)filename
{
    id filename = [super filename];
    if (filename == nil)
        filename = [self preferredFilename];
    return filename;
}
- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames
{
    return [[self regularFileContents] writeToFile:aFile atomically:aAtomically];
}
- (id)hyperContentFilePath
{
    return _filePath;
}
- (id)regularFileContents
{
    if (_filePath == nil)
        return [super regularFileContents];
    return [NSData dataWithContentsOfFile:_filePath];
}
- (id)initWithPath:(id)aPath
{
    self = [super init];
    if (self != nil) {
        _filePath = [aPath retain];
        [HSTemporaryFilesManager registerIfFileIsTemp:aPath];
    }
    return self;
}
- (void)dealloc
{
    [HSTemporaryFilesManager unregisterTempFileAtPath:_filePath];
    [_filePath release];
    [super dealloc];
}
@end
@implementation NSFileWrapper (FilePath)
- (id)hyperContentFilePath
{
    return nil;
}
@end
