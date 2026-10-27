#import "HyperPlayerBasePrefix.h"
#import "HSMediaRepresentation.h"


@interface HSImageMediaRepresentation : HSMediaRepresentation <HSPurgableObject, BTPurgableObject, NSObject, HSSaveOperationQueueObject>
{
    NSImage *_image;
    NSString *_fileName;
    NSRecursiveLock *_imageLock;
    NSRecursiveLock *_fileNameLock;
    unsigned int _isPurgePending:1;
}
- (void)writeDataToFileInSeparateThread;
- (void)purge;
- (void)HSImageMediaRepresentation_purgeIfNeeded;
- (void)prepareToPurge;
- (NSUInteger)purgableSize;
- (id)mediaType;
- (id)mediaData;
- (id)image;
- (void)dealloc;
- (id)initWithImage:(id)aImage;
@end

