#import "HyperPlayerBasePrefix.h"


@interface HSSaveOperationQueue : NSObject <HSSaveOperationQueue>
{
}
+ (void)cleanupTempFolder;
+ (id)createUniqueFileInTempFolder;
+ (id)tempFolderPath;
+ (id)sharedQueue;
+ (void)operationThread;
- (void)removeFileAtPath:(id)aPath;
- (void)saveObjectOnSeparateThread:(NSUInteger)aThread;
@end

