#import "HSScrollCardPositionAssistantPane.h"

@implementation HSScrollCardPositionAssistantPane

- (void)pointSelectionTool:(id)aTool selectedPointChange:(NSPoint)aChange
{
    _position = aChange;
    [[self delegate] setScrollCardPositionAssistantPane:self closeWithPosition:_position];
    [self dismiss:YES];
}

- (void)setPositionAttributes:(id)aAttributes
{
    if (_positionActionAttributes != aAttributes) {
        [_positionActionAttributes release];
        _positionActionAttributes = [aAttributes retain];
    }
}

- (id)positionAttributes
{
    return _positionActionAttributes;
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
    [_delegate setScrollCardPositionAssistantPane:self closeWithPosition:_position];
    [self dismiss:YES];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
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
    _position = [(id<HSPositionAttributes>)[self positionAttributes] position];
    _previousToolTag = (int)[[HSToolManager sharedToolManager] selectedToolTag];
    [[HSToolManager sharedToolManager] selectToolWithTag:0x44 setAsPermanent:NO];
    _pointSelectionTool = [[[HSToolManager sharedToolManager] currentTool] retain];
    [_pointSelectionTool setDelegate:self];
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
    if (_navigationPaneSwitcher == nil) {
        _navigationPaneSwitcher = [HSActionsPaneGoBackSwitcher new];
        [_navigationPaneSwitcher setDelegate:self];
    }
    return _navigationPaneSwitcher;
}

- (void)dealloc
{
    [_positionActionAttributes release];
    [_navigationPaneSwitcher setDelegate:nil];
    [_navigationPaneSwitcher release];
    [super dealloc];
}

@end
