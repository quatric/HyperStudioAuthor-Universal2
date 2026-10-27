#import "HSQuitAction.h"
@implementation HSQuitAction
- (void)startInContext:(id)aContext
{
    // in the web player, quitting closes the browser tab
    if ([[aContext document] isWebPlayerDocument]) {
        [self performSelector:@selector(performCloseSafariCurrentTab) withObject:nil afterDelay:0];
        return;
    }
    [aContext closePlayer];
    [self notifyDidFinish];
}
- (void)performCloseSafariCurrentTab
{
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:
        @"tell application \"Safari\"\n close current tab of first item of windows\n end tell"] autorelease];
    [script executeAndReturnError:NULL];
}
- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performCloseSafariCurrentTab) object:nil];
    [super dealloc];
}
@end
