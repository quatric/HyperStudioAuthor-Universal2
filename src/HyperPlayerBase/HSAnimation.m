#import "HSAnimation.h"
#import "HyperPlayerBaseData.h"

@implementation HSAnimation

+ (NSInteger)animationAbsoluteLayerFromXMLAnimationAbsoluteLayerString:(id)aString
{
    if ([aString isEqualToString:@"bottom"])
        return 0;
    return [aString isEqualToString:@"top"] ? 1 : 2;
}

+ (NSInteger)animationLayerFromXMLAnimationLayerString:(id)aString
{
    if ([aString isEqualToString:@"bottom"])
        return 0;
    return [aString isEqualToString:@"top"] ? 2 : 1;
}

+ (NSInteger)animationSpeedModeFromXMLSpeedModeString:(id)aString
{
    if ([aString isEqualToString:@"clampDuration"])
        return 1;
    return [aString isEqualToString:@"timesPerSecond"] ? 2 : 0;
}

+ (NSInteger)animationLoopModeFromXMLLoopModeString:(id)aString
{
    if ([aString isEqualToString:@"forever"])
        return 1;
    if ([aString isEqualToString:@"pathRepeats"])
        return 2;
    if ([aString isEqualToString:@"seconds"])
        return 3;
    return [aString isEqualToString:@"frameRepeats"] ? 4 : 0;
}

+ (id)XMLAnimationSpeedModeStringForSpeedMode:(NSInteger)aMode
{
    if (aMode == 1)
        return @"clampDuration";
    return aMode == 2 ? @"timesPerSecond" : @"multiplier";
}

+ (id)XMLAnimationLoopModeStingForLoopMode:(NSInteger)aMode
{
    switch (aMode)
    {
        case 1:
            return @"forever";
        case 2:
            return @"pathRepeats";
        case 3:
            return @"seconds";
        case 4:
            return @"frameRepeats";
        default:
            return @"none";
    }
}

+ (id)XMLAnimationLayerStringForAbsoluteLayer:(NSInteger)aLayer
{
    if (aLayer == 0)
        return @"bottom";
    return aLayer == 1 ? @"top" : @"starter";
}

+ (id)XMLAnimationLayerStringForLayer:(NSInteger)aLayer
{
    if (aLayer == 0)
        return @"bottom";
    return aLayer == 2 ? @"top" : @"dontcare";
}

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    // XML points are top-down, the path is bottom-up.
    CGFloat cardHeight = [[aContext stack] hyperCardSize].height;
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSMutableArray *keyFrames = [NSMutableArray array];
    id pathElement = [[aRepresentation elementsForName:@"path"] extraFirstObject];
    BOOL isFirstPoint = YES;
    for (id pointElement in [pathElement children])
    {
        NSArray *coordinates = [[[pointElement attributeForName:@"point"] stringValue] componentsSeparatedByString:@","];
        NSString *timestamp = [[pointElement attributeForName:@"timestamp"] stringValue];
        if ([coordinates count] < 2 || timestamp == nil)
            continue;
        NSPoint point = NSMakePoint([[coordinates objectAtIndex:0] floatValue], cardHeight - [[coordinates objectAtIndex:1] floatValue]);
        if (isFirstPoint)
        {
            [path moveToPoint:point];
            isFirstPoint = NO;
        }
        else
            [path lineToPoint:point];
        [keyFrames addObject:[NSNumber numberWithDouble:[timestamp doubleValue]]];
    }
    [(HSAnimationStructure *)[self structure] setPath:path keyFrames:keyFrames];

    id behavior = [[aRepresentation elementsForName:@"behavior"] extraFirstObject];
    [self setUseClones:[[[behavior attributeForName:@"useClones"] stringValue] hyperBoolValue]];
    [self setHideOnFirstFrame:[[[behavior attributeForName:@"hideFirstFrame"] stringValue] hyperBoolValue]];
    [self setHideOnLastFrame:[[[behavior attributeForName:@"hideLastFrame"] stringValue] hyperBoolValue]];
    [self setDontEraseGoing:[[[behavior attributeForName:@"dontEraseGoing"] stringValue] hyperBoolValue]];
    [self setDontEraseReturning:[[[behavior attributeForName:@"dontEraseReturning"] stringValue] hyperBoolValue]];
    [self setHorizontalFlipAtStart:[[[behavior attributeForName:@"horizontalFlipAtStart"] stringValue] hyperBoolValue]];
    [self setHorizontalFlipAtFinish:[[[behavior attributeForName:@"horizontalFlipAtFinish"] stringValue] hyperBoolValue]];
    [self setVerticalFlipAtStart:[[[behavior attributeForName:@"verticalFlipAtStart"] stringValue] hyperBoolValue]];
    [self setVerticalFlipAtFinish:[[[behavior attributeForName:@"verticalFlipAtFinish"] stringValue] hyperBoolValue]];
    [self setPlayMovie:[[[behavior attributeForName:@"playMovie"] stringValue] hyperBoolValue]];
    [self setMovieSpeed:[[[behavior attributeForName:@"movieSpeed"] stringValue] doubleValue]];

    id loop = [[aRepresentation elementsForName:@"loop"] extraFirstObject];
    [self setLoopMode:[[self class] animationLoopModeFromXMLLoopModeString:[[loop attributeForName:@"mode"] stringValue]]];
    [self setLoopPathRepeats:[[[loop attributeForName:@"pathRepeats"] stringValue] intValue]];
    // The original stores the frame repeats into the path repeats.
    [self setLoopPathRepeats:[[[loop attributeForName:@"frameRepeats"] stringValue] intValue]];
    [self setLoopSeconds:[[[loop attributeForName:@"seconds"] stringValue] doubleValue]];

    id playback = [[aRepresentation elementsForName:@"playback"] extraFirstObject];
    [self setPlaybackDirection:[[[playback attributeForName:@"direction"] stringValue] isEqualToString:@"backward"] ? 1 : 0];
    [self setPlayBackAndForth:[[[playback attributeForName:@"backAndForth"] stringValue] hyperBoolValue]];
    [self setMatchToMovement:[[[playback attributeForName:@"matchToMovement"] stringValue] hyperBoolValue]];
    [self setTimesPerSecond:[[[playback attributeForName:@"timesPerSecond"] stringValue] intValue]];
    [self setSpeedMode:[[self class] animationSpeedModeFromXMLSpeedModeString:[[playback attributeForName:@"speedMode"] stringValue]]];
    [self setSpeedMultiplier:[[[playback attributeForName:@"speedMultiplier"] stringValue] floatValue]];
    [self setClampedDuration:[[[playback attributeForName:@"clampedDuration"] stringValue] doubleValue]];

    id layer = [[aRepresentation elementsForName:@"layer"] extraFirstObject];
    [self setLayer:[[self class] animationLayerFromXMLAnimationLayerString:[[layer attributeForName:@"animations"] stringValue]]];
    [self setGoingAbsoluteLayer:[[self class] animationAbsoluteLayerFromXMLAnimationAbsoluteLayerString:[[layer attributeForName:@"going"] stringValue]]];
    [self setReturningAbsoluteLayer:[[self class] animationAbsoluteLayerFromXMLAnimationAbsoluteLayerString:[[layer attributeForName:@"returning"] stringValue]]];

    id transparency = [[aRepresentation elementsForName:@"transparency"] extraFirstObject];
    [self setUsesTransparentColor:[[[transparency attributeForName:@"enabled"] stringValue] hyperBoolValue]];
    [self setTransparentColorHueTolerance:[[[transparency attributeForName:@"hueTolerance"] stringValue] doubleValue]];
    [self setTransparentColorChromaTolerance:[[[transparency attributeForName:@"chromaTolerance"] stringValue] doubleValue]];
    [self setTransparentColorLightnessTolerance:[[[transparency attributeForName:@"lightnessTolerance"] stringValue] doubleValue]];
    NSColor *color = [NSColor blackColor];
    NSArray *components = [[[transparency attributeForName:@"color"] stringValue] componentsSeparatedByString:@","];
    if ([components count] > 2)
        color = [NSColor colorWithCalibratedRed:[[components objectAtIndex:0] floatValue] green:[[components objectAtIndex:1] floatValue] blue:[[components objectAtIndex:2] floatValue] alpha:1];
    [self setTransparentColor:color];

    [pool release];
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [NSXMLElement elementWithName:[self XMLElementName]];

    NSXMLElement *pathElement = [NSXMLElement elementWithName:@"path"];
    CGFloat cardHeight = [[[aContext document] stack] hyperCardSize].height;
    for (NSNumber *keyFrame in [self pathKeyFrames])
    {
        NSPoint point = [self pathPointAtTime:[keyFrame doubleValue]];
        NSXMLElement *pointElement = [NSXMLElement elementWithName:@"pathPoint"];
        [pointElement addAttribute:[NSXMLNode attributeWithName:@"point" stringValue:[NSString stringWithFormat:@"%.1f,%.1f", (double)(float)point.x, (double)(cardHeight - point.y)]]];
        [pointElement addAttribute:[NSXMLNode attributeWithName:@"timestamp" stringValue:[NSString stringWithFormat:@"%.8f", [keyFrame doubleValue]]]];
        [pathElement addChild:pointElement];
    }
    [element addChild:pathElement];

    NSXMLElement *behavior = [NSXMLElement elementWithName:@"behavior"];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"useClones" stringValue:[self useClones] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"hideFirstFrame" stringValue:[self hideOnFirstFrame] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"hideLastFrame" stringValue:[self hideOnLastFrame] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"dontEraseGoing" stringValue:[self dontEraseGoing] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"dontEraseReturning" stringValue:[self dontEraseReturning] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"horizontalFlipAtStart" stringValue:[self horizontalFlipAtStart] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"horizontalFlipAtFinish" stringValue:[self horizontalFlipAtFinish] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"verticalFlipAtStart" stringValue:[self verticalFlipAtStart] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"verticalFlipAtFinish" stringValue:[self verticalFlipAtFinish] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"playMovie" stringValue:[self playMovie] ? HSXMLStoring1String : HSXMLStoring0String]];
    [behavior addAttribute:[NSXMLNode attributeWithName:@"movieSpeed" stringValue:[NSString stringWithFormat:@"%.2f", [self movieSpeed]]]];
    [element addChild:behavior];

    NSXMLElement *loop = [NSXMLElement elementWithName:@"loop"];
    [loop addAttribute:[NSXMLNode attributeWithName:@"mode" stringValue:[[self class] XMLAnimationLoopModeStingForLoopMode:[self loopMode]]]];
    [loop addAttribute:[NSXMLNode attributeWithName:@"pathRepeats" stringValue:[NSString stringWithFormat:@"%d", (int)[self loopPathRepeats]]]];
    [loop addAttribute:[NSXMLNode attributeWithName:@"frameRepeats" stringValue:[NSString stringWithFormat:@"%d", (int)[self loopFrameRepeats]]]];
    [loop addAttribute:[NSXMLNode attributeWithName:@"seconds" stringValue:[NSString stringWithFormat:@"%.1f", [self loopSeconds]]]];
    [element addChild:loop];

    NSXMLElement *playback = [NSXMLElement elementWithName:@"playback"];
    [playback addAttribute:[NSXMLNode attributeWithName:@"direction" stringValue:[self playbackDirection] == 1 ? @"backward" : @"forward"]];
    [playback addAttribute:[NSXMLNode attributeWithName:@"backAndForth" stringValue:[self playBackAndForth] ? HSXMLStoring1String : HSXMLStoring0String]];
    [playback addAttribute:[NSXMLNode attributeWithName:@"matchToMovement" stringValue:[self matchToMovement] ? HSXMLStoring1String : HSXMLStoring0String]];
    [playback addAttribute:[NSXMLNode attributeWithName:@"timesPerSecond" stringValue:[NSString stringWithFormat:@"%d", (int)[self timesPerSecond]]]];
    [playback addAttribute:[NSXMLNode attributeWithName:@"speedMode" stringValue:[[self class] XMLAnimationSpeedModeStringForSpeedMode:[self speedMode]]]];
    [playback addAttribute:[NSXMLNode attributeWithName:@"speedMultiplier" stringValue:[NSString stringWithFormat:@"%.8f", (double)[self speedMultiplier]]]];
    [playback addAttribute:[NSXMLNode attributeWithName:@"clampedDuration" stringValue:[NSString stringWithFormat:@"%.8f", [self clampedDuration]]]];
    [element addChild:playback];

    NSXMLElement *layer = [NSXMLElement elementWithName:@"layer"];
    [layer addAttribute:[NSXMLNode attributeWithName:@"animations" stringValue:[[self class] XMLAnimationLayerStringForLayer:[self layer]]]];
    [layer addAttribute:[NSXMLNode attributeWithName:@"going" stringValue:[[self class] XMLAnimationLayerStringForAbsoluteLayer:[self goingAbsoluteLayer]]]];
    [layer addAttribute:[NSXMLNode attributeWithName:@"returning" stringValue:[[self class] XMLAnimationLayerStringForAbsoluteLayer:[self returningAbsoluteLayer]]]];
    [element addChild:layer];

    NSXMLElement *transparency = [NSXMLElement elementWithName:@"transparency"];
    [transparency addAttribute:[NSXMLNode attributeWithName:@"enabled" stringValue:[self usesTransparentColor] ? HSXMLStoring1String : HSXMLStoring0String]];
    [transparency addAttribute:[NSXMLNode attributeWithName:@"hueTolerance" stringValue:[NSString stringWithFormat:@"%.2f", [self transparentColorHueTolerance]]]];
    [transparency addAttribute:[NSXMLNode attributeWithName:@"chromaTolerance" stringValue:[NSString stringWithFormat:@"%.2f", [self transparentColorChromaTolerance]]]];
    [transparency addAttribute:[NSXMLNode attributeWithName:@"lightnessTolerance" stringValue:[NSString stringWithFormat:@"%.2f", [self transparentColorLightnessTolerance]]]];
    NSColor *color = [[self transparentColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    double red = 0, green = 0, blue = 0;
    if (color != nil)
    {
        red = [color redComponent];
        green = [color greenComponent];
        blue = [color blueComponent];
    }
    [transparency addAttribute:[NSXMLNode attributeWithName:@"color" stringValue:[NSString stringWithFormat:@"%.8f,%.8f,%.8f", red, green, blue]]];
    [element addChild:transparency];
    return element;
}

- (id)XMLElementName
{
    return @"animation";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

// Records the object's current values as the attribute values at the
// current path time.
- (void)updateAnimationFromObjectToAnimate
{
    if ([self animatedObject] == nil)
        return;
    NSDictionary *attributes = [_structure attributes];
    NSEnumerator *keys = [attributes keyEnumerator];
    id key;
    while ((key = [keys nextObject]) != nil)
    {
        id attribute = [attributes objectForKey:key];
        id value = [[self animatedObject] valueForKey:key];
        if (![[attribute valueAtTime:_pathTime] isEqual:value])
            [attribute setValue:value atTime:_pathTime];
    }
}

- (double)pathTimeForAnimationPositioning:(id)aPositioning
{
    return _pathTime;
}

- (id)structureForAnimationPositioning:(id)aPositioning
{
    return _structure;
}

- (id)objectToAnimateForAnimationPositioning:(id)aPositioning
{
    return [self animatedObject];
}

- (NSPoint)objectPositionAtZeroTime
{
    return [_positioning objectPositionAtZeroTime];
}

- (void)setObjectPosition:(NSPoint)aPosition
{
    [_positioning setObjectPosition:aPosition];
}

- (NSPoint)objectPosition
{
    return [_positioning objectPosition];
}

- (void)updateObject
{
    [_positioning updateObject];
}

- (void)prepareAnimation
{
    _pathTime = 0;
    [self updateAnimationFromObjectToAnimate];
    [_positioning setObjectPosition:[self pathPointAtTime:0]];
    [_positioning updateFixation];
    [self setPathTime:[self startPathTime]];
}

- (id)positioning
{
    return _positioning;
}

- (void)stopFromAnimationMoviePlayback:(id)aPlayback
{
    [self stop];
}

- (BOOL)isPlayingForAnimationMoviePlayback:(id)aPlayback
{
    return [_playbackState isPlaying];
}

- (id)objectToAnimateForAnimationMoviePlayback:(id)aPlayback
{
    return [self animatedObject];
}

- (id)optionsForAnimationMoviePlayback:(id)aPlayback
{
    return _options;
}

- (id)structureForAnimationMoviePlayback:(id)aPlayback
{
    return _structure;
}

- (CGFloat)movieRelativeSpeed
{
    return [_moviePlayback movieRelativeSpeed];
}

- (void)playbackDidEndForAnimationPlaybackState:(id)aState
{
    [_moviePlayback stopMovieIfNecessary];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSAnimationPlaybackDidEndNotification object:self];
}

- (void)playbackTimeDidChangeForAnimationPlaybackState:(id)aState
{
    double playbackTime = [aState playbackTime];
    [self setPathTime:[_times pathTimeForPlaybackTime:playbackTime]];
    BOOL isReturning = [_times isReturningAtPlaybackTime:playbackTime];
    if (isReturning != _wasReturning)
    {
        NSDictionary *info = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:isReturning] forKey:HSAnimationIsReturningKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:HSAnimationDirectionDidChangeNotification object:self userInfo:info];
        _wasReturning = isReturning;
        if ([self canFlipAtFinish] && [self horizontalFlipAtFinish])
            [self flipAnimatedObjectHorizntally];
        if ([self canFlipAtFinish] && [self verticalFlipAtFinish])
            [self flipAnimatedObjectVertically];
        if ([self canFlipAtStart] && [self horizontalFlipAtStart])
            [self flipAnimatedObjectHorizntally];
        if ([self canFlipAtStart] && [self verticalFlipAtStart])
            [self flipAnimatedObjectVertically];
    }
    [_moviePlayback playbackTimeDidChange:playbackTime];
}

- (void)playbackWillStartForAnimationPlaybackState:(id)aState
{
    [_positioning updateFixation];
}

- (NSInteger)timesPerSecondForAnimationPlaybackState:(id)aState
{
    return [self speedMode] == 2 ? [self timesPerSecond] : [self normalTimesPerSecond];
}

- (BOOL)usesNormalTimesPerSecondForAnimationPlaybackState:(id)aState
{
    return [self speedMode] != 2;
}

- (double)playbackDurationForAnimationPlaybackState:(id)aState
{
    return [_times playbackDuration];
}

- (BOOL)wasReturning
{
    return _wasReturning;
}

- (BOOL)isReturning
{
    return [_times isReturningAtPlaybackTime:[_playbackState playbackTime]];
}

- (BOOL)isGoing
{
    return ![self isReturning];
}

- (double)playbackTime
{
    return [_playbackState playbackTime];
}

- (void)resume
{
    [_playbackState resume];
}

- (void)pause
{
    [_playbackState pause];
}

- (BOOL)isPaused
{
    return [_playbackState isPaused];
}

- (void)stop
{
    [_playbackState stop];
}

- (void)start:(BOOL)aStart
{
    [_animatedObject beginContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
    [_positioning updateFixation];
    double startPathTime = [self startPathTime];
    if (aStart)
        [self setPathTime:startPathTime];
    else
        _pathTime = startPathTime;
    _wasReturning = NO;
    [_playbackState start];
    [_moviePlayback startMovieIfNecessary];
    id liveObject = [[self animatedObject] queryHyperInterface:@protocol(HSLiveObjectAttributes)];
    if (liveObject != nil)
        [liveObject hyperStart:self];
}

- (void)start
{
    [self start:NO];
}

- (BOOL)isPlaying
{
    return [_playbackState isPlaying];
}

- (double)finishPathTime
{
    return [_times pathTimeForPlaybackTime:[_times playbackDuration]];
}

- (double)playbackDuration
{
    return [_times playbackDuration];
}

- (double)startPathTime
{
    return [_times pathTimeForPlaybackTime:0];
}

- (void)setPathTime:(double)aTime
{
    _pathTime = aTime;
    [self updateObject];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSAnimationPathTimeDidChangeNotification object:self];
}

- (double)pathTime
{
    return _pathTime;
}

- (NSInteger)normalTimesPerSecondForAnimationTimes:(id)aTimes
{
    return [self normalTimesPerSecond];
}

- (NSInteger)timesPerSecondForAnimationTimes:(id)aTimes
{
    return [self timesPerSecond];
}

- (id)optionsForAnimationTimes:(id)aTimes
{
    return [self options];
}

- (id)structureForAnimationTimes:(id)aTimes
{
    return [self structure];
}

- (void)setSuppressDontErase:(BOOL)aErase
{
    _suppressDontErase = aErase;
}

- (BOOL)suppressDontErase
{
    return _suppressDontErase;
}

- (void)setTransparentColorLightnessTolerance:(double)aTolerance
{
    [_transparentColorAttributes setLightnessTolerance:aTolerance];
}

- (double)transparentColorLightnessTolerance
{
    return [_transparentColorAttributes lightnessTolerance];
}

- (void)setTransparentColorChromaTolerance:(double)aTolerance
{
    [_transparentColorAttributes setChromaTolerance:aTolerance];
}

- (double)transparentColorChromaTolerance
{
    return [_transparentColorAttributes chromaTolerance];
}

- (void)setTransparentColorHueTolerance:(double)aTolerance
{
    [_transparentColorAttributes setHueTolerance:aTolerance];
}

- (double)transparentColorHueTolerance
{
    return [_transparentColorAttributes hueTolerance];
}

- (void)setTransparentColor:(id)aColor
{
    [_transparentColorAttributes setTransparentColor:aColor];
}

- (id)transparentColor
{
    return [_transparentColorAttributes transparentColor];
}

- (void)setUsesTransparentColor:(BOOL)aColor
{
    [_transparentColorAttributes setTransparentColorEnabled:aColor];
}

- (BOOL)usesTransparentColor
{
    return [_transparentColorAttributes isTransparentColorEnabled];
}

- (BOOL)canFlipAtFinish
{
    return [(HSAnimationOptions *)[self options] canFlipAtFinish];
}

- (BOOL)canFlipAtStart
{
    return [(HSAnimationOptions *)[self options] canFlipAtStart];
}

- (void)setVerticalFlipAtFinish:(BOOL)aFinish
{
    [(HSAnimationOptions *)[self options] setVerticalFlipAtFinish:aFinish];
}

- (BOOL)verticalFlipAtFinish
{
    return [(HSAnimationOptions *)[self options] verticalFlipAtFinish];
}

- (void)setHorizontalFlipAtFinish:(BOOL)aFinish
{
    [(HSAnimationOptions *)[self options] setHorizontalFlipAtFinish:aFinish];
}

- (BOOL)horizontalFlipAtFinish
{
    return [(HSAnimationOptions *)[self options] horizontalFlipAtFinish];
}

- (void)setVerticalFlipAtStart:(BOOL)aStart
{
    [(HSAnimationOptions *)[self options] setVerticalFlipAtStart:aStart];
}

- (BOOL)verticalFlipAtStart
{
    return [(HSAnimationOptions *)[self options] verticalFlipAtStart];
}

- (void)setHorizontalFlipAtStart:(BOOL)aStart
{
    [(HSAnimationOptions *)[self options] setHorizontalFlipAtStart:aStart];
}

- (BOOL)horizontalFlipAtStart
{
    return [(HSAnimationOptions *)[self options] horizontalFlipAtStart];
}

- (void)setDontEraseReturning:(BOOL)aReturning
{
    [(HSAnimationOptions *)[self options] setDontEraseReturning:aReturning];
}

- (BOOL)dontEraseReturning
{
    return [(HSAnimationOptions *)[self options] dontEraseReturning];
}

- (void)setDontEraseGoing:(BOOL)aGoing
{
    [(HSAnimationOptions *)[self options] setDontEraseGoing:aGoing];
}

- (BOOL)dontEraseGoing
{
    return [(HSAnimationOptions *)[self options] dontEraseGoing];
}

- (void)setLayer:(NSInteger)aLayer
{
    [(HSAnimationOptions *)[self options] setLayer:aLayer];
}

- (NSInteger)layer
{
    return [(HSAnimationOptions *)[self options] layer];
}

- (void)setReturningAbsoluteLayer:(NSInteger)aLayer
{
    if ([self returningAbsoluteLayer] == aLayer)
        return;
    [(HSAnimationOptions *)[self options] setReturningAbsoluteLayer:aLayer];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSAnimationAbsoluteLayerDidChangeNotification object:self userInfo:nil];
}

- (NSInteger)returningAbsoluteLayer
{
    return [(HSAnimationOptions *)[self options] returningAbsoluteLayer];
}

- (void)setGoingAbsoluteLayer:(NSInteger)aLayer
{
    if ([self goingAbsoluteLayer] == aLayer)
        return;
    [(HSAnimationOptions *)[self options] setGoingAbsoluteLayer:aLayer];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSAnimationAbsoluteLayerDidChangeNotification object:self userInfo:nil];
}

- (NSInteger)goingAbsoluteLayer
{
    return [(HSAnimationOptions *)[self options] goingAbsoluteLayer];
}

- (void)setMatchToMovement:(BOOL)aMovement
{
    [(HSAnimationOptions *)[self options] setMatchToMovement:aMovement];
}

- (BOOL)matchToMovement
{
    return [(HSAnimationOptions *)[self options] matchToMovement];
}

// Key frames per second of the recorded path.
- (NSInteger)normalTimesPerSecond
{
    if ([self path] == nil)
        return 0;
    return (NSInteger)((double)[[self pathKeyFrames] count] / [self duration]);
}

- (BOOL)wasTimesPerSecondSet
{
    return [(HSAnimationOptions *)[self options] wasTimesPerSecondSet];
}

- (void)setTimesPerSecond:(NSInteger)aSecond
{
    [(HSAnimationOptions *)[self options] setTimesPerSecond:aSecond];
}

- (NSInteger)timesPerSecond
{
    if ([self wasTimesPerSecondSet])
        return [(HSAnimationOptions *)[self options] timesPerSecond];
    return [self normalTimesPerSecond];
}

- (void)setMovieSpeed:(double)aSpeed
{
    [(HSAnimationOptions *)[self options] setMovieSpeed:aSpeed];
}

- (double)movieSpeed
{
    return [(HSAnimationOptions *)[self options] movieSpeed];
}

- (BOOL)wasMovieSpeedSet
{
    return [(HSAnimationOptions *)[self options] wasMovieSpeedSet];
}

- (void)setPlayMovie:(BOOL)aMovie
{
    [(HSAnimationOptions *)[self options] setPlayMovie:aMovie];
}

- (BOOL)playMovie
{
    return [(HSAnimationOptions *)[self options] playMovie];
}

- (void)setClampedDuration:(double)aDuration
{
    [(HSAnimationOptions *)[self options] setClampedDuration:aDuration];
}

- (double)clampedDuration
{
    return [(HSAnimationOptions *)[self options] clampedDuration];
}

- (void)setSpeedMultiplier:(CGFloat)aMultiplier
{
    [(HSAnimationOptions *)[self options] setSpeedMultiplier:aMultiplier];
}

- (CGFloat)speedMultiplier
{
    return [(HSAnimationOptions *)[self options] speedMultiplier];
}

- (void)setSpeedMode:(NSInteger)aMode
{
    [(HSAnimationOptions *)[self options] setSpeedMode:aMode];
}

- (NSInteger)speedMode
{
    return [(HSAnimationOptions *)[self options] speedMode];
}

- (void)setPlayBackAndForth:(BOOL)aForth
{
    [(HSAnimationOptions *)[self options] setPlayBackAndForth:aForth];
}

- (BOOL)playBackAndForth
{
    return [(HSAnimationOptions *)[self options] playBackAndForth];
}

- (void)setPlaybackDirection:(NSInteger)aDirection
{
    [(HSAnimationOptions *)[self options] setPlaybackDirection:aDirection];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSAnimationPlaybackDirectionDidChangeNotification object:self userInfo:nil];
}

- (NSInteger)playbackDirection
{
    return [(HSAnimationOptions *)[self options] playbackDirection];
}

- (void)setHideOnLastFrame:(BOOL)aFrame
{
    [(HSAnimationOptions *)[self options] setHideOnLastFrame:aFrame];
}

- (BOOL)hideOnLastFrame
{
    return [(HSAnimationOptions *)[self options] hideOnLastFrame];
}

- (void)setHideOnFirstFrame:(BOOL)aFrame
{
    [(HSAnimationOptions *)[self options] setHideOnFirstFrame:aFrame];
}

- (BOOL)hideOnFirstFrame
{
    return [(HSAnimationOptions *)[self options] hideOnFirstFrame];
}

- (void)setLoopFrameRepeats:(NSInteger)aRepeats
{
    [(HSAnimationOptions *)[self options] setLoopFrameRepeats:aRepeats];
}

- (NSInteger)loopFrameRepeats
{
    return [(HSAnimationOptions *)[self options] loopFrameRepeats];
}

- (void)setLoopSeconds:(double)aSeconds
{
    [(HSAnimationOptions *)[self options] setLoopSeconds:aSeconds];
}

- (double)loopSeconds
{
    return [(HSAnimationOptions *)[self options] loopSeconds];
}

- (void)setLoopPathRepeats:(NSInteger)aRepeats
{
    [(HSAnimationOptions *)[self options] setLoopPathRepeats:aRepeats];
}

- (NSInteger)loopPathRepeats
{
    return [(HSAnimationOptions *)[self options] loopPathRepeats];
}

- (void)setLoopMode:(NSInteger)aMode
{
    [(HSAnimationOptions *)[self options] setLoopMode:aMode];
}

- (NSInteger)loopMode
{
    return [(HSAnimationOptions *)[self options] loopMode];
}

- (void)setUseClones:(BOOL)aClones
{
    [(HSAnimationOptions *)[self options] setUseClones:aClones];
}

- (BOOL)useClones
{
    return [(HSAnimationOptions *)[self options] useClones];
}

- (BOOL)allowRestart
{
    return [(HSAnimationOptions *)[self options] allowRestart];
}

- (void)setRestartMode:(NSInteger)aMode
{
    [(HSAnimationOptions *)[self options] setRestartMode:aMode];
}

- (NSInteger)restartMode
{
    return [(HSAnimationOptions *)[self options] restartMode];
}

- (void)setOptions:(id)aOptions
{
    if (_options == aOptions)
        return;
    [_options release];
    _options = [aOptions copy];
}

- (id)options
{
    return _options;
}

- (void)addAttribute:(id)aAttribute withName:(id)aName
{
    [(HSAnimationStructure *)[self structure] addAttribute:aAttribute withName:aName];
}

- (id)attributes
{
    return [(HSAnimationStructure *)[self structure] attributes];
}

- (NSPoint)pathPointAtTime:(double)aTime
{
    return [(HSAnimationStructure *)[self structure] pathPointAtTime:aTime];
}

- (CGFloat)pathLengthAtTime:(double)aTime
{
    return [(HSAnimationStructure *)[self structure] pathLengthAtTime:aTime];
}

- (void)setPath:(id)aPath keyFrames:(id)aFrames
{
    [(HSAnimationStructure *)[self structure] setPath:aPath keyFrames:aFrames];
    [self setClampedDuration:[[aFrames lastObject] doubleValue]];
}

- (void)setPathAndGenerateKeyFrames:(id)aFrames
{
    [(HSAnimationStructure *)[self structure] setPathAndGenerateKeyFrames:aFrames];
}

- (BOOL)isOnePointPathAnimation
{
    return [(HSAnimationStructure *)[self structure] isOnePointPathAnimation];
}

- (id)pathKeyFrames
{
    return [(HSAnimationStructure *)[self structure] pathKeyFrames];
}

- (id)path
{
    return [(HSAnimationStructure *)[self structure] path];
}

- (void)clear
{
    [(HSAnimationStructure *)[self structure] clear];
}

- (double)duration
{
    return [(HSAnimationStructure *)[self structure] duration];
}

- (BOOL)isEmpty
{
    return [(HSAnimationStructure *)[self structure] isEmpty];
}

- (void)setStructure:(id)aStructure
{
    if (_structure == aStructure)
        return;
    [_structure release];
    _structure = [aStructure copy];
}

- (id)structure
{
    return _structure;
}

- (void)flipAnimatedObjectVertically
{
    id applier = [[[self animatedObject] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier == nil)
        return;
    [[[self animatedObject] undoManager] disableUndoRegistration];
    [applier flipVerticallyWithLayoutGuidingContext:nil];
    [[[self animatedObject] undoManager] enableUndoRegistration];
}

- (void)flipAnimatedObjectHorizntally
{
    id applier = [[[self animatedObject] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    if (applier == nil)
        return;
    [[[self animatedObject] undoManager] disableUndoRegistration];
    [applier flipHorizontallyWithLayoutGuidingContext:nil];
    [[[self animatedObject] undoManager] enableUndoRegistration];
}

- (void)setAnimatedObject:(id)aObject
{
    // The original clears the flag on the incoming object, not the outgoing one.
    [(HSConcreteCardObject *)aObject setAnimatedObject:NO];
    [aObject retain];
    [_animatedObject release];
    _animatedObject = aObject;
    id oldTransparentColorAttributes = _transparentColorAttributes;
    _transparentColorAttributes = [[aObject queryHyperInterface:@protocol(HSTransparentColorAttributes)] retain];
    [[_animatedObject undoManager] disableUndoRegistration];
    // Old animations kept the transparent color in their options.
    NSColor *color = [_options transparentColor];
    if ([_transparentColorAttributes transparentColor] == nil && oldTransparentColorAttributes == nil && color != nil)
    {
        [_transparentColorAttributes setTransparentColorEnabled:[_options usesTransparentColor]];
        [_transparentColorAttributes setTransparentColor:color];
        [_transparentColorAttributes setHueTolerance:[_options tolerance]];
        [_transparentColorAttributes setChromaTolerance:[_options tolerance]];
        [_transparentColorAttributes setLightnessTolerance:[_options tolerance]];
    }
    [oldTransparentColorAttributes release];
    [[_animatedObject undoManager] enableUndoRegistration];
    [_animatedObject setAnimatedObject:YES];
}

- (id)animatedObject
{
    return _animatedObject;
}

- (void)setAnimationUID:(id)aUID
{
    [aUID retain];
    [_animationUID release];
    _animationUID = aUID;
}

- (id)animationUID
{
    return _animationUID;
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSAnimation *copy = [[[HSAnimation class] allocWithZone:aZone] init];
    [copy setAnimationUID:[self animationUID]];
    [copy setStructure:[self structure]];
    [copy setOptions:[self options]];
    [copy setAnimatedObject:[[[self animatedObject] localCopyIncludingNodeUnits:YES] autorelease]];
    return copy;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray array];
    [keys addObject:@"animationUID"];
    [keys addObject:@"animatedObject"];
    [keys addObject:@"structure"];
    [keys addObject:@"options"];
    return keys;
}

- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    HSAnimation *other = aEqual;
    BOOL equal;
    if ([self animationUID] == nil && [other animationUID] == nil)
        equal = YES;
    else
        equal = [[self animationUID] isEqual:[other animationUID]];
    if ([[self animatedObject] respondsToSelector:@selector(isHyperEqual:)] && [[other animatedObject] respondsToSelector:@selector(isHyperEqual:)])
        equal = equal && [[self animatedObject] isHyperEqual:[other animatedObject]];
    if ([self structure] != nil || [other structure] != nil)
        equal = equal && [(HSAnimationStructure *)[self structure] isEqual:[other structure]];
    if (!equal)
        return NO;
    if (([self options] != nil || [other options] != nil) && ![(HSAnimationOptions *)[self options] isEqual:[other options]])
        return NO;
    double otherTime = [other pathTime];
    double time = [self pathTime];
    double tolerance = MAX(time != 0 ? fabs(time) : 1.0, otherTime != 0 ? fabs(otherTime) : 1.0);
    if (fabs(time - otherTime) > tolerance * 1e-05)
        return NO;
    return [self suppressDontErase] == [other suppressDontErase];
}

- (void)dealloc
{
    [_positioning setDataSource:nil];
    [_positioning release];
    [_moviePlayback setOwner:nil];
    [_moviePlayback release];
    [_playbackState setOwner:nil];
    [_playbackState stop];
    [_playbackState release];
    [_times setDataSource:nil];
    [_times release];
    [_options release];
    [_structure release];
    [_animatedObject release];
    [_transparentColorAttributes release];
    [_animationUID release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _animationUID = [[HSUID UID] retain];
        _structure = [HSAnimationStructure new];
        _options = [HSAnimationOptions new];
        _times = [HSAnimationTimes new];
        [_times setDataSource:self];
        _pathTime = 0;
        _playbackState = [HSAnimationPlaybackState new];
        [_playbackState setOwner:self];
        _moviePlayback = [HSAnimationMoviePlayback new];
        [_moviePlayback setOwner:self];
        _wasReturning = NO;
        _positioning = [HSAnimationPositioning new];
        [_positioning setDataSource:self];
    }
    return self;
}

- (BOOL)hasPath
{
    return [[self structure] hasPath];
}

- (int)hideMode
{
    return [[self options] hideMode];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    if ([self isOnePointPathAnimation]) {
        [self setLoopMode:1];
    }
}

- (float)relativeSpeedAtTime:(double)aTime
{
    return [[self structure] relativeSpeedAtTime:aTime];
}

- (void)removeAttributeWithName:(id)aName
{
    [[self structure] removeAttributeWithName:aName];
}

- (void)removePath
{
    [[self structure] clear];
}

- (void)removeUnsupportedFeatures
{
    [[self options] removeUnsupportedFeatures];
}

- (void)setHideMode:(int)aMode
{
    [[self options] setHideMode:aMode];
}

- (void)setTime:(double)aTime ofPathKeyFrameAtIndex:(int)aIndex
{
    [[self structure] setTime:aTime ofPathKeyFrameAtIndex:aIndex];
}

- (double)timeOfPathKeyFrameAtIndex:(int)aIndex
{
    return [[self structure] timeOfPathKeyFrameAtIndex:aIndex];
}

- (void)updatePathKeyFramesTo:(id)aFrames
{
    [[self structure] updatePathKeyFramesTo:aFrames];
}

- (void)updatePathTo:(id)aPath
{
    [[self structure] updatePathTo:aPath];
}

@end
