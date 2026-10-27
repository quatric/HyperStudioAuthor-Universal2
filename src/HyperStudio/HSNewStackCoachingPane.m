#import "HSNewStackCoachingPane.h"

@implementation HSNewStackCoachingPane

- (id)newBackgroundImage
{
    return [[HSChangeStackSizeAssistantPaneSwitcher alloc] initWithNibName:@"StackSizePaneSwitcher"];
}

- (id)init
{
    self = [super initWithCoachingKey:@"StackSizeCoaching"];
    if (self != nil)
        [self setDontShowThisMessageAgainSwitchVisible:YES];
    return self;
}

@end
