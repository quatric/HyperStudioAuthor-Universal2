#import "HyperPlayerBasePrefix.h"


@interface HSTemporaryFilesManager : NSObject
{
    NSMapTable *_files;
}
+ (void)clean;
+ (BOOL)containsTempFileAtPath:(id)aPath;
+ (void)unregisterTempFileAtPath:(id)aPath;
+ (void)registerIfFileIsTemp:(id)aTemp;
+ (void)registerTempFileAtPath:(id)aPath;
+ (id)generatedTempFilePath;
+ (id)generatedTempFilePathWithExtension:(id)aExtension;
+ (id)tempFolderPath;
+ (id)generatedUID;
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedTemporaryFilesManager;
- (BOOL)containsTempFileAtPath:(id)aPath;
- (void)unregisterTempFileAtPath:(id)aPath;
- (void)registerTempFileAtPath:(id)aPath;
- (id)files;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

