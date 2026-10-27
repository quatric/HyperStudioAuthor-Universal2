#import "HyperStudioPrefix.h"
#import "HSDropHelpPane.h"


@interface HSNewObjectDropHelpPane : HSDropHelpPane <HSNewObjectDropHelpPaneInterface, NSObject>
{
    id<HSNodeChild> _objectToAdd;
    id<HSNodeContainer> _containerForAdd;
}
- (void)setContainerForAdd:(id)aAdd;
- (id)containerForAdd;
- (void)setObjectToAdd:(id)aAdd;
- (id)objectToAdd;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (id)dropHelpPaneIdentifier;
- (void)dealloc;
- (id)initWithCoachingKey:(id)aKey dropDelegate:(id)aDelegate objectForAdd:(id)aAdd containerForAdd:(id)aAdd2;
@end

