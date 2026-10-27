#import "HSMoviePlaybackLogger.h"
#import "HSMovie.h"
#import "HSMovieProxy.h"

@implementation HSMoviePlaybackLogger

- (id)log
{
    id log = [[_log copy] autorelease];
    return log ? log : [NSArray array];
}

- (void)movieDidPlayOnce:(id)aOnce
{
    [self movieDidStop:aOnce];
    [self movieDidStart:aOnce];
}

- (void)movieDidStop:(id)aStop
{
    id movie = [aStop object];
    // Close the latest open entry for this movie.
    for (HSMoviePlaybackLogItem *item in [_log reverseObjectEnumerator]) {
        if ([item movie] == movie) {
            if ([item duration] < 0.0)
                [item setDuration:[NSDate timeIntervalSinceReferenceDate] - [item startTime]];
            return;
        }
    }
}

- (void)movieDidStart:(id)aStart
{
    id movie = [aStart object];
    if ([[HSMovieProxy movieProxies] containsObject:movie])
        return;
    double currentTime = [(HSMovie *)movie currentTime];
    float volume = [(HSMovie *)movie volume];
    [self logItem:[HSMoviePlaybackLogItem itemWithMovie:movie
                                              startTime:[NSDate timeIntervalSinceReferenceDate]
                                               duration:-1.0
                                                 volume:volume
                                    currentPlaybackTime:currentTime]];
}

- (void)movieRateDidChange:(id)aChange
{
    id rateValue = [[aChange userInfo] objectForKey:HSMovieRateDidChangeNotificationParameter];
    if (rateValue == nil)
        return;
    float rate = [rateValue floatValue];
    float magnitude = rate != 0.0f ? fabsf(rate) : 1.0f;
    float epsilon = magnitude >= 1.0f ? magnitude * 0.0005f : 0.0005f;
    if (rate > epsilon + 0.0f)
        [self movieDidStart:aChange];
}

- (void)logItem:(id)aItem
{
    if (_log == nil)
        _log = [NSMutableArray new];
    if (aItem != nil)
        [_log addObject:aItem];
}

- (void)stopLogging
{
    if (_isLogging) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:HSMovieDidStopNotification object:nil];
        [center removeObserver:self name:HSMovieDidStartNotification object:nil];
        [center removeObserver:self name:HSMovieRateDidChangeNotification object:nil];
        [center removeObserver:self name:HSMovieDidPlayOnceNotification object:nil];
        _isLogging = NO;
    }
}

- (void)startLogging
{
    if (!_isLogging) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(movieDidStart:) name:HSMovieDidStartNotification object:nil];
        [center addObserver:self selector:@selector(movieDidStop:) name:HSMovieDidStopNotification object:nil];
        [center addObserver:self selector:@selector(movieRateDidChange:) name:HSMovieRateDidChangeNotification object:nil];
        [center addObserver:self selector:@selector(movieDidPlayOnce:) name:HSMovieDidPlayOnceNotification object:nil];
        _isLogging = YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_log release];
    [super dealloc];
}

@end

@implementation HSMoviePlaybackLogItem

+ (id)itemWithMovie:(id)aMovie startTime:(double)aTime duration:(double)aDuration volume:(CGFloat)aVolume currentPlaybackTime:(double)aTime2
{
    HSMoviePlaybackLogItem *item = [[HSMoviePlaybackLogItem new] autorelease];
    [item setMovie:aMovie];
    [item setStartTime:aTime];
    [item setDuration:aDuration];
    [item setVolume:aVolume];
    [item setCurrentPlaybackTime:aTime2];
    return item;
}

- (id)description
{
    return [NSString stringWithFormat:@"<%@ start:%f duration:%f volume:%f>", _movie, _startTime, _duration, (double)_volume];
}

- (void)setCurrentPlaybackTime:(double)aTime
{
    _currentPlaybackTime = aTime;
}

- (double)currentPlaybackTime
{
    return _currentPlaybackTime;
}

- (void)setVolume:(CGFloat)aVolume
{
    _volume = aVolume;
}

- (CGFloat)volume
{
    return _volume;
}

- (void)setMovie:(id)aMovie
{
    if (_movie != aMovie) {
        [_movie release];
        _movie = [aMovie retain];
    }
}

- (id)movie
{
    return _movie;
}

- (void)setDuration:(double)aDuration
{
    _duration = aDuration;
}

- (double)duration
{
    return _duration;
}

- (void)setStartTime:(double)aTime
{
    _startTime = aTime;
}

- (double)startTime
{
    return _startTime;
}

- (void)dealloc
{
    [_movie release];
    [super dealloc];
}

- (id)copyWithStartTime:(double)aTime
{
    return [[HSMoviePlaybackLogItem itemWithMovie:[self movie] startTime:aTime duration:[self duration]
                                           volume:[self volume] currentPlaybackTime:[self currentPlaybackTime]] retain];
}

@end
