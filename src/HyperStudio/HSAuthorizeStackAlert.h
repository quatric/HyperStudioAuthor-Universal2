#import "HyperStudioPrefix.h"


@interface HSAuthorizeStackAlert : HSAlert
{
    NSView *_passwordView;
    NSTextField *_passwordField;
    HSStack *_stack;
}
- (id)init;
- (id)initWithStack:(id)aStack;
@end

@interface HSAuthorizeStackAlert (IBActions)
- (void)firstButtonPressed:(id)aPressed;
@end

