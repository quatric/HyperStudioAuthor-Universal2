#import "HyperPlayerBasePrefix.h"


@interface HSMovieProxy : NSProxy
{
    NSString *_movieFilePath;
    HSMovie *_movie;
    id _delegate;
    BOOL _isOpaque;
    struct HSTimeRange _range;
    double _fadeOutTime;
    double _fadeInTime;
    unsigned int _playCount;
    float _volume;
    double _currentTime;
    unsigned int _angularUnits;
    float _tiltAngle;
    float _panAngle;
    float _fieldOfView;
    unsigned int _backupDisablingCounter;
}
+ (BOOL)respondsToSelector:(SEL)aSelector;
+ (id)movieWithURL:(id)aURL error:(id *)aError;
+ (id)movieWithMovie:(id)aMovie error:(id *)aError;
+ (void)registerMovieProxy:(id)aProxy;
+ (void)unregisterMovieProxy:(id)aProxy;
+ (id)movieProxies;
+ (id)proxyContainers;
- (void)repostNofication:(id)aNofication;
- (void)setDelegate:(id)aDelegate;
- (BOOL)isPlaying;
- (BOOL)isOpaque;
- (void)backupMovie;
- (void)setMovie:(id)aMovie;
- (id)movie;
- (void)saveMovieSettings;
- (void)restoreMovieSettings;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (void)forwardInvocation:(id)aInvocation;
- (id)initWithMovie:(id)aMovie;
- (id)initWithURL:(id)aURL error:(id *)aError;
- (id)initWithMovie:(id)aMovie error:(id *)aError;
- (void)dealloc;
@end

