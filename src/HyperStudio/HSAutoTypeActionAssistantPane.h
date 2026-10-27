#import "HyperStudioPrefix.h"
#import "HSActionAssistantSettingsApplier.h"
#import "HSNBAAssistantPane.h"


@interface HSAutoTypeActionAssistantPane : HSNBAAssistantPane <NSTableViewDataSource, NSObject>
{
    NSTableView *_tableView;
    NSTextView *_textToTypeView;
    NSView *_containerView;
    NSView *_mainView;
    NSView *_emptyView;
    NSView *_currentView;
    NSMutableArray *_availableTextViews;
}
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (id)helpTopicKey;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)mountView:(id)aView;
- (id)availableTextViews;
- (id)actionType;
- (id)actionAttributes;
- (id)autoTypeActionAssistantPaneApplier;
- (Class)applierClass;
- (id)init;
@end

@interface HSAutoTypeActionAssistantPaneApplier : HSActionAssistantSettingsApplier
{
    NSArray *_initialUIDs;
    NSAttributedString *_initialTextToType;
    NSArray *_UIDs;
    NSAttributedString *_textToType;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setTextToType:(id)aType;
- (void)setTextViewUIDs:(id)aDs;
- (void)setUpInitialSettings;
- (id)autoTypeActionAttributes;
- (void)dealloc;
@end

