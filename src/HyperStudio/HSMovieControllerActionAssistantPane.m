#import "HSMovieControllerActionAssistantPane.h"

@implementation HSMovieControllerActionAssistantPane

/* i386 ivar offsets: _movieCommandMatrix=0x88 */

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUIElements];
}

- (void)movieCommandChanged:(id)aChanged
{
    [[self movieControllerActionAssistantPaneApplier] setMovieCommand:[[_movieCommandMatrix selectedCell] tag]];
}

- (id)initialKeyView
{
    return _movieCommandMatrix;
}

- (id)helpTopicKey
{
    return @"HSMovieController";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUIElements];
    [self addActionAssistantPaneObserver];
}

- (id)actionAttribute
{
    return (id)@protocol(HSMovieControllerActionAttributes);
}

- (void)validateUIElements
{
    [_movieCommandMatrix selectCellWithTag:[[self actionAttributes] movieCommand]];
}

- (id)actionAttributes
{
    return [[self movieControllerActionAssistantPaneApplier] movieControllerActionAttributes];
}

- (id)movieControllerActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSMovieControllerActionAssistantPaneApplier class];
}

- (id)actionType
{
    return [HSMovieControllerAction actionType];
}

- (id)init
{
    self = [super initWithNibName:@"MovieControllerAssistantPane"];
    return self;
}

@end

@implementation HSMovieControllerActionAssistantPaneApplier

/* i386 ivar offsets: _initialMovieControllerCommandType=0x30, _movieControllerCommandType=0x34 */

- (BOOL)areSettingsEqual
{
    BOOL bVar2;

    if (![super areSettingsEqual]) {
        bVar2 = NO;
    }
    else {
        bVar2 = _initialMovieControllerCommandType == _movieControllerCommandType;
    }
    return bVar2;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    _movieControllerCommandType = _initialMovieControllerCommandType;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    _initialMovieControllerCommandType = _movieControllerCommandType;
}

- (void)setInitialSettingsToObject
{
    [[self movieControllerActionAttributes] setMovieCommand:_initialMovieControllerCommandType];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self movieControllerActionAttributes] setMovieCommand:_movieControllerCommandType];
}

- (void)setMovieCommand:(NSInteger)aCommand
{
    if (_movieControllerCommandType != aCommand) {
        _movieControllerCommandType = aCommand;
        [self disableUndo];
        [[self movieControllerActionAttributes] setMovieCommand:_movieControllerCommandType];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    NSInteger pvVar1_2;

    pvVar1_2 = [[self movieControllerActionAttributes] movieCommand];
    _movieControllerCommandType = (int)pvVar1_2;
    _initialMovieControllerCommandType = (int)pvVar1_2;
}

- (id)movieControllerActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSMovieControllerActionAttributes)];
}

@end

