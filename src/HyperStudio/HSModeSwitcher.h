#import "HyperStudioPrefix.h"


@interface HSModeSwitcher : NSObject <NSAnimationDelegate, NSObject>
{
    BOOL _switching;
    NSAnimation *_animation;
    NSSet *_temporalStorage;
    NSObject<HSModeController> *_previousModeController;
    NSObject<HSModeController> *_activeModeController;
    NSWindow *_animatedWindow;
    NSRect _destinationViewFrame;
    NSPoint _destinationClipViewBoundsOrigin;
}
- (BOOL)switchesAllWindows;
- (id)previousModeController;
- (BOOL)switching;
- (id)activeModeController;
- (void)switchWithBlockingAnimationAnimationToModeController:(id)aController;
- (void)switchToModeController:(id)aController;
- (void)switchWithoutAnimationToModeController:(id)aController deffered:(BOOL)aDeffered;
- (void)switchToModeController:(id)aController animate:(BOOL)aAnimate deffered:(BOOL)aDeffered blocking:(BOOL)aBlocking;
- (void)awakeFromInit;
- (void)dealloc;
- (id)initWithModeController:(id)aController;
- (id)init;
- (void)animationDidEnd:(id)aEnd;
- (void)animationDidStop:(id)aStop;
- (BOOL)animationShouldStart:(id)aStart;
- (void)startSwitchAnimation:(BOOL)aAnimation deffered:(BOOL)aDeffered blocking:(BOOL)aBlocking;
- (void)notifyWillBecameWorkingInModeSwitcher;
- (void)runSwitchingInSeparateWindows;
- (BOOL)disableSourceAnimation;
- (BOOL)disableDestinationAnimation;
- (id)animationsForWindows:(id)aWindows effect:(id)aEffect;
- (void)runSwitchingInTheSameWindowWithBlockingMode:(NSUInteger)aMode;
- (void)finalizeAnimation;
- (void)notifyDidBecomeWorkingInModeSwitcher;
- (void)finalizeSameWindow;
- (void)finalizeSeparateWindows;
- (id)windowForAnimation;
- (void)setAnimation:(id)aAnimation;
- (void)switchWindow:(id)aWindow controller:(id)aController;
- (void)setPreviousModeController:(id)aController;
- (void)setActiveModeController:(id)aController;
- (void)releaseAfterSwitching;
- (void)retainBeforeSwitching;
- (void)getSwitchingSourceWindowsToRemove:(id *)aRemove destinationWindowsToAdd:(id *)aAdd sameMainWindow:(BOOL *)aWindow;
- (void)removeWinodwsThatAreVisible:(BOOL)aVisible fromArray:(id)aArray;
- (id)switchingDestinationView;
- (id)switchingSourceView;
- (id)mainWindow;
- (id)destinationWindowController;
- (id)sourceWindowController;
- (void)setTemporalStorage:(id)aStorage;
@end

