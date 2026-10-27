#import "HSCelMovieAttributesImplementation.h"
#import "HSCelMovieNodeUnit.h"
#import "HSCelMovieObjectFramesLazyCacheItem.h"
#import "HSGIFMovieNodeUnit.h"

@implementation HSCelMovieAttributesImplementation

+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSCelMovieNodeUnit class]] && ![aUnit isKindOfClass:[HSGIFMovieNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}

- (void)HSCelMovieAttributesImplementation_recacheFrames
{
    HSCelMovieObjectFramesCache *oldCache = _framesCache;
    id precachedImages = [_nodeUnit precachedFrameImages];
    HSCelMovieObjectFramesCache *cache = [HSCelMovieObjectFramesCache alloc];
    if (precachedImages == nil) {
        _framesCache = [cache initWithFramesMedia:[_nodeUnit framesMedia] frameDataSource:_nodeUnit groupIdentifier:nil];
    } else {
        _framesCache = [cache initWithFramesMedia:[_nodeUnit framesMedia] frameImages:precachedImages groupIdentifier:nil];
        [_nodeUnit releasePrecachedFrameImages];
    }
    [oldCache release];
}

- (NSInteger)hyperFrameCount
{
    return [_nodeUnit movieFramesCount];
}

- (void)setHyperEraseWhenDone:(BOOL)aDone
{
    [_nodeUnit setEraseWhenDone:aDone];
}

- (BOOL)hyperEraseWhenDone
{
    return [_nodeUnit eraseWhenDone];
}

- (BOOL)isImageComposite
{
    return NO;
}

- (id)image
{
    if (_framesCache == nil)
        [self HSCelMovieAttributesImplementation_recacheFrames];
    return [_framesCache cachedFrameAtIndex:[_nodeUnit currentFrameIndex]];
}

- (NSRect)imageRect
{
    NSRect rect;
    rect.origin = NSZeroPoint;
    rect.size = [(id<HSSizeAttributes>)[_node queryHyperInterface:@protocol(HSSizeAttributes)] size];
    return rect;
}

- (void)hyperStepForward
{
    [_nodeUnit setCurrentTime:[_nodeUnit nextInterestingTime]];
}

- (void)hyperStepBack
{
    [_nodeUnit setCurrentTime:[_nodeUnit previousInterestingTime]];
}

- (void)setHyperCurrentTime:(double)aTime
{
    [_nodeUnit setCurrentTime:aTime];
}

- (double)hyperCurrentTime
{
    return [_nodeUnit currentTime];
}

- (void)hyperStop
{
    [_nodeUnit stopCelMovie];
    _isMovieStarted = NO;
}

- (void)hyperStart:(id)aStart atRate:(CGFloat)aRate startupMode:(NSInteger)aMode
{
    _isMovieStarted = YES;
    [_nodeUnit startCelMovieAtRate:aRate starter:aStart startupMode:aMode];
}

- (void)hyperStart:(id)aStart startupMode:(NSInteger)aMode
{
    [self hyperStart:aStart atRate:1.0 startupMode:aMode];
}

- (void)hyperStart:(id)aStart
{
    [self hyperStart:aStart startupMode:0];
}

- (id)hyperStarter
{
    return [_nodeUnit celMovieStarter];
}

- (BOOL)isHyperPlaying
{
    return [_nodeUnit isCelMoviePlaying];
}

- (void)setHyperPlayRange:(struct HSTimeRange)aRange
{
    [_nodeUnit setPlayTimeRange:aRange];
}

- (struct HSTimeRange)hyperPlayRange
{
    return [_nodeUnit playTimeRange];
}

- (void)setHyperStartTime:(double)aTime
{
    struct HSTimeRange range = [_nodeUnit playTimeRange];
    [_nodeUnit setPlayTimeRange:HSMakeTimeRange(aTime, range.length)];
}

- (double)hyperStartTime
{
    return [_nodeUnit playTimeRange].location;
}

- (double)hyperDuration
{
    return [_nodeUnit duration];
}

- (id)hyperPlayableObjectName
{
    return nil;
}

- (id)hyperPlayableObjectUID
{
    return [_nodeUnit UID];
}

- (void)setHyperPlayCount:(NSUInteger)aCount
{
    [_nodeUnit setPlayCount:aCount];
}

- (NSUInteger)hyperPlayCount
{
    return [_nodeUnit playCount];
}

- (double)hyperFramesPerSecond
{
    return [_nodeUnit framesPerSecond];
}

- (id)attributeObservingController
{
    return _node;
}

- (id)hyperObject
{
    return _node;
}

- (id)node
{
    return _node;
}

- (void)dealloc
{
    if (_isMovieStarted && [_nodeUnit isCelMoviePlaying])
        [_nodeUnit stopCelMovie];
    [_nodeUnit release];
    [_node release];
    [_framesCache release];
    [super dealloc];
}

- (id)initWithNodeUnit:(id)aUnit node:(id)aNode
{
    self = [super init];
    if (self == nil || aNode == nil || aUnit == nil) {
        [self release];
        return nil;
    }
    _node = [aNode retain];
    _nodeUnit = [aUnit retain];
    [_node associateImplementation:self withInterface:@protocol(HSFramesPerSecondAttributes)];
    [_node associateImplementation:self withInterface:@protocol(HSExtendedPlayableObjectAttributes)];
    [_node associateImplementation:self withInterface:@protocol(HSCelMovieObjectAttributes)];
    [_node associateImplementation:self withInterface:@protocol(HSImageAttributes)];
    [_node associateImplementation:self withInterface:@protocol(HSPlayableObjectAttributes)];
    return self;
}

- (void)hyperPause
{
    _wasMoviePlaying = [self isHyperPlaying];
    [self hyperStop];
}

- (void)hyperResume
{
    if (_wasMoviePlaying)
        [self hyperStart:[self hyperStarter]];
}

@end
