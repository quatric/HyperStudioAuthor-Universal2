#import "HyperPlayerBasePrefix.h"


@interface HSZipWrapper : NSFileWrapper
{
    NSInputStream *_inputStream;
    unsigned int _stackSize;
    NSMutableArray *_fileHeaders;
    id _delegate;
}
- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError;
- (id)compressedData:(id)aData withCompressionLevel:(NSUInteger)aLevel;
- (BOOL)scanLocalHeader;
- (void)scanZipFileInConsecutiveOrderWithDeclaredEntriesCount:(NSUInteger)aCount searchEndPosition:(NSUInteger)aPosition;
- (BOOL)addFileWrapperForPath:(id)aPath withEntry:(struct SZipFileInfo)aEntry;
- (id)dataForEntry:(struct SZipFileInfo)aEntry;
- (BOOL)writeEntry:(struct SZipFileInfo)aEntry toStream:(id)aStream;
- (id)createStringFromFilenameRecord:(void *)aRecord count:(NSInteger)aCount;
- (NSRange)rangeOfData:(id)aData options:(NSUInteger)aOptions range:(NSRange)aRange;
- (id)subdataWithRange:(NSRange)aRange;
- (NSUInteger)writeFileWrapper:(id)aWrapper parentFileWrapper:(id)aWrapper2 parentPath:(id)aPath outStream:(id)aStream;
- (BOOL)writeFileWrapper:(id)aWrapper parentFileWrapper:(id)aWrapper2 parentPath:(id)aPath outStream:(id)aStream byteWritten:(unsigned int *)aWritten error:(id *)aError;
- (NSUInteger)writeFileWrappers:(id)aWrappers parentFileWrapper:(id)aWrapper parentPath:(id)aPath outStream:(id)aStream;
- (BOOL)writeFileWrappers:(id)aWrappers parentFileWrapper:(id)aWrapper parentPath:(id)aPath outStream:(id)aStream byteWritten:(unsigned int *)aWritten error:(id *)aError;
- (BOOL)writeDataFromFile:(id)aFile toStream:(id)aStream;
- (BOOL)writeDataFromStream:(id)aStream toStream:(id)aStream2;
- (BOOL)updateFromPath:(id)aPath;
- (id)serializedRepresentation;
- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames;
- (BOOL)hyperWriteToURL:(id)aURL atomically:(BOOL)aAtomically updateFilenames:(BOOL)aFilenames error:(id *)aError;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)initSymbolicLinkWithDestination:(id)aDestination;
- (id)initSymbolicLinkWithDestination:(id)aDestination withDelegate:(id)aDelegate;
- (id)initWithPath:(id)aPath;
- (id)initWithPath:(id)aPath withDelegate:(id)aDelegate;
- (id)initRegularFileWithContents:(id)aContents;
- (id)initRegularFileWithContents:(id)aContents withDelegate:(id)aDelegate;
- (id)initWithInputStream:(id)aStream withDelegate:(id)aDelegate;
- (void)dealloc;
@end

@interface HSFileHeader : NSObject
{
    struct SFileHeader _fileHeader;
    NSData *_fileNameData;
}
- (id)fileNameData;
- (struct SFileHeader)fileHeader;
- (void)dealloc;
- (id)initWithFileHeader:(struct SFileHeader)aHeader fileNameData:(id)aData;
@end

