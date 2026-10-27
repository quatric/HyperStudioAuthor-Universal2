#import "HyperPlayerBasePrefix.h"
#import "HSMediaRepresentation.h"


@interface HSMediaDataRepresentation : HSMediaRepresentation <HSPurgableObject, BTPurgableObject, NSObject, HSSaveOperationQueueObject>
{
    NSData *_data;
    NSString *_mediaType;
    NSString *_fileName;
    NSRecursiveLock *_dataLock;
    NSRecursiveLock *_fileNameLock;
    unsigned int _isPurgePending:1;
}
- (void)writeDataToFileInSeparateThread;
- (void)purge;
- (void)HSImageMediaRepresentation_purgeIfNeeded;
- (void)prepareToPurge;
- (NSUInteger)purgableSize;
- (id)GPSDictionary;
- (id)mediaType;
- (id)mediaData;
- (void)dealloc;
- (id)initWithRepresentation:(id)aRepresentation mediaType:(id)aType;
- (id)initWithData:(id)aData mediaType:(id)aType;
@end

