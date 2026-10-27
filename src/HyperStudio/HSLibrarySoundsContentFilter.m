#import "HSLibrarySoundsContentFilter.h"

static id HSLibraryContentFilterShared = nil;
static id HSLibraryMoviesContentFilterShared = nil;
static id HSLibrarySoundsContentFilterShared = nil;

@implementation HSLibraryContentFilter

+ (id)sharedContentFilter
{
    if (!HSLibraryContentFilterShared)
        HSLibraryContentFilterShared = [[self alloc] init];
    return HSLibraryContentFilterShared;
}

- (id)dataBasePath
{
    return [[NSBundle bundleForClass:[self class]] pathForResource:@"PhotosMetaData" ofType:@"sql" inDirectory:@"Media Library/Photos"];
}

- (id)rootPathForFilePath:(id)aPath
{
    if (!_rootPaths)
        _rootPaths = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
    id rootPath = [_rootPaths objectForKey:aPath];
    if (!rootPath) {
        NSMutableString *path = [aPath mutableCopy];
        [path replaceOccurrencesOfString:[self contextPath] withString:@"" options:NSAnchoredSearch range:NSMakeRange(0, [path length])];
        rootPath = [[path copy] autorelease];
        [path release];
        if (rootPath && aPath)
            [_rootPaths setObject:rootPath forKey:aPath];
    }
    if (!rootPath)
        rootPath = [NSString string];
    return rootPath;
}

- (id)contextPath
{
    if (!_contextPath)
        _contextPath = [[[[NSBundle bundleForClass:[self class]] pathForResource:@"Media Library" ofType:nil] stringByAppendingString:@"/"] retain];
    return _contextPath;
}

- (id)managedObjectContext
{
    if (!_context) {
        id coordinator = [self persistentStoreCoordinator];
        if (coordinator) {
            _context = [[NSManagedObjectContext allocWithZone:[self zone]] init];
            [_context setPersistentStoreCoordinator:coordinator];
        }
    }
    return _context;
}

// The store is opened read-only; nil when it cannot be added.
- (id)persistentStoreCoordinator
{
    id path = [self dataBasePath];
    if (path) {
        NSPersistentStoreCoordinator *coordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]] autorelease];
        NSDictionary *options = [NSDictionary dictionaryWithObject:(id)kCFBooleanTrue forKey:NSReadOnlyPersistentStoreOption];
        if ([coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:path] options:options error:NULL])
            return coordinator;
    }
    return nil;
}

- (id)managedObjectModel
{
    if (!_managedObjectModel)
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"LibraryContentFilter" ofType:@"mom"]]];
    return _managedObjectModel;
}

- (id)globalUIDStringForMediaItem:(id)aItem
{
    if (![aItem hasPrefix:[self contextPath]])
        return nil;
    return [[[self entities] objectForKey:[self rootPathForFilePath:aItem]] objectForKey:@"globalUID"];
}

- (BOOL)mediaItem:(id)aItem conformsToDisplayNameFilter:(id)aFilter mediaTypeFilter:(id)aFilter2
{
    if (![self managedObjectContext])
        return NO;
    id entity = [[self entities] objectForKey:[self rootPathForFilePath:aItem]];
    if (!entity)
        return NO;
    BOOL conforms;
    if (![aFilter length])
        conforms = YES;
    else
        conforms = [[entity objectForKey:@"mediaDisplayName"] rangeOfString:aFilter options:NSCaseInsensitiveSearch].location != NSNotFound;
    if (![aFilter2 length])
        return conforms;
    if (!conforms)
        return NO;
    return [[entity objectForKey:@"mediaType"] rangeOfString:aFilter2 options:NSCaseInsensitiveSearch].location != NSNotFound;
}

// Display name, type and global UID of every media item, keyed by root path.
- (id)entities
{
    id context = [self managedObjectContext];
    if (!context)
        return nil;
    if (!_entities) {
        _entities = [NSMutableDictionary new];
        NSFetchRequest *request = [[NSFetchRequest new] autorelease];
        [request setEntity:[NSEntityDescription entityForName:@"MediaItem" inManagedObjectContext:context]];
        NSArray *items = [context executeFetchRequest:request error:NULL];
        NSEnumerator *enumerator = [items objectEnumerator];
        id item;
        while ((item = [enumerator nextObject])) {
            id name = [item valueForKey:@"mediaDisplayName"];
            id type = [item valueForKey:@"mediaType"];
            id uid = [item valueForKey:@"globalUID"];
            id entity = [NSDictionary dictionaryWithObjectsAndKeys:name, @"mediaDisplayName", type, @"mediaType", uid, @"globalUID", nil];
            [_entities setObject:entity forKey:[item valueForKey:@"mediaRootPath"]];
        }
    }
    return _entities;
}

- (id)sortedMediaTypes
{
    return [[[self mediaTypes] allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

// The union of the ';'-separated type lists of all media items.
- (id)mediaTypes
{
    id context = [self managedObjectContext];
    if (!context)
        return [NSSet set];
    if (!_mediaTypes) {
        NSMutableSet *types = [[NSMutableSet alloc] initWithCapacity:0];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"MediaItem" inManagedObjectContext:context]];
        NSArray *items = [context executeFetchRequest:request error:NULL];
        [request release];
        NSEnumerator *enumerator = [items objectEnumerator];
        id item;
        while ((item = [enumerator nextObject])) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            [types addObjectsFromArray:[[item valueForKey:@"mediaType"] componentsSeparatedByString:@";"]];
            [pool release];
        }
        _mediaTypes = [types copy];
        [types release];
    }
    return _mediaTypes;
}

- (void)dealloc
{
    [_mediaTypes release];
    [_entities release];
    [_context release];
    [_contextPath release];
    [_rootPaths release];
    [_managedObjectModel release];
    [super dealloc];
}
@end

@implementation HSLibrarySoundsContentFilter

+ (id)sharedContentFilter
{
    if (!HSLibrarySoundsContentFilterShared)
        HSLibrarySoundsContentFilterShared = [[self alloc] init];
    return HSLibrarySoundsContentFilterShared;
}

- (id)dataBasePath
{
    return [[NSBundle bundleForClass:[self class]] pathForResource:@"SoundsMetaData" ofType:@"sql" inDirectory:@"Media Library/Sounds"];
}
@end

@implementation HSLibraryMoviesContentFilter

+ (id)sharedContentFilter
{
    if (!HSLibraryMoviesContentFilterShared)
        HSLibraryMoviesContentFilterShared = [[self alloc] init];
    return HSLibraryMoviesContentFilterShared;
}

- (id)dataBasePath
{
    return [[NSBundle bundleForClass:[self class]] pathForResource:@"MoviesMetaData" ofType:@"sql" inDirectory:@"Media Library/Animation"];
}

@end
