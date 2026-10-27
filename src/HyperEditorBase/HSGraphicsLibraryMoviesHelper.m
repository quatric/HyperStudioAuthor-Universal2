#import "HSGraphicsLibraryMoviesHelper.h"
#import "HSLibraryScanning.h"

// The URL (or the object aClass makes from it) for a movie file, by its
// full media path.
static void HSMoviesAddItem(NSMutableArray *aArray, NSString *aPath, NSString *aType, Class aClass)
{
    NSURL *url = [NSURL fileURLWithPath:[HSNewMediaAccessor fullPathForMediaPath:aPath mediaType:aType]];
    if (![aClass respondsToSelector:@selector(canInitWithURL:)] || ![aClass instancesRespondToSelector:@selector(initWithURL:)]) {
        [aArray addObject:url];
    } else if ([aClass canInitWithURL:url]) {
        id item = [[aClass alloc] initWithURL:url];
        if (item != nil) {
            [aArray addObject:item];
            [item release];
        }
    }
}

@implementation HSGraphicsLibraryMoviesHelper

// The alias's original's path; nil when it isn't an alias.
// (FSResolveAliasFile in the original.)
+ (id)resolveOSXAlias:(id)aAlias
{
    if (aAlias == nil)
        return nil;
    NSURL *url = [NSURL fileURLWithPath:aAlias];
    NSNumber *isAlias = nil;
    if (![url getResourceValue:&isAlias forKey:NSURLIsAliasFileKey error:NULL] || ![isAlias boolValue])
        return nil;
    NSData *bookmark = [NSURL bookmarkDataWithContentsOfURL:url error:NULL];
    if (bookmark == nil)
        return nil;
    return [[NSURL URLByResolvingBookmarkData:bookmark options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:NULL error:NULL] path];
}

+ (id)movieUserObjectClassName
{
    return @"HSMovieObject";
}

+ (id)defaultAttributes:(id)aAttributes
{
    return HSLibraryDefaultAttributes(aAttributes);
}

+ (id)animationsFileTypes
{
    static NSMutableArray *types;
    if (types == nil) {
        types = [[NSMutableArray alloc] init];
        [types addObject:@"gif"];
        [types addObject:@"mov"];
    }
    return types;
}

// The ready-made animations folder's folders but Animations.
+ (id)hyperStudioMoviesFolders
{
    NSMutableArray *folders = [NSMutableArray arrayWithCapacity:0];
    NSString *folder = [[HSPathsProvider sharedPathsProvider] readyMadeAnimationsFolder];
    if ([[NSFileManager defaultManager] fileExistsAtPath:folder]) {
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:NULL];
        for (NSString *name in contents) {
            if (![name isEqualToString:@"Animations"])
                [folders addObject:[folder stringByAppendingPathComponent:name]];
        }
    }
    return folders;
}

+ (id)animationsFolders
{
    return HSLibraryFolderContents([[HSPathsProvider sharedPathsProvider] readyMadeAnimationsFolder]);
}

+ (id)movieFileTypes
{
    static NSArray *types;
    if (types == nil)
        types = [[NSArray alloc] initWithArray:[HSUserObject typesForUserObjectClassName:[self movieUserObjectClassName]]];
    return types;
}

+ (id)movieFolders
{
    NSMutableArray *folders = [NSMutableArray arrayWithCapacity:0];
    NSString *folder = [[HSPathsProvider sharedPathsProvider] libraryMoviesFolder];
    if (folder != nil)
        [folders addObject:folder];
    return folders;
}

+ (void)plainScanDirectory:(id)aDirectory fileTypes:(id)aTypes toArray:(id)aArray insertClass:(Class)aClass
{
    HSLibraryPlainScanDirectory(aDirectory, aTypes, aArray, aClass);
}

// Aliases resolved; packages (movie bundles) count as files.
+ (void)scanDirectory:(id)aDirectory fileTypes:(id)aTypes toDictionary:(id)aDictionary insertClass:(Class)aClass
{
    NSString *directory = [self resolveOSXAlias:aDirectory];
    if (directory == nil)
        directory = aDirectory;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSEnumerator *enumerator = [[manager contentsOfDirectoryAtPath:directory error:NULL] objectEnumerator];
    NSString *name;
    while ((name = [enumerator nextObject])) {
        NSString *path = [directory stringByAppendingPathComponent:name];
        NSString *resolved = [self resolveOSXAlias:path];
        if (resolved != nil)
            path = resolved;
        NSDictionary *attributes = [manager attributesOfItemAtPath:[path stringByResolvingSymlinksInPath] error:NULL];
        if ([[attributes objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]
                && ![[NSWorkspace sharedWorkspace] isFilePackageAtPath:[path stringByResolvingSymlinksInPath]]) {
            NSString *folder = [path lastPathComponent];
            NSMutableArray *array = [aDictionary objectForKey:folder];
            if (array == nil)
                array = [NSMutableArray arrayWithCapacity:0];
            [[self class] scanDirectory:path fileTypes:aTypes toArray:array insertClass:aClass];
            [aDictionary setObject:array forKey:folder];
            continue;
        }
        id type = [manager hyperFileTypeAtPath:path];
        if (![aTypes containsObject:type])
            continue;
        NSMutableArray *array = [aDictionary objectForKey:MoviesRootFolderKey];
        if (array == nil) {
            array = [NSMutableArray arrayWithCapacity:0];
            [aDictionary setObject:array forKey:MoviesRootFolderKey];
        }
        HSMoviesAddItem(array, path, type, aClass);
    }
}

+ (void)scanDirectory:(id)aDirectory fileTypes:(id)aTypes toArray:(id)aArray insertClass:(Class)aClass
{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:aDirectory];
    NSString *name;
    while ((name = [enumerator nextObject])) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        NSString *path = [aDirectory stringByAppendingPathComponent:name];
        NSString *fileType = [[enumerator fileAttributes] objectForKey:NSFileType];
        if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:path])
            [enumerator skipDescendents];
        if ([fileType isEqualToString:NSFileTypeSymbolicLink]) {
            [[self class] scanDirectory:path fileTypes:aTypes toArray:aArray insertClass:aClass];
        } else {
            id type = [[NSFileManager defaultManager] hyperFileTypeAtPath:path];
            if ([aTypes containsObject:type])
                HSMoviesAddItem(aArray, path, type, aClass);
        }
        [pool release];
    }
}

@end
