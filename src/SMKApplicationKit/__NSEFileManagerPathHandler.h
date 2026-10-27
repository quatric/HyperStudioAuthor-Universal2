#import "SMKApplicationKitPrefix.h"


@interface __NSEFileManagerPathHandler : NSObject
{
    id _delegate;
    NSString *_sourcePath;
    NSString *_destinationPath;
    int _errorCode;
    NSError *_error;
}
- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError;
- (id)error;
- (void)dealloc;
- (id)initWithErrorCode:(NSInteger)aCode delegate:(id)aDelegate sourcePath:(id)aPath destinationPath:(id)aPath2;
- (id)init;
@end

@interface __NSEFileManagerURLHandler : NSObject
{
    id _delegate;
    NSURL *_sourceURL;
    NSURL *_destinationURL;
    int _errorCode;
    NSError *_error;
}
- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError;
- (id)error;
- (void)dealloc;
- (id)initWithErrorCode:(NSInteger)aCode delegate:(id)aDelegate sourceURL:(id)aURL destinationURL:(id)aURL2;
- (id)init;
@end

@interface __NSEFileManagerPathDelegate : NSObject
{
    id _delegate;
    NSURL *_sourceURL;
    NSURL *_destinationURL;
}
- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError removingItemAtPath:(id)aPath;
- (BOOL)fileManager:(id)aManager shouldRemoveItemAtPath:(id)aPath;
- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError linkingItemAtPath:(id)aPath toPath:(id)aPath2;
- (BOOL)fileManager:(id)aManager shouldLinkItemAtPath:(id)aPath toPath:(id)aPath2;
- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError movingItemAtPath:(id)aPath toPath:(id)aPath2;
- (BOOL)fileManager:(id)aManager shouldMoveItemAtPath:(id)aPath toPath:(id)aPath2;
- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError copyingItemAtPath:(id)aPath toPath:(id)aPath2;
- (BOOL)fileManager:(id)aManager shouldCopyItemAtPath:(id)aPath toPath:(id)aPath2;
- (id)delegate;
- (void)dealloc;
- (id)initWithDelegate:(id)aDelegate sourceURL:(id)aURL destinationURL:(id)aURL2;
- (id)init;
@end

@interface __NSEFileManagerURLDelegate : NSObject
{
    id _delegate;
}
- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError linkingItemAtURL:(id)aURL toURL:(id)aURL2;
- (BOOL)fileManager:(id)aManager shouldLinkItemAtURL:(id)aURL toURL:(id)aURL2;
- (BOOL)fileManager:(id)aManager shouldProceedAfterError:(id)aError copyingItemAtURL:(id)aURL toURL:(id)aURL2;
- (id)delegate;
- (id)initWithDelegate:(id)aDelegate;
- (id)init;
@end

@interface NSDirectoryEnumerator (NSEDirectoryEnumeratorLoading)
+ (void)load;
@end

@interface NSFileManager (NSEFileManagerLoading)
+ (void)load;
@end

