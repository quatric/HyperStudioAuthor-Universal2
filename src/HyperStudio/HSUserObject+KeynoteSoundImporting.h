#import "HyperStudioPrefix.h"


@interface HSUserObject (KeynoteSoundImporting)
- (void)addSoundMedia:(id)aMedia fromKeynoteMedia:(id)aMedia2 loopMode:(NSInteger)aMode;
- (id)actionEventTypeForKeynoteMedia:(id)aMedia;
- (void)addSoundMedia:(id)aMedia fromKeynoteMedia:(id)aMedia2 forEvent:(id)aEvent loopMode:(NSInteger)aMode;
- (void)chooseAnotherSoundForKeynoteMedia:(id)aMedia loopMode:(NSInteger)aMode;
- (void)addSoundFromKeynoteMedia:(id)aMedia;
- (void)addSoundFromKeynoteMedia:(id)aMedia loopMode:(NSInteger)aMode;
@end

