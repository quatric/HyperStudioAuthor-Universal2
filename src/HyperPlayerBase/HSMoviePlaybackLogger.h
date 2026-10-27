#import "HyperPlayerBasePrefix.h"


@interface HSMoviePlaybackLogger : NSObject
{
    NSMutableArray *_log;
    BOOL _isLogging;
}
- (id)log;
- (void)movieDidPlayOnce:(id)aOnce;
- (void)movieDidStop:(id)aStop;
- (void)movieDidStart:(id)aStart;
- (void)movieRateDidChange:(id)aChange;
- (void)logItem:(id)aItem;
- (void)stopLogging;
- (void)startLogging;
- (void)dealloc;
@end

@interface HSMoviePlaybackLogItem : NSObject
{
    double _startTime;
    double _duration;
    double _currentPlaybackTime;
    HSMovie *_movie;
    float _volume;
}
+ (id)itemWithMovie:(id)aMovie startTime:(double)aTime duration:(double)aDuration volume:(CGFloat)aVolume currentPlaybackTime:(double)aTime2;
- (id)description;
- (void)setCurrentPlaybackTime:(double)aTime;
- (double)currentPlaybackTime;
- (void)setVolume:(CGFloat)aVolume;
- (CGFloat)volume;
- (void)setMovie:(id)aMovie;
- (id)movie;
- (void)setDuration:(double)aDuration;
- (double)duration;
- (void)setStartTime:(double)aTime;
- (double)startTime;
- (void)dealloc;
- (id)copyWithStartTime:(double)aTime;
@end

