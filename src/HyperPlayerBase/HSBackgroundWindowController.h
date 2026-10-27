#import "HyperPlayerBasePrefix.h"


@interface HSBackgroundWindowController : NSWindowController <NSWindowDelegate, NSObject>
{
    HSBackgroundViewRenderer *_backgroundRenderer;
    unsigned int _isActive:1;
    unsigned int _updateWindowsOrderInProcess:1;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)backgroundWindowController;
- (void)UIModeSettingsDidChangeNotification:(id)aNotification;
- (void)screenParametersDidChange:(id)aChange;
- (void)applicationDidBecomeActive:(id)aActive;
- (void)applicationWillResignActive:(id)aActive;
- (void)verifyBackgroundRendererState;
- (BOOL)isActive;
- (void)validateAndDisplay:(BOOL)aDisplay onScreen:(id)aScreen;
- (void)validateAndDisplay:(BOOL)aDisplay;
- (void)deactivate;
- (void)activate;
- (void)updateWindowsOrder;
- (id)applicationWindowsInOrder;
- (id)applicationWindows;
- (BOOL)shouldBeActive;
- (void)subscribeToNotifications;
- (id)windowNibName;
- (void)dealloc;
- (id)init;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

