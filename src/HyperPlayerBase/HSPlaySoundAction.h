#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSPlaySoundAction : HSToDoAction <HSPlaySoundActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSPlaySoundStopsAllSoundsAttribute, HSPlaySoundSoundsAttribute, HSPlaySoundOldVersionAttribute, HSActionMediaPlayerMovieOwner, HSMediaCopySupport, HSSoundItemOwnerAttributes, HSCardObjectOptimization>
{
    NSMutableArray *_sounds;
    NSMutableDictionary *_soundsToStop;
    HSActionExecutionContext *_context;
    BOOL _stopsAllSounds;
    double _fadeOutTimeForStopAllSounds;
    unsigned int _isOldVersionAttributesConverted:1;
}
+ (double)defaultSoundFadeOutTime;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)mediaUIDsForOptimization;
- (void)setSoundPlayRangeAsDictionary:(id)aDictionary;
- (id)soundPlayRangeAsDictionary;
- (void)setMediaUID:(id)aUID;
- (id)mediaUID;
- (void)setPlayCount:(NSUInteger)aCount;
- (NSUInteger)playCount;
- (void)setSoundPlayRange:(struct HSTimeRange)aRange;
- (struct HSTimeRange)soundPlayRange;
- (void)setSynchronousSound:(BOOL)aSound;
- (BOOL)isSynchronousSound;
- (void)setVolume:(CGFloat)aVolume;
- (CGFloat)volume;
- (void)performOperationForMediaUIDs:(id)aDs withSelector:(SEL)aSelector;
- (void)HSPlaySoundAction_setSounds:(id)aSounds;
- (void)setPlaySoundActionVersion:(id)aVersion;
- (id)playSoundActionVersion;
- (void)setFadeOutTimeForStopAllSounds:(double)aSounds;
- (double)fadeOutTimeForStopAllSounds;
- (void)setSoundFadeOutTime:(double)aTime forStopSoundUID:(id)aUID;
- (double)fadeOutTimeForStopSoundUID:(id)aUID;
- (void)removeSoundUIDToStop:(id)aStop;
- (void)addSoundUIDToStop:(id)aStop withFadeOutTime:(double)aTime;
- (void)setSoundsToStop:(id)aStop;
- (id)soundsToStop;
- (id)soundsUIDsToStop;
- (void)setSoundsToStopDictionary:(id)aDictionary;
- (id)soundsToStopDictionary;
- (id)HSPlaySoundAction_soundsToStop;
- (void)setStopsAllSounds:(BOOL)aSounds;
- (BOOL)stopsAllSounds;
- (BOOL)isContainsItem:(id)aItem;
- (void)setSoundFadeOutTime:(double)aTime;
- (double)soundFadeOutTime;
- (void)disableSoundItem:(id)aItem;
- (void)enableSoundItem:(id)aItem;
- (id)soundsForState:(BOOL)aState;
- (void)removeSound:(id)aSound;
- (void)addSound:(id)aSound;
- (void)setSounds:(id)aSounds;
- (id)sounds;
- (id)attributeNotificationCenter;
- (id)undoManager;
- (BOOL)supportedInIPad;
- (BOOL)isValid;
- (id)ownedMediaUIDs;
- (id)mediaUIDs;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (void)mergeInPlaySoundAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (BOOL)wantsSaveAfterRemove;
- (void)hyperPlayableObjectDidStop:(id)aStop;
- (void)startInContext:(id)aContext;
- (void)dealloc;
- (void)convertOldVersionAttributesIfNeeded;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (id)init;
@end

