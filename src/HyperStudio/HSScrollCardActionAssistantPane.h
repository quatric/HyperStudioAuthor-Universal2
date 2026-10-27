#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSScrollCardActionAssistantPane : HSNBAAssistantPane <HSScrollCardPositionAssistantPaneDelegate>
{
    NSButton *_setScrollPositionButton;
    HSScrollCardPositionAssistantPane *_scrollCardPositionAssistantPane;
}
- (void)setScrollCardPositionAssistantPane:(id)aPane closeWithPosition:(NSPoint)aPosition;
- (void)chooseScrollPosition:(id)aPosition;
- (id)scrollCardPositionAssistantPane;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttributes;
- (id)scrollCardActionAssistantPaneApplier;
- (Class)applierClass;
- (id)actionAttribute;
- (id)actionType;
- (void)dealloc;
- (id)init;
@end

@interface HSScrollCardActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSPoint _initialScrollPoint;
    NSPoint _scrollPoint;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (void)setScrollPoint:(NSPoint)aPoint;
- (id)scrollCardActionAttributes;
@end

