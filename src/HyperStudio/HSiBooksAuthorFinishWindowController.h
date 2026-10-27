#import "HyperStudioPrefix.h"


@interface HSiBooksAuthorFinishWindowController : NSWindowController
{
    NSString *_storePath;
    NSTextField *_storePathTextField;
}
- (void)onOK:(id)aOK;
- (void)onOpenFolder:(id)aFolder;
- (void)windowDidLoad;
- (id)windowNibName;
- (void)dealloc;
- (id)initWithStorePath:(id)aPath;
- (id)initWithWindow:(id)aWindow;
@end

