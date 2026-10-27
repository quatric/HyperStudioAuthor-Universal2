#import "HSNewMediaAccessor.h"
#import "HSPlayerBaseID.h"
#import "HSMediaFileWrapper.h"
#import "HSMediaLoader.h"
#import "HSMovie.h"
#import "HSAlert.h"
#import "HSExecutableResourceProvider.h"
#import "NSFileManager+HSExtensions.h"

static NSDictionary *sSupportedMediaTypesDictionary = nil;
static NSDictionary *sSupportedActionMediaTypesDictionary = nil;
static NSDictionary *sUserSubpathesForMediaTypes = nil;
static NSDictionary *sSupportedAnimationMediaTypesDictionary = nil;
static HSNewMediaAccessor *sSharedMediaAccessor = nil;
static NSDictionary *sMediaTypesByHFSType = nil;

@implementation HSNewMediaAccessor

+ (id)userAnimationObjectClassNamesForMediaType:(id)aType
{
    return [[self supportedAnimationMediaTypesDictionary] objectForKey:aType];
}

+ (id)supportedAnimationMediaTypesDictionary
{
    if (sSupportedAnimationMediaTypesDictionary == nil)
        sSupportedAnimationMediaTypesDictionary = [[HSPlayerBaseID extraDictionaryNamed:@"AnimationClassesForMediaTypes"] retain];
    return sSupportedAnimationMediaTypesDictionary;
}

// Tries the HFS/UTI file type first, then the lowercased path extension.
+ (BOOL)canCreateMediaObjectOfClass:(Class)aClass withPath:(id)aPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *supported = nil;
    NSString *type = [fm hyperFileTypeAtPath:aPath];
    BOOL secondTry = NO;
    for (;;) {
        BOOL found;
        if (aClass == Nil) {
            if (supported == nil)
                supported = [self supportedMediaTypes];
            found = [supported containsObject:type];
        } else {
            NSString *className = NSStringFromClass(aClass);
            found = [[self userObjectClassNamesForMediaType:type] containsObject:className];
            if (!found)
                found = [[[self userActionClassNamesForMediaType:type] allValues] containsObject:className];
        }
        if (secondTry || found)
            return found;
        type = [[aPath pathExtension] lowercaseString];
        secondTry = YES;
    }
}

+ (id)userActionClassNamesForMediaType:(id)aType
{
    return [[self supportedActionMediaTypesDictionary] objectForKey:aType];
}

+ (id)userObjectClassNamesForMediaType:(id)aType
{
    return [[self supportedMediaTypesDictionary] objectForKey:aType];
}

+ (id)fullPathForMediaPath:(id)aPath mediaType:(id)aType
{
    if (sUserSubpathesForMediaTypes == nil)
        sUserSubpathesForMediaTypes = [[HSPlayerBaseID extraDictionaryNamed:@"UserSubpathesForMediaTypes"] retain];
    NSString *subpath = [sUserSubpathesForMediaTypes objectForKey:aType];
    if (subpath == nil)
        return nil;
    BOOL isDirectory = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dir = [aPath stringByAppendingPathComponent:subpath];
    if ([fm fileExistsAtPath:dir isDirectory:&isDirectory]) {
        NSEnumerator *e = [[fm directoryContentsAtPath:dir] objectEnumerator];
        NSString *name;
        while ((name = [e nextObject]) != nil) {
            NSString *full = [dir stringByAppendingPathComponent:name];
            if ([[self supportedMediaTypes] containsObject:[fm hyperFileTypeAtPath:full]])
                return full;
        }
    }
    return dir;
}

+ (id)supportedMediaTypesForClass:(id)aClass
{
    NSMutableArray *result = [NSMutableArray array];
    NSDictionary *dict = [self supportedMediaTypesDictionary];
    NSEnumerator *e = [dict keyEnumerator];
    id key;
    while ((key = [e nextObject]) != nil) {
        if ([[dict objectForKey:key] containsObject:aClass] && ![result containsObject:key])
            [result addObject:key];
    }
    dict = [self supportedActionMediaTypesDictionary];
    e = [dict keyEnumerator];
    while ((key = [e nextObject]) != nil) {
        if ([[dict objectForKey:key] containsObject:aClass] && ![result containsObject:key])
            [result addObject:key];
    }
    return result;
}

+ (id)supportedMediaTypes
{
    NSMutableArray *result = [NSMutableArray array];
    [result addObjectsFromArray:[[self supportedMediaTypesDictionary] allKeys]];
    [result addObjectsFromArray:[[self supportedActionMediaTypesDictionary] allKeys]];
    return result;
}

+ (id)supportedActionMediaTypesDictionary
{
    if (sSupportedActionMediaTypesDictionary == nil)
        sSupportedActionMediaTypesDictionary = [[HSPlayerBaseID extraDictionaryNamed:@"UserActionsForMediaTypes"] retain];
    return sSupportedActionMediaTypesDictionary;
}

+ (id)supportedMediaTypesDictionary
{
    if (sSupportedMediaTypesDictionary == nil)
        sSupportedMediaTypesDictionary = [[HSPlayerBaseID extraDictionaryNamed:@"UserClassesForMediaTypes"] retain];
    return sSupportedMediaTypesDictionary;
}

+ (id)extensionForHFSType:(id)aType
{
    if ([aType unsignedIntValue] == 0)
        return nil;
    CFStringRef osType = UTCreateStringForOSType((OSType)[aType unsignedIntValue]);
    if (osType == NULL)
        return nil;
    id result = nil;
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassOSType, osType, NULL);
    if (uti != NULL) {
        result = [(id)UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension) autorelease];
        CFRelease(uti);
    }
    if (result == nil) {
        if (sMediaTypesByHFSType == nil) {
            NSString *path = [[NSBundle bundleForClass:self] pathForResource:@"MediaTypes" ofType:@"plist"];
            if (path != nil)
                sMediaTypesByHFSType = [[NSDictionary alloc] initWithContentsOfFile:path];
        }
        result = [sMediaTypesByHFSType objectForKey:[NSString stringWithFormat:@"'%@'", (NSString *)osType]];
    }
    CFRelease(osType);
    return result;
}

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (sSharedMediaAccessor == nil)
            sSharedMediaAccessor = [super allocWithZone:aZone];
    }
    return sSharedMediaAccessor;
}

+ (id)sharedMediaAccessor
{
    @synchronized(self) {
        if (sSharedMediaAccessor == nil)
            [[self alloc] init];
    }
    return sSharedMediaAccessor;
}

- (void)cleanupMediaUsedByApplication
{
    [_defaultMedia release];
    _defaultMedia = nil;
}

- (void)dereferenceObject:(void *)aObject
{
    NSMapRemove([self mediaMap], [(HSNewMedia *)aObject mediaUID]);
}

// The cache key carries excludeUnused in bit 8, but the set built is the same
// either way (original behaviour).
- (id)allMediaUIDsForGroup:(NSInteger)aGroup excludeUnused:(BOOL)aUnused
{
    NSUInteger key = aUnused ? ((NSUInteger)aGroup | 0x100) : (NSUInteger)aGroup;
    NSMutableSet *uids = NSMapGet([self groupedUIDs], (const void *)key);
    if (uids == nil) {
        if (aGroup == 0 && !aUnused) {
            uids = [NSMutableSet setWithArray:NSAllMapTableKeys([self mediaMap])];
        } else {
            uids = [NSMutableSet set];
            NSMapEnumerator e = NSEnumerateMapTable([self mediaMap]);
            id uid = nil;
            HSNewMedia *media = nil;
            while (NSNextMapEnumeratorPair(&e, (void **)&uid, (void **)&media)) {
                if (aGroup == 0 || [media mediaGroup] == aGroup)
                    [uids addObject:uid];
            }
            NSEndMapTableEnumeration(&e);
        }
        NSMapInsertKnownAbsent([self groupedUIDs], (const void *)key, uids);
    }
    return uids;
}

- (id)groupedUIDs
{
    if (_groupedUIDs == nil)
        _groupedUIDs = NSCreateMapTableWithZone(NSIntegerMapKeyCallBacks, NSObjectMapValueCallBacks, 4, [self zone]);
    return _groupedUIDs;
}

- (void)unregisterMedia:(id)aMedia
{
    NSMapRemove([self mediaMap], [(HSNewMedia *)aMedia mediaUID]);
}

- (void)registerMedia:(id)aMedia
{
    NSMapInsert([self mediaMap], [(HSNewMedia *)aMedia mediaUID], aMedia);
    NSString *path = [aMedia fullPathToMediaFile];
    if ([path length] == 0)
        return;
    if ([HSMovie hasProtectedMovieTrackAtMovieWithURL:[NSURL fileURLWithPath:path] error:NULL]) {
        HSAlert *alert = [HSAlert new];
        NSString *format = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"The file \"%@\" might not play" value:@"" table:@"Alerts"];
        NSString *message = [NSString stringWithFormat:format, [path lastPathComponent]];
        NSString *info = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"The file you have added to the card is subject to digital rights management. It might not play on some computers." value:@"" table:@"Alerts"];
        [alert setMessageText:message];
        [alert setInformativeText:info];
        [alert setIcon:[HSAlert warningIcon]];
        [alert runModal];
        [alert release];
    }
}

- (id)mediaForUID:(id)aUID
{
    return [[(id)NSMapGet([self mediaMap], aUID) retain] autorelease];
}

- (id)mediaMap
{
    if (_mediaMap == nil) {
        _mediaMap = NSCreateMapTable(NSObjectMapKeyCallBacks, NSNonRetainedObjectMapValueCallBacks, 0);
        NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MediaAccessor"]];
        _defaultMedia = [[HSMediaLoader loadResourcesWrapper:wrapper resourcesFolderPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MediaAccessor"] loadUIDs:YES] retain];
        [wrapper release];
    }
    return _mediaMap;
}

// Singleton: memory management is a no-op.
- (id)autorelease
{
    return self;
}

- (void)release
{
}

- (NSUInteger)retainCount
{
    return UINT_MAX;
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
