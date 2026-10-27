#import "HSCelMovieNodeUnit.h"
#import "HSAnimationMoviePlayback.h"
#import "HSCelMovieAttributesImplementation.h"
#import "HSCelMovieObjectFramesLazyCacheItem.h"
#import "HSFunctions.h"
#import "HSNewMediaAccessor.h"
#import "HSProtocolIdentifier.h"
#import "HSThreadInvocationWrapper.h"
#import "NSEMutableProtocolSet.h"
#import "NSMutableDictionary+EXValue.h"

// A movie made of a sequence of image media ("cels") played at a fixed rate.
// Frame i covers [i, i + 1) * _oneFrameTime; the current time sits in the
// middle of the current frame.
@implementation HSCelMovieNodeUnit

+ (id)keysForStoring
{
    return [NSArray arrayWithObjects:[@"framesMedia" extraKeyForCollection], @"defaultFrameSizeData", @"framesPerSecond",
            @"playLoopMode", @"eraseWhenDone", nil];
}

- (void)HSCelMovieNodeUnit_setFramesMedia:(id)aMedia cacheFrames:(id)aFrames
{
    if (_framesMediaUIDs == aMedia)
        return;

    [_framesMediaUIDs release];
    _framesMediaUIDs = [aMedia retain];
    [_framesMedia release];
    _framesMedia = [[NSMutableArray alloc] initWithCapacity:[aMedia count]];
    NSEnumerator *enumerator = [aMedia objectEnumerator];
    id UID;
    while ((UID = [enumerator nextObject]) != nil) {
        id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:UID];
        if (media != nil)
            [_framesMedia addObject:media];
    }
    _playTimeRange = HSMakeTimeRange(0, [_framesMediaUIDs count] / _framesPerSecond);

    if (_precachedFrameImages != aFrames) {
        [_precachedFrameImages release];
        _precachedFrameImages = [aFrames retain];
        [HSCelMovieObjectFramesCache precacheFramesMedia:_framesMediaUIDs frameImages:_precachedFrameImages];
    }
}

- (void)HSCelMovieNodeUnit_setCurrentTime:(double)aTime
{
    _currentFrame = (unsigned int)floor(aTime / _oneFrameTime);
    _currentTime = ((double)_currentFrame + 0.5) * _oneFrameTime;
    [self notifyChange:2 ofAttribute:@protocol(HSImageAttribute) withUserInfo:nil];
}

- (void)HSCelMovieNodeUnit_setFramesPerSecond:(double)aSecond resetPlayTimeRange:(BOOL)aRange
{
    _framesPerSecond = fabs(aSecond);
    _oneFrameTime = 1.0 / _framesPerSecond;
    double duration = [_framesMediaUIDs count] / _framesPerSecond;
    if (aRange) {
        _playTimeRange = HSMakeTimeRange(0, duration);
    } else if (_playTimeRange.location <= duration) {
        // Clip the play range to the new duration.
        if (HSMaxTimeRange(_playTimeRange) <= duration)
            return;
        _playTimeRange.length = duration - _playTimeRange.location;
    } else {
        _playTimeRange = HSMakeTimeRange(duration, 0);
    }
}

- (void)HSCelMovieNodeUnit_incrementLoopedCelMovieTime:(id)aTime
{
    double time = _currentTime + _oneFrameTime;
    if (_playbackDuration <= time) {
        _playbackRepeatsCount++;
        if (_movieStarter != nil && [_movieStarter respondsToSelector:@selector(hyperPlayableObjectDidPlayOnce:frameCount:)]) {
            for (id node in [self hostNodes]) {
                id playable = [node queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
                if (playable != nil)
                    [_movieStarter hyperPlayableObjectDidPlayOnce:playable frameCount:_playbackRepeatsCount];
            }
        }
        // Quirk kept: loops restart at time 0, not at the play range start.
        time = 0.0;
    }
    if (_isPlaying)
        [self HSCelMovieNodeUnit_setCurrentTime:time];
}

- (void)HSCelMovieNodeUnit_incrementCelMovieTime:(id)aTime
{
    double time = _currentTime + _oneFrameTime;
    if (_playbackDuration <= time)
        [self stopCelMovie];
    else
        [self HSCelMovieNodeUnit_setCurrentTime:time];
}

- (id)frameImageForMediaUID:(id)aUID
{
    if (_precachedFrameImages != nil) {
        @try {
            NSUInteger index = [_framesMediaUIDs indexOfObject:aUID];
            if (index != NSNotFound)
                return [_precachedFrameImages objectAtIndex:index];
        } @catch (NSException *exception) {
        }
    }
    id image = [HSCelMovieObjectFramesCache cachedFrameForMediaUID:aUID groupIdentifier:nil];
    if (image == nil)
        image = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID] image];
    return image;
}

- (void)releasePrecachedFrameImages
{
    [_precachedFrameImages release];
    _precachedFrameImages = nil;
}

- (id)precachedFrameImages
{
    return _precachedFrameImages;
}

- (id)celMovieStarter
{
    return _movieStarter;
}

- (BOOL)isCelMoviePlaying
{
    return _isPlaying;
}

- (void)stopCelMovie
{
    [_playbackTimer invalidate];
    [_playbackTimer release];
    _playbackTimer = nil;
    if (!_isPlaying)
        return;

    _isPlaying = NO;
    if (_movieStarter != nil && [_movieStarter respondsToSelector:@selector(hyperPlayableObjectDidStop:)]) {
        for (id node in [self hostNodes]) {
            id playable = [node queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
            if (playable != nil)
                [_movieStarter hyperPlayableObjectDidStop:playable];
        }
    }
    _movieStarter = nil;
    _playbackDuration = 0.0;
    [self notifyChange:0x80 ofAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSImageAttribute), @protocol(HSImageRectAttribute), nil] withUserInfo:nil];
}

- (void)startCelMovieAtRate:(CGFloat)aRate starter:(id)aStarter startupMode:(NSInteger)aMode
{
    if (_isPlaying)
        [self stopCelMovie];
    if (_oneFrameTime == 0.0 || aRate == 0.0)
        return;

    _playbackDuration = HSMaxTimeRange(_playTimeRange);
    // Needs at least two frames to play.
    if (_oneFrameTime + _oneFrameTime > _playbackDuration)
        return;

    _currentFrame = (unsigned int)floor(_playTimeRange.location / _oneFrameTime);
    _currentTime = ((double)_currentFrame + 0.5) * _oneFrameTime;
    _playbackRepeatsCount = 0;
    _movieStarter = aStarter;
    [self notifyChange:0x40 ofAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSImageAttribute), @protocol(HSImageRectAttribute), nil] withUserInfo:nil];
    _isPlaying = YES;
    if (aMode == 0 && _playbackTimer == nil) {
        SEL selector = _playLoopMode == 1 ? @selector(HSCelMovieNodeUnit_incrementLoopedCelMovieTime:) : @selector(HSCelMovieNodeUnit_incrementCelMovieTime:);
        _playbackTimer = [[NSThread hyperScheduledThreadTimerWithInterval:1.0 / (fabs((double)aRate) * _framesPerSecond) mainThreadTarget:self selector:selector object:nil repeats:YES] retain];
    }
}

- (void)setCurrentTime:(double)aTime
{
    double duration = [self duration];
    double time;
    if (_playLoopMode == 1) {
        time = fmod(aTime, duration);
        if (time < 0.0)
            time += duration;
    } else {
        time = 0.0;
        if (aTime >= 0.0) {
            time = aTime;
            if (duration <= aTime)
                time = duration - _oneFrameTime;
        }
    }
    [self HSCelMovieNodeUnit_setCurrentTime:time];
}

- (double)previousInterestingTime
{
    int previousFrame = (int)((unsigned int)floor(_currentTime / _oneFrameTime) - 1);
    if (previousFrame >= 0)
        return previousFrame * _oneFrameTime;
    if (_playLoopMode == 0)
        return 0.0;
    return [self duration] - _oneFrameTime;
}

- (double)nextInterestingTime
{
    NSUInteger nextFrame = (unsigned int)floor(_currentTime / _oneFrameTime) + 1;
    if (nextFrame < [self movieFramesCount])
        return nextFrame * _oneFrameTime;
    if (_playLoopMode == 0)
        return _currentTime;
    return 0.0;
}

- (double)currentTime
{
    return _currentTime;
}

- (NSUInteger)currentFrameIndex
{
    return _currentFrame;
}

- (NSUInteger)movieFramesCount
{
    return [[self framesMedia] count];
}

- (void)setEraseWhenDone:(BOOL)aDone
{
    _eraseLastFrame = aDone;
}

- (BOOL)eraseWhenDone
{
    return _eraseLastFrame;
}

- (double)duration
{
    return [_framesMediaUIDs count] / _framesPerSecond;
}

- (id)playableObjectName
{
    return nil;
}

- (void)setPlayTimeRange:(struct HSTimeRange)aRange
{
    double duration = [self duration];
    if (aRange.location >= 0.0)
        _playTimeRange.location = MIN(aRange.location, duration);
    else
        _playTimeRange.location = 0.0;

    if (aRange.length >= 0.0) {
        // Quirk kept: the overflow test uses the previous length.
        if (HSMaxTimeRange(_playTimeRange) > duration)
            aRange.length = duration - _playTimeRange.location;
        _playTimeRange.length = aRange.length;
    } else {
        _playTimeRange.length = 0.0;
    }
}

- (struct HSTimeRange)playTimeRange
{
    return _playTimeRange;
}

- (void)setPlayLoopMode:(NSInteger)aMode
{
    _playLoopMode = (int)aMode;
}

- (NSInteger)playLoopMode
{
    return _playLoopMode;
}

- (void)setPlayCount:(NSUInteger)aCount
{
    _playCount = (unsigned int)aCount;
}

- (NSUInteger)playCount
{
    return _playCount;
}

- (void)setFrameTimeLength:(long long)aLength
{
    double framesPerSecond = aLength == 0 ? 12.0 : HSDefaultCelMovieScaling / (double)aLength;
    [self HSCelMovieNodeUnit_setFramesPerSecond:framesPerSecond resetPlayTimeRange:NO];
}

- (void)setFramesPerSecond:(double)aSecond
{
    [self HSCelMovieNodeUnit_setFramesPerSecond:aSecond resetPlayTimeRange:YES];
}

- (double)framesPerSecond
{
    return _framesPerSecond;
}

- (void)setDefaultFrameSize:(NSSize)aSize
{
    _defaultFrameSize = aSize;
}

- (NSSize)defaultFrameSize
{
    return _defaultFrameSize;
}

- (void)setFramesMedia:(id)aMedia precachedFrames:(id)aFrames
{
    [self HSCelMovieNodeUnit_setFramesMedia:aMedia cacheFrames:aFrames];
}

- (void)setFramesMedia:(id)aMedia
{
    [self HSCelMovieNodeUnit_setFramesMedia:aMedia cacheFrames:nil];
}

- (id)framesMedia
{
    return _framesMediaUIDs;
}

- (void)setDefaultFrameSizeData:(id)aData
{
    if (aData != nil)
        [self setDefaultFrameSize:[aData extraSizeValue]];
}

- (id)defaultFrameSizeData
{
    return [NSDictionary extraDictionaryWithSize:_defaultFrameSize];
}

- (id)objectMediaUIDs
{
    if ([_framesMediaUIDs count] == 0)
        return [NSSet set];
    return [NSSet setWithArray:_framesMediaUIDs];
}

- (id)mediaUIDs
{
    NSSet *mediaUIDs = [super mediaUIDs];
    NSSet *objectMediaUIDs = [self objectMediaUIDs];
    if ([mediaUIDs count] != 0 && [objectMediaUIDs count] != 0) {
        NSMutableSet *allUIDs = [NSMutableSet setWithSet:mediaUIDs];
        [allUIDs unionSet:objectMediaUIDs];
        return allUIDs;
    }
    if ([objectMediaUIDs count] != 0)
        return objectMediaUIDs;
    return mediaUIDs;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[[self class] keysForStoring]];
}

- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if ([self implementsHyperInterface:aInterface])
        return [HSCelMovieAttributesImplementation class];
    return Nil;
}

- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSCelMovieObjectAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayableObjectAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSExtendedPlayableObjectAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSFramesPerSecondAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSImageAttributes), aInterface);
}

- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSCelMovieObjectAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSPlayableObjectAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSExtendedPlayableObjectAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSFramesPerSecondAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSImageAttributes)], nil];
}

- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocols:@protocol(HSImageAttribute), nil];
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSCelMovieNodeUnit *copy = [super copyWithZone:aZone];
    // The storage round trip in super already set these; the original leaked them.
    [copy->_framesMedia release];
    copy->_framesMedia = (NSMutableArray *)[[NSArray alloc] initWithArray:_framesMedia copyItems:YES];
    [copy->_precachedFrameImages release];
    copy->_precachedFrameImages = [[NSMutableArray alloc] initWithArray:_precachedFrameImages copyItems:YES];
    copy->_movieStarter = _movieStarter;
    [copy->_playbackTimer release];
    copy->_playbackTimer = [_playbackTimer retain];
    copy->_framesPerSecond = _framesPerSecond;
    copy->_oneFrameTime = _oneFrameTime;
    copy->_playTimeRange = _playTimeRange;
    copy->_defaultFrameSize = _defaultFrameSize;
    copy->_playLoopMode = _playLoopMode;
    copy->_currentFrame = _currentFrame;
    copy->_currentTime = _currentTime;
    copy->_playbackDuration = _playbackDuration;
    copy->_playbackRepeatsCount = _playbackRepeatsCount;
    copy->_isPlaying = _isPlaying;
    copy->_eraseLastFrame = _eraseLastFrame;
    return copy;
}

- (void)dealloc
{
    if (_playbackTimer != nil) {
        [_playbackTimer invalidate];
        [_playbackTimer release];
    }
    [_framesMediaUIDs release];
    [_framesMedia release];
    [_precachedFrameImages release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _framesPerSecond = 12.0;
        _oneFrameTime = 1.0 / 12.0;
        _playLoopMode = 1;
    }
    return self;
}

@end
