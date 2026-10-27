#import "HSDropOffPlaceObjectAssistantPane.h"

@interface NSObject (HSDropOffPlaceObjectAssistantPaneDelegateMethods)
- (void)placeObjectShouldCancelFromPlaceObjectAssistantPane:(id)aPane;
- (void)prepareToolAndCardViewAfterSwitchForPlaceObjectAssistantPane:(id)aPane;
- (void)prepareToolAndCardViewForPlaceObjectAssistantPane:(id)aPane;
@end

@implementation HSDropOffPlaceObjectAssistantPane

- (id)helpTopicKey
{
    return @"HSPlayAnimation";
}

- (void)paneWillGoBack:(id)aBack
{
    [_delegate placeObjectShouldCancelFromPlaceObjectAssistantPane:self];
}

- (void)cancel:(id)aCancel
{
    [self dismiss:YES];
}

- (id)assistantPaneUndoManager
{
    return [self dummyUndoManager];
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

- (id)dummyUndoManager
{
    if (!_dummyUndoManager)
        _dummyUndoManager = [NSUndoManager new];
    return _dummyUndoManager;
}

// When another document's window becomes main, the tool and card view are
// set up again for the new document.
- (void)HSAnimationSetupDrawPathAssistantPane_windowDidResignMain:(id)aMain
{
    id document = [[HSEditorController sharedDocumentController] currentDocument];
    if (document && document != [[self stack] document])
        [_delegate prepareToolAndCardViewAfterSwitchForPlaceObjectAssistantPane:self];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:[[[[self stack] document] cardView] window]];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_delegate prepareToolAndCardViewForPlaceObjectAssistantPane:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSAnimationSetupDrawPathAssistantPane_windowDidResignMain:) name:NSWindowDidResignMainNotification object:[[[[self stack] document] cardView] window]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDontShowThisMessageAgainSwitchVisible:NO];
}

// (The method is named newBackgroundImage in the binary but creates the
// go-back navigation switcher.)
- (id)newBackgroundImage
{
    return [HSActionsPaneGoBackSwitcher new];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_dummyUndoManager release];
    [super dealloc];
}

@end
