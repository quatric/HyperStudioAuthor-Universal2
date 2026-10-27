#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSMovieControllerActionAssistantPane : HSNBAAssistantPane
{
    NSMatrix *_movieCommandMatrix;
}
- (void)validateUIWithNotification:(id)aNotification;
- (void)movieCommandChanged:(id)aChanged;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttribute;
- (void)validateUIElements;
- (id)actionAttributes;
- (id)movieControllerActionAssistantPaneApplier;
- (Class)applierClass;
- (id)actionType;
- (id)init;
@end

@interface HSMovieControllerActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    int _initialMovieControllerCommandType;
    int _movieControllerCommandType;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setMovieCommand:(NSInteger)aCommand;
- (void)setUpInitialSettings;
- (id)movieControllerActionAttributes;
@end

