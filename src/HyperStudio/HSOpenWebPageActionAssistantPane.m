#import "HSOpenWebPageActionAssistantPane.h"

@implementation HSOpenWebPageActionAssistantPane

// Addresses typed without a scheme get http://.
// Original quirk kept: an empty or invalid address returns without calling super.
- (void)viewWillDisappear:(BOOL)aDisappear
{
    NSString *address = [_addressField stringValue];
    if (address == nil || [address length] == 0)
        return;
    NSURL *url = [NSURL URLWithString:address];
    if (url == nil)
        return;
    if (![url isEqual:[[self actionAttributes] URL]]) {
        if ([url scheme] == nil || [[url scheme] length] == 0)
            address = [NSString stringWithFormat:@"%@%@", @"http://", address];
        [[self actionAttributes] setURL:[NSURL URLWithString:address]];
    }
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    NSString *address = [[[self actionAttributes] URL] absoluteString];
    [_addressField setStringValue:address != nil ? address : @""];
}

- (id)actionAttributes
{
    id actor = [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
    id action = [actor hyperActionOfType:[HSOpenWebPageAction actionType] forEvent:[self actionEvent]];
    return [action queryHyperInterface:@protocol(HSOpenWebPageActionAttributes)];
}

- (id)init
{
    return [super initWithNibName:@"OpenWebPageAssistantPane"];
}

@end
