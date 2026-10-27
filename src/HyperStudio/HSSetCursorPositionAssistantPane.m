#import "HSSetCursorPositionAssistantPane.h"

@interface NSObject (HSSetCursorPositionAssistantPaneDelegateMethods)
- (void)actionPaneDidClose:(id)aPane withApplier:(id)anApplier canceled:(BOOL)aCanceled;
@end

@implementation HSSetCursorPositionAssistantPane

// The selected point is in card coordinates with the origin at the top left;
// the action stores it relative to the card centre with y up.
- (void)pointSelectionTool:(id)aTool selectedPointChange:(NSPoint)aChange
{
    NSSize cardSize = [[self stack] hyperCardSize];
    HSActionAssistantSettingsApplier *applier = [[HSActionAssistantSettingsApplier alloc] initWithObject:[[self assistant] object] actionType:[HSSetCursorPositionAction actionType] actionEvents:[self actionEvents]];
    id attributes = [[applier actionAttributes] queryHyperInterface:@protocol(HSSetCursorPositionActionAttributes)];
    [attributes setCursorPosition:NSMakePoint(cardSize.width * -0.5f + aChange.x, cardSize.height * 0.5f - aChange.y)];
    [applier addActionToActor];
    if ([_delegate respondsToSelector:@selector(actionPaneDidClose:withApplier:canceled:)])
        [_delegate actionPaneDidClose:nil withApplier:applier canceled:NO];
    [applier release];
    [self dismiss:YES];
}

- (void)setActionEvents:(id)aEvents
{
    if (_actionEvents != aEvents) {
        [_actionEvents release];
        _actionEvents = [aEvents retain];
    }
}

- (id)actionEvents
{
    return _actionEvents;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)paneWillGoBack:(id)aBack
{
    [self dismiss:YES];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[[self stack] undoManager] disableUndoRegistration];
    [_pointSelectionTool setDelegate:nil];
    [_pointSelectionTool release];
    _pointSelectionTool = nil;
    [(HSToolManager *)[HSToolManager sharedToolManager] selectToolWithTag:_previousToolTag];
    [[[HSToolManager sharedToolManager] toolView] setOccupiedByTool:NO];
    [[HSObjectListPaletteController sharedInstance] setHyperPaletteLocked:NO];
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [[[self stack] undoManager] enableUndoRegistration];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[[self stack] undoManager] disableUndoRegistration];
    [[[HSToolManager sharedToolManager] toolView] setOccupiedByTool:YES];
    [[HSObjectListPaletteController sharedInstance] setHyperPaletteLocked:YES];
    [[HSObjectAssistantController sharedAssistantController] setLocked:YES delegate:self];
    _previousToolTag = (int)[[HSToolManager sharedToolManager] selectedToolTag];
    [[HSToolManager sharedToolManager] selectToolWithTag:0x44 setAsPermanent:NO];
    _pointSelectionTool = [[[HSToolManager sharedToolManager] currentTool] retain];
    [_pointSelectionTool setDelegate:self];
    [[[self stack] undoManager] enableUndoRegistration];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDontShowThisMessageAgainSwitchVisible:NO];
}

- (BOOL)shouldDismissWhenDisappearedByDefault
{
    return NO;
}

- (BOOL)needsToBeSavedInHistory
{
    return NO;
}

- (id)navigationPaneSwitcher
{
    if (!_navigationPaneSwitcher) {
        _navigationPaneSwitcher = [HSActionsPaneGoBackSwitcher new];
        [_navigationPaneSwitcher setDelegate:self];
    }
    return _navigationPaneSwitcher;
}

- (void)dealloc
{
    [_navigationPaneSwitcher setDelegate:nil];
    [_navigationPaneSwitcher release];
    [_actionEvents release];
    [super dealloc];
}

@end
