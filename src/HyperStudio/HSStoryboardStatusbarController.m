#import "HSStoryboardStatusbarController.h"

@implementation HSStoryboardStatusbarController

- (void)validateUI
{
    [super validateUI];
    [_goToHomeStackButton setToolTip:[[NSBundle mainBundle] localizedStringForKey:@"Go to home stack." value:@"" table:@"Localizable"]];
}

- (void)setZoomControlsEnabled:(BOOL)aEnabled
{
}

- (id)nibName
{
    return @"StoryboardStatusbar";
}

@end
