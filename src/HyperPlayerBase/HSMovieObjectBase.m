#import "HSMovieObjectBase.h"
#import "HSFunctions.h"
#import "HSMediaFileWrapper.h"
#import "HSMovie.h"
#import "HSMovieObjectBaseData.h"
#import "HSMovieProxy.h"
#import "HSNewMedia+DataHelpers.h"

static BOOL HSMovieObjectBaseFloatsAreEqual(float aValue1, float aValue2)
{
    float scale1 = aValue1 != 0.0f ? fabsf(aValue1) : 1.0f;
    float scale2 = aValue2 != 0.0f ? fabsf(aValue2) : 1.0f;
    return fabsf(aValue1 - aValue2) <= MAX(scale1, scale2) * 0.0005f;
}

// A movie playing object. The attributes live in the node data, shared by the
// objects with the same node data; the movie is made lazily from the media.
@implementation HSMovieObjectBase

+ (Class)nodeDataClass
{
    return [HSMovieObjectBaseData class];
}

- (void)mediaPathToMediaFileDidChange:(id)aChange
{
    [self destroyMovie];
    _movie = nil;
}

- (void)copyMovieAttributesToMovie:(id)aMovie
{
    [(HSMovie *)aMovie setPlayRange:[self hyperPlayRange]];
    [(HSMovie *)aMovie setPlayCount:[self hyperPlayCount]];
    [(HSMovie *)aMovie setVolume:[self hyperVolume]];
}

- (void)willDisconnectFromDocument
{
    if ([self isHyperPlaying])
        [self hyperStop];
    [super willDisconnectFromDocument];
}

- (id)nameBaseTemplates
{
    return [NSArray arrayWithObjects:[[self media] mediaName], nil];
}

- (void)movieDidStop:(id)aStop
{
    [self movieDidEnd:aStop];
}

- (void)movieDidPlayOnce:(id)aOnce
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSPlayableObjectDidPlayOnceNotification" object:self];
}

- (void)movieDidEnd:(id)aEnd
{
    if (_starter && [_starter respondsToSelector:@selector(hyperPlayableObjectDidStop:)])
        [_starter hyperPlayableObjectDidStop:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSPlayableObjectDidEndNotification" object:self];
}

- (void)movieDidChangeImage:(id)aImage
{
}

- (id)hyperMovie
{
    return [self movie];
}

- (void)setVolume:(CGFloat)aVolume
{
    HSMovieObjectBaseData *data = [self movieObjectBaseNodeData];
    [data setVolume:aVolume];
    [(HSMovie *)[self movie] setVolume:[(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] volume]];
}

- (CGFloat)volume
{
    return [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] volume];
}

// An unchanged volume still brings the movie's volume in line.
- (void)setHyperVolume:(CGFloat)aVolume
{
    float volume = [self volume];
    if (HSMovieObjectBaseFloatsAreEqual(aVolume, volume)) {
        if (!HSMovieObjectBaseFloatsAreEqual(volume, [(HSMovie *)[self movie] volume]))
            [(HSMovie *)[self movie] setVolume:volume];
        return;
    }
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Movie Volume" value:@"" table:@"UndoManager"]];
    [(HSMovieObjectBase *)[[self undoManager] prepareWithInvocationTarget:self] setHyperVolume:volume];
    [self notifyChange:1 ofAttribute:@protocol(HSMovieObjectBaseVolumeAttribute) withUserInfo:nil];
    [self setVolume:aVolume];
    [self notifyChange:2 ofAttribute:@protocol(HSMovieObjectBaseVolumeAttribute) withUserInfo:nil];
}

- (CGFloat)hyperVolume
{
    return [self volume];
}

- (void)setHyperMovieWithPath:(id)aPath
{
    [self setHyperMovieWithPath:aPath error:NULL];
}

- (void)setHyperMovieWithPath:(id)aPath error:(id *)aError
{
    [self setMedia:[HSNewMedia mediaWithPath:aPath] error:aError];
    [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] setStoredPlayRange:[(HSMovie *)[self movie] playRange]];
}

- (void)setHyperMovie:(id)aMovie name:(id)aName
{
    [self setMedia:[HSNewMedia mediaWithData:[aMovie movieHyperDataRepresentation] name:aName type:@"mov"]];
    [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] setStoredPlayRange:[(HSMovie *)[self movie] playRange]];
}

- (BOOL)isHyperEmpty
{
    return [self media] == nil;
}

- (void)setHyperAllowPlayingOtherSounds:(BOOL)aSounds
{
    BOOL allows = [self isHyperAllowPlayingOtherSounds];
    if (allows == aSounds)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Allow Playing Sounds" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperAllowPlayingOtherSounds:allows];
    [self notifyChange:1 ofAttribute:@protocol(HSPlayableObjectHyperAllowPlayingOtherSoundsAttribute) withUserInfo:nil];
    [self setAllowPlayingOtherSounds:aSounds];
    [self notifyChange:2 ofAttribute:@protocol(HSPlayableObjectHyperAllowPlayingOtherSoundsAttribute) withUserInfo:nil];
}

- (BOOL)isHyperAllowPlayingOtherSounds
{
    return [self isAllowPlayingOtherSounds];
}

- (void)setAllowPlayingOtherSounds:(BOOL)aSounds
{
    [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] setAllowPlayingOtherSounds:aSounds];
}

- (BOOL)isAllowPlayingOtherSounds
{
    return [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] isAllowPlayingOtherSounds];
}

- (void)setHyperAllowPlayingOtherMovies:(BOOL)aMovies
{
    BOOL allows = [self isHyperAllowPlayingOtherMovies];
    if (allows == aMovies)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Allow Playing Movies" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperAllowPlayingOtherMovies:allows];
    [self notifyChange:1 ofAttribute:@protocol(HSPlayableObjectHyperAllowPlayingOtherMoviesAttribute) withUserInfo:nil];
    [self setAllowPlayingOtherMovies:aMovies];
    [self notifyChange:2 ofAttribute:@protocol(HSPlayableObjectHyperAllowPlayingOtherMoviesAttribute) withUserInfo:nil];
}

- (BOOL)isHyperAllowPlayingOtherMovies
{
    return [self isAllowPlayingOtherMovies];
}

- (void)setAllowPlayingOtherMovies:(BOOL)aMovies
{
    [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] setAllowPlayingOtherMovies:aMovies];
}

- (BOOL)isAllowPlayingOtherMovies
{
    return [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] isAllowPlayingOtherMovies];
}

- (void)setHyperStartingOnClick:(BOOL)aClick
{
    BOOL starts = [self isHyperStartingOnClick];
    if (starts == aClick)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Starting On Click" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperStartingOnClick:starts];
    [self notifyChange:1 ofAttribute:@protocol(HSPlayableObjectHyperStartingOnClickAttribute) withUserInfo:nil];
    [self setStartingOnClick:aClick];
    [self notifyChange:2 ofAttribute:@protocol(HSPlayableObjectHyperStartingOnClickAttribute) withUserInfo:nil];
}

- (BOOL)isHyperStartingOnClick
{
    return [self isStartingOnClick];
}

- (void)setStartingOnClick:(BOOL)aClick
{
    [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] setStartingOnClick:aClick];
}

- (BOOL)isStartingOnClick
{
    return [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] isStartingOnClick];
}

// Stops the movie, tells the starter, and resets the movie to its whole range.
- (void)hyperStop
{
    if (!_movie)
        return;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSPlayableObjectWillStopNotification" object:self];
    [_movie stop];
    if (_starter && [_starter respondsToSelector:@selector(hyperPlayableObjectDidStop:)])
        [_starter hyperPlayableObjectDidStop:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSPlayableObjectDidStopNotification" object:self];
    [_starter release];
    _starter = nil;
    [_movie setPlayRange:HSMakeTimeRange(0, [_movie duration])];
}

// A zero rate keeps the previous starter.
- (void)hyperStart:(id)aStart atRate:(CGFloat)aRate startupMode:(NSInteger)aMode
{
    if (![self movie])
        return;
    float rate = aRate;
    float magnitude = rate != 0.0f ? fabsf(rate) : 1.0f;
    float tolerance = magnitude >= 1.0f ? magnitude * 0.0005f : 0.0005f;
    if (fabsf(rate) > tolerance) {
        [aStart retain];
        [_starter release];
        _starter = aStart;
    }
    [_movie setPlayRange:[self playRange]];
    [_movie setCurrentTime:[self hyperCurrentTime]];
    [_movie setRate:aRate];
}

- (void)hyperStart:(id)aStart startupMode:(NSInteger)aMode
{
    [self hyperStart:aStart atRate:1.0 startupMode:aMode];
}

- (void)hyperStart:(id)aStart
{
    [self hyperStart:aStart startupMode:0];
}

- (void)hyperStepForward
{
    [[self movie] stepForward];
}

- (void)hyperStepBack
{
    [[self movie] stepBack];
}

- (void)setHyperCurrentTime:(double)aTime
{
    if ([self movie])
        [(HSMovie *)[self movie] setCurrentTime:aTime];
}

- (double)hyperCurrentTime
{
    return _movie ? [_movie currentTime] : 0.0;
}

- (id)hyperStarter
{
    return _starter;
}

- (BOOL)isHyperPlaying
{
    return _movie ? [_movie isPlaying] : NO;
}

- (void)setHyperPlayCount:(NSUInteger)aCount
{
    if ([self playCount] == aCount)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Movie Play Count" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperPlayCount:[self playCount]];
    [self notifyChange:1 ofAttribute:@protocol(HSExtendedPlayableObjectPlayCountAttribute) withUserInfo:nil];
    [self setPlayCount:aCount];
    [self notifyChange:2 ofAttribute:@protocol(HSExtendedPlayableObjectPlayCountAttribute) withUserInfo:nil];
}

- (NSUInteger)hyperPlayCount
{
    return [self playCount];
}

- (void)setPlayCount:(NSUInteger)aCount
{
    [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] setPlayCount:aCount];
    [(HSMovie *)[self movie] setPlayCount:[(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] playCount]];
}

- (NSUInteger)playCount
{
    return [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] playCount];
}

- (void)setStartTime:(double)aTime
{
}

- (double)startTime
{
    return [self playRange].location;
}

- (void)setHyperStartTime:(double)aTime
{
}

- (double)hyperStartTime
{
    return [self startTime];
}

- (void)setPendingSetPlayRange:(BOOL)aRange
{
    _pendingSetPlayRange = aRange;
}

- (void)undoableSetPlayRange:(struct HSTimeRange)aRange
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Movie Play Range" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] undoableSetPlayRange:[self playRange]];
    [self notifyChange:1 ofAttribute:@protocol(HSPlayableObjectPlayRangeAttribute) withUserInfo:nil];
    [self notifyChange:1 ofAttribute:@protocol(HSPlayableObjectStartTimeAttribute) withUserInfo:nil];
    [self setPlayRange:aRange];
    [self notifyChange:2 ofAttribute:@protocol(HSPlayableObjectStartTimeAttribute) withUserInfo:nil];
    [self notifyChange:2 ofAttribute:@protocol(HSPlayableObjectPlayRangeAttribute) withUserInfo:nil];
}

- (id)localCopyIncludingNodeUnits:(BOOL)aUnits
{
    id copy = [super localCopyIncludingNodeUnits:aUnits];
    [copy setPlayRange:[self playRange]];
    return copy;
}

// Stored for every object sharing the node data; their movies take it when
// they next apply their attributes.
- (void)setPlayRange:(struct HSTimeRange)aRange
{
    HSMovieObjectBaseData *data = [self movieObjectBaseNodeData];
    NSEnumerator *objects = [[[data owner] objectsWithNodeDataUID:[(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] nodeDataUID]] objectEnumerator];
    id object;
    while ((object = [objects nextObject])) {
        HSMovieObjectBaseData *objectData = [object nodeData];
        [object setPendingSetPlayRange:YES];
        [objectData setStoredPlayRange:aRange];
    }
}

- (struct HSTimeRange)playRange
{
    return [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] storedPlayRange];
}

- (void)setHyperPlayRange:(struct HSTimeRange)aRange
{
    if (!HSEqualTimeRanges(aRange, [self playRange]))
        [self undoableSetPlayRange:aRange];
}

- (struct HSTimeRange)hyperPlayRange
{
    return [self playRange];
}

- (double)hyperDuration
{
    return [self movie] ? [_movie duration] : 0.0;
}

- (id)hyperPlayableObjectName
{
    return [[self media] mediaName];
}

- (id)hyperPlayableObjectUID
{
    return [self hyperUID];
}

// Undone with the current media, and the attributes applied when this applies
// none.
- (void)setMedia:(id)aMedia applyAttributes:(BOOL)aAttributes attributes:(struct MovieAttributesForMediaChange)aAttributes2 error:(id *)aError
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Insert Movie" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setMedia:[self media] applyAttributes:!aAttributes attributes:aAttributes2 error:NULL];
    [self changeCurrentMediaFrom:[self media] to:aMedia error:aError];
    if (aAttributes) {
        [self setHyperPlayRange:aAttributes2.f0];
        [(id<HSMutableSizeAttributes>)[self queryHyperInterface:@protocol(HSMutableSizeAttributes)] setSize:aAttributes2.f2];
    }
}

- (BOOL)isCurrentMediaDifferentFrom:(id)aFrom
{
    id media = [self media];
    if (media)
        return ![media isEqual:aFrom];
    return aFrom != nil;
}

- (BOOL)canUseMedia:(id)aMedia error:(id *)aError
{
    return NO;
}

- (void)setMedia:(id)aMedia
{
    [self setMedia:aMedia error:NULL];
}

- (void)setMedia:(id)aMedia error:(id *)aError
{
    if (![self isCurrentMediaDifferentFrom:aMedia])
        return;
    struct MovieAttributesForMediaChange attributes;
    attributes.f0 = [self hyperPlayRange];
    attributes.f1 = [self hyperStartTime];
    attributes.f2 = [(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
    [self setMedia:aMedia applyAttributes:NO attributes:attributes error:aError];
}

- (id)initWithMedia:(id)aMedia
{
    return [self initWithMedia:aMedia error:NULL];
}

- (id)initWithMedia:(id)aMedia error:(id *)aError
{
    self = [self init];
    if (!self)
        return nil;
    if (![self canUseMedia:aMedia error:aError]) {
        [self release];
        return nil;
    }
    [self setMedia:aMedia error:NULL];
    return self;
}

- (void)clearMediaDependentAttributes
{
    [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] setStartTime:0];
    _pendingSetPlayRange = NO;
}

- (void)applyAttributesToMovie
{
    HSMovie *movie = [self movie];
    if (!movie)
        return;
    if (_pendingSetPlayRange) {
        [_movie setPlayRange:[(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] storedPlayRange]];
        _pendingSetPlayRange = NO;
    }
    [movie setPlayCount:[self playCount]];
    [movie setVolume:[self hyperVolume]];
}

- (void)readAttributesFromMovie
{
    HSMovie *movie = [self movie];
    if (movie)
        [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] setStoredPlayRange:[movie playRange]];
}

- (void)destroyMovie
{
    [_movie setDelegate:nil];
    [_movie release];
    _movie = nil;
}

- (BOOL)createMovieFromMedia:(id)aMedia error:(id *)aError
{
    NSString *path = [aMedia fullPathToMediaFileCreateIfNeeded:YES];
    if (path && [[NSFileManager defaultManager] hyperIsFileReadableAtPath:path])
        _movie = (HSMovie *)[[HSMovieProxy alloc] initWithURL:[NSURL fileURLWithPath:path] error:aError];
    return _movie != nil;
}

- (id)moviePtr
{
    return _movie;
}

// Made from the media on first use; media that makes no movie is dropped.
- (id)movie
{
    if (_movie || _movieCreation)
        return _movie;
    _movieCreation = YES;
    if ([(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] media]) {
        id media = [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] media];
        if ([self createMovieFromMedia:media error:NULL]) {
            [self applyAttributesToMovie];
            [_movie setDelegate:self];
        } else {
            [self changeCurrentMediaFrom:media to:nil error:NULL];
        }
    }
    _movieCreation = NO;
    return _movie;
}

// As in the original, the media is asked for twice and never found missing
// the second time, so this does nothing.
- (void)validateMedia
{
    if ([(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] media] && ![(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] media])
        [self changeCurrentMediaFrom:nil to:nil error:NULL];
}

- (void)currentMediaDidChange
{
}

- (void)currentMediaWillChange
{
}

- (void)HSMovieObjectBase_mediaDidChangeDataSource:(id)aSource
{
    id media = [aSource object];
    [self HSMovieObjectBase_changeCurrentMediaFrom:media to:media error:NULL];
}

// Changes the media of every object sharing the node data, moving their
// observing of the media's data source along.
- (void)changeCurrentMediaFrom:(id)aFrom to:(id)aTo error:(id *)aError
{
    HSMovieObjectBaseData *data = [self movieObjectBaseNodeData];
    NSArray *objects = [[data owner] objectsWithNodeDataUID:[data nodeDataUID]];
    NSUInteger count = [objects count];
    if (!count || ![self canUseMedia:aTo error:aError])
        return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    for (NSUInteger index = 0; index < count; index++) {
        id object = [objects objectAtIndex:index];
        if (aFrom)
            [center removeObserver:object name:@"HSMediaDidChangeDataSourceNotification" object:aFrom];
        [object HSMovieObjectBase_changeCurrentMediaFrom:aFrom to:aTo error:aError];
        if (aTo)
            [center addObserver:object selector:@selector(HSMovieObjectBase_mediaDidChangeDataSource:) name:@"HSMediaDidChangeDataSourceNotification" object:aTo];
    }
}

- (void)HSMovieObjectBase_changeCurrentMediaFrom:(id)aFrom to:(id)aTo error:(id *)aError
{
    [self notifyChange:1 ofAttribute:@protocol(HSMediaAttribute) withUserInfo:nil];
    [self currentMediaWillChange];
    [self notifyChange:1 ofAttribute:@protocol(HSSelectionKnobsProviderAttribute) withUserInfo:nil];
    [self hyperStop];
    [self clearMediaDependentAttributes];
    [self destroyMovie];
    HSMovieObjectBaseData *data = [self movieObjectBaseNodeData];
    [data setMedia:aTo];
    if ([data media]) {
        if ([self createMovieFromMedia:aTo error:aError]) {
            [self readAttributesFromMovie];
            [self applyAttributesToMovie];
            [(HSMovie *)[self movie] setDelegate:self];
        } else {
            [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] setMedia:nil];
        }
    }
    [self currentMediaDidChange];
    [self notifyChange:2 ofAttribute:@protocol(HSMediaAttribute) withUserInfo:nil];
    [self notifyChange:2 ofAttribute:@protocol(HSSelectionKnobsProviderAttribute) withUserInfo:nil];
    [self userObjectNameBaseTemplateDidChange];
}

- (id)media
{
    return [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] media];
}

- (id)mediaUID
{
    return [[(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] media] mediaUID];
}

- (void)setLoopMode:(NSInteger)aMode
{
    [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] setLoopMode:aMode];
}

- (NSInteger)loopMode
{
    return [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] loopMode];
}

- (void)setPlayRangeAsString:(id)aString
{
    [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] setPlayRangeAsString:aString];
}

- (id)playRangeAsString
{
    return [(HSMovieObjectBaseData *)[self movieObjectBaseNodeData] playRangeAsString];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:@"mediaUID"];
    [keys addObject:@"startTime"];
    [keys addObject:@"playCount"];
    [keys addObject:@"volume"];
    [keys addObject:@"playRangeAsString"];
    [keys addObject:@"startingOnClick"];
    [keys addObject:@"allowPlayingOtherMovies"];
    [keys addObject:@"allowPlayingOtherSounds"];
    [keys addObject:@"loopMode"];
    return keys;
}

// The last release stops observing the media's data source.
- (void)release
{
    if ([self retainCount] == 1) {
        id media = [self media];
        if (media)
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSMediaDidChangeDataSourceNotification" object:media];
    }
    [super release];
}

- (void)dealloc
{
    [_starter release];
    [self destroyMovie];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
        _pendingSetPlayRange = YES;
    return self;
}

- (id)movieObjectBaseNodeData
{
    return [super nodeData];
}

@end
