#import "HyperStudioPrefix.h"
#import "HSDropHelpPane.h"


@interface HSAnimationDropHelpPane : HSDropHelpPane <HSAnimationDropHelpPaneInterface, NSObject>
{
    id _delegate;
    HSConcreteCardObject *_animatedObject;
    id<HyperInterface> _actingObject;
    NSArray *_actionEvents;
    int _mode;
}
- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide;
- (void)paneDidOK:(id)aOK;
- (NSInteger)revertMode;
- (void)setRevertMode:(NSInteger)aMode;
- (void)setActionEvents:(id)aEvents;
- (id)actionEvents;
- (void)setActingObject:(id)aObject;
- (id)actingObject;
- (void)setAnimatedObject:(id)aObject;
- (id)animatedObject;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (id)dropHelpPaneIdentifier;
- (void)dealloc;
@end

