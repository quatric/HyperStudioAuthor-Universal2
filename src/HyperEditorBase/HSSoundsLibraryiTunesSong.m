#import "HSSoundsLibraryiTunesSong.h"

// A song of the iTunes library, from its library dictionary.

@implementation HSSoundsLibraryiTunesSong

// The name gets the video badge for songs with video.
+ (id)valueForSong:(id)aSong forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo
{
    id value = [self stringForSong:aSong forIdentifier:aIdentifier];
    if (aInfo != nil)
        value = [[[NSAttributedString alloc] initWithString:value attributes:aInfo] autorelease];
    if ([aIdentifier isEqualToString:itHumanReadableNameKey] && [aSong hasVideo])
        value = [NSArray arrayWithObjects:value, [aSong hasVideoImage], nil];
    return value;
}

// Total times (milliseconds) as [h:]mm:ss.
+ (id)stringForSong:(id)aSong forIdentifier:(id)aIdentifier
{
    if (aIdentifier == nil || aSong == nil)
        return @"";
    id value = [[aSong info] objectForKey:aIdentifier];
    if (![aIdentifier isEqualToString:itTotalTimeKey])
        return [value isKindOfClass:[NSString class]] ? value : nil;
    int milliseconds = [value intValue];
    int rest = milliseconds / 1000 - (milliseconds / 3600000) * 3600;
    BOOL hours = milliseconds >= 3600000;
    NSString *string = hours ? [NSString stringWithFormat:@"%d:", milliseconds / 3600000] : [NSString string];
    string = [string stringByAppendingFormat:rest < 600 && hours ? @"0%d:" : @"%d:", rest / 60];
    return [string stringByAppendingFormat:rest % 60 < 10 ? @"0%d" : @"%d", rest % 60];
}

+ (id)dataCellForIdentifier:(id)aIdentifier
{
    if (![aIdentifier isEqualToString:itHumanReadableNameKey])
        return nil;
    HSImageTextTableCell *cell = [[HSImageTextTableCell alloc] init];
    [cell setImageTextPosition:2];
    [cell setLineBreakMode:NSLineBreakByTruncatingTail];
    return [cell autorelease];
}

+ (CGFloat)maxWidthForIdentifier:(id)aIdentifier cell:(id)aCell
{
    return [self minWidthForIdentifier:aIdentifier cell:aCell];
}

+ (CGFloat)minWidthForIdentifier:(id)aIdentifier cell:(id)aCell
{
    return -1.0;
}

+ (id)songIdentifiers
{
    return [NSArray arrayWithObjects:itHumanReadableNameKey, itArtistKey, itTotalTimeKey, nil];
}

- (id)hasVideoImage
{
    if (_hasVideoImage == nil) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"iTunesHasVideo" ofType:@"tiff"];
        if (path != nil)
            _hasVideoImage = [[NSImage alloc] initWithContentsOfFile:path];
    }
    return _hasVideoImage;
}

- (BOOL)hasVideo
{
    return [[[self info] objectForKey:itHasVideoKey] boolValue];
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
    if ([aType isEqualToString:NSStringPboardType]) {
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
    return _info;
}

- (void)resetURLAccessTested
{
    _urlAccessTested = NO;
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
    return [[self info] objectForKey:itHumanReadableNameKey];
}

- (id)URL
{
    NSString *location = [[self info] objectForKey:itLocationKey];
    if (location == nil)
        return nil;
    NSURL *url = [NSURL URLWithString:location];
    NSURL *resolved = [HSSoundsLibraryiTunesHelper resolveAliasesInURL:url];
    return resolved != nil ? resolved : url;
}

- (void)dealloc
{
    [_info release];
    [_hasVideoImage release];
    [super dealloc];
}

- (id)initWithDictionaryRepresentation:(id)aRepresentation
{
    if ((self = [super init]))
        _info = [aRepresentation retain];
    return self;
}

- (id)init
{
    return [self initWithDictionaryRepresentation:nil];
}

@end
