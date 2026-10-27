#import "HSAnimationSetupDrawPathAssistantPane.h"

@implementation HSAnimationSetupDrawPathAssistantPane

- (void)setupUIForNonSegmentedPathCreationMode
{
    _isSegmentedPathCreationModeActive = NO;
}

- (void)setupUIForSegmentedPathCreationMode
{
    _isSegmentedPathCreationModeActive = YES;
}

- (id)helpTopicKey
{
    return @"HSPlayAnimation";
}

- (void)setPathCreationCanBeFinished:(BOOL)aFinished
{
    _pathCreationCanBeFinished = aFinished;
    [self updatePaneSwitcherIfNeeded];
}

- (void)updatePaneSwitcherIfNeeded
{
    if (_isSegmentedPathCreationModeActive)
        [(HSActionsPaneGoBackContinueSwitcher *)_currentNavigationPaneSwitcher setCanContinue:_pathCreationCanBeFinished];
}

- (void)paneContinue:(id)aContinue
{
    [_delegate drawPathShouldFinishFromDrawPathAssistantPane:self];
}

- (void)paneWillGoBack:(id)aBack
{
    [_delegate drawPathShouldCancelFromDrawPathAssistantPane:self];
}

- (void)cancel:(id)aCancel
{
    [self dismiss:YES];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (BOOL)needsToBeSavedInHistory
{
    return YES;
}

- (BOOL)assistantShouldBeKeyWindow
{
    return NO;
}

- (BOOL)shouldDismissWhenDisappearedByDefault
{
    return NO;
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self updatePaneSwitcherIfNeeded];
}

// A hidden button gives the pane an Escape key equivalent that cancels it.
- (void)viewDidLoad
{
    [super viewDidLoad];
    _cancelButton = [NSButton new];
    [_cancelButton setTarget:self];
    [_cancelButton setAction:@selector(paneDidCancel:)];
    [_cancelButton setFrame:NSZeroRect];
    unichar escape = 0x1b;
    [_cancelButton setKeyEquivalent:[NSString stringWithCharacters:&escape length:1]];
    [[self view] addSubview:_cancelButton];
    [self setDontShowThisMessageAgainSwitchVisible:NO];
}

- (id)newBackgroundImage
{
    Class switcherClass = _isSegmentedPathCreationModeActive ? [HSActionsPaneGoBackContinueSwitcher class] : [HSActionsPaneGoBackSwitcher class];
    _currentNavigationPaneSwitcher = [switcherClass new];
    return _currentNavigationPaneSwitcher;
}

- (id)assistantPaneUndoManager
{
    return [_delegate undoManagerForDrawPathAssistantPane:self];
}

@end
