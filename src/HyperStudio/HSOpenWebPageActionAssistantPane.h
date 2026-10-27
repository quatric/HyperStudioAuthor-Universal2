#import "HyperStudioPrefix.h"
#import "HSActionAssistantPane.h"


@interface HSOpenWebPageActionAssistantPane : HSActionAssistantPane
{
    NSTextField *_addressField;
}
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttributes;
- (id)init;
@end

