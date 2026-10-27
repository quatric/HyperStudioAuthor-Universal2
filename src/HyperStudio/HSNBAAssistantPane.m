#import "HSNBAAssistantPane.h"

@implementation HSNBAAssistantPane

- (void)hideHelp:(id)aHelp
{
    [self hideHelpNeedsRelayout:YES];
}

- (void)showHelp:(id)aHelp
{
    [[self assistant] toggleDrawerModeWithDrawerSize:[[self actionHelpView] frame].size];
    [self setFooterView:[self actionHelpView]];
    [[_helpTextView textStorage] setAttributedString:[[HSNBAHelpProvider sharedNBAHelpProvider] localizedHelpForActionOfType:[self helpActionType]]];
    [self layoutIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(helpViewDidEndLiveResize:) name:@"HSPaneScrollViewDidEndLiveResizeNotification" object:[_helpTextView enclosingScrollView]];
    _helpIsActive = YES;
}

- (void)hideHelpNeedsRelayout:(BOOL)aRelayout
{
    [self setFooterView:nil];
    if (aRelayout)
        [self layoutIfNeeded];
    _helpIsActive = NO;
    [[self assistant] toggleDrawerModeWithDrawerSize:[[self actionHelpView] frame].size];
}

- (id)helpDrawer
{
    if (!_helpDrawer) {
        _helpDrawer = [[HSObjectAssistantDrawer alloc] initWithContentView:[self actionHelpView] objectAssistant:[self assistant]];
        [[_helpTextView textStorage] setAttributedString:[[HSNBAHelpProvider sharedNBAHelpProvider] localizedHelpForActionOfType:[self helpActionType]]];
    }
    return _helpDrawer;
}

- (BOOL)isHelpVisible
{
    return _helpIsActive;
}

- (id)helpActionType
{
    return [self actionType];
}

- (id)actionHelpView
{
    if (!_actionHelpView)
        [NSBundle loadNibNamed:@"NBAHelpView" owner:self];
    return _actionHelpView;
}

- (void)applySettingsOnOK
{
}

- (void)paneDidCancel:(id)aCancel
{
    if ([self isHelpVisible])
        [self hideHelpNeedsRelayout:YES];
    [super paneDidCancel:aCancel];
}

- (void)paneDidOK:(id)aOK
{
    if ([self isHelpVisible])
        [self hideHelpNeedsRelayout:YES];
    [super paneDidOK:aOK];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    if ([self isHelpVisible])
        [self hideHelpNeedsRelayout:NO];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[self navigationPaneSwitcher] validateUserInterface];
}

- (id)navigationPaneSwitcher
{
    if (!_paneSwitcher) {
        _paneSwitcher = [HSNBAAssistantNavigationPaneSwitcher new];
        [_paneSwitcher setDelegate:self];
    }
    return _paneSwitcher;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_actionHelpView release];
    [_helpDrawer release];
    [super dealloc];
}

@end
