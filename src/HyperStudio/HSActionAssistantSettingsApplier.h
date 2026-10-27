#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"


@interface HSActionAssistantSettingsApplier : HSAssistantPaneApplier
{
    BOOL _isInActor;
    BOOL _initialIsInActor;
    NSString *_actionType;
    NSArray *_actionEvents;
    id _action;
    BOOL _isToGoAction;
    id _previousToGoAction;
    BOOL _isNBA;
    id _previousNBA;
    id<HSActor> _actor;
}
- (void)actionsDidChange:(id)aChange;
- (BOOL)initialIsInActor;
- (BOOL)isInActor;
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (id)undoActionName;
- (void)invalidateActionAttributes;
- (void)removeActionFromActor;
- (void)addActionToActor;
- (void)restorePreviousNBAIfNeeded;
- (void)restorePreviousToGoActionIfNeeded;
- (void)setPreviousNBA:(id)aNBA;
- (id)previousNBA;
- (void)setPreviousToGoAction:(id)aAction;
- (id)previousToGoAction;
- (void)setUpInitialSettings;
- (id)actionEvent;
- (id)actionAttributes;
- (id)actor;
- (void)dealloc;
- (id)initWithObject:(id)aObject actionType:(id)aType actionEvents:(id)aEvents;
@end

