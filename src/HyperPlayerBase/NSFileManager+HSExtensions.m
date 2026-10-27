#import "NSFileManager+HSExtensions.h"
#import <copyfile.h>

// File helpers, mostly over the Carbon File Manager and Launch Services.
@implementation NSFileManager (HSExtensions)
// The original of a Finder alias (nil if it isn't one or can't be
// resolved; no UI, no mounting).
- (id)hyperResolveAliasAtPath:(id)aPath
{
    if (aPath == nil || ![self isHyperAliasAtPath:aPath])
        return nil;
    CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)aPath, kCFURLPOSIXPathStyle, false);
    if (url == NULL)
        return nil;
    NSString *resolved = nil;
    FSRef ref;
    Boolean isFolder, wasAliased = false;
    CFURLGetFSRef(url, &ref);
    if (FSResolveAliasFileWithMountFlags(&ref, true, &isFolder, &wasAliased, kResolveAliasFileNoUI) == noErr && wasAliased) {
        CFURLRef resolvedURL = CFURLCreateFromFSRef(NULL, &ref);
        if (resolvedURL != NULL) {
            resolved = (NSString *)CFURLCopyFileSystemPath(resolvedURL, kCFURLPOSIXPathStyle);
            CFRelease(resolvedURL);
        }
    }
    CFRelease(url);
    return [resolved autorelease];
}
// An alias file, not a symbolic link.
- (BOOL)isHyperAliasAtPath:(id)aPath
{
    LSItemInfoRecord info = { 0 };
    LSCopyItemInfoForURL((CFURLRef)[NSURL fileURLWithPath:aPath], kLSRequestAllFlags, &info);
    BOOL isAlias = (info.flags & kLSItemInfoIsAliasFile) != 0 && [aPath isEqual:[aPath stringByResolvingSymlinksInPath]];
    if (info.extension != NULL)
        CFRelease(info.extension);
    return isAlias;
}
// Dot files, invisible files, and anything Launch Services can't tell.
- (BOOL)hyperIsFileInvisibleAtPath:(id)aPath
{
    if ([[aPath lastPathComponent] hasPrefix:@"."])
        return YES;
    LSItemInfoRecord info = { 0 };
    LSCopyItemInfoForURL((CFURLRef)[NSURL fileURLWithPath:aPath], kLSRequestAllInfo, &info);
    BOOL invisible = info.flags == 0 || (info.flags & kLSItemInfoIsInvisible) != 0;
    if (info.extension != NULL)
        CFRelease(info.extension);
    return invisible;
}
// By extension, else by HFS type.
- (BOOL)hyperIsTextForPath:(id)aPath
{
    NSString *type = [[aPath pathExtension] length] != 0 ? [aPath pathExtension] : [self hyperFileTypeAtPath:aPath];
    return [[NSAttributedString textUnfilteredFileTypes] containsObject:type];
}
// Reading a stack needs 100 MB free in the temporary folder.
- (BOOL)hyperIsFileAbleToReadFromPath:(id)aPath document:(id)aDocument error:(id *)aError
{
    NSString *temporaryFolder = [[HSPathsProvider sharedPathsProvider] temporaryFolder];
    unsigned long long freeSize = [[[[NSFileManager defaultManager] fileSystemAttributesAtPath:temporaryFolder] objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    if (aError != NULL && freeSize < 100 * 1024 * 1024)
        *aError = [HSError fileErrorWithHSCode:20022 filePath:aPath];
    return freeSize >= 100 * 1024 * 1024;
}
- (BOOL)hyperIsFileWritableAtPath:(id)aPath checkDirectory:(BOOL)aDirectory
{
    if (aDirectory)
        return [self hyperIsFileWritableAtPath:aPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:aPath])
        return YES;
    return [manager isWritableFileAtPath:aPath];
}
- (BOOL)hyperIsFileWritableAtPath:(id)aPath
{
    return [self hyperIsFileWritableAtPath:aPath directory:NULL];
}
// A missing file is writable if its folder is. aDirectory gets whether the
// folder is writable (when it exists).
- (BOOL)hyperIsFileWritableAtPath:(id)aPath directory:(BOOL *)aDirectory
{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL writable = ![manager fileExistsAtPath:aPath] || [manager isWritableFileAtPath:aPath];
    BOOL isDirectory = NO;
    NSString *folder = [aPath stringByDeletingLastPathComponent];
    [manager fileExistsAtPath:folder isDirectory:&isDirectory];
    if (isDirectory) {
        BOOL folderWritable = [manager isWritableFileAtPath:folder];
        if (aDirectory != NULL)
            *aDirectory = folderWritable;
        writable = writable && folderWritable;
    }
    return writable;
}
- (BOOL)hyperIsFileReadableAtPath:(id)aPath
{
    return aPath != nil && [[NSFileManager defaultManager] isReadableFileAtPath:aPath];
}
- (BOOL)hyperIsReadableFileAtPath:(id)aPath showAlert:(BOOL)aAlert error:(id *)aError
{
    if ([self isReadableFileAtPath:aPath])
        return YES;
    NSError *error = [HSError fileErrorWithHSCode:0x101 filePath:aPath];
    if (aAlert)
        [[HSErrorManager sharedErrorManager] presentError:error];
    if (aError != NULL)
        *aError = error;
    return NO;
}
- (NSInteger)resourceTypesCountAtPath:(id)aPath
{
    FSRef ref;
    if (!CFURLGetFSRef((CFURLRef)[NSURL fileURLWithPath:aPath], &ref))
        return 0;
    ResFileRefNum currentFile = CurResFile();
    ResFileRefNum file = FSOpenResFile(&ref, fsRdPerm);
    if (file == -1 || ResError() != noErr)
        return 0;
    UseResFile(file);
    NSInteger count = Count1Types();
    UseResFile(currentFile);
    CloseResFile(file);
    return count;
}
// Files only.
- (BOOL)forkSizesAtPath:(id)aPath dataLogicalSize:(unsigned long long *)aSize rsrcLogicalSize:(unsigned long long *)aSize2
{
    FSRef ref;
    if (!CFURLGetFSRef((CFURLRef)[NSURL fileURLWithPath:aPath], &ref))
        return NO;
    FSCatalogInfoBitmap which = kFSCatInfoNodeFlags;
    if (aSize != NULL)
        which |= kFSCatInfoDataSizes;
    if (aSize2 != NULL)
        which |= kFSCatInfoRsrcSizes;
    FSCatalogInfo info;
    if (FSGetCatalogInfo(&ref, which, &info, NULL, NULL, NULL) != noErr || (info.nodeFlags & kFSNodeIsDirectoryMask) != 0)
        return NO;
    if (aSize != NULL)
        *aSize = info.dataLogicalSize;
    if (aSize2 != NULL)
        *aSize2 = info.rsrcLogicalSize;
    return YES;
}
// The original used PBHCopyFileSync, a server-side copy that only volumes
// with bHasCopyFile (file servers) support, and failed elsewhere;
// PBHCopyFileSync and UnicodeNameGetHFSName don't exist on 64-bit. copyfile
// copies both forks and the metadata on any volume.
- (BOOL)copyFileWithResFork:(id)aFork toPath:(id)aPath
{
    if ([[aPath lastPathComponent] length] == 0)
        return NO;
    return copyfile([aFork fileSystemRepresentation], [aPath fileSystemRepresentation], NULL, COPYFILE_ALL) == 0;
}
// Depth first; stops at the first failure.
- (BOOL)removeDirectoryAtPath:(id)aPath
{
    NSEnumerator *enumerator = [[self directoryContentsAtPath:aPath] objectEnumerator];
    NSString *name;
    while ((name = [enumerator nextObject]) != nil) {
        NSString *path = [aPath stringByAppendingPathComponent:name];
        BOOL removed;
        if ([[[self fileAttributesAtPath:path traverseLink:NO] objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory])
            removed = [self removeDirectoryAtPath:path];
        else
            removed = [self removeFileAtPath:path handler:nil];
        if (!removed)
            return NO;
    }
    return [self removeFileAtPath:aPath handler:nil];
}
// With intermediate folders: creates each missing one (sandboxed, an
// existing folder is checked without reading attributes). Returns the last
// creation's result: NO when every folder already existed (as in the
// original).
- (BOOL)createDirectoryAtPath:(id)aPath attributes:(id)aAttributes createIntermediate:(BOOL)aIntermediate
{
    if (!aIntermediate)
        return [self createDirectoryAtPath:aPath attributes:aAttributes];
    NSString *path = [NSString string];
    BOOL created = NO;
    NSEnumerator *enumerator = [[aPath componentsSeparatedByString:@"/"] objectEnumerator];
    NSString *component;
    while ((component = [enumerator nextObject]) != nil) {
        path = [path stringByAppendingPathComponent:component];
        if ([path length] == 0)
            path = [path stringByAppendingString:@"/"];
        BOOL exists;
        if ([[HSSystem sharedSystem] isSandboxed]) {
            BOOL isDirectory = NO;
            exists = [self fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory;
        } else
            exists = [self fileExistsAtPath:path] && [[[self fileAttributesAtPath:path traverseLink:YES] objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory];
        if (exists)
            continue;
        created = [self createDirectoryAtPath:path attributes:aAttributes];
        if (!created)
            return NO;
    }
    return created;
}
// The HFS type ('TEXT'…), else the lowercased extension.
- (id)hyperFileTypeAtPath:(id)aPath
{
    if (![self fileExistsAtPath:aPath] || ![self isReadableFileAtPath:aPath])
        return nil;
    NSString *type = NSHFSTypeOfFile(aPath);
    if (type != nil && ![type isEqualToString:@"''"] && ![type isEqualToString:@"'?\?\?\?'"])
        return type;
    return [[aPath pathExtension] lowercaseString];
}
// Into the user's Trash, replacing a file of the same name or numbering
// the new one ("name 2.ext"…).
- (void)moveFileToUserTrash:(id)aTrash createUniqueFileInTrash:(BOOL)aTrash2
{
    FSRef ref;
    if (FSFindFolder(kUserDomain, kTrashFolderType, kDontCreateFolder, &ref) != noErr)
        return;
    CFURLRef url = CFURLCreateFromFSRef(kCFAllocatorSystemDefault, &ref);
    if (url == NULL)
        return;
    NSString *trash = (NSString *)CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
    if (trash != nil) {
        NSString *destination = [trash stringByAppendingPathComponent:[aTrash lastPathComponent]];
        if (!aTrash2)
            [[NSFileManager defaultManager] removeFileAtPath:destination handler:nil];
        else {
            NSString *name = [destination lastPathComponent];
            NSString *extension = [name pathExtension];
            NSString *base = [name stringByDeletingPathExtension];
            for (int number = 2; [[NSFileManager defaultManager] fileExistsAtPath:destination]; number++) {
                destination = [trash stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ %d", base, number]];
                if ([extension length] != 0)
                    destination = [destination stringByAppendingPathExtension:extension];
            }
        }
        [[NSFileManager defaultManager] movePath:aTrash toPath:destination handler:nil];
        CFRelease(trash);
    }
    CFRelease(url);
}
@end
