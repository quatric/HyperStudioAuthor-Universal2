#import "HSSoundItem.h"
#import "HSFunctions.h"
#import "HSMovie.h"
#import "HSMediaFileWrapper.h"
#import "HSMediaSaver.h"
#import "HSUID+HSUIDScriptExtensions.h"
#import "HSSystem.h"
#import "HSHTML5ExporterHelper.h"
#import "HSAttributeNotificationCenter.h"

// The HTML5 export context, which belongs to the editor.
@protocol HSSoundItemHTML5ExportContext
- (NSString *)documentType;
- (id)mediaNameForUID:(id)aUID;
- (void)addUID:(id)aUID withMediaName:(id)aName;
- (void)addMedia:(id)aMedia;
@end

@implementation HSSoundItem

/* i386 ivar offsets: _owner=0x4, _sound=0x8, _media=0xc, _itemUID=0x10, _volume=0x14, _soundPlayRange=0x18, _soundFadeOutTime=0x28, _enabled=0x30, _synchronousSound=0x31, _playCount=0x34, _stopThisSound=0x38 */

- (id)soundItemDuration
{
    return [NSNumber numberWithDouble:[(HSMovie *)[self sound] duration]];
}

- (id)soundItemName
{
    return [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[self mediaUID]] mediaName];
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
    [[_owner attributeNotificationCenter] notifyChange:0x80 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttributeSet:(id)aSet
{
    [[_owner attributeNotificationCenter] notifyChange:0x40 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)endContinuousChangeOfAttribute:(id)aAttribute
{
    [[_owner attributeNotificationCenter] notifyChange:0x80 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttribute:(id)aAttribute
{
    [[_owner attributeNotificationCenter] notifyChange:0x40 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)removeAttributeObserver:(id)aObserver
{
    [[_owner attributeNotificationCenter] removeObserver:aObserver selector:NULL ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector
{
    [[_owner attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces
{
    [[_owner attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface
{
    [[_owner attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet
{
    [[_owner attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes
{
    [[_owner attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute
{
    [[_owner attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority
{
    [[_owner attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority
{
    [[_owner attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority
{
    [[_owner attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority
{
    [[_owner attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority
{
    [[_owner attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self withPriority:aPriority];
}

- (id)attributeObservingController
{
    return self;
}

// A zero range plays the whole sound.
- (void)setSoundPlayRangeAsDictionary:(id)aDictionary
{
    id location = [aDictionary objectForKey:@"location"];
    id length = [aDictionary objectForKey:@"length"];
    struct HSTimeRange range = HSMakeTimeRange([location doubleValue], [length doubleValue]);
    if (HSEqualTimeRanges(range, _soundPlayRange))
        return;
    _soundPlayRange = range;
    if (range.length == 0.0 && range.location == 0.0)
        [_sound setPlayRange:[_sound playRange]];
    else
        [_sound setPlayRange:range];
}

- (id)soundPlayRangeAsDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:_soundPlayRange.location], @"location",
                                                      [NSNumber numberWithDouble:_soundPlayRange.length], @"length", nil];
}

- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType
{
    return nil;
}

- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType
{
    return NO;
}

- (BOOL)shouldBeExportedAsImage
{
    return NO;
}

- (id)HTML5UnsupportedFunctionalityDescription
{
    return nil;
}

// Sounds the target cannot play are exported converted, as m4a for iBooks
// Author and aac otherwise.
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    id<HSSoundItemHTML5ExportContext> context = aContext;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    HSNewMedia *media = [self media];
    HSUID *mediaUID = media != nil ? [self mediaUID] : nil;
    if (mediaUID != nil) {
        id source = [context mediaNameForUID:mediaUID];
        if (source == nil) {
            BOOL iBooksAuthor = [[context documentType] isEqualToString:@"HSiBooksAuthorDocumentType"];
            HSMovie *sound = [self sound];
            if (!(iBooksAuthor ? [sound isCompatibleWithIBooksAuthor] : [sound isCompatibleWithIPad]))
                media = [self mediaConvertedForIPadExport];
            if (media != nil) {
                NSString *type = iBooksAuthor ? @"m4a" : @"aac";
                if (![[media mediaType] isEqualToString:type])
                    media = [HSNewMedia mediaWithMedia:media type:type];
                id filename = [HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media andDocumentType:[context documentType]];
                if (filename != nil) {
                    source = [@"Resources" stringByAppendingPathComponent:filename];
                    [context addUID:mediaUID withMediaName:source];
                    [context addMedia:media];
                }
            }
        }
        if (source != nil) {
            [dictionary setObject:[mediaUID stringValue] forKey:@"id"];
            [dictionary setObject:@"sound" forKey:@"type"];
            [dictionary setObject:source forKey:@"src"];
        }
    }
    [pool release];
    return dictionary;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (id)mediaConvertedForIPadExport
{
    id path = [[self sound] convertedForIPadExportSoundPath];
    if (path == nil)
        return nil;
    return [HSNewMedia mediaWithPath:path];
}

- (BOOL)isIPadExportableFileType
{
    return [[self sound] isIPadExportableFileType];
}

- (id)recordName
{
    return [self soundItemName];
}

- (id)defaultRecordName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"MySoundRecord" value:@"" table:@"AssistantPanes"];
}

- (void)copyAttributesFromSoundItem:(id)aItem
{
    [self setEnabled:[aItem isEnabled]];
    id playback = [aItem queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
    [self setPlayCount:[playback playCount]];
    [self setSynchronousSound:[playback isSynchronousSound]];
}

- (void)setEnabled:(BOOL)aEnabled
{
    if (_enabled == (aEnabled != NO))
        return;
    [[_owner attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSoundItemEnableAttribute) ofObject:self withUserInfo:nil];
    _enabled = aEnabled != NO;
    [[_owner attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSoundItemEnableAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)isEnabled
{
    return _enabled;
}

// The old owner hears the change begin and the new owner hears it end.
- (void)setOwner:(id)aOwner
{
    if (_owner == aOwner)
        return;
    [[_owner attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSoundItemOwnerAttribute) ofObject:self withUserInfo:nil];
    _owner = aOwner;
    [[aOwner attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSoundItemOwnerAttribute) ofObject:self withUserInfo:nil];
}

- (id)owner
{
    return _owner;
}

- (void)setStopThisSound:(BOOL)aSound
{
    _stopThisSound = aSound;
}

- (BOOL)stopThisSound
{
    return _stopThisSound;
}

- (void)setItemUID:(id)aUID
{
    if (_itemUID != aUID) {
        [_itemUID release];
        _itemUID = [aUID retain];
    }
}

- (id)itemUID
{
    if (_itemUID == nil)
        _itemUID = [[HSUID UID] retain];
    return _itemUID;
}

- (void)setMediaUID:(id)aUID
{
    [self setMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID]];
}

- (id)mediaUID
{
    return [[self media] mediaUID];
}

- (void)HSSoundItem_mediaDidChangeDataSource:(id)aSource
{
    [self HSSoundItem_setMedia:[aSource object]];
}

- (void)setMedia:(id)aMedia
{
    if (_media == aMedia)
        return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (_media != nil)
        [center removeObserver:self name:@"HSMediaDidChangeDataSourceNotification" object:_media];
    [self HSSoundItem_setMedia:aMedia];
    if (_media != nil)
        [center addObserver:self selector:@selector(HSSoundItem_mediaDidChangeDataSource:) name:@"HSMediaDidChangeDataSourceNotification" object:_media];
}

// Media that cannot be played as a sound is dropped.
- (void)HSSoundItem_setMedia:(id)aMedia
{
    [[_owner attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSoundPlaybackMediaAttribute) ofObject:self withUserInfo:nil];
    [_sound release];
    _sound = nil;
    [_media release];
    _media = [aMedia retain];
    if (_media != nil && [self sound] == nil) {
        [_media release];
        _media = nil;
    }
    [[_owner attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSoundPlaybackMediaAttribute) ofObject:self withUserInfo:nil];
}

- (id)media
{
    return _media;
}

// A looping sound has a play count of zero.
- (void)setLoopSound:(BOOL)aSound
{
    _playCount = aSound == NO;
}

- (BOOL)loopSound
{
    return _playCount != 1;
}

- (void)setPlayCount:(NSUInteger)aCount
{
    if (_playCount == aCount)
        return;
    [[_owner undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Play Count" value:@"" table:@"UndoManager"]];
    [[[_owner undoManager] prepareWithInvocationTarget:self] setPlayCount:[self playCount]];
    [[_owner attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSoundPlaybackPlayCountAttribute) ofObject:self withUserInfo:nil];
    _playCount = (unsigned int)aCount;
    [_sound setPlayCount:aCount];
    [[_owner attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSoundPlaybackPlayCountAttribute) ofObject:self withUserInfo:nil];
}

- (NSUInteger)playCount
{
    return _playCount;
}

- (void)setSoundFadeOutTime:(double)aTime
{
    double magnitude = fmax(_soundFadeOutTime != 0.0 ? fabs(_soundFadeOutTime) : 1.0, aTime != 0.0 ? fabs(aTime) : 1.0);
    if (!(magnitude * 1e-05 < fabs(_soundFadeOutTime - aTime)))
        return;
    [[_owner undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Fade Out" value:@"" table:@"UndoManager"]];
    [[[_owner undoManager] prepareWithInvocationTarget:self] setSoundFadeOutTime:_soundFadeOutTime];
    [[_owner attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSoundPlaybackFadeOutTimeAttribute) ofObject:self withUserInfo:nil];
    _soundFadeOutTime = aTime;
    [_sound setSoundFadeOutTime:aTime];
    [[_owner attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSoundPlaybackFadeOutTimeAttribute) ofObject:self withUserInfo:nil];
}

- (double)soundFadeOutTime
{
    return _soundFadeOutTime;
}

- (double)soundDuration
{
    return [(HSMovie *)[self sound] duration];
}

- (void)setSoundPlayRange:(struct HSTimeRange)aRange
{
    if (HSEqualTimeRanges(_soundPlayRange, aRange))
        return;
    [[_owner undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Play Range" value:@"" table:@"UndoManager"]];
    [[[_owner undoManager] prepareWithInvocationTarget:self] setSoundPlayRange:[self soundPlayRange]];
    [[_owner attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSoundPlaybackPlayRangeAttribute) ofObject:self withUserInfo:nil];
    _soundPlayRange = aRange;
    [_sound setPlayRange:aRange];
    [[_owner attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSoundPlaybackPlayRangeAttribute) ofObject:self withUserInfo:nil];
}

- (struct HSTimeRange)soundPlayRange
{
    return _soundPlayRange;
}

- (void)setSynchronousSound:(BOOL)aSound
{
    if (_synchronousSound == aSound)
        return;
    [[_owner undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Synchronous" value:@"" table:@"UndoManager"]];
    [[[_owner undoManager] prepareWithInvocationTarget:self] setSynchronousSound:[self isSynchronousSound]];
    [[_owner attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSoundPlaybackSynchronousSoundAttribute) ofObject:self withUserInfo:nil];
    _synchronousSound = aSound;
    [[_owner attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSoundPlaybackSynchronousSoundAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)isSynchronousSound
{
    return _synchronousSound;
}

- (void)setVolume:(CGFloat)aVolume
{
    if (_volume == (float)aVolume)
        return;
    [[_owner attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSoundPlaybackVolumeAttribute) ofObject:self withUserInfo:nil];
    _volume = aVolume;
    [_sound setVolume:aVolume];
    [[_owner attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSoundPlaybackVolumeAttribute) ofObject:self withUserInfo:nil];
}

- (CGFloat)volume
{
    return _volume;
}

// Created on demand from the media file, with the item's options applied.
- (id)sound
{
    if (_sound != nil)
        return _sound;
    id error = nil;
    id path = [[self media] fullPathToMediaFileCreateIfNeeded:YES];
    if (path != nil)
        _sound = [self createSoundWithMediaPath:path error:&error];
    if (_sound == nil || error != nil) {
        [_sound release];
        _sound = nil;
        return nil;
    }
    [self applySoundOptions];
    return _sound;
}

// A sandboxed application plays MIDI through its converted file.
- (id)createSoundWithMediaPath:(id)aPath error:(id *)aError
{
    HSMovie *sound = nil;
    if (aPath != nil)
        sound = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:aPath] error:aError];
    if ([[HSSystem sharedSystem] isSandboxed] && [sound isMIDI]) {
        id convertedPath = [sound convertedForIPadExportSoundPath];
        [sound release];
        sound = nil;
        if (convertedPath != nil)
            sound = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:convertedPath] error:aError];
    }
    return sound;
}

- (NSUInteger)hash
{
    double hash = (double)((float)[_media hash] + _volume) + _soundPlayRange.location + _soundPlayRange.length +
                  (double)(unsigned int)((int)(char)(_synchronousSound ^ _enabled) ^ _playCount);
    return (NSUInteger)hash;
}

- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[HSSoundItem class]])
        return NO;
    if (![_media isEqual:[aEqual media]])
        return NO;
    float volume = [(HSSoundItem *)aEqual volume];
    float magnitude = fmaxf(_volume != 0.0f ? fabsf(_volume) : 1.0f, volume != 0.0f ? fabsf(volume) : 1.0f);
    if (fabsf(_volume - volume) > magnitude * 0.0005f)
        return NO;
    if (_enabled != [aEqual isEnabled] || _synchronousSound != [aEqual isSynchronousSound] || _playCount != [aEqual playCount])
        return NO;
    return [_itemUID isEqual:[aEqual itemUID]];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithExtraDictionary:[self extraDictionaryRepresentation]];
}

- (void)setSoundItemVersion:(id)aVersion
{
}

- (id)soundItemVersion
{
    return [NSNumber numberWithFloat:639.0f];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"mediaUID", @"itemUID", @"volume", @"soundPlayRangeAsDictionary", @"soundFadeOutTime", @"synchronousSound",
                                     @"playCount", @"enabled", @"stopThisSound", @"soundItemVersion", @"loopSound", nil];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"mediaUID", @"itemUID", @"volume", @"soundPlayRangeAsDictionary", @"soundFadeOutTime",
                                                           @"synchronousSound", @"playCount", @"enabled", @"soundItemVersion", nil];
    if (_playCount < 2)
        [keys addObject:@"loopSound"];
    return keys;
}

- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    return [super initWithExtraDictionary:aDictionary codingContext:aContext];
}

// A zero range plays the whole sound.
- (void)applySoundOptions
{
    if (_sound == nil)
        return;
    [_sound setVolume:_volume];
    [_sound setSoundFadeOutTime:_soundFadeOutTime];
    [_sound setPlayCount:_playCount];
    if (_soundPlayRange.length == 0.0 && _soundPlayRange.location == 0.0)
        [_sound setPlayRange:[_sound playRange]];
    else
        [_sound setPlayRange:_soundPlayRange];
}

// The media observation is removed with the last reference.
- (oneway void)release
{
    if ([self retainCount] == 1 && _media != nil)
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSMediaDidChangeDataSourceNotification" object:_media];
    [super release];
}

- (void)dealloc
{
    [_sound release];
    [_media release];
    [_itemUID release];
    [super dealloc];
}

// Options from a sound also give the item a new UID.
- (id)initWithMediaUID:(id)aUID andApplyOptionsFromSound:(id)aSound
{
    self = [self init];
    if (self == nil)
        return nil;
    if (aUID == nil) {
        [self release];
        return nil;
    }
    _media = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID] retain];
    if (_media != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSSoundItem_mediaDidChangeDataSource:) name:@"HSMediaDidChangeDataSourceNotification" object:_media];
    if (aSound != nil) {
        _volume = [(HSMovie *)aSound volume];
        _soundFadeOutTime = [aSound soundFadeOutTime];
        _playCount = (unsigned int)[aSound playCount];
        _soundPlayRange = [aSound playRange];
        _itemUID = [[HSUID UID] retain];
    }
    return self;
}

- (id)initWithMediaUID:(id)aUID
{
    return [self initWithMediaUID:aUID andApplyOptionsFromSound:nil];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _volume = 0.5f;
        _synchronousSound = YES;
        _playCount = 1;
    }
    return self;
}

@end
