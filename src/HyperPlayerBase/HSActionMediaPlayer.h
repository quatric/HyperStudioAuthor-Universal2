#import "HyperPlayerBasePrefix.h"


@interface HSActionMediaPlayer : NSObject <HSMovieDelegate>
{
    NSMapTable *_movieWithAttributesMap;
    NSMutableArray *_backgroundSounds;
    HSMovie *_foregroundSound;
    NSMutableDictionary *_ownersBySound;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedActionMediaPlayer;
- (void)stopSoundForObject:(id)aObject;
- (void)startSound:(id)aSound forObject:(id)aObject;
- (void)stopSound:(id)aSound;
- (id)ownersBySound;
- (void)setForegroundSound:(id)aSound;
- (id)foregroundSound;
- (id)movieWithSoundAttributes:(id)aAttributes;
- (id)ownerForAction:(id)aAction;
- (void)movieDidStop:(id)aStop;
- (void)movieDidPlayOnce:(id)aOnce;
- (void)movieDidEnd:(id)aEnd;
- (void)movieDidChangeImage:(id)aImage;
- (void)stopSoundsForSoundAttributes:(id)aAttributes;
- (void)stopThisSoundForSoundAttributes:(id)aAttributes;
- (void)stopAllForeignSounds:(id)aSounds affectLeavingSounds:(BOOL)aSounds2;
- (void)stopAllSounds;
- (void)stopAllSoundsForSoundAttributes:(id)aAttributes;
- (void)startForegroundSoundForSoundAttributes:(id)aAttributes;
- (void)startBackgroundSoundForSoundAttributes:(id)aAttributes;
- (void)hyperPlayableObjectDidStop:(id)aStop;
- (void)stopAllMovies;
- (void)stopMovie:(id)aMovie;
- (void)playMovie:(id)aMovie movieOwner:(id)aOwner;
- (id)movieWithAttributesMap;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

