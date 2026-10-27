#import "HSActionsPaneGoBackContinueSwitcher.h"

@implementation HSActionsPaneGoBackContinueSwitcher

- (void)assistantContinue:(id)aContinue
{
    if ([[self delegate] respondsToSelector:@selector(paneContinue:)])
        [[self delegate] paneContinue:self];
}

- (void)setCanContinue:(BOOL)aContinue
{
    [_continueButton setEnabled:aContinue];
}

- (id)init
{
    return [self initWithNibName:@"GoBackContinueSwitcher"];
}

@end
