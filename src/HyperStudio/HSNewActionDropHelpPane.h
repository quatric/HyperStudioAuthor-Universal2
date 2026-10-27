#import "HyperStudioPrefix.h"
#import "HSDropHelpPane.h"


@interface HSNewActionDropHelpPane : HSDropHelpPane <HSNewActionDropHelpPaneInterface, NSObject>
{
    NSMutableArray *_actionsToAdd;
    NSMutableArray *_actionEvents;
    NSMutableArray *_containersForAdd;
    id<HSAddActionHandlerDelegate> _delegate;
}
- (id)containersForAdd;
- (id)actionsToAdd;
- (void)addActionToAdd:(id)aAdd actionEvent:(id)aEvent forContainer:(id)aContainer;
- (void)setDelegate:(id)aDelegate;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (id)dropHelpPaneIdentifier;
- (void)dealloc;
- (id)initWithCoachingKey:(id)aKey actionForAdd:(id)aAdd actionEvent:(id)aEvent andContainerForAdd:(id)aAdd2;
@end

