#import "HSMovieObjectBaseData.h"
#import "HSNewMediaAccessor.h"

@implementation HSMovieObjectBaseData

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    if (![[aContext codingOperation] isEqualToString:@"HSObjectStyleCodingOperation"]) {
        [keys addObject:@"mediaUID"];
        [keys addObject:@"startTime"];
        [keys addObject:@"playRangeAsString"];
    }
    [keys addObject:@"playCount"];
    [keys addObject:@"volume"];
    [keys addObject:@"startingOnClick"];
    [keys addObject:@"allowPlayingOtherMovies"];
    [keys addObject:@"allowPlayingOtherSounds"];
    return keys;
}

- (void)setAllowPlayingOtherSounds:(BOOL)aSounds
{
    _allowPlayingOtherSounds = aSounds;
}

- (BOOL)isAllowPlayingOtherSounds
{
    return _allowPlayingOtherSounds;
}

- (void)setAllowPlayingOtherMovies:(BOOL)aMovies
{
    _allowPlayingOtherMovies = aMovies;
}

- (BOOL)isAllowPlayingOtherMovies
{
    return _allowPlayingOtherMovies;
}

- (void)setStartingOnClick:(BOOL)aClick
{
    _startingOnClick = aClick;
}

- (BOOL)isStartingOnClick
{
    return _startingOnClick;
}

- (void)setVolume:(CGFloat)aVolume
{
    _volume = aVolume;
}

- (CGFloat)volume
{
    return _volume;
}

- (void)setPlayCount:(NSUInteger)aCount
{
    _playCount = (unsigned int)aCount;
}

- (NSUInteger)playCount
{
    return _playCount;
}

- (void)setLoopMode:(NSInteger)aMode
{
    _loopMode = (int)aMode;
}

- (NSInteger)loopMode
{
    return _loopMode;
}

- (void)setStartTime:(double)aTime
{
    _startTime = aTime;
}

- (double)startTime
{
    return _startTime;
}

- (void)setPlayRangeAsString:(id)aString
{
    // Stored as an NSSize string: width = location, height = length.
    NSSize size = NSSizeFromString(aString);
    struct HSTimeRange range = HSMakeTimeRange((float)size.width, (float)size.height);
    [self setStoredPlayRange:range];
    if ([self hasOwner])
        [[[self owner] anyOwningObjectForNodeData:self] setPlayRange:range];
}

- (id)playRangeAsString
{
    NSSize size = NSZeroSize;
    if ([self hasOwner]) {
        id object = [[self owner] anyOwningObjectForNodeData:self];
        size = NSMakeSize((float)[object playRange].location, (float)[object playRange].length);
    }
    return NSStringFromSize(size);
}

- (void)setStoredPlayRange:(struct HSTimeRange)aRange
{
    _storedPlayRange = aRange;
}

- (struct HSTimeRange)storedPlayRange
{
    return _storedPlayRange;
}

- (void)setMedia:(id)aMedia
{
    if (_media != aMedia) {
        [_media release];
        _media = [aMedia retain];
    }
}

- (id)media
{
    return _media;
}

- (void)setMediaUID:(id)aUID
{
    [self setMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID]];
}

- (id)mediaUID
{
    return [[self media] mediaUID];
}

- (void)dealloc
{
    [_media release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _storedPlayRange = HSMakeTimeRange(0.0, 0.0);
        _startTime = 0.0;
        _loopMode = 0;
        _volume = 1.0f;
        _playCount = 1;
    }
    return self;
}

@end
