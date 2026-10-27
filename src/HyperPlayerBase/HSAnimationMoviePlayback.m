#import "HSAnimationMoviePlayback.h"
// Plays the animated object's movie (or animated image) while it moves
// along an animation path: at its own pace, at the option's movie speed,
// or matched to the movement (the movie time follows the path length,
// kAnimationPathDefaultPointsPerSecondCount points per second). The owner
// (the animation) provides the object, options and path.

@implementation HSAnimationMoviePlayback

- (void)stop
{
    [_owner stopFromAnimationMoviePlayback:self];
}

- (BOOL)isPlaying
{
    return [_owner isPlayingForAnimationMoviePlayback:self];
}

- (id)objectToAnimate
{
    return [_owner objectToAnimateForAnimationMoviePlayback:self];
}

- (id)options
{
    return [_owner optionsForAnimationMoviePlayback:self];
}

- (id)structure
{
    return [_owner structureForAnimationMoviePlayback:self];
}

// Playing once (loop frame repeats 1) ends the animation with the movie.
- (void)hyperPlayableObjectDidPlayOnce:(id)aOnce frameCount:(NSInteger)aCount
{
    if (_playTimeLoopFrameRepeats == aCount)
        [self stop];
}

// The playback's length at the movie speed, or when it actually finished.
- (CGFloat)movieDuration
{
    id attributes = _playTimeAttributes;
    if (!attributes)
        attributes = [[self objectToAnimate] queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
    double framesPerSecond = [[[self objectToAnimate] queryHyperInterface:@protocol(HSFramesPerSecondAttributes)] hyperFramesPerSecond];
    double duration = _playbackCompletionTime;
    if (duration == 0)
        duration = ((double)(int)framesPerSecond * [attributes hyperDuration]) / [[self options] movieSpeed];
    return (float)duration;
}

// The movie speed relative to the movie's own frame rate.
- (CGFloat)movieRelativeSpeed
{
    HSAnimationOptions *options = [self options];
    if ([options playMovie] && [options wasMovieSpeedSet] && [self objectToAnimate] && ![options matchToMovement]) {
        double framesPerSecond = [[[self objectToAnimate] queryHyperInterface:@protocol(HSFramesPerSecondAttributes)] hyperFramesPerSecond];
        if (framesPerSecond != 0)
            return (float)([[self options] movieSpeed] / framesPerSecond);
    }
    return 1.0f;
}

// Matching the movement: the movie time is the path length so far (plus
// a frame), wrapped into the play range. Loop mode 4 stops after the
// frame repeats.
- (void)playbackTimeDidChange:(double)aChange
{
    if (!_playTimeIsMatchToMovement || ![self isPlaying] || ![[self options] playMovie])
        return;
    double framesPerSecond = [[[self objectToAnimate] queryHyperInterface:@protocol(HSFramesPerSecondAttributes)] hyperFramesPerSecond];
    id structure = [self structure];
    double pathLength = [structure pathLengthAtTime:[_owner pathTimeForAnimationMoviePlayback:self]];
    struct HSTimeRange range = [_playTimeAttributes hyperPlayRange];
    double time = pathLength / kAnimationPathDefaultPointsPerSecondCount + 1.0 / framesPerSecond;
    double movieTime = fmod(time, range.length) + range.location;
    if (_playTimeLoopMode == 4 && time >= _playTimeLoopFrameRepeatsStopTime) {
        _playbackCompletionTime = aChange;
        [_playTimeAttributes setHyperCurrentTime:HSMaxTimeRange(range)];
        [self stop];
    } else
        [_playTimeAttributes setHyperCurrentTime:movieTime];
}

- (void)stopMovieIfNecessary
{
    if (![[self options] playMovie])
        return;
    [_playTimeAttributes hyperStop];
    id attributes = _playTimeAttributes;
    _playTimeAttributes = nil;
    [attributes release];
}

// Loop mode 4 makes this the movie's delegate, to count its plays.
- (void)startMovieIfNecessary
{
    if (![[self options] playMovie])
        return;
    // (The original doesn't release attributes of an earlier start.)
    _playTimeAttributes = [[[self objectToAnimate] queryHyperInterface:@protocol(HSExtendedPlayableObjectAttributes)] retain];
    id framesPerSecondAttributes = [_playTimeAttributes queryHyperInterface:@protocol(HSFramesPerSecondAttributes)];
    _playTimeIsMatchToMovement = [[self options] matchToMovement];
    _playTimeLoopFrameRepeats = (int)[[self options] loopFrameRepeats];
    _playTimeLoopMode = (int)[[self options] loopMode];
    [[[self objectToAnimate] undoManager] disableUndoRegistration];
    [_playTimeAttributes setHyperPlayCount:0];
    [[[self objectToAnimate] undoManager] enableUndoRegistration];
    id delegate = _playTimeLoopMode == 4 ? self : nil;
    if ([[self options] movieSpeed] == [HSAnimationOptions undefinedMovieSpeed] || _playTimeIsMatchToMovement) {
        _playbackCompletionTime = 0;
        _playTimeLoopFrameRepeatsStopTime = (double)_playTimeLoopFrameRepeats * HSMaxTimeRange([_playTimeAttributes hyperPlayRange]);
        [_playTimeAttributes hyperStart:delegate startupMode:1];
    } else {
        _playTimeLoopFrameRepeatsStopTime = 0;
        double framesPerSecond = [framesPerSecondAttributes hyperFramesPerSecond];
        float rate = framesPerSecond == 0 ? 1.0f : (float)([[self options] movieSpeed] / framesPerSecond);
        [_playTimeAttributes hyperStart:delegate atRate:rate startupMode:0];
    }
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

- (void)dealloc
{
    [_playTimeAttributes release];
    [super dealloc];
}

@end
