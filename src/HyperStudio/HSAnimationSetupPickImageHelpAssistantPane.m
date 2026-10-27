#import "HSAnimationSetupPickImageHelpAssistantPane.h"

@implementation HSAnimationSetupPickImageHelpAssistantPane

- (void)cancel:(id)aCancel
{
    [_delegate cancelFromPickImageHelpPane:self];
    [self dismiss:YES];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (id)init
{
    return [super initWithNibName:@"AnimationPickImageHelpPane"];
}

@end
