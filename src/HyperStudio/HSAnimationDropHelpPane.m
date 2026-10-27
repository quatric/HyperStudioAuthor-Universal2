#import "HSAnimationDropHelpPane.h"

@interface NSObject (HSAnimationDropHelpPaneDelegateMethods)
- (void)animationDropHelpPaneWillDismiss:(id)aPane;
- (void)animationDropHelpPaneDoContinue:(id)aPane;
@end

@implementation HSAnimationDropHelpPane

- (void)dismiss:(BOOL)aDismiss slide:(BOOL)aSlide
{
    if ([_delegate respondsToSelector:@selector(animationDropHelpPaneWillDismiss:)])
        [_delegate animationDropHelpPaneWillDismiss:self];
    [super dismiss:aDismiss slide:aSlide];
}

- (void)paneDidOK:(id)aOK
{
    if ([_delegate respondsToSelector:@selector(animationDropHelpPaneDoContinue:)])
        [_delegate animationDropHelpPaneDoContinue:self];
}

- (NSInteger)revertMode
{
    return _mode;
}

- (void)setRevertMode:(NSInteger)aMode
{
    _mode = (int)aMode;
}

- (void)setActionEvents:(id)aEvents
{
    [aEvents retain];
    [_actionEvents release];
    _actionEvents = aEvents;
}

- (id)actionEvents
{
    return _actionEvents;
}

- (void)setActingObject:(id)aObject
{
    [aObject retain];
    [_actingObject release];
    _actingObject = aObject;
}

- (id)actingObject
{
    return _actingObject;
}

- (void)setAnimatedObject:(id)aObject
{
    [aObject retain];
    [_animatedObject release];
    _animatedObject = aObject;
}

- (id)animatedObject
{
    return _animatedObject;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return YES;
}

- (id)dropHelpPaneIdentifier
{
    return @"HSAnimationDropHelpPane";
}

- (void)dealloc
{
    [_animatedObject release];
    [_actingObject release];
    [_actionEvents release];
    [super dealloc];
}

@end
