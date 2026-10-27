#import "HSNewActionDropHelpPane.h"

@implementation HSNewActionDropHelpPane

- (id)containersForAdd
{
    return _containersForAdd;
}

- (id)actionsToAdd
{
    return _actionsToAdd;
}

- (void)addActionToAdd:(id)aAdd actionEvent:(id)aEvent forContainer:(id)aContainer
{
    if (_actionsToAdd == nil)
        _actionsToAdd = [NSMutableArray new];
    if (_actionEvents == nil)
        _actionEvents = [NSMutableArray new];
    if (_containersForAdd == nil)
        _containersForAdd = [NSMutableArray new];
    [_actionsToAdd addObject:aAdd];
    [_actionEvents addObject:aEvent];
    [_containersForAdd addObject:aContainer];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (void)paneDidCancel:(id)aCancel
{
    if (_dropDelegate != nil)
        [_dropDelegate dropHelpPaneDidEnd:self canceled:YES];
    [self dismiss:YES];
}

- (void)paneDidOK:(id)aOK
{
    if (_dropDelegate != nil)
        [_dropDelegate dropHelpPaneDidEnd:self canceled:NO];
    [self dismiss:YES];
}

- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return YES;
}

- (id)dropHelpPaneIdentifier
{
    return @"HSNewActionDropHelpPane";
}

- (void)dealloc
{
    [_actionsToAdd release];
    [_actionEvents release];
    [_containersForAdd release];
    [super dealloc];
}

- (id)initWithCoachingKey:(id)aKey actionForAdd:(id)aAdd actionEvent:(id)aEvent andContainerForAdd:(id)aAdd2
{
    self = [super initWithCoachingKey:aKey];
    if (self != nil) {
        _actionsToAdd = [NSMutableArray new];
        [_actionsToAdd addObject:aAdd];
        _actionEvents = [NSMutableArray new];
        [_actionEvents addObject:aEvent];
        _containersForAdd = [NSMutableArray new];
        [_containersForAdd addObject:aAdd2];
    }
    return self;
}

@end
