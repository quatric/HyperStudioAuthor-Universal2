#import "HyperStudioPrefix.h"


@interface HSSplashScreenWindowController : NSObject
{
    NSPanel *_window;
    NSImage *_image;
    double _slashWindowShowTimeInterval;
    double _slashWindowTimeout;
}
+ (id)sharedSplashWindow;
- (void)addSplashImage;
- (id)image;
- (id)window;
- (BOOL)isSplashVisible;
- (void)hideSplashWaitUntilTimeout:(BOOL)aTimeout;
- (void)showSplashWithMinimalTimeout:(double)aTimeout;
- (void)dealloc;
@end

