#import "HyperStudioPrefix.h"


@interface HSAExportPanelController : NSWindowController
{
    HSPublisher *_publisher;
    NSInvocation *_didEndSheetInvocation;
}
- (id)initWithPublisher:(id)aPublisher;
- (void)beginSheetForDirectory:(id)aDirectory file:(id)aFile modalForWindow:(id)aWindow modalDelegate:(id)aDelegate didEndSelector:(SEL)aSelector contextInfo:(void *)aInfo;
- (void)endSheetWithReturnCode:(int)aCode;
- (IBAction)ok:(id)aSender;
- (IBAction)cancel:(id)aSender;
- (id)directory;
- (id)filename;
- (id)requiredFileType;
- (void)setRequiredFileType:(id)aType;
- (id)accessoryView;
- (void)setAccessoryView:(id)aView;
- (id)accessoryViewController;
- (void)setAccessoryViewController:(id)aController;
@end
