#import "HSMovieProxy.h"
#import "HSMovie.h"
#import "NSFileManager+HSExtensions.h"

static NSMutableSet *HSMovieProxyContainers = nil;

// Stands in for an HSMovie loaded from a file. Once more than ten proxies hold
// a movie, the stopped ones save their settings and drop it; the next message
// reloads the movie from the file and restores the settings.
@implementation HSMovieProxy
+ (BOOL)respondsToSelector:(SEL)aSelector
{
    return [HSMovie respondsToSelector:aSelector];
}
+ (id)movieWithURL:(id)aURL error:(id *)aError
{
    return [[[HSMovieProxy alloc] initWithURL:aURL error:aError] autorelease];
}
+ (id)movieWithMovie:(id)aMovie error:(id *)aError
{
    // Fix: the original sent movieWithMovie:error: to the allocated proxy,
    // which forwarded it to a nil movie, returned nil and leaked the proxy.
    return [[[HSMovieProxy alloc] initWithMovie:aMovie error:aError] autorelease];
}
+ (void)registerMovieProxy:(id)aProxy
{
    NSMutableSet *containers = [HSMovieProxy proxyContainers];
    if ([containers count] > 10)
        [[HSMovieProxy movieProxies] makeObjectsPerformSelector:@selector(backupMovie)];
    [containers addObject:[NSValue valueWithNonretainedObject:aProxy]];
}
+ (void)unregisterMovieProxy:(id)aProxy
{
    [[HSMovieProxy proxyContainers] removeObject:[NSValue valueWithNonretainedObject:aProxy]];
}
+ (id)movieProxies
{
    NSMutableSet *proxies = [NSMutableSet set];
    for (NSValue *container in [self proxyContainers])
        [proxies addObject:[container nonretainedObjectValue]];
    return proxies;
}
+ (id)proxyContainers
{
    if (HSMovieProxyContainers == nil)
        HSMovieProxyContainers = [NSMutableSet new];
    return HSMovieProxyContainers;
}
- (void)repostNofication:(id)aNofication
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[(NSNotification *)aNofication name] object:self userInfo:[aNofication userInfo]];
}
- (void)setDelegate:(id)aDelegate
{
    if (_movie) {
        _backupDisablingCounter++;
        [_movie setDelegate:aDelegate];
        _backupDisablingCounter--;
    }
    _delegate = aDelegate;
}
- (BOOL)isPlaying
{
    if (_movie == nil)
        return NO;
    _backupDisablingCounter++;
    BOOL playing = [_movie isPlaying];
    _backupDisablingCounter--;
    return playing;
}
- (BOOL)isOpaque
{
    if (_movie == nil)
        return _isOpaque;
    _backupDisablingCounter++;
    _isOpaque = [_movie isOpaque];
    _backupDisablingCounter--;
    return _isOpaque;
}
- (void)backupMovie
{
    if (_backupDisablingCounter != 0)
        return;
    _backupDisablingCounter = 1;
    if (_movie && ![_movie isPlaying] && _movieFilePath
        && [[NSFileManager defaultManager] hyperIsFileReadableAtPath:_movieFilePath]) {
        [self saveMovieSettings];
        [self setMovie:nil];
    }
    _backupDisablingCounter--;
}
- (void)setMovie:(id)aMovie
{
    HSMovie *oldMovie = _movie;
    if (oldMovie == aMovie)
        return;
    if (oldMovie)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:oldMovie];
    [oldMovie release];
    _movie = [aMovie retain];
    if (_movie) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repostNofication:) name:nil object:_movie];
        if (oldMovie == nil)
            [HSMovieProxy registerMovieProxy:self];
    } else if (oldMovie) {
        [HSMovieProxy unregisterMovieProxy:self];
    }
}
- (id)movie
{
    if (_movieFilePath && _movie == nil) {
        _backupDisablingCounter++;
        HSMovie *movie = [[[HSMovie alloc] initWithMovie:[QTMovie movieWithFile:_movieFilePath error:NULL] error:NULL] autorelease];
        [self setMovie:movie];
        [self restoreMovieSettings];
        _backupDisablingCounter--;
    }
    return _movie;
}
- (void)saveMovieSettings
{
    _delegate = [_movie delegate];
    _isOpaque = [_movie isOpaque];
    _range = [_movie playRange];
    _fadeOutTime = [_movie soundFadeOutTime];
    _fadeInTime = [_movie soundFadeInTime];
    _playCount = (unsigned int)[_movie playCount];
    _volume = [_movie volume];
    _currentTime = [_movie currentTime];
    _angularUnits = (unsigned int)[_movie angularUnits];
    _tiltAngle = [_movie tiltAngle];
    _panAngle = [_movie panAngle];
    _fieldOfView = [_movie fieldOfView];
}
- (void)restoreMovieSettings
{
    [_movie setDelegate:_delegate];
    [_movie setPlayRange:_range];
    [_movie setSoundFadeOutTime:_fadeOutTime];
    [_movie setSoundFadeInTime:_fadeInTime];
    [_movie setPlayCount:_playCount];
    [_movie setVolume:_volume];
    [_movie setCurrentTime:_currentTime];
    [_movie setAngularUnits:_angularUnits];
    [_movie setTiltAngle:_tiltAngle];
    [_movie setPanAngle:_panAngle];
    [_movie setFieldOfView:_fieldOfView];
}
- (id)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [HSMovie instanceMethodSignatureForSelector:aSelector];
    if (signature == nil) {
        _backupDisablingCounter++;
        signature = [[self movie] methodSignatureForSelector:aSelector];
        _backupDisablingCounter--;
    }
    return signature;
}
- (void)forwardInvocation:(id)aInvocation
{
    _backupDisablingCounter++;
    [aInvocation invokeWithTarget:[self movie]];
    _backupDisablingCounter--;
}
- (id)initWithMovie:(id)aMovie
{
    [self setMovie:aMovie];
    return self;
}
- (id)initWithURL:(id)aURL error:(id *)aError
{
    HSMovie *movie = [[HSMovie alloc] initWithURL:aURL error:aError];
    id result;
    if (movie == nil) {
        [self release];
        result = nil;
    } else {
        _movieFilePath = [[aURL path] retain];
        result = [self initWithMovie:movie];
    }
    [movie release];
    return result;
}
- (id)initWithMovie:(id)aMovie error:(id *)aError
{
    HSMovie *movie = [[HSMovie alloc] initWithMovie:aMovie error:aError];
    id result;
    if (movie == nil) {
        [self release];
        result = nil;
    } else {
        result = [self initWithMovie:movie];
    }
    [movie release];
    return result;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_movie) {
        [HSMovieProxy unregisterMovieProxy:self];
        [_movie release];
    }
    [_movieFilePath release];
    [super dealloc];
}
- (id)movieObjectInfo
{
    return _movieObjectInfo;
}

- (void)setMovieObjectInfo:(id)aMovieObjectInfo
{
    _movieObjectInfo = aMovieObjectInfo;
}

@end
