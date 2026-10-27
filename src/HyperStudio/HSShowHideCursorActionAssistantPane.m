#import "HSShowHideCursorActionAssistantPane.h"

@implementation HSShowHideCursorActionAssistantPane

- (void)validateUI
{
    id attributes = [self actionAttributes];
    if (attributes)
        [_actionMatrix selectCellWithTag:[attributes changeCursorVisibilityAction]];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)cursorActionChanged:(id)aChanged
{
    [[self showHideActionAssistantPaneApplier] setChangeCursorVisibilityAction:[[aChanged selectedCell] tag]];
}

- (id)initialKeyView
{
    return _actionMatrix;
}

- (id)helpTopicKey
{
    return @"HSHideCursor";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [self validateUI];
}

- (id)actionAttribute
{
    return (id)@protocol(HSShowHideCursorActionAttributes);
}

- (id)actionAttributes
{
    return [[self showHideActionAssistantPaneApplier] showHideCursorActionAttributes];
}

- (id)showHideActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSShowHideCursorActionAssistantPaneApplier class];
}

- (id)actionType
{
    return [HSShowHideCursorAction actionType];
}

- (id)init
{
    return [super initWithNibName:@"ShowHideCursorAssistantPane"];
}

@end

@implementation HSShowHideCursorActionAssistantPaneApplier

- (BOOL)areSettingsEqual
{
    return [super areSettingsEqual] && _initialChangeCursorVisibilityAction == _changeCursorVisibilityAction;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    _changeCursorVisibilityAction = _initialChangeCursorVisibilityAction;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    _initialChangeCursorVisibilityAction = _changeCursorVisibilityAction;
}

- (void)setInitialSettingsToObject
{
    [[self showHideCursorActionAttributes] setChangeCursorVisibilityAction:_initialChangeCursorVisibilityAction];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self showHideCursorActionAttributes] setChangeCursorVisibilityAction:_changeCursorVisibilityAction];
}

- (void)setChangeCursorVisibilityAction:(NSInteger)aAction
{
    if (_changeCursorVisibilityAction != aAction) {
        _changeCursorVisibilityAction = (int)aAction;
        [self disableUndo];
        [[self showHideCursorActionAttributes] setChangeCursorVisibilityAction:_changeCursorVisibilityAction];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    _changeCursorVisibilityAction = (int)[[self showHideCursorActionAttributes] changeCursorVisibilityAction];
    _initialChangeCursorVisibilityAction = _changeCursorVisibilityAction;
}

- (id)showHideCursorActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSShowHideCursorActionAttributes)];
}

@end
