#import "HyperPlayerBasePrefix.h"


@interface NSFileManager (HSExtensions)
- (id)hyperResolveAliasAtPath:(id)aPath;
- (BOOL)isHyperAliasAtPath:(id)aPath;
- (BOOL)hyperIsFileInvisibleAtPath:(id)aPath;
- (BOOL)hyperIsTextForPath:(id)aPath;
- (BOOL)hyperIsFileAbleToReadFromPath:(id)aPath document:(id)aDocument error:(id *)aError;
- (BOOL)hyperIsFileWritableAtPath:(id)aPath checkDirectory:(BOOL)aDirectory;
- (BOOL)hyperIsFileWritableAtPath:(id)aPath;
- (BOOL)hyperIsFileWritableAtPath:(id)aPath directory:(BOOL *)aDirectory;
- (BOOL)hyperIsFileReadableAtPath:(id)aPath;
- (BOOL)hyperIsReadableFileAtPath:(id)aPath showAlert:(BOOL)aAlert error:(id *)aError;
- (NSInteger)resourceTypesCountAtPath:(id)aPath;
- (BOOL)forkSizesAtPath:(id)aPath dataLogicalSize:(unsigned long long *)aSize rsrcLogicalSize:(unsigned long long *)aSize2;
- (BOOL)copyFileWithResFork:(id)aFork toPath:(id)aPath;
- (BOOL)removeDirectoryAtPath:(id)aPath;
- (BOOL)createDirectoryAtPath:(id)aPath attributes:(id)aAttributes createIntermediate:(BOOL)aIntermediate;
- (id)hyperFileTypeAtPath:(id)aPath;
- (void)moveFileToUserTrash:(id)aTrash createUniqueFileInTrash:(BOOL)aTrash2;
@end

