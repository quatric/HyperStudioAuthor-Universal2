#import "HSMediaWrapper.h"
#import "HSMediaFileWrapper.h"
#import "HSMovie.h"
#import "HSNewMediaAccessor.h"
#import "HSPlayerBaseID.h"
#import "NSFileManager+HSExtensions.h"

// Old media record kept for reading older documents; decoding one yields an HSNewMedia instead.
// The file is tracked by path plus an alias, and its HFS type/creator are restored on the first path set.
@implementation HSMediaWrapper
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"uid", @"mediaName", @"mediaPath", @"storageRetainCount", @"fullPathToMediaFile", @"hfsTypeCode", @"hfsCreatorCode", nil];
}
- (void)setFullPathToMediaFile:(id)aFile isTemporary:(BOOL)aTemporary
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![_fullPathToMediaFile isEqualToString:aFile] || _fileAlias == NULL) {
        if (_isFullPathTemporary && _fullPathToMediaFile != nil)
            [fileManager removeItemAtPath:_fullPathToMediaFile error:NULL];
        [_fullPathToMediaFile release];
        _fullPathToMediaFile = [aFile copy];
        if (_fileAlias != NULL) {
            DisposeHandle((Handle)_fileAlias);
            _fileAlias = NULL;
        }
        [self HSMediaWrapper_saveOrRestoreFileAttributes];
        FSRef ref;
        if (CFURLGetFSRef((CFURLRef)[NSURL fileURLWithPath:_fullPathToMediaFile], &ref))
            FSNewAlias(NULL, &ref, (AliasHandle *)&_fileAlias);
        [[NSNotificationCenter defaultCenter] postNotificationName:HSMediaPathToMediaFileDidChangeNotification object:self userInfo:nil];
    }
    _isFullPathTemporary = aTemporary;
}
- (void)setFileWrapper:(id)aWrapper
{
    [_wrapper autorelease];
    _wrapper = [aWrapper retain];
}
- (id)fileWrapper
{
    return _wrapper;
}
- (id)mediaPath
{
    return _mediaPath;
}
- (void)releaseStorage
{
    if (_storageRetainCount != 0)
        _storageRetainCount--;
}
- (id)retainStorage
{
    _storageRetainCount++;
    return self;
}
- (NSUInteger)storageRetainCount
{
    return _storageRetainCount;
}
- (id)description
{
    return [NSString stringWithFormat:@"<%@ path = '%@', name = '%@'>", NSStringFromClass([self class]), [self mediaPath], [self mediaName]];
}
- (id)copyWithZone:(NSZone *)aZone
{
    id copy = nil;
    @try {
        NSDictionary *dictionary = [self extraDictionaryRepresentation];
        if (dictionary != nil)
            copy = [[HSMediaWrapper objectWithExtraDictionary:dictionary zone:aZone] retain];
        // The original clears the storage retain count by ivar offset whatever the copy's class
        // (decoding normally yields an HSNewMedia).
        if ([copy isKindOfClass:[HSMediaWrapper class]])
            ((HSMediaWrapper *)copy)->_storageRetainCount = 0;
    }
    @catch (NSException *exception) {
    }
    return copy;
}
- (void)dealloc
{
    [_wrapper release];
    [_uid release];
    [_mediaName release];
    [_mediaPath release];
    [_mediaType release];
    [_hfsTypeCode release];
    [_hfsCreatorCode release];
    if (_isFullPathTemporary && _fullPathToMediaFile != nil)
        [[NSFileManager defaultManager] removeItemAtPath:_fullPathToMediaFile error:NULL];
    [_fullPathToMediaFile release];
    if (_fileAlias != NULL)
        DisposeHandle((Handle)_fileAlias);
    [super dealloc];
}
- (id)initWithUID:(id)aUID mediaName:(id)aName fileWrapper:(id)aWrapper keyForFileWrapper:(id)aWrapper2
{
    self = [super init];
    if (self != nil) {
        _wrapper = [aWrapper retain];
        _uid = [aUID retain];
        _storageRetainCount = 0;
        _mediaName = [aName copy];
        _mediaPath = [aWrapper2 copy];
        _isRestoredHFSAttributes = YES;
    }
    return self;
}
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    [self release];
    return (id)[[HSNewMedia alloc] initWithExtraDictionary:aDictionary codingContext:aContext];
}
@end

@implementation HSMediaWrapper (HSMediaWrapperPublic)
// The first time a path is set after decoding, the stored HFS codes go back onto the file;
// afterwards the codes are read from the file.
- (void)HSMediaWrapper_saveOrRestoreFileAttributes
{
    // -fileAttributesAtPath:traverseLink:YES in the original.
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_fullPathToMediaFile stringByResolvingSymlinksInPath] error:NULL];
    if (!_isRestoredHFSAttributes) {
        if (_hfsTypeCode != nil && _hfsCreatorCode != nil) {
            NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
            [newAttributes setObject:_hfsTypeCode forKey:NSFileHFSTypeCode];
            [newAttributes setObject:_hfsCreatorCode forKey:NSFileHFSCreatorCode];
            [[NSFileManager defaultManager] setAttributes:newAttributes ofItemAtPath:_fullPathToMediaFile error:NULL];
        }
        _isRestoredHFSAttributes = YES;
    } else {
        [_hfsTypeCode release];
        [_hfsCreatorCode release];
        _hfsTypeCode = [[attributes objectForKey:NSFileHFSTypeCode] retain];
        _hfsCreatorCode = [[attributes objectForKey:NSFileHFSCreatorCode] retain];
    }
}
// Media types: 1 video, 2 sound, 3 image.
- (BOOL)canUseMediaFromPath:(id)aPath forMediaType:(NSInteger)aType
{
    if (aType == 1)
        return [HSMovie canInitAsVideoWithURL:[NSURL fileURLWithPath:aPath] error:NULL];
    if (aType == 3)
        return [[[NSImage alloc] initWithContentsOfFile:aPath] autorelease] != nil;
    if (aType != 2)
        return NO;
    HSMovie *movie = [[[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:aPath] error:NULL] autorelease];
    if (movie != nil && [movie isSound])
        return YES;
    return [HSMovie hasProtectedMovieTrackAtMovieWithURL:[NSURL fileURLWithPath:aPath] error:NULL];
}
- (id)mediaTypesFromDictionary:(id)aDictionary forFileType:(id)aType
{
    NSMutableArray *types = [NSMutableArray array];
    NSEnumerator *keys = [aDictionary keyEnumerator];
    id key;
    while ((key = [keys nextObject]) != nil && [types count] == 0) {
        if ([key isEqualToString:aType])
            [types addObjectsFromArray:[aDictionary objectForKey:key]];
    }
    return types;
}
- (NSInteger)mediaTypeForMediaAtPath:(id)aPath
{
    if (aPath == nil)
        return 0;
    NSArray *types = [self mediaTypesFromDictionary:[self mediaTypesByGroups] forFileType:[self mediaType]];
    NSEnumerator *enumerator = [types objectEnumerator];
    NSInteger mediaType = 0;
    id type;
    while ((type = [enumerator nextObject]) != nil && mediaType == 0) {
        if ([self canUseMediaFromPath:aPath forMediaType:[type intValue]])
            mediaType = [type intValue];
    }
    return mediaType;
}
- (id)mediaTypesByGroups
{
    static NSDictionary *sMediaTypesByGroups;
    if (sMediaTypesByGroups == nil)
        sMediaTypesByGroups = [[HSPlayerBaseID extraDictionaryNamed:@"MediaTypesByGroups"] retain];
    return sMediaTypesByGroups;
}
- (id)dictionaryRepresentation
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[self mediaType], @"mediaType", [self mediaName], @"mediaName", [self mediaData], @"mediaData", nil];
}
// Follows the alias when the file has moved.
- (id)fullPathToMediaFile
{
    if (_fileAlias != NULL) {
        FSRef ref;
        Boolean wasChanged = false;
        if (FSResolveAlias(NULL, (AliasHandle)_fileAlias, &ref, &wasChanged) == noErr && wasChanged) {
            CFURLRef url = CFURLCreateFromFSRef(kCFAllocatorDefault, &ref);
            if (url != NULL) {
                [_fullPathToMediaFile release];
                _fullPathToMediaFile = [[(NSURL *)url path] copy];
                CFRelease(url);
            }
        }
    }
    return _fullPathToMediaFile;
}
- (id)mediaDataSize
{
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:[[self fullPathToMediaFile] stringByResolvingSymlinksInPath] error:NULL] objectForKey:NSFileSize];
}
- (id)mediaData
{
    return [NSData dataWithContentsOfFile:[self fullPathToMediaFile]];
}
- (id)mediaName
{
    return _mediaName;
}
- (NSInteger)mediaGroup
{
    if (_mediaGroup == 0)
        _mediaGroup = (int)[self mediaTypeForMediaAtPath:[self fullPathToMediaFile]];
    return _mediaGroup;
}
- (id)mediaType
{
    if (_mediaType == nil) {
        _mediaType = [[NSFileManager defaultManager] hyperFileTypeAtPath:[self fullPathToMediaFile]];
        if (![[HSNewMediaAccessor supportedMediaTypes] containsObject:_mediaType])
            _mediaType = [[[self fullPathToMediaFile] pathExtension] lowercaseString];
        [_mediaType retain];
    }
    return _mediaType;
}
- (id)mediaUID
{
    return _uid;
}
@end
