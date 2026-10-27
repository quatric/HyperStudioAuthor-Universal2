#import "HyperPlayerBasePrefix.h"


@interface HSLinkButton : NSButton
{
}
- (void)resetCursorRects;
@end

@interface HSAboutBoxController : NSWindowController
{
    NSTextField *_aboutApplicationName;
    NSTextField *_aboutBuildVersion;
    NSTextField *_macVersionApplicationName;
    NSTextField *_macVersionBuildVersion;
    NSTextField *_creditsApplicationName;
    NSTextField *_creditsBuildVersion;
    NSTextView *_authors;
    NSTextField *_copyRight;
    NSTextView *_credits;
    NSButton *_linkButton;
}
+ (id)sharedInstance;
- (id)copyright;
- (id)versionString;
- (id)applicationNameRegistered;
- (id)appName;
- (id)windowTitle;
- (id)creditsRTF;
- (id)authorsRTF;
- (void)linkButtonPressed:(id)aPressed;
- (void)windowDidLoad;
- (id)init;
@end

