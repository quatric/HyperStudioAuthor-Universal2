#import "HSStoryboardHelpAssistantPane.h"

@implementation HSStoryboardHelpAssistantPane

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setWindowTitle:[[NSBundle mainBundle] localizedStringForKey:@"Storyboard" value:@"" table:@"AssistantPanes"]];
}

- (id)newBackgroundImage
{
    return [[HSObjectAssistantNavigationPaneSwitcher alloc] initWithNibName:@"AssistantNavigationSwitcher"];
}

@end
