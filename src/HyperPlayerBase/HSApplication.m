#import "HSApplication.h"
@implementation HSApplication
- (NSInteger)runModalForWindow:(id)aWindow
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSWillRunModalWindowNotification" object:nil];
    NSInteger result = [super runModalForWindow:aWindow];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSDidEndModalWindowNotification" object:nil];
    return result;
}
@end
