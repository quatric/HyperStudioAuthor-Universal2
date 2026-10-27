#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"


@interface HSPlaySoundActionPaneApplier : HSActionAssistantSettingsApplier
{
    NSMutableArray *_initialSoundItems;
    NSMutableArray *_soundItems;
    NSMutableDictionary *_initialSoundItemsToStop;
    NSMutableDictionary *_soundItemsToStop;
    unsigned int _initialStopsAllSounds:1;
    unsigned int _stopsAllSounds:1;
    double _initialFadeOutTimeForStopAllSounds;
    double _fadeOutTimeForStopAllSounds;
    unsigned int _ignoresAssistantActions:1;
}
- (BOOL)areSettingsEqual;
- (BOOL)ignoresAssistantActions;
- (void)setIgnoresAssistantActions:(BOOL)aActions;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)applyChanges;
- (void)setFadeOutStopTimeForStopAllSounds:(double)aSounds;
- (void)setFadeOutStopTime:(double)aTime forSoundUID:(id)aUID;
- (void)removeSoundUIDToStop:(id)aStop;
- (void)addSoundUIDToStop:(id)aStop withFadeOutTime:(double)aTime;
- (void)setStopsAllSounds:(BOOL)aSounds;
- (void)setSoundPlayback:(id)aPlayback stopThisSound:(BOOL)aSound;
- (void)setSoundPlayback:(id)aPlayback playRange:(struct HSTimeRange)aRange;
- (void)setSoundPlayback:(id)aPlayback fadeOutTime:(double)aTime;
- (void)setSoundPlayback:(id)aPlayback playCount:(NSUInteger)aCount;
- (void)setSoundPlayback:(id)aPlayback synchronousSound:(BOOL)aSound;
- (void)setSoundPlayback:(id)aPlayback volume:(CGFloat)aVolume;
- (void)removeSound:(id)aSound;
- (void)addSound:(id)aSound;
- (void)setSounds:(id)aSounds;
- (void)setUpInitialSettings;
- (id)playSoundActionAttributes;
- (void)dealloc;
@end

