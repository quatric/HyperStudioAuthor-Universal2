#import "HSLibrarySound.h"

// A sound file of the library; its duration is indexed.

@implementation HSLibrarySound

// Durations as [h:]mm:ss.
+ (id)stringForValue:(id)aValue forIdentifier:(id)aIdentifier
{
    if (![aIdentifier isEqualToString:biTotalTimeKey])
        return [aValue isKindOfClass:[NSString class]] ? aValue : nil;
    int seconds = [aValue intValue];
    int rest = seconds % 3600;
    NSString *string = seconds >= 3600 ? [NSString stringWithFormat:@"%d:", seconds / 3600] : [NSString string];
    string = [string stringByAppendingFormat:rest < 600 && seconds >= 3600 ? @"0%d:" : @"%d:", rest / 60];
    return [string stringByAppendingFormat:rest % 60 < 10 ? @"0%d" : @"%d", rest % 60];
}

+ (CGFloat)maxWidthForIdentifier:(id)aIdentifier cell:(id)aCell
{
    return [self minWidthForIdentifier:aIdentifier cell:aCell];
}

+ (CGFloat)minWidthForIdentifier:(id)aIdentifier cell:(id)aCell
{
    return -1.0;
}

+ (id)soundIdentifiers
{
    return [NSArray arrayWithObjects:itHumanReadableNameKey, biTotalTimeKey, nil];
}

+ (BOOL)canInitWithURL:(id)aURL
{
    return YES;
}

// The indexed duration, else the movie's (then indexed).
- (id)getTotalTime
{
    if (_duration == nil) {
        HSLibrarySoundIndexer *indexer = [HSLibrarySoundIndexer sharedLibrarySoundIndexing];
        // Fix: the indexed duration was kept without being retained.
        _duration = [[indexer durationForLibrarySoundAtPath:[[self URL] path]] retain];
        if (_duration == nil) {
            HSMovie *movie = [HSMovie movieWithURL:[self URL] error:NULL];
            _duration = [[NSNumber alloc] initWithDouble:[movie duration]];
            [indexer setDuration:_duration forLibrarySoundAtPath:[[self URL] path]];
        }
    }
    return _duration;
}

- (id)getArtist
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"SoundsArtist" value:@"" table:@"Sounds"];
}

- (id)getName
{
    return [self displayName];
}

- (NSInteger)compareWithSound:(id)aSound
{
    return [[self displayName] caseInsensitiveCompare:[aSound displayName]];
}

- (id)dataDisplayName
{
    return [self displayName];
}

- (id)dataURL
{
    return [self URL];
}

- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType
{
    NSPasteboard *pasteboard = aPasteboard;
    if ([aType isEqualToString:@"HSLibraryReusableMediaPboardType"]) {
        NSString *path = [[self URL] path];
        NSString *uid = [[[HSLibraryManager sharedLibraryManager] soundsContentFilter] globalUIDStringForMediaItem:path];
        if (path != nil && uid != nil)
            [pasteboard setPropertyList:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:uid, @"HSLibraryReusableMediaGlobalUIDKey", path, @"HSLibraryReusableMediaPathKey", nil]] forType:aType];
    } else if ([aType isEqualToString:NSStringPboardType]) {
        NSString *name = [self displayName];
        if (name != nil)
            [pasteboard setString:name forType:aType];
    } else if ([aType isEqualToString:NSURLPboardType]) {
        [[self URL] writeToPasteboard:pasteboard];
    } else if ([aType isEqualToString:NSRTFPboardType] || [aType isEqualToString:NSRTFDPboardType]) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:[self displayName]];
        NSRange range = NSMakeRange(0, [string length]);
        NSData *data = [aType isEqualToString:NSRTFPboardType] ? [string RTFFromRange:range documentAttributes:@{}] : [string RTFDFromRange:range documentAttributes:@{}];
        [string release];
        if (data != nil)
            [pasteboard setData:data forType:aType];
    }
}

- (id)info
{
    if (_info == nil)
        _info = [[[NSFileManager defaultManager] attributesOfItemAtPath:[[[self URL] path] stringByResolvingSymlinksInPath] error:NULL] retain];
    return _info;
}

- (BOOL)hasAccessibleURL
{
    if (!_urlAccessTested) {
        NSURL *url = [self URL];
        if ([url isFileURL])
            _urlAccessOk = [[NSFileManager defaultManager] isReadableFileAtPath:[url path]];
        _urlAccessTested = YES;
    }
    return _urlAccessOk;
}

- (id)displayName
{
    if (_displayString == nil)
        _displayString = [[[[[self URL] path] lastPathComponent] stringByDeletingPathExtension] retain];
    return _displayString;
}

- (id)URL
{
    return _soundURL;
}

- (void)dealloc
{
    [_soundURL release];
    [_displayString release];
    [_info release];
    [_duration release];
    [super dealloc];
}

- (id)initWithURL:(id)aURL
{
    if ((self = [super init]))
        _soundURL = [aURL retain];
    return self;
}

@end
