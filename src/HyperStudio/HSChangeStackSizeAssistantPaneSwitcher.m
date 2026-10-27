#import "HSChangeStackSizeAssistantPaneSwitcher.h"

@implementation HSChangeStackSizeAssistantPaneSwitcher

- (void)changeSize:(id)aSize
{
    HSStackSizesAssistantPane *pane = [HSStackSizesAssistantPane new];
    [pane setUseDefaultCardSize:YES];
    [[self navigationController] pushViewController:pane withIdentifier:nil animate:YES replacePrevious:YES];
    [pane release];
}

@end
