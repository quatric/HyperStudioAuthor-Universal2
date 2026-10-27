#import "HSQTTransition.h"
#import "HSAttributeNotificationCenter.h"
#import "HSExecutableResourceProvider.h"
#import "HSFunctions.h"
#import "HSPlayerBaseID.h"
#import "HSTransitionEffect.h"
#import "HSTransitionEffectProvider.h"
#import "NSEMutableProtocolSet.h"

static NSSet *HSTransitionQTTransitionNames = nil;
static NSSet *HSTransitionQCTransitionNames = nil;

// A card transition: an effect by name, with its duration and an optional
// sound. Older documents stored the QuickTime, Quartz Composer and fastest
// transitions as subclasses, which now all make plain transitions.
@implementation HSTransition

// The transition going the other way (from OppositeTransitions.plist), with
// the same duration; the transition itself when it has none.
+ (id)oppositeTransitionForTransition:(id)aTransition
{
    NSString *path = [[HSPlayerBaseID bundle] pathForResource:@"OppositeTransitions" ofType:@"plist"];
    NSString *name = [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:[aTransition transitionName]];
    if ([name length] == 0)
        return aTransition;
    HSTransition *transition = [HSTransition transitionWithName:name];
    [transition setDuration:[(HSTransition *)aTransition duration]];
    return transition;
}

+ (id)transitionWithName:(id)aName
{
    return [[[self alloc] initWithName:aName] autorelease];
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    NSMutableSet *features = [NSMutableSet set];
    if ([self effect] == nil)
        [features addObject:[self HTML5UnsupportedFunctionalityDescription]];
    return features;
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    return [self effect] == nil;
}

- (BOOL)shouldBeExportedAsImage
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (id)HTML5UnsupportedFunctionalityDescription
{
    NSString *displayName = [[HSTransitionEffectProvider sharedTransitionEffectProvider] displayNameForTransitionEffectWithName:_name];
    NSString *format = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSHTML5UnsupportedFeatureTransition" value:@"" table:@"Export"];
    return [NSString stringWithFormat:format, displayName];
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)attributesChangedTemporary
{
    return [NSEProtocolSet protocolSet];
}

- (id)attributesBeingChangedContinuously
{
    return [NSEProtocolSet protocolSet];
}

- (void)endContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)endContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)removeAttributeObserver:(id)aObserver
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:NULL ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self withPriority:aPriority];
}

- (id)attributeObservingController
{
    return self;
}

- (id)attributeNotificationCenter
{
    return [HSAttributeNotificationCenter defaultCenter];
}

// The delegate's undo manager for the transition, if it gives one.
- (id)undoManager
{
    if (![_delegate respondsToSelector:@selector(undoManagerForTransition:)])
        return nil;
    return [_delegate undoManagerForTransition:self];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (BOOL)isFastestTransition
{
    if (![[self transitionName] isEqualToString:@"No Transition"])
        return NO;
    return ![[self effect] isExternal];
}

- (void)setShouldStopOnMouseClick:(BOOL)aClick
{
    _shouldStopOnMouseClick = aClick;
}

- (BOOL)shouldStopOnMouseClick
{
    return _shouldStopOnMouseClick;
}

- (void)setSoundPlaybackMode:(NSInteger)aMode
{
    if (_soundMode == aMode)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Transition Sound Playback Mode" value:@"" table:@"UndoManager"]];
    [(HSTransition *)[[self undoManager] prepareWithInvocationTarget:self] setSoundPlaybackMode:[self soundPlaybackMode]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSTransitionSoundPlaybackModeAttribute) ofObject:self withUserInfo:nil];
    _soundMode = (int)aMode;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSTransitionSoundPlaybackModeAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)soundPlaybackMode
{
    return _soundMode;
}

- (void)setDuration:(double)aDuration
{
    double duration = [self duration];
    double scale = MAX(duration != 0.0 ? fabs(duration) : 1.0, aDuration != 0.0 ? fabs(aDuration) : 1.0);
    if (fabs(duration - aDuration) <= scale * 1e-05)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Transition Duration" value:@"" table:@"UndoManager"]];
    [(HSTransition *)[[self undoManager] prepareWithInvocationTarget:self] setDuration:[self duration]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSTransitionDurationAttribute) ofObject:self withUserInfo:nil];
    _duration = aDuration;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSTransitionDurationAttribute) ofObject:self withUserInfo:nil];
}

- (double)duration
{
    return _duration;
}

- (void)setSound:(id)aSound
{
    if (_sound == aSound)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Transition Sound" value:@"" table:@"UndoManager"]];
    [(HSTransition *)[[self undoManager] prepareWithInvocationTarget:self] setSound:[self sound]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSTransitionSoundAttribute) ofObject:self withUserInfo:nil];
    [_sound release];
    _sound = [aSound retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSTransitionSoundAttribute) ofObject:self withUserInfo:nil];
}

- (id)sound
{
    return _sound;
}

- (id)displayName
{
    return [[HSTransitionEffectProvider sharedTransitionEffectProvider] displayNameForTransitionEffectWithName:_name];
}

- (id)effect
{
    return _effect;
}

- (void)setEffect:(id)aEffect
{
    if ([_effect isEqual:aEffect])
        return;
    [_effect release];
    _effect = [aEffect retain];
}

- (void)setTransitionName:(id)aName
{
    if ([_name isEqualToString:aName])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Transition Effect" value:@"" table:@"UndoManager"]];
    // Original quirk kept: the undo restores the duration, not the name.
    [(HSTransition *)[[self undoManager] prepareWithInvocationTarget:self] setDuration:[self duration]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSTransitionNameAttribute) ofObject:self withUserInfo:nil];
    [self setName:aName];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSTransitionNameAttribute) ofObject:self withUserInfo:nil];
}

- (id)transitionName
{
    return _name;
}

- (NSUInteger)hash
{
    return [_name hash];
}

// A subclass instance compares itself.
- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSTransition class]])
        return NO;
    if (![aEqual isMemberOfClass:[self class]] && [aEqual isKindOfClass:[self class]])
        return [aEqual isEqual:self];
    if (![_name isEqualToString:[aEqual transitionName]] || _duration != [(HSTransition *)aEqual duration])
        return NO;
    if (![_sound isEqual:[aEqual sound]] || _soundMode != [aEqual soundPlaybackMode])
        return NO;
    return (_shouldStopOnMouseClick != NO) == ([aEqual shouldStopOnMouseClick] != NO);
}

// Fastest transitions were stored with their old duration; they take none.
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    if ([[aRepresentation objectForKey:EXClassNameKey] isEqualToString:@"HSFastestTransition"])
        _duration = 0.0;
}

// The stored duration: "No Transition" gets a token one, "Stars" none.
- (double)_duration
{
    if ([_name isEqualToString:@"No Transition"])
        return 0.001;
    if ([_name isEqualToString:@"Stars"])
        return 0.0;
    return _duration;
}

- (void)set_transitionName:(id)aName
{
    [self setName:aName];
}

- (id)_transitionName
{
    return [self name];
}

- (void)set_compositionName:(id)aName
{
    [self setName:aName];
}

- (id)_compositionName
{
    return [self name];
}

// A new name brings its effect along.
- (void)setName:(id)aName
{
    if ([_name isEqualToString:aName])
        return;
    [_effect release];
    _effect = nil;
    [_name release];
    _name = [aName copy];
    if (_name != nil)
        _effect = [[[HSTransitionEffectProvider sharedTransitionEffectProvider] transitionEffectWithName:_name] retain];
}

- (id)name
{
    return _name;
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"name", @"_duration", @"_soundMode", @"effect", @"_compositionName", @"_transitionName", nil];
}

// External effects are stored along.
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [NSArray arrayWithObjects:@"name", @"_duration", [self HSTransition_nameKeyToMaintainForwardCompatibility], nil];
    if ([_effect isExternal])
        keys = [keys arrayByAddingObject:@"effect"];
    return keys;
}

// The name key older versions read for the transition's kind.
- (id)HSTransition_nameKeyToMaintainForwardCompatibility
{
    if ([[self HSTransition_QCTransitionNames] containsObject:_name])
        return @"_compositionName";
    if ([[self HSTransition_QTTransitionNames] containsObject:_name])
        return @"_transitionName";
    return nil;
}

// The class older versions expect for the transition's kind.
- (id)extraClassNameForStoring
{
    if ([_name isEqualToString:@"No Transition"])
        return @"HSFastestTransition";
    if ([[self HSTransition_QCTransitionNames] containsObject:_name])
        return @"HSQCViewTransition";
    if ([[self HSTransition_QTTransitionNames] containsObject:_name])
        return @"HSQTTransition";
    return [super extraClassNameForStoring];
}

- (id)HSTransition_QTTransitionNames
{
    if (HSTransitionQTTransitionNames == nil)
        HSTransitionQTTransitionNames = [[NSSet alloc] initWithObjects:@"Fade", @"Kaleidoscope", @"Iris Star", @"Wipe Up", @"Barn", @"Jaws",
            @"Slide Down", @"Push", @"PushBottom", @"PushLeft", @"PushRight", @"Wipe Left", @"Wipe Right", @"Page Tear", @"Slide Left",
            @"Lawnmower", @"Windmill", @"Spotlight", @"Open Sesame", @"Iris Heart", @"Iris Rectangle", @"Engulf", @"Barn Door", @"Spiral",
            @"Iris Circle", @"Slide Up", @"Waterfall", @"Wipe Diagonal", @"Clock Face", @"Wiper", @"Implode", @"Slide Right", @"Wipe Down",
            @"Zoom", @"Explode", @"Implode Circle", nil];
    return HSTransitionQTTransitionNames;
}

- (id)HSTransition_QCTransitionNames
{
    if (HSTransitionQCTransitionNames == nil)
        HSTransitionQCTransitionNames = [[NSSet alloc] initWithObjects:@"Reverse CubeMixer", @"LiquidImage", @"Twirl", @"SkyClouds",
            @"CubeMixer", @"Ripple", @"CopyMachine", @"Mod", @"Swipe", @"Flash", @"GaussianBlur", @"Slide Remove Down",
            @"Slide Remove Left", @"Slide Remove Right", @"Slide Remove Up", nil];
    return HSTransitionQCTransitionNames;
}

- (void)dealloc
{
    [_name release];
    [_effect release];
    [_sound release];
    [super dealloc];
}

// nil without a name or an effect of that name.
- (id)initWithName:(id)aName
{
    self = [super init];
    if (self == nil)
        return nil;
    _name = [aName copy];
    if (_name != nil) {
        _effect = [[[HSTransitionEffectProvider sharedTransitionEffectProvider] transitionEffectWithName:_name] retain];
        if (_effect != nil)
            return self;
    }
    [super release];
    return nil;
}

- (id)init
{
    return [self initWithName:@"No Transition"];
}

- (void)removeUnsupportedFeatures
{
    if (_effect == nil) {
        [_name release];
        _name = [[NSString alloc] initWithString:@"Fade"];
        _effect = [[[HSTransitionEffectProvider sharedTransitionEffectProvider] transitionEffectWithName:_name] retain];
    }
}

@end

// Old archived classes; they unarchive as plain transitions.
@implementation HSQTTransition

+ (id)allocWithZone:(NSZone *)aZone
{
    return (id)[HSTransition allocWithZone:aZone];
}

@end

@implementation HSQCViewTransition

+ (id)allocWithZone:(NSZone *)aZone
{
    return (id)[HSTransition allocWithZone:aZone];
}

@end

@implementation HSFastestTransition

+ (id)allocWithZone:(NSZone *)aZone
{
    return (id)[HSTransition allocWithZone:aZone];
}

@end
