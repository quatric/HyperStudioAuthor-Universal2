#import "HSPlayAnimationAction.h"

// "Play animation" action: runs a path animation of an object through the
// card's animation controller.
@implementation HSPlayAnimationAction
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    HSAnimation *animation = [HSAnimation new];
    id animationElement = [[aRepresentation elementsForName:[animation XMLElementName]] extraFirstObject];
    [animation importFromXMLElementRepresentation:animationElement inContext:aContext];
    id objectElement = [[[[aRepresentation elementsForName:@"animatedObject"] extraFirstObject] children] extraFirstObject];
    NSString *objectName = [(NSXMLNode *)objectElement name];
    NSString *className = [HSiPadImporterHelper cardObjectClassNameForIPadObjectName:objectName];
    if ([className length]) {
        Class objectClass = NSClassFromString(className);
        if (objectClass) {
            id object = [objectClass defaultObject];
            [object importFromXMLElementRepresentation:objectElement inContext:aContext];
            [animation setAnimatedObject:object];
        }
    }
    [self setAnimation:animation];
    // Original leaks the +new'ed animation.
}
- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    if ([_animation canBeStoredAsXMLElement]) {
        id animationElement = [_animation XMLElementRepresentationInContext:aContext];
        if (animationElement)
            [element addChild:animationElement];
        NSXMLElement *objectElement = [NSXMLElement elementWithName:@"animatedObject"];
        id objectRepresentation = [[_animation animatedObject] XMLElementRepresentationInContext:aContext];
        if (objectRepresentation)
            [objectElement addChild:objectRepresentation];
        [element addChild:objectElement];
    }
    return element;
}
- (id)XMLElementName
{
    return @"actPlayAnimation";
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)supportedInIPad
{
    return YES;
}
- (id)mediaUIDs
{
    return [NSSet setWithSet:[self ownedMediaUIDs]];
}
- (id)ownedMediaUIDs
{
    id copySupport = [[[self animation] animatedObject] queryHyperInterface:@protocol(HSMediaCopySupport)];
    return copySupport ? [copySupport ownedMediaUIDs] : [NSCountedSet set];
}
static NSString *HSPlayAnimationAction_exportString(NSString *aKey)
{
    return [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:aKey value:@"" table:@"Export"];
}
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    NSMutableSet *features = [NSMutableSet set];
    HSAnimation *animation = [self animation];
    HSAnimationOptions *options = [animation options];
    NSInteger loopMode = [options loopMode];
    if (loopMode == 4)
        [features addObject:HSPlayAnimationAction_exportString(@"HSHTML5UnsupportedFeaturePlayAnimationSeveralFrames")];
    else if (loopMode == 3)
        [features addObject:HSPlayAnimationAction_exportString(@"HSHTML5UnsupportedFeaturePlayAnimationSeveralSeconds")];
    if ([options useClones])
        [features addObject:HSPlayAnimationAction_exportString(@"HSHTML5UnsupportedFeaturePlayAnimationAllowClones")];
    id object = [animation animatedObject];
    if ([object isKindOfClass:[HSYouTubeObject class]])
        [features addObject:HSPlayAnimationAction_exportString(@"HSHTML5UnsupportedFeaturePlayAnimationYouTube")];
    if ([object isKindOfClass:[HSLiveObject class]])
        [features addObject:HSPlayAnimationAction_exportString(@"HSHTML5UnsupportedFeaturePlayAnimationLive")];
    if ([object isKindOfClass:[HSMovieObject class]]) {
        if ([object isHyperPanoramaObject])
            [features addObject:HSPlayAnimationAction_exportString(@"HSHTML5UnsupportedFeaturePlayAnimationPanorama")];
        else if ([object isHyperQTVR])
            [features addObject:HSPlayAnimationAction_exportString(@"HSHTML5UnsupportedFeaturePlayAnimationQTVR")];
        if ([[object queryHyperInterface:@protocol(HSTransparentColorAttributes)] isTransparentColorEnabled])
            [features addObject:HSPlayAnimationAction_exportString(@"HSHTML5UnsupportedFeaturePlayAnimationTransparentMovie")];
    }
    return features;
}
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    HSAnimation *animation = [self animation];
    HSAnimationOptions *options = [animation options];
    NSUInteger loopMode = [options loopMode];
    if (loopMode - 3 < 2 || [options useClones])
        return YES;
    id object = [animation animatedObject];
    if ([object isKindOfClass:[HSMovieObject class]]) {
        if ([object isHyperPanoramaObject] || [object isHyperQTVR])
            return YES;
        if ([[object queryHyperInterface:@protocol(HSTransparentColorAttributes)] isTransparentColorEnabled])
            return YES;
    }
    if ([object isKindOfClass:[HSYouTubeObject class]])
        return YES;
    return [object isKindOfClass:[HSLiveObject class]];
}
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}
#define HS_BOOL_STRING(b) ((b) ? @"1" : @"0")
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    HSAnimation *animation = [self animation];
    id object = [animation animatedObject];
    if ([object isKindOfClass:[HSYouTubeObject class]] || [object isKindOfClass:[HSLiveObject class]])
        return nil;
    if ([object isKindOfClass:[HSMovieObject class]] && ([object isHyperPanoramaObject] || [object isHyperQTVR]))
        return nil;
    NSString *objectUID = [[object hyperUID] stringValue];
    if (objectUID == nil)
        return nil;
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [dictionary setObject:@"HSAnimationAction" forKey:@"type"];
    [dictionary setObject:objectUID forKey:@"object"];
    id geometry = [object queryHyperInterface:@protocol(HSGeometryAttributes)];
    id structure = [animation structure];
    NSMutableArray *points = [NSMutableArray new];
    for (NSNumber *keyFrame in [structure pathKeyFrames]) {
        double time = [keyFrame doubleValue];
        NSPoint point = [(HSAnimationStructure *)structure pathPointAtTime:time];
        NSMutableDictionary *pointDictionary = [NSMutableDictionary new];
        [pointDictionary setValue:[NSString stringWithFormat:@"%.3f", time] forKey:@"t"];
        [pointDictionary setValue:[NSString stringWithFormat:@"%.1f", (double)((float)[geometry affineFrameWidth] * -0.5f + (float)point.x)] forKey:@"x"];
        [pointDictionary setValue:[NSString stringWithFormat:@"%.1f", (double)((float)[geometry affineFrameHeight] * -0.5f + (float)point.y)] forKey:@"y"];
        [points addObject:pointDictionary];
        [pointDictionary release];
    }
    [dictionary setObject:points forKey:@"points"];
    [points release];
    if ([object isKindOfClass:[HSMovieObject class]] || [object isKindOfClass:[HSGIFMovieObject class]]) {
        [dictionary setObject:HS_BOOL_STRING([geometry isFlippedHorizontally]) forKey:@"isFlippedHorizontally"];
        [dictionary setObject:HS_BOOL_STRING([geometry isFlippedVertically]) forKey:@"isFlippedVertically"];
    }
    HSAnimationOptions *options = [animation options];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[options loopMode]] forKey:@"loopMode"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[options loopPathRepeats]] forKey:@"loopPathRepeats"];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)[options loopSeconds]] forKey:@"loopSeconds"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[options loopFrameRepeats]] forKey:@"loopFrameRepeats"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[options restartMode]] forKey:@"restartMode"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[options playbackDirection]] forKey:@"playbackDirection"];
    [dictionary setObject:HS_BOOL_STRING([options playBackAndForth]) forKey:@"autoReverse"];
    [dictionary setObject:HS_BOOL_STRING([animation matchToMovement]) forKey:@"matchToMovement"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[options speedMode]] forKey:@"speedMode"];
    [dictionary setObject:[NSString stringWithFormat:@"%.2f", (double)[options speedMultiplier]] forKey:@"speedMultiplier"];
    [dictionary setObject:[NSString stringWithFormat:@"%.1f", (double)[options clampedDuration]] forKey:@"clampedDuration"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[animation timesPerSecond]] forKey:@"timesPerSecond"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[options layer]] forKey:@"layer"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[options goingAbsoluteLayer]] forKey:@"goingAbsoluteLayer"];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[options returningAbsoluteLayer]] forKey:@"returningAbsoluteLayer"];
    [dictionary setObject:HS_BOOL_STRING(![options dontEraseGoing]) forKey:@"eraseGoing"];
    [dictionary setObject:HS_BOOL_STRING(![options dontEraseReturning]) forKey:@"eraseReturning"];
    [dictionary setObject:HS_BOOL_STRING([options horizontalFlipAtStart]) forKey:@"horizontalFlipAtStart"];
    [dictionary setObject:HS_BOOL_STRING([options verticalFlipAtStart]) forKey:@"verticalFlipAtStart"];
    [dictionary setObject:HS_BOOL_STRING([options horizontalFlipAtFinish]) forKey:@"horizontalFlipAtFinish"];
    [dictionary setObject:HS_BOOL_STRING([options verticalFlipAtFinish]) forKey:@"verticalFlipAtFinish"];
    [pool release];
    return dictionary;
}
- (void)animationPlaybackDidEnd:(id)aEnd
{
    [self notifyDidFinish];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSAnimationPlaybackDidEndNotification object:[(NSNotification *)aEnd object]];
}
- (BOOL)canBeStopped
{
    return YES;
}
- (void)stop:(id)aStop
{
    if ([_playingAnimation isPlaying])
        [[[self card] animationController] stopAnimation:_playingAnimation];
    [super stop:aStop];
}
- (void)startInContext:(id)aContext
{
    if (_animation == nil)
        return;
    _context = [aContext retain]; // Original never releases a previous context.
    [_playingAnimation release];
    _playingAnimation = nil;
    if ([aContext isInLimitedMode]
        && [[_animation queryHyperInterface:@protocol(HSAnimationOptions)] loopMode] == 1) {
        // Endless loops are played once in limited mode.
        _playingAnimation = [_animation copyWithZone:[self zone]];
        [[_playingAnimation queryHyperInterface:@protocol(HSAnimationOptions)] setLoopMode:0];
    } else {
        _playingAnimation = [_animation retain];
    }
    id started = [[[self card] animationController] startAnimation:_playingAnimation forActingObject:[self hyperObject]];
    if (_playingAnimation != started) {
        [_playingAnimation release];
        _playingAnimation = [started retain];
    }
    if (_playingAnimation == nil || [_playingAnimation useClones])
        [self notifyDidFinish];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationPlaybackDidEnd:) name:HSAnimationPlaybackDidEndNotification object:started];
}
- (void)setAnimation:(id)aAnimation
{
    [aAnimation retain];
    [_animation release];
    _animation = aAnimation;
}
- (id)animation
{
    return _animation;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"animation"];
    return keys;
}
- (BOOL)isValid
{
    return _animation != nil && [_animation animatedObject] != nil;
}
- (BOOL)wantsSaveAfterRemove
{
    return NO;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSAnimationPlaybackDidEndNotification object:nil];
    [_animation release];
    [_playingAnimation release];
    [_context release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self)
        [self setSynchronous:NO];
    return self;
}
@end
