#import "HSObjectsBrowserCoachingPane.h"

@implementation HSObjectsBrowserCoachingPane

+ (id)coachingKey
{
    return @"ObjectsBrowserCoaching";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setWindowTitle:[[NSBundle mainBundle] localizedStringForKey:@"Objects Browser" value:@"" table:@"AssistantPanes"]];
}

- (id)init
{
    return [super initWithCoachingKey:@"ObjectsBrowserCoaching"];
}

@end
