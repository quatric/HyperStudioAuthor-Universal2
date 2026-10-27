#import "HSMovie.h"
#import "HSMoviePixelBufferRenderer.h"
#import "HSSystem.h"
#import "HSVolumeCurve.h"
#import "HSError.h"
#import "HSFunctions.h"
#import "NSImage+HSImageSize.h"

// A movie for the player, on the HSQTKit QTMovie (AVFoundation underneath).
// The original drove the QuickTime Movie Toolbox directly; here:
// - tracks, media and sample descriptions are AVAssetTracks and their
//   format descriptions (media types and data formats keep their OSTypes);
// - the play range is the movie's selection, played selection-only;
// - the time base's stop callback is QTMovieDidEndNotification, and the
//   loop modes the time base ran (loop, back and forth) are run here so
//   every pass is still counted;
// - the fade-out stop callback is a time the playback timer watches;
// - QTVR, movie controllers, matrices and display clip regions are gone.

static NSString * const HSMovieRendererDidUpdateFrameImageNotification = @"HSMovieRendererDidUpdateFrameImageNotification";

static const unsigned int kHSMovieVideoTypes[2] = { 'vide', 'MPEG' };
static const unsigned int kHSMovieSoundTypes[2] = { 'soun', 'musi' };

// Within QuickTime's relative tolerance of zero.
static BOOL HSMovieIsNearZero(double aValue)
{
    double magnitude = aValue != 0 ? fabs(aValue) : 1;
    return fabs(aValue) <= (magnitude >= 1 ? magnitude * 0.0005 : 0.0005);
}

static OSType HSMovieOSTypeFromString(NSString *aString)
{
    const char *bytes = [aString UTF8String];
    if (bytes == NULL || strlen(bytes) != 4)
        return 0;
    return ((OSType)(unsigned char)bytes[0] << 24) | ((OSType)(unsigned char)bytes[1] << 16) | ((OSType)(unsigned char)bytes[2] << 8) | (unsigned char)bytes[3];
}

// QuickTime's media handler type: AVFoundation names muxed MPEG 'muxx'.
static OSType HSMovieMediaTypeOfTrack(AVAssetTrack *aTrack)
{
    OSType type = HSMovieOSTypeFromString([aTrack mediaType]);
    return type == 'muxx' ? 'MPEG' : type;
}

// Samples in the track, counting no further than aLimit (0 for all).
static NSInteger HSMovieSampleCountOfTrack(AVAssetTrack *aTrack, NSInteger aLimit)
{
    if ([aTrack canProvideSampleCursors]) {
        AVSampleCursor *cursor = [aTrack makeSampleCursorAtFirstSampleInDecodeOrder];
        if (cursor == nil)
            return 0;
        NSInteger count = 1;
        while ((aLimit == 0 || count < aLimit) && [cursor stepInDecodeOrderByCount:1] == 1)
            count++;
        return count;
    }
    float rate = [aTrack nominalFrameRate];
    return rate > 0 ? (NSInteger)lround(CMTimeGetSeconds([aTrack timeRange].duration) * rate) : ([aTrack timeRange].duration.value > 0 ? 1 : 0);
}

@implementation HSMovie

+ (CGFloat)fieldOfViewForMovie:(id)aMovie
{
    return [self fieldOfViewForQTVRInstance:[self QTVRInstanceForMovie:aMovie]];
}

+ (CGFloat)panAngleForMovie:(id)aMovie
{
    return [self panAngleForQTVRInstance:[self QTVRInstanceForMovie:aMovie]];
}

+ (CGFloat)tiltAngleForMovie:(id)aMovie
{
    return [self tiltAngleForQTVRInstance:[self QTVRInstanceForMovie:aMovie]];
}

+ (BOOL)hasProtectedMovieTrackAtMovieWithURL:(id)aURL error:(id *)aError
{
    id movie = [HSMovie createMovieAndDontResolveDataRefsWithURL:aURL error:aError];
    if (movie == nil)
        return NO;
    BOOL result = [self hasProtectedMovieTrackAtMovie:movie error:aError];
    [movie release];
    return result;
}

+ (BOOL)hasProtectedMovieTrackAtMovie:(id)aMovie error:(id *)aError
{
    HSMovie *movie = [[HSMovie alloc] initWithMovie:aMovie error:aError];
    if (movie == nil)
        return NO;
    BOOL result = [movie hasProtectedMovieTrack];
    [movie release];
    return result;
}

+ (BOOL)canInitAsSoundOnlyWithURL:(id)aURL error:(id *)aError
{
    id movie = [self createMovieAndDontResolveDataRefsWithURL:aURL error:aError];
    if (movie == nil)
        return NO;
    BOOL result = [self canPlayMovieAsSoundOnly:movie error:aError];
    [movie release];
    return result;
}

+ (BOOL)canInitAsVideoWithURL:(id)aURL error:(id *)aError
{
    id movie = [self createMovieAndDontResolveDataRefsWithURL:aURL error:aError];
    if (movie == nil)
        return NO;
    BOOL result = [HSMovie canPlayMovieAsVideo:movie error:aError];
    [movie release];
    return result;
}

+ (BOOL)canInitWithURL:(id)aURL error:(id *)aError
{
    id movie = [self createMovieAndDontResolveDataRefsWithURL:aURL error:aError];
    if (movie == nil)
        return NO;
    BOOL result = [self canPlayMovie:movie error:aError];
    [movie release];
    return result;
}

// Something audible with a duration and nothing to see.
+ (BOOL)canPlayMovieAsSoundOnly:(id)aOnly error:(id *)aError
{
    HSMovie *movie = [[HSMovie alloc] initWithMovie:aOnly error:aError];
    BOOL result = movie != nil && ![movie hasAnythingVisible] && [movie hasDuration] && [movie hasSound];
    [movie release];
    return result;
}

// Panoramas and objects play as video; anything else needs something
// visible with a duration, and a GIF needs more than one frame.
+ (BOOL)canPlayMovieAsVideo:(id)aVideo error:(id *)aError
{
    HSMovie *movie = [[HSMovie alloc] initWithMovie:aVideo error:aError];
    BOOL result = [movie isQTVRMovie] || [movie isPanoramaObject] || ([movie hasAnythingVisible] && [movie hasDuration]);
    if (result && [movie HSMovie_isGIF])
        result = [movie hasMultiplySamples];
    [movie release];
    return result;
}

+ (BOOL)canPlayMovie:(id)aMovie error:(id *)aError
{
    HSMovie *movie = [[HSMovie alloc] initWithMovie:aMovie error:aError];
    BOOL result = NO;
    if (movie != nil) {
        double duration = [movie duration];
        result = [movie hasAnythingVisible] || !(duration <= (fabs(duration) >= 1 ? fabs(duration) * 0.0005 : 0.0005));
    }
    [movie release];
    return result;
}

// Returns a +1 movie that doesn't look for or ask about missing media.
+ (id)createMovieAndDontResolveDataRefsWithURL:(id)aURL error:(id *)aError
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [QTDataReference dataReferenceWithReferenceToURL:aURL], QTMovieDataReferenceAttribute,
                                [NSNumber numberWithBool:NO], QTMovieResolveDataRefsAttribute,
                                [NSNumber numberWithBool:NO], QTMovieAskUnresolvedDataRefsAttribute,
                                nil];
    return [[QTMovie alloc] initWithAttributes:attributes error:aError];
}

// QTVR is gone, so no movie has a QTVR instance and these stay 0.
+ (CGFloat)fieldOfViewForQTVRInstance:(struct OpaqueQTVRInstance *)aInstance
{
    return 0;
}

+ (CGFloat)panAngleForQTVRInstance:(struct OpaqueQTVRInstance *)aInstance
{
    return 0;
}

+ (CGFloat)tiltAngleForQTVRInstance:(struct OpaqueQTVRInstance *)aInstance
{
    return 0;
}

+ (struct OpaqueQTVRInstance *)QTVRInstanceForMovie:(id)aMovie
{
    return NULL;
}

// The time base's start and stop times in the original: the selection when
// the movie plays its selection only, else the whole movie.
+ (struct HSTimeRange)HSMovie_playRangeForMovie:(struct MovieType **)aMovie
{
    QTMovie *movie = (QTMovie *)aMovie;
    struct HSTimeRange range = { 0, 0 };
    if (movie == nil)
        return range;
    NSTimeInterval start = 0, length = 0;
    QTTimeRange selection = [[movie attributeForKey:QTMovieSelectionAttribute] QTTimeRangeValue];
    if ([[movie attributeForKey:QTMoviePlaysSelectionOnlyAttribute] boolValue] && selection.duration.timeValue > 0) {
        QTGetTimeInterval(selection.time, &start);
        QTGetTimeInterval(selection.duration, &length);
    } else
        QTGetTimeInterval([movie duration], &length);
    range.location = start;
    range.length = length;
    return range;
}

+ (struct HSTimeRange)playRangeForMovie:(struct MovieType **)aMovie
{
    struct HSTimeRange range = { 0, 0 };
    if (aMovie != NULL)
        range = [HSMovie HSMovie_playRangeForMovie:aMovie];
    return range;
}

+ (id)movieWithURL:(id)aURL error:(id *)aError
{
    return [[[HSMovie alloc] initWithURL:aURL error:aError] autorelease];
}

+ (id)movieWithMovie:(id)aMovie error:(id *)aError
{
    return [[[HSMovie alloc] initWithMovie:aMovie error:aError] autorelease];
}

// EnterMovies() is gone with QuickTime.
+ (void)initialize
{
}

- (void)HSMovie_newImageAvailableInRenderer:(id)aRenderer
{
    [self HSMovie_notifyNewImageAvailable];
}

- (void)stopObservingFromMovieRenderer:(id)aRenderer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSMovieRendererDidUpdateFrameImageNotification object:aRenderer];
}

- (void)startObservingFromMovieRenderer:(id)aRenderer
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSMovie_newImageAvailableInRenderer:) name:HSMovieRendererDidUpdateFrameImageNotification object:aRenderer];
}

// MoviesTask(): AVFoundation services its movies itself; the renderer gets
// its chance to pick up a new frame.
- (void)moviesTaskWithPerformer:(id)aPerformer
{
    if (_movieRenderer != nil)
        [_movieRenderer HSMovieVisualContextRenderer_invalidateMovie];
}

- (void)HSMovie_notifyNewImageAvailable
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HSMovieImageDidChangeNotification object:self];
    [[self delegate] movieDidChangeImage:self];
}

- (void)destroyStopSoundFadeOutCompleteCallback
{
    _stopSoundFadeOutTime = -1;
}

// The playback timer stops the movie once it passes aTime (movie time units).
- (short)createStopSoundFadeOutCompleteCallbackWithTime:(NSInteger)aTime
{
    if ([self quickTimeMovie] == NULL)
        return -1;
    _stopSoundFadeOutTime = aTime;
    return noErr;
}

// The movie reached an end of its play range: counts the pass, stops for
// good after the last one, and resets the fade.
- (void)playbackDidFinish
{
    _currentPlayCount++;
    NSInteger loopMode = [self loopMode];
    if (loopMode == 0) {
        [self stop];
        [[NSNotificationCenter defaultCenter] postNotificationName:HSMovieDidEndNotification object:self];
        [[self delegate] movieDidEnd:self];
        if (_currentPlayCount == _playCount && _previousLoopMode != 0)
            [self setLoopMode:_previousLoopMode];
    } else {
        // The last pass plays without looping, so it ends the movie.
        if (_currentPlayCount == _playCount - 1) {
            _previousLoopMode = (int)loopMode;
            [self setLoopMode:0];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:HSMovieDidPlayOnceNotification object:self];
        [[self delegate] movieDidPlayOnce:self];
        if (_startTime.timeValue > 0 && loopMode == 1)
            [_movie setCurrentTime:QTMakeTime(_startTime.timeValue, _startTime.timeScale)];
    }
    if (_soundFadeInTime > 0 || _soundFadeOutTime > 0 || _soundFadeOutStopTime > 0)
        [self setVolume:_initialVolume];
    [self setupMoviePlaybackCompleteCallback];
}

// What the looping time base did on its own: start the next pass.
- (void)HSMovie_continueLoopingInMode:(NSInteger)aLoopMode
{
    if (aLoopMode == 0 || _movie == nil)
        return;
    struct HSTimeRange range = [self playRange];
    float rate = _playingRate != 0 ? fabsf(_playingRate) : 1;
    if (aLoopMode == 2 && !_isPlayingBackwards) {
        _isPlayingBackwards = YES;
        [_movie setCurrentTime:QTMakeTimeWithTimeInterval(HSMaxTimeRange(range))];
        [_movie setRate:-rate];
    } else {
        _isPlayingBackwards = NO;
        if (aLoopMode == 1 && _startTime.timeValue > 0)
            [_movie setCurrentTime:QTMakeTime(_startTime.timeValue, _startTime.timeScale)];
        else
            [_movie setCurrentTime:QTMakeTimeWithTimeInterval(range.location)];
        [_movie setRate:rate];
    }
}

- (void)HSMovie_movieDidEnd:(NSNotification *)aNotification
{
    NSInteger loopMode = [self loopMode];
    [[self retain] autorelease];
    [self playbackDidFinish];
    [self HSMovie_continueLoopingInMode:loopMode];
}

// Playing backwards stops at the start without an end notification.
- (void)HSMovie_movieRateDidChange:(NSNotification *)aNotification
{
    if (!_isPlayingBackwards || [_movie rate] != 0)
        return;
    if (fabs([self currentTime] - [self playRange].location) > 0.1)
        return;
    NSInteger loopMode = [self loopMode];
    [[self retain] autorelease];
    [self playbackDidFinish];
    [self HSMovie_continueLoopingInMode:loopMode];
}

- (void)setupMoviePlaybackCompleteCallback
{
    if (_isObservingMovieEnd)
        return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(HSMovie_movieDidEnd:) name:QTMovieDidEndNotification object:_movie];
    [center addObserver:self selector:@selector(HSMovie_movieRateDidChange:) name:QTMovieRateDidChangeNotification object:_movie];
    _isObservingMovieEnd = YES;
}

- (void)destroyMoviePlaybackCompleteCallback
{
    if (!_isObservingMovieEnd)
        return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:QTMovieDidEndNotification object:_movie];
    [center removeObserver:self name:QTMovieRateDidChangeNotification object:_movie];
    _isObservingMovieEnd = NO;
}

- (void)createMoviePlaybackCompleteCallback
{
    [self setupMoviePlaybackCompleteCallback];
}

// The original updated and tasked the movie so it drew its current frame
// into the renderer's visual context. A seek finishes asynchronously, so
// the renderer looks again a moment later.
- (void)redraw
{
    if (_movieRenderer == nil)
        return;
    [_movieRenderer HSMovieVisualContextRenderer_invalidateMovie];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(moviesTaskWithPerformer:) object:nil];
    [self performSelector:@selector(moviesTaskWithPerformer:) withObject:nil afterDelay:0.05];
}

- (id)currentFrameImage
{
    return [NSImage hyperImageWithCGImage:[(HSMoviePixelBufferRenderer *)[self HSMovie_movieRenderer] currentFrameImage]];
}

- (id)posterFrameImage
{
    double time = [self currentTime];
    [self setCurrentTime:[self posterTime]];
    id image = [self currentFrameImage];
    [self setCurrentTime:time];
    return image;
}

- (id)posterImage
{
    return [[self HSMovie_movieRenderer] posterImage];
}

// The original kept the movie's matrix and display clip region while the
// renderer was detached; HSQTKit movies have neither.
- (void)HSMovie_restoreMoviePropertiesBeforReAttachRenderer
{
}

- (void)HSMovie_saveMoviePropertiesBeforeDetachRenderer
{
}

- (void)activateMovieRenderer
{
    if (--_movieRendererDeactivateCounter == 0) {
        [self HSMovie_restoreMoviePropertiesBeforReAttachRenderer];
        [_movieRenderer reattachToMovie];
        [self redraw];
        [_movie setIdling:NO];
    }
}

- (void)deactivateMovieRenderer
{
    if (_movieRendererDeactivateCounter == 0) {
        [self HSMovie_saveMoviePropertiesBeforeDetachRenderer];
        [_movieRenderer detachFromMovie];
        [_movie setIdling:YES];
    }
    _movieRendererDeactivateCounter++;
}

- (id)movieRenderer
{
    return [self HSMovie_movieRenderer];
}

- (void)makeSureWeHaveMovieRendererIfPossible
{
    [self movieRenderer];
}

- (BOOL)hasMovieRenderer
{
    return _movieRenderer != nil;
}

- (void)destroyMovieRenderer
{
    if (_movieRenderer != nil) {
        [self stopObservingFromMovieRenderer:_movieRenderer];
        [_movieRenderer release];
        _movieRenderer = nil;
    }
}

- (id)HSMovie_movieRenderer
{
    if (![self hasAnythingVisible])
        return nil;
    if (_movieRenderer != nil)
        return _movieRenderer;
    _movieRenderer = [[HSMoviePixelBufferRenderer alloc] initWithQTMovie:_movie storage:nil];
    if (_movieRenderer == nil)
        return nil;
    [self startObservingFromMovieRenderer:_movieRenderer];
    [self redraw];
    return _movieRenderer;
}

// A +1 copy carrying the view parameters (which only QTVR had).
- (void)showDefaultView
{
}

- (CGFloat)maxFieldOfView
{
    float value = 0;
    [self QTVRConstraintsForType:2 minValue:NULL maxValue:&value];
    return value;
}

- (CGFloat)minFieldOfView
{
    float value = 0;
    [self QTVRConstraintsForType:2 minValue:&value maxValue:NULL];
    return value;
}

- (CGFloat)fieldOfView
{
    return [[self class] fieldOfViewForQTVRInstance:[self QTVRInstance]];
}

- (void)setFieldOfView:(CGFloat)aView
{
}

- (CGFloat)maxPanAngle
{
    float value = 0;
    [self QTVRConstraintsForType:0 minValue:NULL maxValue:&value];
    return value;
}

- (CGFloat)minPanAngle
{
    float value = 0;
    [self QTVRConstraintsForType:0 minValue:&value maxValue:NULL];
    return value;
}

- (CGFloat)panAngle
{
    return [[self class] panAngleForQTVRInstance:[self QTVRInstance]];
}

- (void)setPanAngle:(CGFloat)aAngle
{
}

- (CGFloat)maxTiltAngle
{
    float value = 0;
    [self QTVRConstraintsForType:1 minValue:NULL maxValue:&value];
    return value;
}

- (CGFloat)minTiltAngle
{
    float value = 0;
    [self QTVRConstraintsForType:1 minValue:&value maxValue:NULL];
    return value;
}

- (CGFloat)tiltAngle
{
    return [[self class] tiltAngleForQTVRInstance:[self QTVRInstance]];
}

- (void)setTiltAngle:(CGFloat)aAngle
{
}

// QTVR's default unit was degrees (2) in the original's callers; with no
// instance QTVRGetAngularUnits was never reached and 0 came back.
- (NSUInteger)angularUnits
{
    return 0;
}

- (void)setAngularUnits:(NSUInteger)aUnits
{
}

// Controller types from the movie's 'ctyp' user data.
- (BOOL)isPanoramaObject
{
    NSUInteger type = [self HSMovie_movieControllerType];
    return type == 'STpn' || type == 'pano';
}

- (BOOL)isQTVRMovie
{
    NSUInteger type = [self HSMovie_movieControllerType];
    return type == 'obje' || type == 'qtvr' || type == 'stna';
}

- (id)QTMovie
{
    return _movie;
}

- (NSUInteger)HSMovie_movieControllerType
{
    OSType type = 0x3f3f3f3f; // '????'
    for (AVMetadataItem *item in [[_movie AVAsset] metadataForFormat:AVMetadataFormatQuickTimeUserData]) {
        id key = [item key];
        BOOL isControllerType = [key isKindOfClass:[NSNumber class]] ? [key unsignedIntValue] == 'ctyp'
                              : [key isKindOfClass:[NSString class]] && [key isEqualToString:@"ctyp"];
        if (!isControllerType)
            continue;
        NSData *data = [item dataValue];
        if ([data length] >= 4)
            type = CFSwapInt32BigToHost(*(const UInt32 *)[data bytes]);
        else if ([item numberValue] != nil)
            type = [[item numberValue] unsignedIntValue];
        break;
    }
    return type;
}

- (BOOL)checkExistingForCodecs:(id *)aCodecs
{
    BOOL exists = [self existsVideoDecompressorWithError:aCodecs];
    if (exists)
        exists = [self existsSoundDecompressorWithError:aCodecs];
    return exists;
}

- (id)osTypeToNSString:(NSUInteger)aString
{
    return [NSString stringWithFormat:@"%c%c%c%c", (int)(aString >> 24) & 0xff, (int)(aString >> 16) & 0xff, (int)(aString >> 8) & 0xff, (int)aString & 0xff];
}

- (id)errorForCode:(NSInteger)aCode withDescription:(id)aDescription
{
    NSMutableDictionary *userInfo = nil;
    if (aDescription != nil) {
        userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:aDescription forKey:HSLocalizedDescriptionKey];
    }
    return [HSError errorWithDomain:aCode < 10000 ? HSCocoaErrorDomain : HSSpecificErrorDomain code:aCode userInfo:userInfo];
}

// The original looked for a decompressor component of aComponent's type
// for each of the track's data formats; AVFoundation says whether it can
// decode the track. The first format stands for the missing component.
- (BOOL)isExistComponent:(NSUInteger)aComponent forTrack:(AVAssetTrack *)aTrack notExistingComponent:(unsigned int *)aComponent2
{
    if ([self mediaSampleDescriptionsCountForTrack:aTrack] == 0 || [aTrack isDecodable])
        return YES;
    if (aComponent2 != NULL)
        *aComponent2 = (unsigned int)[self mediaSampleDataFormatForTrack:aTrack atDescriptionIndex:0];
    return NO;
}

- (struct ComponentDescription)initializeComponentDescriptionWithComponentType:(NSUInteger)aType andSubType:(NSUInteger)aType2
{
    struct ComponentDescription description = { (OSType)aType, (OSType)aType2, 0, 0, 0 };
    return description;
}

// The aIndex-th track (0-based) of the first of the types that has one.
- (AVAssetTrack *)trackAtIndex:(NSInteger)aIndex ofTypes:(unsigned int *)aTypes count:(NSInteger)aCount
{
    NSArray *tracks = [[_movie AVAsset] tracks];
    for (NSInteger i = 0; i < aCount; i++) {
        NSInteger index = 0;
        for (AVAssetTrack *track in tracks)
            if (HSMovieMediaTypeOfTrack(track) == aTypes[i] && index++ == aIndex)
                return track;
    }
    return nil;
}

- (NSUInteger)mediaSampleDataFormatForTrack:(AVAssetTrack *)aTrack atDescriptionIndex:(NSInteger)aIndex
{
    NSArray *descriptions = [aTrack formatDescriptions];
    if (aIndex < 0 || aIndex >= (NSInteger)[descriptions count])
        return 0;
    return CMFormatDescriptionGetMediaSubType((CMFormatDescriptionRef)[descriptions objectAtIndex:aIndex]);
}

- (NSInteger)mediaSampleDescriptionsCountForTrack:(AVAssetTrack *)aTrack
{
    return [[aTrack formatDescriptions] count];
}

- (NSInteger)trackCountOfTypes:(unsigned int *)aTypes count:(NSInteger)aCount
{
    NSInteger count = 0;
    for (AVAssetTrack *track in [[_movie AVAsset] tracks]) {
        OSType type = HSMovieMediaTypeOfTrack(track);
        for (NSInteger i = 0; i < aCount; i++)
            if (type == aTypes[i]) {
                count++;
                break;
            }
    }
    return count;
}

- (NSInteger)trackCountOfType:(NSUInteger)aType
{
    unsigned int type = (unsigned int)aType;
    return [self trackCountOfTypes:&type count:1];
}

- (NSInteger)totalTrackCount
{
    return _movie != nil ? [[[_movie AVAsset] tracks] count] : 0;
}

- (BOOL)existsSoundDecompressorWithError:(id *)aError
{
    NSInteger count = [self trackCountOfTypes:(unsigned int *)kHSMovieSoundTypes count:2];
    for (NSInteger i = 0; i < count; i++) {
        unsigned int missing = 0;
        AVAssetTrack *track = [self trackAtIndex:i ofTypes:(unsigned int *)kHSMovieSoundTypes count:2];
        if (![self isExistComponent:'sdec' forTrack:track notExistingComponent:&missing]) {
            if (aError != NULL) {
                NSString *file = [[[_movie attributeForKey:QTMovieURLAttribute] path] lastPathComponent];
                NSString *format = [[NSBundle mainBundle] localizedStringForKey:HSMovieSoundDecompressorError value:@"" table:nil];
                *aError = [self errorForCode:0x5023 withDescription:[NSString stringWithFormat:format, [self osTypeToNSString:missing], file]];
            }
            return NO;
        }
    }
    return YES;
}

- (BOOL)existsVideoDecompressorWithError:(id *)aError
{
    NSInteger count = [self trackCountOfTypes:(unsigned int *)kHSMovieVideoTypes count:2];
    for (NSInteger i = 0; i < count; i++) {
        unsigned int missing = 0;
        AVAssetTrack *track = [self trackAtIndex:i ofTypes:(unsigned int *)kHSMovieVideoTypes count:2];
        if (![self isExistComponent:'imdc' forTrack:track notExistingComponent:&missing]) {
            if (aError != NULL) {
                NSString *file = [[[_movie attributeForKey:QTMovieURLAttribute] path] lastPathComponent];
                NSString *format = [[NSBundle mainBundle] localizedStringForKey:HSMovieVideoDecompressorError value:@"" table:nil];
                *aError = [self errorForCode:0x5022 withDescription:[NSString stringWithFormat:format, [self osTypeToNSString:missing], file]];
            }
            return NO;
        }
    }
    return YES;
}

// More than one sample over the enabled visual tracks.
- (BOOL)hasMultiplySamples
{
    NSInteger samples = 0;
    for (AVAssetTrack *track in [[_movie AVAsset] tracksWithMediaCharacteristic:AVMediaCharacteristicVisual]) {
        if (![track isEnabled])
            continue;
        samples += HSMovieSampleCountOfTrack(track, 2);
        if (samples > 1)
            return YES;
    }
    return NO;
}

- (BOOL)isAnimatedGifMovie
{
    return [self HSMovie_isGIF] && [self hasMultiplySamples];
}

// Original quirk kept: only the first sample description is looked at, as
// many times as there are descriptions.
- (BOOL)isMIDI
{
    if (![self isSound] || [self trackCountOfTypes:(unsigned int *)kHSMovieSoundTypes count:2] != 1)
        return NO;
    AVAssetTrack *track = [self trackAtIndex:0 ofTypes:(unsigned int *)kHSMovieSoundTypes count:2];
    NSInteger count = [self mediaSampleDescriptionsCountForTrack:track];
    for (NSInteger i = 0; i < count; i++)
        if ([self mediaSampleDataFormatForTrack:track atDescriptionIndex:0] == 'musi')
            return YES;
    return NO;
}

// An MPEG-4 file whose major or a compatible brand is an iTunes video
// ('M4V ', 'M4VP', 'M4VH'), or audio ('M4A ') with no video.
- (BOOL)isCompatibleWithIBooksAuthor
{
    NSURL *url = [_movie attributeForKey:QTMovieURLAttribute];
    if (url == nil)
        return NO;
    NSInputStream *stream = [NSInputStream inputStreamWithURL:url];
    if (stream == nil)
        return NO;
    [stream open];
    BOOL hasVideo = [self hasVideo];
    BOOL result = NO;
    UInt32 word = 0, size = 0;
    BOOL (^isCompatibleBrand)(UInt32) = ^BOOL(UInt32 brand) {
        return brand == 'M4V ' || brand == 'M4VP' || brand == 'M4VH' || (brand == 'M4A ' && !hasVideo);
    };
    if ([stream read:(uint8_t *)&size maxLength:4] == 4 && (size = CFSwapInt32BigToHost(size)) > 11
        && [stream read:(uint8_t *)&word maxLength:4] == 4 && CFSwapInt32BigToHost(word) == 'ftyp'
        && [stream read:(uint8_t *)&word maxLength:4] == 4) {
        if (isCompatibleBrand(CFSwapInt32BigToHost(word)))
            result = YES;
        else if (size > 0x13 && [stream read:(uint8_t *)&word maxLength:4] == 4) {
            for (UInt32 i = 0; i < (size - 16) / 4; i++) {
                if ([stream read:(uint8_t *)&word maxLength:4] != 4)
                    break;
                if (isCompatibleBrand(CFSwapInt32BigToHost(word))) {
                    result = YES;
                    break;
                }
            }
        }
    }
    [stream close];
    return result;
}

// AAC sound at 44.1 kHz or less, and at most one H.264 video track.
- (BOOL)isCompatibleWithIPad
{
    NSInteger soundTracks = [self trackCountOfTypes:(unsigned int *)kHSMovieSoundTypes count:2];
    for (NSInteger i = 0; i < soundTracks; i++) {
        AVAssetTrack *track = [self trackAtIndex:i ofTypes:(unsigned int *)kHSMovieSoundTypes count:2];
        NSInteger count = [self mediaSampleDescriptionsCountForTrack:track];
        for (NSInteger j = 0; j < count; j++)
            if ([self mediaSampleDataFormatForTrack:track atDescriptionIndex:j] != 'mp4a')
                return NO;
        CMAudioFormatDescriptionRef description = (CMAudioFormatDescriptionRef)[[track formatDescriptions] firstObject];
        const AudioStreamBasicDescription *basic = description ? CMAudioFormatDescriptionGetStreamBasicDescription(description) : NULL;
        if (basic != NULL && basic->mSampleRate > 44100.0)
            return NO;
    }
    unsigned int video = 'vide';
    NSInteger videoTracks = [self trackCountOfTypes:&video count:1];
    if (videoTracks >= 2)
        return NO;
    if (videoTracks > 0) {
        AVAssetTrack *track = [self trackAtIndex:0 ofTypes:&video count:1];
        NSInteger count = [self mediaSampleDescriptionsCountForTrack:track];
        for (NSInteger j = 0; j < count; j++)
            if ([self mediaSampleDataFormatForTrack:track atDescriptionIndex:j] != 'avc1')
                return NO;
    }
    return YES;
}

- (BOOL)isGifMovie
{
    return [self HSMovie_isGIF];
}

- (BOOL)HSMovie_isGIF
{
    for (AVAssetTrack *track in [[_movie AVAsset] tracksWithMediaCharacteristic:AVMediaCharacteristicVisual]) {
        if (![track isEnabled])
            continue;
        NSInteger count = [self mediaSampleDescriptionsCountForTrack:track];
        for (NSInteger i = 0; i < count; i++)
            if ([self mediaSampleDataFormatForTrack:track atDescriptionIndex:i] == 'gif ')
                return YES;
    }
    return NO;
}

// Every track's media lies in the movie file itself (the original checked
// each media data reference's self-contained flag).
- (BOOL)isMovieSelfContained
{
    NSURL *url = [[_movie attributeForKey:QTMovieURLAttribute] URLByStandardizingPath];
    for (AVAssetTrack *track in [[_movie AVAsset] tracks]) {
        if (![track canProvideSampleCursors])
            continue;
        AVSampleCursor *cursor = [track makeSampleCursorAtFirstSampleInDecodeOrder];
        NSURL *storage = [[cursor currentChunkStorageURL] URLByStandardizingPath];
        if (storage != nil && url != nil && ![storage isEqual:url])
            return NO;
    }
    return YES;
}

// Asked of the movie controller; there is none any more.
- (BOOL)isInteractiveMovie
{
    return NO;
}

- (BOOL)isFlash
{
    NSInteger total = [self totalTrackCount];
    return total > 0 && [self trackCountOfType:'flsh'] == total;
}

- (BOOL)isSound
{
    return [self hasSound] && ![self hasVideo];
}

- (BOOL)hasSound
{
    return [self trackCountOfTypes:(unsigned int *)kHSMovieSoundTypes count:2] > 0;
}

- (BOOL)hasVideo
{
    return [self trackCountOfTypes:(unsigned int *)kHSMovieVideoTypes count:2] > 0;
}

- (BOOL)hasDuration
{
    float duration = [self duration];
    float magnitude = duration != 0 ? fabsf(duration) : 1;
    if (magnitude < 0.01f)
        magnitude = 0.01f;
    return magnitude * -0.0005f + 0.01f <= duration;
}

// No video sample description with an alpha channel (32-bit depth) or GIF.
- (BOOL)isOpaque
{
    if (_movie == nil)
        return NO;
    unsigned int video = 'vide';
    NSInteger tracks = [self trackCountOfTypes:&video count:1];
    for (NSInteger i = 0; i < tracks; i++) {
        AVAssetTrack *track = [self trackAtIndex:i ofTypes:&video count:1];
        for (id description in [track formatDescriptions]) {
            NSNumber *depth = (NSNumber *)CMFormatDescriptionGetExtension((CMFormatDescriptionRef)description, kCMFormatDescriptionExtension_Depth);
            if ([depth intValue] == 32 || CMFormatDescriptionGetMediaSubType((CMFormatDescriptionRef)description) == 'gif ')
                return NO;
        }
    }
    return YES;
}

- (BOOL)hasAnythingVisible
{
    return !HSMovieIsNearZero(_originalSize.width) && _originalSize.width > 0
        && !HSMovieIsNearZero(_originalSize.height) && _originalSize.height > 0;
}

// FairPlay-protected sound.
- (BOOL)hasProtectedMovieTrack
{
    NSInteger count = [self trackCountOfTypes:(unsigned int *)kHSMovieSoundTypes count:2];
    for (NSInteger i = 0; i < count; i++) {
        AVAssetTrack *track = [self trackAtIndex:i ofTypes:(unsigned int *)kHSMovieSoundTypes count:2];
        NSInteger descriptions = [self mediaSampleDescriptionsCountForTrack:track];
        for (NSInteger j = 0; j < descriptions; j++) {
            NSUInteger format = [self mediaSampleDataFormatForTrack:track atDescriptionIndex:j];
            if (format == 'drms' || format == 'enca')
                return YES;
        }
    }
    return NO;
}

// Starting forward at the end (or backward at the start) of the play range
// starts over from the other end.
- (void)adjustCurrentTimeForSetRate:(CGFloat)aRate
{
    struct HSTimeRange range = [self playRange];
    if (!HSMovieIsNearZero(aRate) && aRate > 0) {
        if (fabs([self currentTime] - HSMaxTimeRange(range)) <= 0.1)
            [self gotoBeginning];
    } else if (!HSMovieIsNearZero(aRate) && aRate < 0) {
        if (fabs([self currentTime] - range.location) <= 0.1)
            [self gotoEnd];
    }
}

- (void)stepBack
{
    [self makeStepWithRate:-1];
}

- (void)stepForward
{
    [self makeStepWithRate:1];
}

// mcActionStep through the movie controller in the original.
- (void)makeStepWithRate:(NSInteger)aRate
{
    if ([self quickTimeMovie] == NULL)
        return;
    if (aRate < 0)
        for (NSInteger i = 0; i < -aRate; i++)
            [_movie stepBackward];
    else
        for (NSInteger i = 0; i < aRate; i++)
            [_movie stepForward];
    if ([self hasMovieRenderer])
        [self redraw];
}

// GoToEndOfMovie/GoToBeginningOfMovie: the ends of the time base, which is
// the play range.
- (void)gotoEnd
{
    if ([self quickTimeMovie] == NULL)
        return;
    [_movie setCurrentTime:QTMakeTimeWithTimeInterval(HSMaxTimeRange([self playRange]))];
    if ([self hasMovieRenderer])
        [self redraw];
}

- (void)gotoBeginning
{
    if ([self quickTimeMovie] == NULL)
        return;
    [_movie setCurrentTime:QTMakeTimeWithTimeInterval([self playRange].location)];
    if ([self hasMovieRenderer])
        [self redraw];
}

- (BOOL)isPlaying
{
    float rate = [self rate];
    return !HSMovieIsNearZero(rate);
}

- (void)HSMovie_stop
{
    [self destroyStopSoundFadeOutCompleteCallback];
    if ([_movie quickTimeMovie] != NULL && [self isPlaying]) {
        if (_playbackTimer != nil) {
            [self uninstallPlaybackTimer];
            [self setVolume:_volume];
        }
        _isPlayingBackwards = NO;
        [_movie stop];
        [[self delegate] movieDidStop:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:HSMovieDidStopNotification object:self];
    }
    [_movie setIdling:NO];
}

// With a fade-out stop time the movie fades out before it stops.
- (void)stop
{
    if (_stopSoundFadeOutTime < 0) {
        if (_soundFadeOutStopTime > 0)
            [self startSoundFadeOut];
        else
            [self HSMovie_stop];
    }
}

- (void)play
{
    if ([self quickTimeMovie] == NULL || [self isPlaying])
        return;
    [_movie setIdling:YES];
    [self updateFade];
    [self adjustCurrentTimeForSetRate:1];
    [self makeSureWeHaveMovieRendererIfPossible];
    [self installPlaybackTimer];
    _isPlayingBackwards = NO;
    [_movie play];
    _playingRate = [_movie rate];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSMovieDidStartNotification object:self];
}

- (void)setRate:(CGFloat)aRate
{
    if ([self quickTimeMovie] == NULL)
        return;
    if (!HSMovieIsNearZero(aRate)) {
        [self updateFade];
        [_movie setIdling:YES];
    } else
        [_movie setIdling:NO];
    [self adjustCurrentTimeForSetRate:aRate];
    [self makeSureWeHaveMovieRendererIfPossible];
    _isPlayingBackwards = aRate < 0;
    [_movie setRate:aRate];
    if (aRate != 0)
        _playingRate = aRate;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:aRate] forKey:HSMovieRateDidChangeNotificationParameter];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSMovieRateDidChangeNotification object:self userInfo:userInfo];
    [self installPlaybackTimer];
}

- (CGFloat)rate
{
    return [self quickTimeMovie] != NULL ? [_movie rate] : 0;
}

- (void)setCurrentTime:(double)aTime
{
    if ([self quickTimeMovie] == NULL)
        return;
    [_movie setCurrentTime:QTMakeTimeScaled(QTMakeTimeWithTimeInterval(aTime), [[_movie attributeForKey:QTMovieTimeScaleAttribute] longValue])];
    if ([self hasMovieRenderer])
        [self redraw];
}

- (double)currentTime
{
    if ([self quickTimeMovie] == NULL)
        return 0;
    QTTime time = [_movie currentTime];
    return time.timeScale ? (double)((float)time.timeValue / (float)time.timeScale) : 0;
}

// Samples of the movie's tracks of that type (QTVR movies count none).
- (NSInteger)numberOfFramesForMediaType:(NSUInteger)aType
{
    if ([self quickTimeMovie] == NULL || [self isQTVRMovie] || [self isPanoramaObject])
        return 0;
    NSInteger frames = 0;
    for (AVAssetTrack *track in [[_movie AVAsset] tracks])
        if (HSMovieMediaTypeOfTrack(track) == aType)
            frames = MAX(frames, HSMovieSampleCountOfTrack(track, 0));
    return frames;
}

// Frames of the first video (or MPEG) track per second of the movie.
- (NSInteger)framesPerSecond
{
    if ([self quickTimeMovie] == NULL)
        return 0;
    NSInteger fps = 0;
    QTTime duration = [_movie duration];
    for (int i = 0; i < 2 && fps <= 0; i++) {
        for (AVAssetTrack *track in [[_movie AVAsset] tracks]) {
            if (HSMovieMediaTypeOfTrack(track) != kHSMovieVideoTypes[i])
                continue;
            NSInteger frames = [self numberOfFramesForMediaType:kHSMovieVideoTypes[i]];
            // Fix: the original divided by the duration even when it was 0.
            fps = duration.timeValue > 0 ? (NSInteger)((duration.timeScale * (long long)frames) / duration.timeValue) : 0;
            break;
        }
    }
    return fps;
}

- (void)setVolume:(CGFloat)aVolume
{
    [self setVolume:aVolume updateFade:YES];
}

// QuickTime volumes: 8.8 fixed, ±1.0; negative meant muted.
- (void)setVolume:(CGFloat)aVolume updateFade:(BOOL)aFade
{
    if ([self quickTimeMovie] == NULL)
        return;
    short volume = (short)(int)(aVolume * 256);
    volume = MIN(MAX(volume, -0x100), 0x100);
    if (volume == (short)(int)([_movie volume] * 256))
        return;
    [_movie setVolume:MAX(volume, 0) / 256.0f];
    _volume = MAX(volume, 0) * (1.0f / 256);
    if (aFade)
        [self updateFade];
}

- (CGFloat)volume
{
    return _volume;
}

- (NSUInteger)playCount
{
    return _playCount;
}

- (void)setPlayCount:(NSUInteger)aCount
{
    _playCount = (unsigned int)aCount;
    _previousLoopMode = aCount != 1;
    [self setLoopMode:aCount != 1];
}

// 1 loops, 2 loops back and forth (the time base's loop flags).
- (void)setLoopMode:(NSInteger)aMode
{
    if ([self quickTimeMovie] == NULL)
        return;
    _loopMode = aMode == 1 || aMode == 2 ? aMode : 0;
}

- (NSInteger)loopMode
{
    return [self quickTimeMovie] != NULL ? _loopMode : 0;
}

- (void)QTVRConstraintsForType:(NSInteger)aType minValue:(float *)aValue maxValue:(float *)aValue2
{
}

- (struct OpaqueQTVRInstance *)QTVRInstance
{
    return NULL;
}

// The playback timer: follows the volume curve, and stops the movie once a
// fade-out has run its course.
- (void)correctPlayback:(id)aPlayback
{
    if ([self quickTimeMovie] == NULL || ![self isPlaying])
        return;
    long long now = [_movie currentTime].timeValue;
    if (_stopSoundFadeOutTime >= 0 && now >= _stopSoundFadeOutTime) {
        [[self retain] autorelease];
        [self HSMovie_stop];
        return;
    }
    [self setVolume:[_volumeCurve convertRawToDB:(NSInteger)now] updateFade:NO];
}

- (void)uninstallPlaybackTimer
{
    [_playbackTimer invalidate];
    [_playbackTimer release];
    _playbackTimer = nil;
}

// Every 50 ms in the common run loop modes, while there is a fade.
- (void)installPlaybackTimer
{
    _currentPlayCount = 0;
    if (_playbackTimer != nil)
        [self uninstallPlaybackTimer];
    if (_soundFadeInTime > 0 || _soundFadeOutTime > 0 || _soundFadeOutStopTime > 0) {
        _initialVolume = _volume;
        _playbackTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(correctPlayback:) userInfo:nil repeats:YES] retain];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:_playbackTimer forMode:NSDefaultRunLoopMode];
        [runLoop addTimer:_playbackTimer forMode:NSEventTrackingRunLoopMode];
        [runLoop addTimer:_playbackTimer forMode:NSModalPanelRunLoopMode];
    }
}

// Fades out from now over the fade-out stop time (cut short at the end of
// the play range, which the stop time then keeps), then stops.
- (void)startSoundFadeOut
{
    if ([self quickTimeMovie] == NULL)
        return;
    long scale = [[_movie attributeForKey:QTMovieTimeScaleAttribute] longValue];
    double current = [self currentTime];
    long now = lround(current * scale);
    double stopTime = _soundFadeOutStopTime;
    double end = HSMaxTimeRange([self playRange]);
    if (end < stopTime + current) {
        stopTime = end - current;
        _soundFadeOutStopTime = stopTime;
    }
    long stop = lround(stopTime * scale) + now;
    if (now < stop) {
        if ([self createStopSoundFadeOutCompleteCallbackWithTime:stop] == noErr) {
            [_volumeCurve resetRange];
            [_volumeCurve addRangeWithMinRaw:now maxRaw:stop minDB:_volume maxDB:0];
            [self installPlaybackTimer];
        }
    } else
        // Fix: the original left the movie playing when no time was left.
        [self HSMovie_stop];
}

// The volume curve over the play range: fade in from silence, hold, fade
// out to silence, in movie time units.
- (void)updateFade
{
    if ([self quickTimeMovie] == NULL)
        return;
    long scale = [[_movie attributeForKey:QTMovieTimeScaleAttribute] longValue];
    struct HSTimeRange range = [self playRange];
    NSInteger start = (NSInteger)(range.location * scale);
    NSInteger stop = (NSInteger)(HSMaxTimeRange(range) * scale);
    NSInteger fadeIn = (NSInteger)([self soundFadeInTime] * scale);
    NSInteger fadeOut = (NSInteger)([self soundFadeOutTime] * scale);
    [_volumeCurve resetRange];
    if (fadeIn != 0)
        [_volumeCurve addRangeWithMinRaw:start maxRaw:start + fadeIn minDB:0 maxDB:_volume];
    [_volumeCurve addRangeWithMinRaw:start + fadeIn maxRaw:stop - fadeOut minDB:_volume maxDB:_volume];
    if (fadeOut != 0)
        [_volumeCurve addRangeWithMinRaw:stop - fadeOut maxRaw:stop minDB:_volume maxDB:0];
}

- (void)setSoundFadeInTime:(double)aTime
{
    _soundFadeInTime = aTime;
}

- (double)soundFadeInTime
{
    return _soundFadeInTime;
}

- (void)setSoundFadeOutStopTime:(double)aTime
{
    _soundFadeOutStopTime = aTime;
}

- (double)soundFadeOutStopTime
{
    return _soundFadeOutStopTime;
}

- (void)setSoundFadeOutTime:(double)aTime
{
    _soundFadeOutTime = aTime;
}

- (double)soundFadeOutTime
{
    return _soundFadeOutTime;
}

// Clamped to the movie: a negative start becomes 0, an end past the movie
// its end. Looping starts over at the range's start.
- (void)setPlayRange:(struct HSTimeRange)aRange
{
    if ([self quickTimeMovie] == NULL)
        return;
    double location = HSMovieIsNearZero(aRange.location) || aRange.location >= 0 ? aRange.location : 0;
    if (location < 0)
        location = 0;
    double length = aRange.length;
    double duration = [self duration];
    struct HSTimeRange clamped = { location, length };
    double end = HSMaxTimeRange(clamped);
    if (MAX(fabs(end), MAX(fabs(duration), 1.0)) * 0.0005 + duration < end)
        length = duration - location;
    clamped.length = length;
    [_movie setSelection:QTMakeTimeRange(QTMakeTimeWithTimeInterval(location), QTMakeTimeWithTimeInterval(length))];
    [_movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMoviePlaysSelectionOnlyAttribute];
    QTTime start = QTMakeTimeWithTimeInterval(location);
    _startTime.timeValue = start.timeValue;
    _startTime.timeScale = (int)start.timeScale;
    _startTime.flags = (int)start.flags;
}

- (struct HSTimeRange)playRange
{
    struct HSTimeRange range = { 0, 0 };
    if ([self quickTimeMovie] != NULL)
        range = [HSMovie HSMovie_playRangeForMovie:(struct MovieType **)[self quickTimeMovie]];
    return range;
}

- (double)posterTime
{
    if ([self quickTimeMovie] == NULL)
        return 0;
    QTTime time = [[_movie attributeForKey:QTMoviePosterTimeAttribute] QTTimeValue];
    return time.timeScale ? (double)((float)time.timeValue / (float)time.timeScale) : 0;
}

- (double)duration
{
    if ([self quickTimeMovie] == NULL)
        return 0;
    QTTime time = [_movie duration];
    return time.timeScale ? (double)((float)time.timeValue / (float)time.timeScale) : 0;
}

// The movie box.
- (NSSize)size
{
    if ([self quickTimeMovie] == NULL)
        return NSZeroSize;
    NSSize size = [[_movie attributeForKey:QTMovieCurrentSizeAttribute] sizeValue];
    return NSMakeSize(floor(size.width), floor(size.height));
}

- (NSSize)originalSize
{
    return _originalSize;
}

- (void *)quickTimeMovie
{
    return [_movie quickTimeMovie];
}

- (struct ComponentInstanceRecord *)movieController
{
    return _movieController;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_playbackTimer != nil)
        [self uninstallPlaybackTimer];
    [self HSMovie_stop];
    [self destroyMovieRenderer];
    [self destroyMoviePlaybackCompleteCallback];
    [_movie release];
    [_volumeCurve release];
    [super dealloc];
}

- (id)initWithURL:(id)aURL error:(id *)aError
{
    id movie = [[HSMovie createMovieAndDontResolveDataRefsWithURL:aURL error:aError] autorelease];
    if (movie == nil) {
        [self release];
        return nil;
    }
    return [self initWithMovie:movie error:aError];
}

- (id)initWithMovie:(id)aMovie error:(id *)aError
{
    if (!(self = [super init]))
        return nil;
    if (aMovie == nil) {
        [self release];
        return nil;
    }
    _movie = [aMovie retain];
    [_movie setIdling:NO];
    _movieController = [_movie quickTimeMovieController];
    _stopSoundFadeOutTime = -1;
    _originalSize = [self size];
    _volume = MIN(MAX([_movie volume], 0.0f), 1.0f);
    _volumeCurve = [HSVolumeCurve new];
    [self updateFade];
    _playCount = 1;
    if (![self isInteractiveMovie])
        [self createMoviePlaybackCompleteCallback];
    return self;
}

- (void)pause
{
    if (_movie != nil && [self isPlaying]) {
        [_movie stop];
        _isPaused = YES;
    }
}

- (void)resume
{
    if (_movie != nil && _isPaused && ![self isPlaying]) {
        [_movie play];
        _isPaused = NO;
    }
}

- (BOOL)isSynchronousRendering
{
    return _isSynchronousRendering;
}

- (void)setSynchronousRendering:(BOOL)aSynchronousRendering
{
    if (_isSynchronousRendering != aSynchronousRendering) {
        _isSynchronousRendering = aSynchronousRendering;
        [self destroyMovieRenderer];
        [self makeSureWeHaveMovieRendererIfPossible];
    }
}

@end
