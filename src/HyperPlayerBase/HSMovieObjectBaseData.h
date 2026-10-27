#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObjectData.h"


@interface HSMovieObjectBaseData : HSShadowedObjectData
{
    HSNewMedia *_media;
    struct HSTimeRange _storedPlayRange;
    double _startTime;
    int _loopMode;
    unsigned int _playCount;
    float _volume;
    BOOL _startingOnClick;
    BOOL _allowPlayingOtherMovies;
    BOOL _allowPlayingOtherSounds;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setAllowPlayingOtherSounds:(BOOL)aSounds;
- (BOOL)isAllowPlayingOtherSounds;
- (void)setAllowPlayingOtherMovies:(BOOL)aMovies;
- (BOOL)isAllowPlayingOtherMovies;
- (void)setStartingOnClick:(BOOL)aClick;
- (BOOL)isStartingOnClick;
- (void)setVolume:(CGFloat)aVolume;
- (CGFloat)volume;
- (void)setPlayCount:(NSUInteger)aCount;
- (NSUInteger)playCount;
- (void)setLoopMode:(NSInteger)aMode;
- (NSInteger)loopMode;
- (void)setStartTime:(double)aTime;
- (double)startTime;
- (void)setPlayRangeAsString:(id)aString;
- (id)playRangeAsString;
- (void)setStoredPlayRange:(struct HSTimeRange)aRange;
- (struct HSTimeRange)storedPlayRange;
- (void)setMedia:(id)aMedia;
- (id)media;
- (void)setMediaUID:(id)aUID;
- (id)mediaUID;
- (void)dealloc;
- (id)init;
@end

