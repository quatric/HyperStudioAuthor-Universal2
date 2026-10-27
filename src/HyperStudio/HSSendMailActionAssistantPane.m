#import "HSSendMailActionAssistantPane.h"

@implementation HSSendMailActionAssistantPane

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[self actionAttributes] setHyperEmailAddresses:[_emailTextFieldController emailAddresses]];
    if ([[self actionAttributes] hyperInvalidEmailAddressError] != nil)
        [[HSErrorManager sharedErrorManager] presentError:[[self actionAttributes] hyperInvalidEmailAddressError]];
    [[self actionAttributes] setHyperEmailSubject:[_emailSubjectField stringValue]];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    id attributes = [self actionAttributes];
    if (attributes != nil) {
        [_emailTextFieldController setEmailAddresses:[attributes hyperEmailAddresses]];
        [_emailSubjectField setStringValue:[attributes hyperEmailSubject]];
    }
}

- (id)actionAttributes
{
    id actor = [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
    id action = [actor hyperActionOfType:[HSSendMailAction actionType] forEvent:[self actionEvent]];
    return [action queryHyperInterface:@protocol(HSSendMailActionAttributes)];
}

- (id)init
{
    return [super initWithNibName:@"SendMailAssistantPaneTiger"];
}

@end
