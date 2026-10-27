#import "HyperPlayerBasePrefix.h"


@interface HSActionMediaPlayer : NSObject <HSMovieDelegate>
{
    NSMapTable *_movieWithAttributesMap;
    NSMutableDictionary *_ownersBySound;
    NSMutableDictionary *_stackSounds;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedActionMediaPlayer;
- (void)startSound:(id)aSound forObject:(id)aObject;
- (id)ownersBySound;
- (id)stackSounds;
- (void)removeSound:(id)aSound;
- (void)setForegroundSound:(id)aSound forStackUID:(id)aUID;
- (void)stopSoundForObject:(id)aObject forStackUID:(id)aUID;
- (void)stopAllForeignSounds:(id)aSounds affectLeavingSounds:(BOOL)aSounds2 forStackUID:(id)aUID;
- (void)stopAllSoundsForStackUID:(id)aUID andSoundAttributes:(id)aAttributes;
- (void)stopBackgroundSoundsForStackUID:(id)aUID withFadeOutTime:(double)aTime;
- (void)startForegroundSoundForSoundAttributes:(id)aAttributes forStackUID:(id)aUID;
- (void)startBackgroundSoundForSoundAttributes:(id)aAttributes forStackUID:(id)aUID;
- (void)pauseAllSoundsForStackUID:(id)aUID;
- (void)resumeAllSoundsForStackUID:(id)aUID;
- (void)playMovie:(id)aMovie movieOwner:(id)aOwner forStackUID:(id)aUID;
// HyperStudio 5 entry points: the stack is taken from the object or action.
- (void)stopSoundForObject:(id)aObject;
- (void)stopAllSounds;
- (void)stopAllSoundsForSoundAttributes:(id)aAttributes;
- (void)startForegroundSoundForSoundAttributes:(id)aAttributes;
- (void)startBackgroundSoundForSoundAttributes:(id)aAttributes;
- (void)playMovie:(id)aMovie movieOwner:(id)aOwner;
- (id)movieWithSoundAttributes:(id)aAttributes;
- (id)ownerForAction:(id)aAction;
- (void)movieDidStop:(id)aStop;
- (void)movieDidPlayOnce:(id)aOnce;
- (void)movieDidEnd:(id)aEnd;
- (void)movieDidChangeImage:(id)aImage;
- (void)stopSoundsForSoundAttributes:(id)aAttributes;
- (void)stopThisSoundForSoundAttributes:(id)aAttributes;
- (void)hyperPlayableObjectDidStop:(id)aStop;
- (void)stopAllMovies;
- (void)stopMovie:(id)aMovie;
- (id)movieWithAttributesMap;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

