#import "HSPlaySoundAction.h"
#import "HSSoundItem.h"
#import "HSSoundsInUseProvider.h"
#import "HSActionMediaPlayer.h"
#import "HSActionExecutionContext.h"
#import "HSExecutableResourceProvider.h"
#import "HSNewMediaAccessor.h"
#import "HSUID.h"
#import "HSFunctions.h"
#import "EXCodingContext.h"
#import "NSEMutableProtocolSet.h"
#import "NSMutableArray+EXMutableArray.h"
#import "NSString+NSStringLinkRecognitionHSExtensions.h"

@protocol HSPlaySoundActionHTML5ExportContext
- (NSString *)documentType;
@end

// Stored sounds-to-stop: string UID -> {fadeOutTime}; in memory HSUID -> NSNumber.
static void HSPlaySoundStoreSoundToStop(const void *aKey, const void *aValue, void *aContext)
{
    NSString *uid = [(id)aKey stringValue];
    if (uid == nil)
        return;
    NSDictionary *entry = [NSDictionary dictionaryWithObject:(id)aValue forKey:@"fadeOutTime"];
    if (entry != nil)
        [(NSMutableDictionary *)aContext setObject:entry forKey:uid];
}

static void HSPlaySoundLoadSoundToStop(const void *aKey, const void *aValue, void *aContext)
{
    HSUID *uid = [HSUID UIDWithString:(id)aKey];
    if (uid == nil)
        return;
    id fadeOutTime = [(id)aValue objectForKey:@"fadeOutTime"];
    if (fadeOutTime == nil)
        fadeOutTime = [NSNumber numberWithDouble:0.0];
    if (fadeOutTime != nil)
        [(NSMutableDictionary *)aContext setObject:fadeOutTime forKey:uid];
}

// Plays the action's sound items; can also stop all sounds, or a set of other
// sound items (keyed by item UID, with a fade out time each).
@implementation HSPlaySoundAction

+ (double)defaultSoundFadeOutTime
{
    return 2.0;
}

- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext
{
    [super importFromXMLElementRepresentation:aRepresentation inContext:aContext];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id media = [[aRepresentation elementsForName:@"media"] extraFirstObject];
    HSUID *uid = [HSUID UIDWithString:[[media attributeForName:HSXMLStoringRefIdString] stringValue]];
    id behavior = [[aRepresentation elementsForName:@"behavior"] extraFirstObject];
    HSSoundItem *item = [[[HSSoundItem alloc] initWithMediaUID:uid] autorelease];
    [item setVolume:[[[behavior attributeForName:@"volume"] stringValue] floatValue]];
    [item setSynchronousSound:[[[behavior attributeForName:@"isSynchronousSound"] stringValue] hyperBoolValue]];
    [item setPlayCount:[[[behavior attributeForName:@"playCount"] stringValue] hyperUnsignedValue]];
    [item setSoundFadeOutTime:[[[behavior attributeForName:@"soundFadeOutTime"] stringValue] doubleValue]];
    NSArray *range = [[[behavior attributeForName:@"soundPlayRange"] stringValue] componentsSeparatedByString:@","];
    if ([range count] >= 2)
        [item setSoundPlayRange:HSMakeTimeRange([[range objectAtIndex:0] doubleValue], [[range objectAtIndex:1] doubleValue])];
    [self addSound:item];
    [self setStopsAllSounds:[[[behavior attributeForName:@"stopAllSounds"] stringValue] hyperBoolValue]];
    [pool release];
}

// Only the first sound is stored (media reference + behavior attributes).
- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    if (![aContext shouldTerminateExport]) {
        HSUID *mediaUID = [self mediaUID];
        id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:mediaUID];
        id sound = [[self sounds] extraFirstObject];
        if (![aContext shouldTerminateExport]) {
            if (mediaUID != nil) {
                NSXMLElement *mediaElement = [NSXMLElement elementWithName:@"media"];
                [mediaElement addAttribute:[NSXMLNode attributeWithName:HSXMLStoringRefIdString stringValue:[mediaUID stringValue]]];
                [element addChild:mediaElement];
                [aContext addMedia:media];
            }
            NSXMLElement *behavior = [NSXMLElement elementWithName:@"behavior"];
            HSSoundItem *attributes = [sound queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
            if (attributes != nil) {
                [behavior addAttribute:[NSXMLNode attributeWithName:@"volume" stringValue:[NSString stringWithFormat:@"%.8f", (double)[attributes volume]]]];
                [behavior addAttribute:[NSXMLNode attributeWithName:@"isSynchronousSound" stringValue:[attributes isSynchronousSound] ? HSXMLStoring1String : HSXMLStoring0String]];
                NSString *playCount = [attributes playCount] ? [NSString stringWithFormat:@"%u", (unsigned int)[attributes playCount]] : HSXMLStoring0String;
                [behavior addAttribute:[NSXMLNode attributeWithName:@"playCount" stringValue:playCount]];
                [behavior addAttribute:[NSXMLNode attributeWithName:@"soundFadeOutTime" stringValue:[NSString stringWithFormat:@"%.2f", [attributes soundFadeOutTime]]]];
                struct HSTimeRange range = [attributes soundPlayRange];
                [behavior addAttribute:[NSXMLNode attributeWithName:@"soundPlayRange" stringValue:[NSString stringWithFormat:@"%.2f,%.2f", range.location, range.length]]];
            }
            [behavior addAttribute:[NSXMLNode attributeWithName:@"stopAllSounds" stringValue:[self stopsAllSounds] ? HSXMLStoring1String : HSXMLStoring0String]];
            [element addChild:behavior];
        }
    }
    [pool release];
    return element;
}

- (id)XMLElementName
{
    return @"actPlaySound";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    NSMutableSet *features = [NSMutableSet set];
    HSExecutableResourceProvider *provider = nil;
    for (HSSoundItem *sound in [self sounds]) {
        if (![sound isSynchronousSound]) {
            provider = [HSExecutableResourceProvider sharedInstance];
            [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeaturePlaySoundBackground" value:@"" table:@"Export"]];
        }
        if ([sound volume] != 1.0f && [aType isEqualToString:@"HSiBooksAuthorDocumentType"]) {
            provider = [HSExecutableResourceProvider sharedInstance];
            [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeaturePlaySoundVolume" value:@"" table:@"Export"]];
        }
        if ([sound soundFadeOutTime] != 0.0 && [aType isEqualToString:@"HSiBooksAuthorDocumentType"]) {
            provider = [HSExecutableResourceProvider sharedInstance];
            [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeaturePlaySoundFadeOut" value:@"" table:@"Export"]];
        }
        if ([[self soundsToStopDictionary] count] && [aType isEqualToString:@"HSiBooksAuthorDocumentType"]) {
            provider = [HSExecutableResourceProvider sharedInstance];
            [features addObject:[provider localizedStringForKey:@"HSHTML5UnsupportedFeatureSoundsToStop" value:@"" table:@"Export"]];
        }
    }
    return features;
}

// Quirk kept: exportability is always checked against the HTML5 type.
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    for (HSSoundItem *sound in [self sounds]) {
        if (![sound canBeExportedToHTML5DocumentType:@"HSHTML5DocumentType"] || ![sound isSynchronousSound])
            return YES;
        if ([sound volume] != 1.0f && [aType isEqualToString:@"HSiBooksAuthorDocumentType"])
            return YES;
        if ([sound soundFadeOutTime] != 0.0 && [aType isEqualToString:@"HSiBooksAuthorDocumentType"])
            return YES;
        if ([[self soundsToStopDictionary] count] && [aType isEqualToString:@"HSiBooksAuthorDocumentType"])
            return YES;
    }
    return NO;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    NSMutableDictionary *representation = [super HTML5DictionaryRepresentationInContext:aContext];
    if ([self stopsAllSounds]) {
        [representation setObject:@"1" forKey:@"stopAllSounds"];
        [representation setObject:[NSArray array] forKey:@"sounds"];
    }
    HSSoundItem *sound = [[self sounds] extraFirstObject];
    HSUID *mediaUID;
    if (![sound canBeExportedToHTML5DocumentType:[(id<HSPlaySoundActionHTML5ExportContext>)aContext documentType]] || (mediaUID = [sound mediaUID]) == nil)
        return representation;

    NSMutableDictionary *soundDictionary = [NSMutableDictionary new];
    [soundDictionary setObject:[mediaUID stringValue] forKey:@"object"];
    [soundDictionary setObject:[NSString stringWithFormat:@"%u", (unsigned int)[sound playCount]] forKey:@"playCount"];
    [soundDictionary setObject:[NSString stringWithFormat:@"%.2f", [sound soundPlayRange].location] forKey:@"startTime"];
    [soundDictionary setObject:[NSString stringWithFormat:@"%.2f", [sound soundPlayRange].length] forKey:@"length"];
    [soundDictionary setObject:[NSString stringWithFormat:@"%.2f", (double)[sound volume]] forKey:@"volume"];
    [soundDictionary setObject:[sound isSynchronousSound] ? @"0" : @"1" forKey:@"isBackgroundSound"];
    [soundDictionary setObject:[sound isEnabled] ? @"1" : @"0" forKey:@"isEnabled"];
    [soundDictionary setObject:[NSString stringWithFormat:@"%.2f", [sound soundFadeOutTime]] forKey:@"fadeOutTime"];
    NSArray *sounds = [NSArray arrayWithObject:soundDictionary];
    [soundDictionary release];
    [representation setObject:sounds forKey:@"sounds"];

    // Sounds to stop are exported by the media of the item they name, looked
    // up among the play sound actions of the stack.
    NSMutableArray *soundsToStop = [NSMutableArray new];
    NSDictionary *stops = [self soundsToStopDictionary];
    for (NSString *itemUID in stops) {
        NSString *stopMediaUID = nil;
        for (id action in [HSSoundsInUseProvider playSoundActionsInUseForStack:[self stack]]) {
            if (stopMediaUID != nil)
                continue;
            for (id item in [action sounds]) {
                if ([itemUID isEqualToString:[[item itemUID] stringValue]])
                    stopMediaUID = [[item mediaUID] stringValue];
            }
        }
        if (stopMediaUID != nil) {
            NSString *fadeOutTime = [NSString stringWithFormat:@"%.2f", (double)[[[stops objectForKey:itemUID] objectForKey:@"fadeOutTime"] floatValue]];
            [soundsToStop addObject:[NSDictionary dictionaryWithObjectsAndKeys:stopMediaUID, @"id", fadeOutTime, @"fadeOutTime", nil]];
        }
    }
    [representation setObject:soundsToStop forKey:@"soundsToStop"];
    [soundsToStop release];
    return representation;
}

- (id)mediaUIDsForOptimization
{
    return [self mediaUIDs];
}

// The single-sound accessors below read the first sound; their setters only
// exist so old documents can be loaded through the extra dictionary keys.
- (void)setSoundPlayRangeAsDictionary:(id)aDictionary
{
}

- (id)soundPlayRangeAsDictionary
{
    struct HSTimeRange range = [self soundPlayRange];
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:range.location], @"location", [NSNumber numberWithDouble:range.length], @"length", nil];
}

- (void)setMediaUID:(id)aUID
{
}

- (id)mediaUID
{
    if (![_sounds count])
        return nil;
    return [[[[self sounds] extraFirstObject] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)] mediaUID];
}

- (void)setPlayCount:(NSUInteger)aCount
{
}

- (NSUInteger)playCount
{
    if (![_sounds count])
        return 1;
    return [[[[self sounds] extraFirstObject] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)] playCount];
}

- (void)setSoundPlayRange:(struct HSTimeRange)aRange
{
}

- (struct HSTimeRange)soundPlayRange
{
    struct HSTimeRange range = {0, 0};
    if ([_sounds count])
        range = [[[[self sounds] extraFirstObject] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)] soundPlayRange];
    return range;
}

- (void)setSynchronousSound:(BOOL)aSound
{
}

- (BOOL)isSynchronousSound
{
    if (![_sounds count])
        return YES;
    return [[[[self sounds] extraFirstObject] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)] isSynchronousSound];
}

- (void)setVolume:(CGFloat)aVolume
{
}

- (CGFloat)volume
{
    if (![_sounds count])
        return 0.0;
    return [(HSSoundItem *)[[[self sounds] extraFirstObject] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)] volume];
}

- (void)performOperationForMediaUIDs:(id)aDs withSelector:(SEL)aSelector
{
    if (aDs == nil || ![aDs count] || aSelector == NULL)
        return;
    NSEnumerator *enumerator = [aDs objectEnumerator];
    id uid;
    while ((uid = [enumerator nextObject]) != nil)
        [[HSNewMediaAccessor sharedMediaAccessor] performSelector:aSelector withObject:uid];
}

- (void)HSPlaySoundAction_setSounds:(id)aSounds
{
    id sound;
    if (_sounds != nil) {
        NSEnumerator *enumerator = [_sounds objectEnumerator];
        while ((sound = [enumerator nextObject]) != nil) {
            [sound setOwner:nil];
            [sound setEnabled:NO];
        }
    }
    [_sounds release];
    _sounds = [aSounds mutableCopy];
    if (_sounds != nil) {
        NSEnumerator *enumerator = [_sounds objectEnumerator];
        while ((sound = [enumerator nextObject]) != nil) {
            [sound setOwner:self];
            [sound setEnabled:YES];
        }
    }
}

- (void)setPlaySoundActionVersion:(id)aVersion
{
}

- (id)playSoundActionVersion
{
    return [NSNumber numberWithFloat:639.0f];
}

- (void)setFadeOutTimeForStopAllSounds:(double)aSounds
{
    if (_fadeOutTimeForStopAllSounds == aSounds)
        return;
    id undoManager = [self undoManager];
    [undoManager setActionName:@"Change Fade Out Time"];
    [[undoManager prepareWithInvocationTarget:self] setFadeOutTimeForStopAllSounds:_fadeOutTimeForStopAllSounds];
    _fadeOutTimeForStopAllSounds = aSounds;
}

- (double)fadeOutTimeForStopAllSounds
{
    return _fadeOutTimeForStopAllSounds;
}

- (void)setSoundFadeOutTime:(double)aTime forStopSoundUID:(id)aUID
{
    NSNumber *time = [[NSNumber alloc] initWithDouble:aTime];
    if (time == nil)
        return;
    id undoManager = [self undoManager];
    [undoManager setActionName:@"Change Fade Out Time"];
    [[undoManager prepareWithInvocationTarget:self] setSoundFadeOutTime:[[[self HSPlaySoundAction_soundsToStop] objectForKey:aUID] doubleValue] forStopSoundUID:aUID];
    [[self HSPlaySoundAction_soundsToStop] setObject:time forKey:aUID];
    [time release];
}

- (double)fadeOutTimeForStopSoundUID:(id)aUID
{
    return [[[self HSPlaySoundAction_soundsToStop] objectForKey:aUID] doubleValue];
}

- (void)removeSoundUIDToStop:(id)aStop
{
    id time = [[self HSPlaySoundAction_soundsToStop] objectForKey:aStop];
    if (time == nil)
        return;
    id undoManager = [self undoManager];
    [undoManager setActionName:@"Remove Sound to Stop"];
    [[undoManager prepareWithInvocationTarget:self] addSoundUIDToStop:aStop withFadeOutTime:[time doubleValue]];
    id center = [self attributeNotificationCenter];
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSActionValidationStatusAttribute), @protocol(HSPlaySoundSoundsAttribute), nil];
    [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
    [_soundsToStop removeObjectForKey:aStop];
    [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
}

- (void)addSoundUIDToStop:(id)aStop withFadeOutTime:(double)aTime
{
    if ([[self HSPlaySoundAction_soundsToStop] objectForKey:aStop] != nil)
        return;
    id undoManager = [self undoManager];
    [undoManager setActionName:@"Add Sound to Stop"];
    [[undoManager prepareWithInvocationTarget:self] removeSoundUIDToStop:aStop];
    id center = [self attributeNotificationCenter];
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSActionValidationStatusAttribute), @protocol(HSPlaySoundSoundsAttribute), nil];
    [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
    NSNumber *time = [[NSNumber alloc] initWithDouble:aTime];
    if (time != nil) {
        [_soundsToStop setObject:time forKey:aStop];
        [time release];
    }
    [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
}

- (void)setSoundsToStop:(id)aStop
{
    if ([_soundsToStop isEqualToDictionary:aStop])
        return;
    id undoManager = [self undoManager];
    [undoManager setActionName:@"Set Sounds to Stop"];
    [[undoManager prepareWithInvocationTarget:self] setSoundsToStop:_soundsToStop];
    id center = [self attributeNotificationCenter];
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSActionValidationStatusAttribute), @protocol(HSPlaySoundSoundsAttribute), nil];
    [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
    [_soundsToStop release];
    _soundsToStop = [aStop mutableCopy];
    [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
}

- (id)soundsToStop
{
    return [self HSPlaySoundAction_soundsToStop];
}

- (id)soundsUIDsToStop
{
    return [[self HSPlaySoundAction_soundsToStop] allKeys];
}

- (void)setSoundsToStopDictionary:(id)aDictionary
{
    [_soundsToStop removeAllObjects];
    if (aDictionary != nil)
        CFDictionaryApplyFunction((CFDictionaryRef)aDictionary, HSPlaySoundLoadSoundToStop, [self HSPlaySoundAction_soundsToStop]);
}

- (id)soundsToStopDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (_soundsToStop != nil)
        CFDictionaryApplyFunction((CFDictionaryRef)_soundsToStop, HSPlaySoundStoreSoundToStop, dictionary);
    return dictionary;
}

- (id)HSPlaySoundAction_soundsToStop
{
    if (_soundsToStop == nil)
        _soundsToStop = [NSMutableDictionary new];
    return _soundsToStop;
}

- (void)setStopsAllSounds:(BOOL)aSounds
{
    if (_stopsAllSounds == (aSounds != NO))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Stop All Sounds" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setStopsAllSounds:[self stopsAllSounds]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPlaySoundStopsAllSoundsAttribute) ofObject:self withUserInfo:nil];
    _stopsAllSounds = aSounds != NO;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPlaySoundStopsAllSoundsAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)stopsAllSounds
{
    return _stopsAllSounds;
}

- (BOOL)isContainsItem:(id)aItem
{
    return [aItem owner] == self && [[self sounds] containsObject:aItem];
}

- (void)setSoundFadeOutTime:(double)aTime
{
}

- (double)soundFadeOutTime
{
    if (![_sounds count])
        return 0.0;
    return [[[[self sounds] extraFirstObject] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)] soundFadeOutTime];
}

- (void)disableSoundItem:(id)aItem
{
    if ([aItem owner] != self || ![[self sounds] containsObject:aItem])
        return;
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [aItem setEnabled:NO];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (void)enableSoundItem:(id)aItem
{
    if ([aItem owner] != self || ![[self sounds] containsObject:aItem])
        return;
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [aItem setEnabled:YES];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)soundsForState:(BOOL)aState
{
    NSMutableArray *sounds = [NSMutableArray new];
    NSEnumerator *enumerator = [_sounds objectEnumerator];
    id sound;
    while ((sound = [enumerator nextObject]) != nil) {
        if ([sound isEnabled] == aState)
            [sounds addObject:sound];
    }
    return [sounds autorelease];
}

- (void)removeSound:(id)aSound
{
    if ([aSound owner] != self || ![[self sounds] containsObject:aSound])
        return;
    id undoManager = [self undoManager];
    [undoManager setActionName:@"Remove Sound"];
    [[undoManager prepareWithInvocationTarget:self] addSound:aSound];
    id center = [self attributeNotificationCenter];
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSActionValidationStatusAttribute), @protocol(HSPlaySoundSoundsAttribute), nil];
    [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
    [aSound setOwner:nil];
    [aSound setEnabled:NO];
    [_sounds removeObject:aSound];
    [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
}

- (void)addSound:(id)aSound
{
    if ([aSound owner] == self || [[self sounds] containsObject:aSound])
        return;
    id undoManager = [self undoManager];
    [undoManager setActionName:@"Add Sound"];
    [[undoManager prepareWithInvocationTarget:self] removeSound:aSound];
    id center = [self attributeNotificationCenter];
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSActionValidationStatusAttribute), @protocol(HSPlaySoundSoundsAttribute), nil];
    [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
    [aSound setOwner:self];
    [aSound setEnabled:YES];
    [_sounds addObject:aSound];
    [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
}

// Sounds whose media is missing are dropped.
- (void)setSounds:(id)aSounds
{
    NSArray *sounds = aSounds;
    NSMutableArray *filtered = nil;
    for (id sound in aSounds) {
        if ([sound media] == nil) {
            if (filtered == nil)
                filtered = [aSounds mutableCopy];
            [filtered removeObject:sound];
        }
    }
    if (filtered != nil)
        sounds = [filtered autorelease];
    if ([[self sounds] isEqualToArray:sounds])
        return;
    id undoManager = [self undoManager];
    [undoManager setActionName:@"Set Sounds"];
    [[undoManager prepareWithInvocationTarget:self] setSounds:_sounds];
    id center = [self attributeNotificationCenter];
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSActionValidationStatusAttribute), @protocol(HSPlaySoundSoundsAttribute), nil];
    [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
    [self HSPlaySoundAction_setSounds:sounds];
    [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
}

- (id)sounds
{
    if (_sounds == nil)
        _sounds = [NSMutableArray new];
    return _sounds;
}

- (id)attributeNotificationCenter
{
    return [super attributeNotificationCenter];
}

- (id)undoManager
{
    return [super undoManager];
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (BOOL)isValid
{
    if ([[self soundsForState:YES] count] || [self stopsAllSounds])
        return YES;
    return [[self soundsToStop] count] != 0;
}

- (id)ownedMediaUIDs
{
    NSCountedSet *uids = [NSCountedSet set];
    NSEnumerator *enumerator = [_sounds objectEnumerator];
    id sound;
    while ((sound = [enumerator nextObject]) != nil) {
        id uid = [[sound queryHyperInterface:@protocol(HSSoundPlaybackAttributes)] mediaUID];
        if (uid != nil)
            [uids addObject:uid];
    }
    return uids;
}

- (id)mediaUIDs
{
    return [NSSet setWithSet:[self ownedMediaUIDs]];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    [self convertOldVersionAttributesIfNeeded];
    return [self keysForExtraLoadingWithCodingContext:aContext];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSArray *keys = [super keysForExtraStoringWithCodingContext:aContext];
    return [keys arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:[@"sounds" extraKeyForCollection], @"soundsToStopDictionary", @"stopsAllSounds", @"fadeOutTimeForStopAllSounds", @"playSoundActionVersion", @"soundFadeOutTime", @"soundPlayRangeAsDictionary", @"synchronousSound", @"volume", @"mediaUID", nil]];
}

// Sounds stopped by the merged action leave this one; its other sounds join
// unless this action stops them or already plays their media.
- (void)mergeInPlaySoundAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    NSMutableDictionary *stops = [[NSMutableDictionary alloc] initWithDictionary:[aAction soundsToStop]];
    if (stops == nil)
        return;
    NSDictionary *ownStops = [self soundsToStop];
    NSMutableSet *mediaUIDs = [NSMutableSet new];
    for (id sound in [[[self sounds] copy] autorelease]) {
        if ([stops objectForKey:[sound itemUID]] != nil)
            [self removeSound:sound];
        else
            [mediaUIDs addObject:[sound mediaUID]];
    }
    for (id sound in [aAction sounds]) {
        if ([ownStops objectForKey:[sound itemUID]] != nil || [mediaUIDs containsObject:[sound mediaUID]])
            continue;
        id copy = [sound copy];
        if (copy != nil) {
            [self addSound:copy];
            [copy release];
        }
    }
    [stops addEntriesFromDictionary:ownStops];
    [self setSoundsToStop:stops];
    [stops release];
    [mediaUIDs release];
    if (![self stopsAllSounds])
        [self setStopsAllSounds:[aAction stopsAllSounds]];
}

- (BOOL)wantsSaveAfterRemove
{
    return NO;
}

- (void)hyperPlayableObjectDidStop:(id)aStop
{
    [self notifyDidFinish];
}

// In limited mode a sound set to loop forever plays once, unless an actor owns
// the action. The media player takes the action itself for every sound.
- (void)startInContext:(id)aContext
{
    [self convertOldVersionAttributesIfNeeded];
    HSActionMediaPlayer *player = [HSActionMediaPlayer sharedActionMediaPlayer];
    id stackUID = [[[self stack] queryHyperInterface:@protocol(HSObjectUIDAttribute)] hyperUID];
    if ([self stopsAllSounds]) {
        [player stopAllSoundsForStackUID:stackUID andSoundAttributes:self];
        [self notifyDidFinish];
        return;
    }
    for (HSSoundItem *sound in [self sounds]) {
        HSSoundItem *attributes = [sound queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
        if ([aContext isInLimitedMode] && ![[self owner] implementsHyperInterface:@protocol(HSActor)] && [attributes playCount] == 0) {
            [[self undoManager] disableUndoRegistration];
            [attributes setPlayCount:1];
            [[self undoManager] enableUndoRegistration];
        }
        if ([attributes isSynchronousSound])
            [player startForegroundSoundForSoundAttributes:self forStackUID:stackUID];
        else
            [player startBackgroundSoundForSoundAttributes:self forStackUID:stackUID];
    }
    [player stopSoundsForSoundAttributes:self];
}

- (void)dealloc
{
    [_sounds release];
    [_soundsToStop release];
    [super dealloc];
}

// Old documents flagged sounds as "stop this sound"; they become sounds to stop
// (fade out 0) for every sound in use with the same media.
- (void)convertOldVersionAttributesIfNeeded
{
    if (_isOldVersionAttributesConverted)
        return;
    NSMutableArray *stopped = [NSMutableArray new];
    NSArray *sounds = [self sounds];
    for (id sound in sounds) {
        if (![sound stopThisSound])
            continue;
        [stopped addObject:sound];
        NSArray *inUse = [HSSoundsInUseProvider soundsInUseWithMediaUID:[sound mediaUID] forStack:[self stack]];
        for (id other in inUse)
            [self addSoundUIDToStop:[other itemUID] withFadeOutTime:0.0];
    }
    if ([stopped count]) {
        NSMutableArray *remaining = [[NSMutableArray alloc] initWithArray:sounds];
        [remaining removeObjectsInArray:stopped];
        [self setSounds:remaining];
        [remaining release];
    }
    [stopped release];
    _isOldVersionAttributesConverted = 1;
}

// Before version 639 the action held one sound in flat keys (mediaUID,
// synchronousSound, soundFadeOutTime, volume, soundPlayRangeAsDictionary).
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    NSMutableDictionary *dictionary = [aDictionary mutableCopy];
    id versionNumber = [dictionary objectForKey:@"playSoundActionVersion"];
    float version = versionNumber ? [versionNumber floatValue] : 0.0f;
    HSSoundItem *item = nil;
    if ([dictionary objectForKey:[@"sounds" extraKeyForCollection]] == nil && (version == 0.0f || version < 639.0f) && [dictionary objectForKey:@"mediaUID"] != nil) {
        id mediaUID = [NSObject objectWithExtraDictionary:[dictionary objectForKey:@"mediaUID"] zone:[self zone] codingContext:aContext];
        if (mediaUID != nil) {
            [dictionary removeObjectForKey:@"mediaUID"];
            id synchronous = [dictionary objectForKey:@"synchronousSound"];
            [dictionary removeObjectForKey:@"synchronousSound"];
            id fadeOutTime = [dictionary objectForKey:@"soundFadeOutTime"];
            [dictionary removeObjectForKey:@"soundFadeOutTime"];
            id volume = [dictionary objectForKey:@"volume"];
            [dictionary removeObjectForKey:@"volume"];
            id range = [dictionary objectForKey:@"soundPlayRangeAsDictionary"];
            [dictionary removeObjectForKey:@"soundPlayRangeAsDictionary"];
            item = [[HSSoundItem alloc] initWithMediaUID:mediaUID];
            [item setSynchronousSound:synchronous ? [synchronous boolValue] : YES];
            [item setSoundFadeOutTime:fadeOutTime ? [fadeOutTime doubleValue] : 0.0];
            [item setSoundPlayRange:range ? HSMakeTimeRange([[range objectForKey:@"location"] doubleValue], [[range objectForKey:@"length"] doubleValue]) : HSMakeTimeRange(0, 0)];
            [item setVolume:volume ? [volume floatValue] : 0.5f];
        }
    }
    self = [super initWithExtraDictionary:dictionary codingContext:aContext];
    if (self != nil && item != nil)
        [self HSPlaySoundAction_setSounds:[NSArray arrayWithObject:item]];
    // The original released the item only on success; it leaked when super
    // returned nil.
    [item release];
    [dictionary release];
    return self;
}

- (id)init
{
    self = [super init];
    if (self != nil)
        [self setSynchronous:NO];
    return self;
}

- (BOOL)hasSoundToStopWithValidFadeOut
{
    for (id uid in [self soundsUIDsToStop]) {
        if ([self fadeOutTimeForStopSoundUID:uid] != 0.0)
            return YES;
    }
    return NO;
}

- (void)removeUnsupportedFeatures
{
    [super removeUnsupportedFeatures];
    for (id sound in [self sounds]) {
        [sound setSynchronousSound:YES];
        [sound setSoundFadeOutTime:0.0];
        [sound setVolume:1.0];
    }
    for (id uid in [self soundsUIDsToStop])
        [self setSoundFadeOutTime:0.0 forStopSoundUID:uid];
    [self setFadeOutTimeForStopAllSounds:0.0];
}

@end
