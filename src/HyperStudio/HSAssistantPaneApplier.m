#import "HSAssistantPaneApplier.h"

@interface NSObject (HSAssistantPaneApplierSubclassMethods)
- (void)makeCurrentEqualToInitial;
- (BOOL)areSettingsEqual;
- (id)undoActionName;
- (void)setCurrentSettingsToObject;
- (void)setInitialSettingsToObject;
- (BOOL)canRegisterUndoInApplier:(id)anApplier;
- (id)undoManagerForApplier:(id)anApplier;
@end

@implementation HSAssistantPaneApplier

- (BOOL)canRegisterUndo
{
    if (![_delegate respondsToSelector:@selector(canRegisterUndoInApplier:)])
        return YES;
    return [_delegate canRegisterUndoInApplier:self];
}

- (void)revertChanges
{
    [self restoreIfNotApplied];
    [self makeCurrentEqualToInitial];
}

- (void)applyChanges
{
    [self disableNotifications];
    [self restoreIfNotApplied];
    BOOL undoOff = ![self canRegisterUndo];
    if (undoOff)
        [self disableUndo];
    if (![self areSettingsEqual]) {
        [[self undoManager] setMultipleActionsName:[self undoActionName]];
        [self setCurrentSettingsToObject];
    }
    if (undoOff)
        [self enableUndo];
    [self enableNotifications];
}

- (void)restoreIfNotApplied
{
    if (![self areSettingsEqual]) {
        [self disableUndo];
        [self setInitialSettingsToObject];
        [self enableUndo];
    }
}

- (void)updateObject
{
    [self disableUndo];
    [self setCurrentSettingsToObject];
    [self enableUndo];
}

- (void)enableNotifications
{
}

- (void)disableNotifications
{
}

- (void)enableUndo
{
    [[self undoManager] enableUndoRegistration];
}

- (void)disableUndo
{
    [[self undoManager] disableUndoRegistration];
}

- (id)undoManager
{
    if ([_delegate respondsToSelector:@selector(undoManagerForApplier:)])
        return [_delegate undoManagerForApplier:self];
    return [[(id)[_object queryHyperInterface:@protocol(HSNodeSupportAttributes)] support] undoManager];
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)object
{
    return _object;
}

- (id)initWithObject:(id)aObject
{
    self = [super init];
    if (self)
        _object = aObject;
    return self;
}

- (id)init
{
    return nil;
}

@end
