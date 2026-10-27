#import "HyperStudioPrefix.h"


@interface HSInfoTagWindow : NSWindow
{
    float _storedAlphaValue;
    NSTimer *_fadeOutTimer;
    float _fadeOutStep;
    float _fadeOutInterval;
}
- (void)close;
- (void)orderFront:(id)aFront;
- (void)makeKeyAndOrderFront:(id)aFront;
- (void)_adjustFrame;
- (void)fadeOut;
- (void)_fadeOut:(id)aOut;
- (void)_setFadingOut:(BOOL)aOut;
- (BOOL)isFadingOut;
- (BOOL)canBecomeMainWindow;
- (BOOL)canBecomeKeyWindow;
- (id)initWithContentRect:(NSRect)aRect styleMask:(NSUInteger)aMask backing:(NSUInteger)aBacking defer:(BOOL)aDefer;
@end

