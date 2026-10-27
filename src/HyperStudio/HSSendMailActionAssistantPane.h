#import "HyperStudioPrefix.h"
#import "HSActionAssistantPane.h"


@interface HSSendMailActionAssistantPane : HSActionAssistantPane
{
    NSTextField *_emailAddressField;
    NSTextField *_emailSubjectField;
    id<HSEmailTextFieldController> _emailTextFieldController;
    HSAddressBookEmailTokenFieldController *_addressBookEmailTokenFieldController;
}
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)actionAttributes;
- (id)init;
@end

