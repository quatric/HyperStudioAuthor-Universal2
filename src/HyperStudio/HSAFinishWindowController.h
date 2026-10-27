#import "HyperStudioPrefix.h"


@interface HSAFinishWindowController : NSWindowController
{
    NSTextField *_storePathTextField;
    NSString *_embeddedCode;
    NSString *_storePath;
}
- (id)initWithStorePath:(id)aPath;
- (id)initWithWindow:(id)aWindow;
- (id)windowNibName;
- (void)windowDidLoad;
- (IBAction)onOK:(id)aSender;
- (IBAction)onPreviewSiteNow:(id)aSender;
- (IBAction)onEmbedCode:(id)aSender;
- (void)dealloc;
@end
