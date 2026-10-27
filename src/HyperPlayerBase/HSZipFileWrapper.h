#import "HyperPlayerBasePrefix.h"


@interface HSZipFileWrapper : NSFileWrapper
{
    NSString *_filePath;
}
- (id)filename;
- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames;
- (id)hyperContentFilePath;
- (id)regularFileContents;
- (id)initWithPath:(id)aPath;
- (void)dealloc;
@end

@interface NSFileWrapper (FilePath)
- (id)hyperContentFilePath;
@end

