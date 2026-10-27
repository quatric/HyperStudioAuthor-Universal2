#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSAnimationSetupPickImageHelpAssistantPane : HSObjectAssistantPane
{
    id<HSAnimationSetupPickImageHelpAssistantPaneDelegate> _delegate;
}
- (void)cancel:(id)aCancel;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)init;
@end

