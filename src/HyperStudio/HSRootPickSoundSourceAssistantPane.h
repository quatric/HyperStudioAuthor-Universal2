#import "HyperStudioPrefix.h"
#import "HSPickSoundSourceAssistantPane.h"


@interface HSRootPickSoundSourceAssistantPane : HSPickSoundSourceAssistantPane
{
    HSPlaySoundActionAssistantPane *_playSoundActionAssistantPane;
}
- (void)dismissPaneIfNeeded;
- (void)stopSound:(id)aSound;
- (void)processSoundItem:(id)aItem;
- (void)openPlaySoundActionAssistantPane;
- (id)playSoundActionAssistantPane;
- (void)dealloc;
@end

