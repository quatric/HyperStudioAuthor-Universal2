#import "HSSaveOperationQueue.h"
#include <pthread.h>

static NSConnection *sConnection = nil;
static HSSaveOperationQueue *sQueue = nil;
static NSThread * volatile sOperationThread = nil;
static NSString *sTempFolderPath = nil;
static pthread_once_t sOnce = PTHREAD_ONCE_INIT;
static pthread_mutex_t sMutex;

static void HSSaveOperationQueueInitMutex(void)
{
    pthread_mutex_init(&sMutex, NULL);
}

// Saves (and removals of files) done on a thread of their own, reached
// through a connection (the root proxy) from other threads; plus a temporary
// folder of the process for the files saved.
@implementation HSSaveOperationQueue
+ (void)cleanupTempFolder
{
    if (sTempFolderPath == nil || pthread_mutex_lock(&sMutex) != 0)
        return;
    if (sTempFolderPath != nil) {
        [[NSFileManager defaultManager] removeItemAtPath:sTempFolderPath error:NULL];
        [sTempFolderPath release];
        sTempFolderPath = nil;
    }
    pthread_mutex_unlock(&sMutex);
}
+ (id)createUniqueFileInTempFolder
{
    NSString *template = [[self tempFolderPath] stringByAppendingPathComponent:@"hsmrXXXXXXXXXXXXXXXXXXXX"];
    const char *cTemplate = [template cStringUsingEncoding:NSUTF8StringEncoding];
    if (cTemplate == NULL)
        return nil;
    char *path = strdup(cTemplate);
    if (path == NULL)
        return nil;
    NSString *result = nil;
    int file = mkstemp(path);
    if (file != -1) {
        result = [NSString stringWithUTF8String:path];
        close(file);
    }
    free(path);
    return result;
}
+ (id)tempFolderPath
{
    if (sTempFolderPath == nil && pthread_once(&sOnce, HSSaveOperationQueueInitMutex) == 0
        && pthread_mutex_lock(&sMutex) == 0) {
        if (sTempFolderPath == nil) {
            NSString *name = [NSString hyperUIDString];
            if (name != nil) {
                sTempFolderPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:name] retain];
                if (sTempFolderPath != nil
                    && ![[NSFileManager defaultManager] createDirectoryAtPath:sTempFolderPath withIntermediateDirectories:NO attributes:nil error:NULL]) {
                    [sTempFolderPath release];
                    sTempFolderPath = nil;
                }
            }
        }
        pthread_mutex_unlock(&sMutex);
    }
    return sTempFolderPath;
}
// The queue itself on its thread, its proxy elsewhere. The first call
// starts the thread and waits for it.
+ (id)sharedQueue
{
    if (sQueue == nil && pthread_once(&sOnce, HSSaveOperationQueueInitMutex) == 0
        && pthread_mutex_lock(&sMutex) == 0) {
        NSPort *receivePort, *sendPort;
        if (sQueue == nil && (receivePort = [NSPort port]) != nil && (sendPort = [NSPort port]) != nil) {
            sConnection = [[NSConnection alloc] initWithReceivePort:receivePort sendPort:sendPort];
            if (sConnection != nil) {
                [sConnection enableMultipleThreads];
                [NSThread detachNewThreadSelector:@selector(operationThread) toTarget:[HSSaveOperationQueue class] withObject:nil];
                while (sOperationThread == nil)
                    ;
            }
        }
        pthread_mutex_unlock(&sMutex);
    }
    if ([NSThread currentThread] == sOperationThread)
        return sQueue;
    id proxy = [sConnection rootProxy];
    [proxy setProtocolForProxy:@protocol(HSSaveOperationQueue)];
    return proxy;
}
+ (void)operationThread
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSConnection *connection = [NSConnection connectionWithReceivePort:[sConnection sendPort] sendPort:[sConnection receivePort]];
    if (connection != nil) {
        sQueue = [[self alloc] init];
        if (sQueue != nil) {
            [connection setRootObject:sQueue];
            sOperationThread = [NSThread currentThread];
            [[NSRunLoop currentRunLoop] run];
            sOperationThread = nil;
        }
    }
    [pool release];
}
- (void)removeFileAtPath:(id)aPath
{
    [[NSFileManager defaultManager] removeItemAtPath:aPath error:NULL];
}
// The object travels as a number so it isn't proxied; it was retained for
// the queue.
- (void)saveObjectOnSeparateThread:(NSUInteger)aThread
{
    id object = (id)aThread;
    [object writeDataToFileInSeparateThread];
    [object release];
}
@end
