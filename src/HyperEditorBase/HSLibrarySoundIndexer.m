#import "HSLibrarySoundIndexer.h"

// The durations of the library sounds by file name (soundsIndex.plist in
// the support folder, else the one shipped with the sounds); a singleton
// never released.

static HSLibrarySoundIndexer *sSharedIndexer;

@implementation HSLibrarySoundIndexer

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (sSharedIndexer == nil) {
            sSharedIndexer = [super allocWithZone:aZone];
            return sSharedIndexer;
        }
    }
    return nil;
}

+ (id)sharedLibrarySoundIndexing
{
    @synchronized(self) {
        if (sSharedIndexer == nil)
            [[self alloc] init];
    }
    return sSharedIndexer;
}

- (void)synchronize
{
    if (!_hasChanges)
        return;
    NSString *folder = [[HSPathsProvider sharedPathsProvider] hyperStudioSupportFolder];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:_soundPathToDurationMap format:NSPropertyListXMLFormat_v1_0 options:0 error:NULL];
    if (data != nil)
        [data writeToFile:[folder stringByAppendingPathComponent:@"soundsIndex.plist"] atomically:YES];
}

- (void)setDuration:(id)aDuration forLibrarySoundAtPath:(id)aPath
{
    [_soundPathToDurationMap setObject:aDuration forKey:[aPath lastPathComponent]];
    _hasChanges = YES;
}

- (id)durationForLibrarySoundAtPath:(id)aPath
{
    return [_soundPathToDurationMap objectForKey:[aPath lastPathComponent]];
}

- (id)init
{
    if ((self = [super init])) {
        NSString *folder = [[HSPathsProvider sharedPathsProvider] hyperStudioSupportFolder];
        _soundPathToDurationMap = [[NSMutableDictionary alloc] initWithContentsOfFile:[folder stringByAppendingPathComponent:@"soundsIndex.plist"]];
        if (_soundPathToDurationMap == nil) {
            folder = [[HSPathsProvider sharedPathsProvider] mediaSoundFolder];
            _soundPathToDurationMap = [[NSMutableDictionary alloc] initWithContentsOfFile:[folder stringByAppendingPathComponent:@"soundsIndex.plist"]];
        }
        // Fix: with neither file the map was nil and nothing was ever kept.
        if (_soundPathToDurationMap == nil)
            _soundPathToDurationMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_soundPathToDurationMap release];
    [super dealloc];
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
