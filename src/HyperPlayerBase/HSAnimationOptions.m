#import "HSAnimationOptions.h"

// Bits of the absolute layer flags byte.
#define HSAnimationOptionsGoingLayerReadFlag 0x10
#define HSAnimationOptionsReturningLayerReadFlag 0x20

@implementation HSAnimationOptions

/* i386 ivar offsets: _restartMode=0x4, _loopMode=0x8, _loopPathRepeats=0xc, _loopSeconds=0x10, _loopFrameRepeats=0x18, _playbackDirection=0x1c, _speedMode=0x20, _speedMultiplier=0x24, _clampedDuration=0x28, _movieSpeed=0x30, _timesPerSecond=0x38, _layer=0x3c, _transparentColor=0x40, _tolerance=0x44, _playBackAndForth=0x4c, _playMovie=0x4d, _matchToMovement=0x4e, _dontEraseGoing=0x4f, _dontEraseReturning=0x50, _horizontalFlipAtStart=0x51, _verticalFlipAtStart=0x52, _horizontalFlipAtFinish=0x53, _verticalFlipAtFinish=0x54, _usesTransparentColor=0x55, _hideOnFirstFrame=0x56, _hideOnLastFrame=0x57, _goingAbsoluteLayer=0x58, _returningAbsoluteLayer=0x58, _isGoingAbsoluteLayerRead=0x58, _isReturningAbsoluteLayerRead=0x58 */

+ (NSInteger)undefinedTimesPerSecond
{
    return -1;
}

+ (double)undefinedMovieSpeed
{
    return -1.0;
}

- (void)setHideMode:(BOOL)aMode
{
    [self setOldFormatHideMode:aMode];
}

- (NSInteger)hideMode
{
    return [self oldFormatHideMode];
}

// floatOverGoing/floatOverReturning are the old keys of the absolute layers;
// they count only while the absolute layer itself was not read.
- (void)setFloatOverReturning:(BOOL)aReturning
{
    if (!_isReturningAbsoluteLayerRead)
        _returningAbsoluteLayer = aReturning ? 1 : 0;
}

- (BOOL)floatOverReturning
{
    return _returningAbsoluteLayer != 0;
}

- (void)setFloatOverGoing:(BOOL)aGoing
{
    if (!_isGoingAbsoluteLayerRead)
        _goingAbsoluteLayer = aGoing ? 1 : 0;
}

- (BOOL)floatOverGoing
{
    return _goingAbsoluteLayer != 0;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] objectWithExtraDictionary:[self extraDictionaryRepresentation] zone:aZone] retain];
}

- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    _isGoingAbsoluteLayerRead = 0;
    _isReturningAbsoluteLayerRead = 0;
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"restartMode", @"loopMode", @"loopPathRepeats", @"loopSeconds", @"loopFrameRepeats",
        @"playbackDirection", @"playBackAndForth", @"speedMode", @"speedMultiplier", @"clampedDuration", @"playMovie",
        @"movieSpeed", @"timesPerSecond", @"matchToMovement", @"dontEraseGoing", @"dontEraseReturning", @"layer",
        @"horizontalFlipAtStart", @"verticalFlipAtStart", @"horizontalFlipAtFinish", @"verticalFlipAtFinish",
        @"usesTransparentColor", [@"transparentColor" extraKeyForMultiRepresentations], @"tolerance",
        @"goingAbsoluteLayer", @"returningAbsoluteLayer", @"floatOverGoing", @"floatOverReturning", @"hideMode", nil];
}

// The transparent color is not stored (original).
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"restartMode", @"loopMode", @"loopPathRepeats", @"loopSeconds", @"loopFrameRepeats",
        @"playbackDirection", @"playBackAndForth", @"speedMode", @"speedMultiplier", @"clampedDuration", @"playMovie",
        @"movieSpeed", @"timesPerSecond", @"matchToMovement", @"dontEraseGoing", @"dontEraseReturning", @"layer",
        @"horizontalFlipAtStart", @"verticalFlipAtStart", @"horizontalFlipAtFinish", @"verticalFlipAtFinish",
        @"goingAbsoluteLayer", @"returningAbsoluteLayer", @"floatOverGoing", @"floatOverReturning", @"hideMode", nil];
}

// A device transparent color is first moved into the main display's color
// space when that space has the same model.
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    NSString *colorSpaceName = [_transparentColor colorSpaceName];
    CGColorSpaceModel model = kCGColorSpaceModelUnknown;
    if ([colorSpaceName isEqualToString:NSDeviceRGBColorSpace])
        model = kCGColorSpaceModelRGB;
    else if ([colorSpaceName isEqualToString:NSDeviceWhiteColorSpace] || [colorSpaceName isEqualToString:NSDeviceBlackColorSpace])
        model = kCGColorSpaceModelMonochrome;
    else if ([colorSpaceName isEqualToString:NSDeviceCMYKColorSpace])
        model = kCGColorSpaceModelCMYK;
    if (model != kCGColorSpaceModelUnknown) {
        // Original: the default ColorSync display profile (CMGetDefaultProfileByUse).
        CGColorSpaceRef displayColorSpace = CGDisplayCopyColorSpace(CGMainDisplayID());
        if (displayColorSpace != NULL) {
            if (CGColorSpaceGetModel(displayColorSpace) == model) {
                NSColorSpace *colorSpace = [[NSColorSpace alloc] initWithCGColorSpace:displayColorSpace];
                NSColor *color = [[_transparentColor colorUsingColorSpace:colorSpace] retain];
                [_transparentColor release];
                _transparentColor = color;
                [colorSpace release];
            }
            CGColorSpaceRelease(displayColorSpace);
        }
    }
    return [super extraDictionaryRepresentationWithCodingContext:aContext];
}

- (void)setTolerance:(double)aTolerance
{
    _tolerance = aTolerance;
}

- (double)tolerance
{
    return _tolerance;
}

- (void)setTransparentColor:(id)aColor
{
    if (_transparentColor != aColor) {
        [_transparentColor release];
        _transparentColor = [aColor retain];
    }
}

- (id)transparentColor
{
    return _transparentColor;
}

- (void)setUsesTransparentColor:(BOOL)aColor
{
    _usesTransparentColor = aColor != NO;
}

- (BOOL)usesTransparentColor
{
    return _usesTransparentColor != NO;
}

- (BOOL)canFlipAtFinish
{
    return _playBackAndForth && _playbackDirection == 0;
}

- (BOOL)canFlipAtStart
{
    return _playBackAndForth && _playbackDirection == 1;
}

- (void)setVerticalFlipAtFinish:(BOOL)aFinish
{
    _verticalFlipAtFinish = aFinish != NO;
}

- (BOOL)verticalFlipAtFinish
{
    return _verticalFlipAtFinish != NO;
}

- (void)setHorizontalFlipAtFinish:(BOOL)aFinish
{
    _horizontalFlipAtFinish = aFinish != NO;
}

- (BOOL)horizontalFlipAtFinish
{
    return _horizontalFlipAtFinish != NO;
}

- (void)setVerticalFlipAtStart:(BOOL)aStart
{
    _verticalFlipAtStart = aStart != NO;
}

- (BOOL)verticalFlipAtStart
{
    return _verticalFlipAtStart != NO;
}

- (void)setHorizontalFlipAtStart:(BOOL)aStart
{
    _horizontalFlipAtStart = aStart != NO;
}

- (BOOL)horizontalFlipAtStart
{
    return _horizontalFlipAtStart != NO;
}

- (void)setDontEraseReturning:(BOOL)aReturning
{
    _dontEraseReturning = aReturning != NO;
}

- (BOOL)dontEraseReturning
{
    return _dontEraseReturning != NO;
}

- (void)setDontEraseGoing:(BOOL)aGoing
{
    _dontEraseGoing = aGoing != NO;
}

- (BOOL)dontEraseGoing
{
    return _dontEraseGoing != NO;
}

- (void)setLayer:(NSInteger)aLayer
{
    _layer = (int)aLayer;
}

- (NSInteger)layer
{
    return _layer;
}

- (void)setReturningAbsoluteLayer:(NSInteger)aLayer
{
    _returningAbsoluteLayer = aLayer & 3;
    _isReturningAbsoluteLayerRead = 1;
}

- (NSInteger)returningAbsoluteLayer
{
    return _returningAbsoluteLayer;
}

- (void)setGoingAbsoluteLayer:(NSInteger)aLayer
{
    _goingAbsoluteLayer = aLayer & 3;
    _isGoingAbsoluteLayerRead = 1;
}

- (NSInteger)goingAbsoluteLayer
{
    return _goingAbsoluteLayer;
}

- (void)setMatchToMovement:(BOOL)aMovement
{
    _matchToMovement = aMovement;
}

- (BOOL)matchToMovement
{
    return _matchToMovement != NO;
}

- (BOOL)wasTimesPerSecondSet
{
    return _timesPerSecond != [[self class] undefinedTimesPerSecond];
}

- (void)setTimesPerSecond:(NSInteger)aSecond
{
    _timesPerSecond = (int)aSecond;
}

- (NSInteger)timesPerSecond
{
    return _timesPerSecond;
}

// Speeds below 1 become 1, except the undefined speed.
- (void)setMovieSpeed:(double)aSpeed
{
    if (aSpeed < 1.0 && aSpeed != [[self class] undefinedMovieSpeed]) {
        _movieSpeed = 1.0;
        return;
    }
    _movieSpeed = aSpeed;
}

- (double)movieSpeed
{
    return _movieSpeed;
}

- (BOOL)wasMovieSpeedSet
{
    return _movieSpeed != [[self class] undefinedMovieSpeed];
}

- (void)setPlayMovie:(BOOL)aMovie
{
    _playMovie = aMovie;
}

- (BOOL)playMovie
{
    return _playMovie != NO;
}

- (void)setClampedDuration:(double)aDuration
{
    _clampedDuration = aDuration;
}

- (double)clampedDuration
{
    return _clampedDuration;
}

- (void)setSpeedMultiplier:(CGFloat)aMultiplier
{
    _speedMultiplier = aMultiplier;
}

- (CGFloat)speedMultiplier
{
    return _speedMultiplier;
}

- (void)setSpeedMode:(NSInteger)aMode
{
    _speedMode = (int)aMode;
}

- (NSInteger)speedMode
{
    return _speedMode;
}

- (void)setPlayBackAndForth:(BOOL)aForth
{
    _playBackAndForth = aForth;
}

- (BOOL)playBackAndForth
{
    return _playBackAndForth != NO;
}

- (void)setPlaybackDirection:(NSInteger)aDirection
{
    _playbackDirection = (int)aDirection;
}

- (NSInteger)playbackDirection
{
    return _playbackDirection;
}

- (void)setLoopFrameRepeats:(NSInteger)aRepeats
{
    _loopFrameRepeats = (int)aRepeats;
}

- (NSInteger)loopFrameRepeats
{
    return _loopFrameRepeats;
}

- (void)setLoopSeconds:(double)aSeconds
{
    _loopSeconds = aSeconds;
}

- (double)loopSeconds
{
    return _loopSeconds;
}

- (void)setLoopPathRepeats:(NSInteger)aRepeats
{
    _loopPathRepeats = (int)aRepeats;
}

- (NSInteger)loopPathRepeats
{
    return _loopPathRepeats;
}

- (void)setLoopMode:(NSInteger)aMode
{
    _loopMode = (int)aMode;
}

- (NSInteger)loopMode
{
    return _loopMode;
}

- (void)setHideOnLastFrame:(BOOL)aFrame
{
    _hideOnLastFrame = aFrame;
}

- (BOOL)hideOnLastFrame
{
    return _hideOnLastFrame;
}

- (void)setHideOnFirstFrame:(BOOL)aFrame
{
    _hideOnFirstFrame = aFrame;
}

- (BOOL)hideOnFirstFrame
{
    return _hideOnFirstFrame;
}

// 0 never hides, 1 hides on the first frame, 2 on the last, 3 on both;
// other modes change nothing.
- (void)setUseClones:(BOOL)aClones
{
    if (aClones)
        _restartMode = 2;
    else
        _restartMode = [self allowRestart] ? 1 : 0;
}

- (BOOL)useClones
{
    return _restartMode == 2;
}

- (BOOL)allowRestart
{
    return _restartMode != 0;
}

- (void)setRestartMode:(NSInteger)aMode
{
    _restartMode = (int)aMode;
}

- (NSInteger)restartMode
{
    return _restartMode;
}

- (BOOL)isEqual:(id)aEqual
{
    return [[self extraDictionaryRepresentation] isEqualToDictionary:[aEqual extraDictionaryRepresentation]];
}

- (NSInteger)defaultLoopFrameRepeats
{
    return 1;
}

- (double)defaultLoopSeconds
{
    return 1.0;
}

- (NSInteger)defaultLoopPathRepeats
{
    return 1;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _restartMode = 1;
        _loopMode = 0;
        _loopPathRepeats = (int)[self defaultLoopPathRepeats];
        _loopSeconds = [self defaultLoopSeconds];
        _loopFrameRepeats = (int)[self defaultLoopFrameRepeats];
        _playbackDirection = 0;
        _playBackAndForth = NO;
        _speedMode = 0;
        _speedMultiplier = 1.0f;
        _clampedDuration = 1.0;
        _playMovie = NO;
        _movieSpeed = [[self class] undefinedMovieSpeed];
        _timesPerSecond = (int)[[self class] undefinedTimesPerSecond];
        _matchToMovement = NO;
        _goingAbsoluteLayer = 1;
        _returningAbsoluteLayer = 1;
        _dontEraseGoing = NO;
        _dontEraseReturning = NO;
        _layer = 1;
        _horizontalFlipAtStart = NO;
        _verticalFlipAtStart = NO;
        _horizontalFlipAtFinish = NO;
        _verticalFlipAtFinish = NO;
        _usesTransparentColor = NO;
        _hideOnFirstFrame = NO;
        _hideOnLastFrame = NO;
    }
    return self;
}

// Not in the original, which leaked the transparent color.
- (void)dealloc
{
    [_transparentColor release];
    [super dealloc];
}

@end
