#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSCelMovieNodeUnit : HSNodeUnit
{
    NSArray *_framesMediaUIDs;
    NSMutableArray *_framesMedia;
    double _framesPerSecond;
    double _oneFrameTime;
    struct HSTimeRange _playTimeRange;
    NSSize _defaultFrameSize;
    int _playLoopMode;
    unsigned int _playCount;
    id _movieStarter;
    unsigned int _currentFrame;
    double _currentTime;
    NSTimer *_playbackTimer;
    double _playbackDuration;
    unsigned int _playbackRepeatsCount;
    NSArray *_precachedFrameImages;
    unsigned int _isPlaying:1;
    unsigned int _eraseLastFrame:1;
}
+ (id)keysForStoring;
- (void)HSCelMovieNodeUnit_setFramesMedia:(id)aMedia cacheFrames:(id)aFrames;
- (void)HSCelMovieNodeUnit_setCurrentTime:(double)aTime;
- (void)HSCelMovieNodeUnit_setFramesPerSecond:(double)aSecond resetPlayTimeRange:(BOOL)aRange;
- (void)HSCelMovieNodeUnit_incrementLoopedCelMovieTime:(id)aTime;
- (void)HSCelMovieNodeUnit_incrementCelMovieTime:(id)aTime;
- (id)frameImageForMediaUID:(id)aUID;
- (void)releasePrecachedFrameImages;
- (id)precachedFrameImages;
- (id)celMovieStarter;
- (BOOL)isCelMoviePlaying;
- (void)stopCelMovie;
- (void)startCelMovieAtRate:(CGFloat)aRate starter:(id)aStarter startupMode:(NSInteger)aMode;
- (void)setCurrentTime:(double)aTime;
- (double)previousInterestingTime;
- (double)nextInterestingTime;
- (double)currentTime;
- (NSUInteger)currentFrameIndex;
- (NSUInteger)movieFramesCount;
- (void)setEraseWhenDone:(BOOL)aDone;
- (BOOL)eraseWhenDone;
- (double)duration;
- (id)playableObjectName;
- (void)setPlayTimeRange:(struct HSTimeRange)aRange;
- (struct HSTimeRange)playTimeRange;
- (void)setPlayLoopMode:(NSInteger)aMode;
- (NSInteger)playLoopMode;
- (void)setPlayCount:(NSUInteger)aCount;
- (NSUInteger)playCount;
- (void)setFrameTimeLength:(long long)aLength;
- (void)setFramesPerSecond:(double)aSecond;
- (double)framesPerSecond;
- (void)setDefaultFrameSize:(NSSize)aSize;
- (NSSize)defaultFrameSize;
- (void)setFramesMedia:(id)aMedia precachedFrames:(id)aFrames;
- (void)setFramesMedia:(id)aMedia;
- (id)framesMedia;
- (void)setDefaultFrameSizeData:(id)aData;
- (id)defaultFrameSizeData;
- (id)objectMediaUIDs;
- (id)mediaUIDs;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)init;
@end

