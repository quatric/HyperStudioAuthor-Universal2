#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSSpeechRecognitionActionAssistantPane : HSNBAAssistantPane <NSTableViewDataSource, NSObject>
{
    NSView *_containerView;
    NSView *_emptyView;
    NSView *_mainView;
    NSTableView *_tableView;
    NSView *_scrollOptionsView;
    NSArray *_availableObjects;
    NSView *_currentView;
}
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (id)initialKeyView;
- (id)helpTopicKey;
- (void)dealloc;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)mountView:(id)aView;
- (id)availableObjects;
- (id)actionType;
- (id)actionAttributes;
- (id)speechRecognitionActionAssistantPaneApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSSpeechRecognitionActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSArray *_initialObjectUIDs;
    NSArray *_objectUIDs;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setObjectUIDs:(id)aDs;
- (void)setUpInitialSettings;
- (id)speechRecognitionActionAttributes;
- (void)dealloc;
@end

