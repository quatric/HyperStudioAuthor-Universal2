#import "HSTemporaryFilesManager.h"

static NSString *HSTemporaryFilesManagerFolder = nil;
static HSTemporaryFilesManager *HSTemporaryFilesManagerShared = nil;

// Temporary files are counted by name; the last unregistration deletes them.
@implementation HSTemporaryFilesManager
+ (void)clean
{
    if (HSTemporaryFilesManagerFolder) {
        [[NSFileManager defaultManager] removeItemAtPath:[self tempFolderPath] error:NULL];
        [HSTemporaryFilesManagerFolder release];
        HSTemporaryFilesManagerFolder = nil;
    }
}
+ (BOOL)containsTempFileAtPath:(id)aPath
{
    return [[self sharedTemporaryFilesManager] containsTempFileAtPath:aPath];
}
+ (void)unregisterTempFileAtPath:(id)aPath
{
    [[self sharedTemporaryFilesManager] unregisterTempFileAtPath:aPath];
}
+ (void)registerIfFileIsTemp:(id)aTemp
{
    if ([self containsTempFileAtPath:aTemp])
        [self registerTempFileAtPath:aTemp];
}
+ (void)registerTempFileAtPath:(id)aPath
{
    [[self sharedTemporaryFilesManager] registerTempFileAtPath:aPath];
}
+ (id)generatedTempFilePath
{
    return [self generatedTempFilePathWithExtension:nil];
}
+ (id)generatedTempFilePathWithExtension:(id)aExtension
{
    NSString *path = [[self tempFolderPath] stringByAppendingPathComponent:[self generatedUID]];
    if (aExtension)
        path = [path stringByAppendingPathExtension:aExtension];
    return path;
}
+ (id)tempFolderPath
{
    if (!HSTemporaryFilesManagerFolder) {
        HSTemporaryFilesManagerFolder = [[NSTemporaryDirectory() stringByAppendingPathComponent:[self generatedUID]] retain];
        if (![[NSFileManager defaultManager] createDirectoryAtPath:HSTemporaryFilesManagerFolder withIntermediateDirectories:NO attributes:nil error:NULL]) {
            [HSTemporaryFilesManagerFolder release];
            HSTemporaryFilesManagerFolder = nil;
        }
    }
    return HSTemporaryFilesManagerFolder;
}
+ (id)generatedUID
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *string = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return [string autorelease];
}
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (!HSTemporaryFilesManagerShared) {
            HSTemporaryFilesManagerShared = [super allocWithZone:aZone];
            return HSTemporaryFilesManagerShared;
        }
    }
    return nil;
}
+ (id)sharedTemporaryFilesManager
{
    @synchronized(self) {
        if (!HSTemporaryFilesManagerShared)
            [[self alloc] init];
    }
    return HSTemporaryFilesManagerShared;
}
- (BOOL)containsTempFileAtPath:(id)aPath
{
    return NSMapGet([self files], [aPath lastPathComponent]) != NULL;
}
- (void)unregisterTempFileAtPath:(id)aPath
{
    NSString *name = [aPath lastPathComponent];
    NSInteger count = (NSInteger)(intptr_t)NSMapGet([self files], name) - 1;
    if (count == 0) {
        [[NSFileManager defaultManager] removeItemAtPath:aPath error:NULL];
        NSMapRemove([self files], name);
    } else if (count > 0) {
        NSMapInsert([self files], name, (void *)(intptr_t)count);
    }
}
- (void)registerTempFileAtPath:(id)aPath
{
    NSString *name = [aPath lastPathComponent];
    NSInteger count = (NSInteger)(intptr_t)NSMapGet([self files], name);
    NSMapInsert([self files], name, (void *)(intptr_t)(count + 1));
}
- (id)files
{
    if (!_files)
        _files = NSCreateMapTable(NSObjectMapKeyCallBacks, NSIntegerMapValueCallBacks, 0);
    return _files;
}
- (id)autorelease
{
    return self;
}
- (void)release
{
}
- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}
- (id)retain
{
    return self;
}
- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}
@end
