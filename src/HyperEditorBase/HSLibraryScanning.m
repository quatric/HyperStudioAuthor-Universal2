#import "HSLibraryScanning.h"

// The URL as is, or an object of aClass made from it when aClass can make
// one (nil when it declines).
static id HSLibraryItemForURL(NSURL *aURL, Class aClass, BOOL *aOwned)
{
    *aOwned = NO;
    if (![aClass respondsToSelector:@selector(canInitWithURL:)] || ![aClass instancesRespondToSelector:@selector(initWithURL:)])
        return aURL;
    if (![aClass canInitWithURL:aURL])
        return nil;
    *aOwned = YES;
    return [[aClass alloc] initWithURL:aURL];
}

static void HSLibraryAddItem(NSMutableArray *aArray, NSString *aPath, Class aClass)
{
    BOOL owned;
    id item = HSLibraryItemForURL([NSURL fileURLWithPath:aPath], aClass, &owned);
    if (item == nil)
        return;
    [aArray addObject:item];
    if (owned)
        [item release];
}

// The regular files of the directory itself.
void HSLibraryPlainScanDirectory(NSString *aDirectory, id aTypes, NSMutableArray *aArray, Class aClass)
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSEnumerator *enumerator = [[manager contentsOfDirectoryAtPath:aDirectory error:NULL] objectEnumerator];
    NSString *name;
    while ((name = [enumerator nextObject])) {
        NSString *path = [aDirectory stringByAppendingPathComponent:name];
        id type = [manager hyperFileTypeAtPath:path];
        NSDictionary *attributes = [manager attributesOfItemAtPath:[path stringByResolvingSymlinksInPath] error:NULL];
        if ([[attributes objectForKey:NSFileType] isEqualToString:NSFileTypeRegular] && [aTypes containsObject:type])
            HSLibraryAddItem(aArray, path, aClass);
    }
}

// Each subdirectory's files (all levels) under its name, the directory's
// own under HSRootFolderKey.
void HSLibraryScanDirectoryToDictionary(Class aHelper, NSString *aDirectory, id aTypes, NSMutableDictionary *aDictionary, Class aClass)
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSEnumerator *enumerator = [[manager contentsOfDirectoryAtPath:aDirectory error:NULL] objectEnumerator];
    NSString *name;
    while ((name = [enumerator nextObject])) {
        NSString *path = [aDirectory stringByAppendingPathComponent:name];
        NSDictionary *attributes = [manager attributesOfItemAtPath:[path stringByResolvingSymlinksInPath] error:NULL];
        if ([[attributes objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]) {
            NSString *folder = [path lastPathComponent];
            NSMutableArray *array = [aDictionary objectForKey:folder];
            if (array == nil)
                array = [NSMutableArray arrayWithCapacity:0];
            [aHelper scanDirectory:path fileTypes:aTypes toArray:array insertClass:aClass];
            [aDictionary setObject:array forKey:folder];
        } else if ([aTypes containsObject:[manager hyperFileTypeAtPath:path]]) {
            NSMutableArray *array = [aDictionary objectForKey:HSRootFolderKey];
            if (array == nil) {
                array = [NSMutableArray arrayWithCapacity:0];
                [aDictionary setObject:array forKey:HSRootFolderKey];
            }
            HSLibraryAddItem(array, path, aClass);
        }
    }
}

// Every level of the directory, following symbolic links.
void HSLibraryScanDirectoryToArray(Class aHelper, NSString *aDirectory, id aTypes, NSMutableArray *aArray, Class aClass)
{
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:aDirectory];
    NSString *name;
    while ((name = [enumerator nextObject])) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        NSString *path = [aDirectory stringByAppendingPathComponent:name];
        if ([[[enumerator fileAttributes] objectForKey:NSFileType] isEqualToString:NSFileTypeSymbolicLink])
            [aHelper scanDirectory:path fileTypes:aTypes toArray:aArray insertClass:aClass];
        else if ([aTypes containsObject:[[NSFileManager defaultManager] hyperFileTypeAtPath:path]])
            HSLibraryAddItem(aArray, path, aClass);
        [pool release];
    }
}

// The paths of the folder's items, when it exists.
NSMutableArray *HSLibraryFolderContents(NSString *aFolder)
{
    NSMutableArray *folders = [NSMutableArray arrayWithCapacity:0];
    if ([[NSFileManager defaultManager] fileExistsAtPath:aFolder]) {
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aFolder error:NULL];
        for (NSUInteger i = 0; i < [contents count]; i++)
            [folders addObject:[aFolder stringByAppendingPathComponent:[contents objectAtIndex:i]]];
    }
    return folders;
}

// The cell's font, colours and alignment (clipped), white text when it's
// highlighted in the key view, or for no cell.
NSMutableDictionary *HSLibraryDefaultAttributes(id aCell)
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:0];
    // Fix: the original went on with a plain NSCell for other cells, which
    // has no text colour to give.
    NSTextFieldCell *cell = [aCell isKindOfClass:[NSTextFieldCell class]] ? aCell : nil;
    NSCell *fontCell = cell != nil ? cell : [[[NSCell alloc] initTextCell:[NSString string]] autorelease];
    [attributes setObject:[fontCell font] forKey:NSFontAttributeName];
    BOOL isFirstResponder = [cell controlView] != nil && [[[cell controlView] window] firstResponder] == [cell controlView];
    if (cell != nil && !([cell isHighlighted] && isFirstResponder))
        [attributes setObject:[cell textColor] forKey:NSForegroundColorAttributeName];
    else
        [attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    if (cell != nil && [cell drawsBackground])
        [attributes setObject:[cell backgroundColor] forKey:NSBackgroundColorAttributeName];
    [attributes setObject:[NSParagraphStyle hyperParagraphStyleWithAlignment:[fontCell alignment] lineBreakMode:NSLineBreakByClipping] forKey:NSParagraphStyleAttributeName];
    return attributes;
}

// The app's recent databases from the iApps preferences, or the default
// location for each key (localized in aTable) when none exists.
NSArray *HSiAppsRecentDatabasesForKeys(Class aHelper, NSArray *aKeys, NSString *aTable)
{
    NSBundle *bundle = [NSBundle bundleForClass:aHelper];
    NSDictionary *domain = [[NSUserDefaults standardUserDefaults] persistentDomainForName:[bundle localizedStringForKey:@"iAppsSignature" value:@"" table:aTable]];
    NSArray *databases = nil;
    NSEnumerator *enumerator;
    NSString *key;
    if (domain != nil) {
        enumerator = [aKeys objectEnumerator];
        while ([databases count] == 0 && (key = [enumerator nextObject])) {
            NSArray *paths = [domain objectForKey:key];
            if ([paths count] == 0)
                continue;
            NSMutableArray *urls = [NSMutableArray arrayWithCapacity:0];
            for (id path in paths) {
                @try {
                    NSURL *url = [NSURL URLWithString:path];
                    if (url != nil)
                        [urls addObject:url];
                } @catch (NSException *exception) {
                }
            }
            databases = [aHelper arrayByRemovingNonExistedPaths:urls];
        }
    }
    if ([databases count] == 0) {
        enumerator = [aKeys objectEnumerator];
        while ([databases count] == 0 && (key = [enumerator nextObject])) {
            NSURL *url = [NSURL fileURLWithPath:[[bundle localizedStringForKey:key value:@"" table:aTable] stringByExpandingTildeInPath]];
            if (url != nil)
                databases = [aHelper arrayByRemovingNonExistedPaths:[NSArray arrayWithObject:url]];
        }
    }
    return databases;
}

// (LSFindApplicationForInfo in the original, with the creator code too.)
NSBundle *HSiAppsApplicationBundle(NSString *aBundleID)
{
    NSURL *url = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:aBundleID];
    if (![url isFileURL])
        return nil;
    return [NSBundle bundleWithPath:[[url absoluteURL] path]];
}

// The readable files, aliases resolved.
NSArray *HSiAppsArrayByRemovingNonExistedPaths(Class aHelper, NSArray *aURLs)
{
    NSMutableArray *urls = [NSMutableArray array];
    for (NSURL *url in aURLs) {
        NSURL *resolved = [aHelper resolveAliasesInURL:url];
        if (resolved != nil)
            url = resolved;
        if ([url isFileURL] && [[NSFileManager defaultManager] isReadableFileAtPath:[url path]])
            [urls addObject:url];
    }
    return urls;
}

// The alias the URL names (or one of its folders) resolved; nil when
// there's no alias. (FSResolveAliasFile in the original.)
NSURL *HSiAppsResolveAliasesInURL(Class aHelper, NSURL *aURL)
{
    if (aURL == nil)
        return nil;
    NSURL *url = aURL;
    if (![url checkResourceIsReachableAndReturnError:NULL]) {
        NSURL *folder = [aHelper resolveAliasesInURL:[url URLByDeletingLastPathComponent]];
        if (folder == nil)
            return nil;
        url = [folder URLByAppendingPathComponent:[aURL lastPathComponent]];
        if (![url checkResourceIsReachableAndReturnError:NULL])
            return nil;
    }
    NSNumber *isAlias = nil;
    if (![url getResourceValue:&isAlias forKey:NSURLIsAliasFileKey error:NULL] || ![isAlias boolValue])
        return url != aURL ? url : nil;
    NSData *bookmark = [NSURL bookmarkDataWithContentsOfURL:url error:NULL];
    if (bookmark == nil)
        return nil;
    return [NSURL URLByResolvingBookmarkData:bookmark options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:NULL error:NULL];
}
