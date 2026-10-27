#import "HyperPlayerBasePrefix.h"
#import "HSAlert.h"


@interface HSDisplayCheckerAlert : HSAlert
{
}
- (void)stopModal;
- (id)init;
@end

@interface HSDisplayCheckerAlert (IBActions)
- (void)secondButtonPressed:(id)aPressed;
- (void)firstButtonPressed:(id)aPressed;
@end

