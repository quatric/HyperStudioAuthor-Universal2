#import "HyperStudioPrefix.h"
#import "HSAFinishWindowController.h"


@interface HSAFTPServerFinishWindowController : HSAFinishWindowController
{
    NSWindow *_finishWindow;
    NSView *_openURLFinishView;
    NSView *_finishView;
}
- (id)windowNibName;
- (void)windowDidLoad;
- (IBAction)onPreviewSiteNow:(id)aSender;
@end
