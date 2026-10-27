#import "HSAnimationSetupPickPartOfCardAssistantPane.h"

@implementation HSAnimationSetupPickPartOfCardAssistantPane

- (void)selectCardObject:(id)aObject
{
    [_delegate pickCardObjectForAssistantPane:self temporaryObject:_temporaryObject];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    id renderer = [HSAssistantLargeButtonBackgroundRenderer sharedBackgroundRenderer];
    [[_selectSquireCardPartButton cell] setBackgroundRenderer:renderer];
    [[_selectCircleCardPartButton cell] setBackgroundRenderer:renderer];
    [[_selectCardPartUsingLassoButton cell] setBackgroundRenderer:renderer];
    [[_selectCardObjectButton cell] setBackgroundRenderer:renderer];
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (BOOL)assistantShouldBeKeyWindow
{
    return NO;
}

- (id)initWithOptions:(id)aOptions
{
    self = [super initWithNibName:@"AnimationPickPartOfCardPane"];
    if (self != nil)
        _imageOptions = [aOptions retain];
    return self;
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [_image release];
    _image = [[[self card] imageWithVisualizationProtocol:@protocol(HSPlayerVisualization)] retain];
    [super viewWillAppear:aAppear];
}

- (void)HSAnimationSetupPickPartOfCardAssistantPane_cardsWillChange:(id)aChange
{
    NSSet *removed = [[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    if ([[[aChange userInfo] objectForKey:@"HSNodeChildrenForAddition"] count] == 0 && ![removed containsObject:[self card]]) {
        return;
    }
    [[HSToolManager sharedToolManager] selectToolWithTag:0];
}

- (void)HSAnimationSetupPickPartOfCardAssistantPane_currentCardWillChange:(id)aChange
{
    [[HSToolManager sharedToolManager] selectToolWithTag:0];
}

- (void)HSAnimationSetupPickPartOfCardAssistantPane_objectsWillChange:(id)aChange
{
    NSSet *removed = [[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    if ([[[aChange userInfo] objectForKey:@"HSNodeChildrenForAddition"] count] == 0 && ![removed containsObject:[[self assistant] object]]) {
        return;
    }
    [[HSToolManager sharedToolManager] selectToolWithTag:0];
}

- (void)HSAnimationSetupPickPartOfCardAssistantPane_toolDidChange:(id)aChange
{
    [[[self cardView] selection] removeAllNodes];
}

- (void)HSAnimationSetupPickPartOfCardAssistantPane_windowDidResignMain:(id)aChange
{
    id current = [[HSEditorController sharedDocumentController] currentDocument];
    if (current != nil && current != [self document]) {
        [[HSToolManager sharedToolManager] selectToolWithTag:0];
    }
}

- (id)assistantPaneUndoManager
{
    return [_delegate undoManagerForPickPartOfCardAssistantPane:self];
}

- (id)cardView
{
    return [_delegate cardViewForPickPartOfCardAssistantPane:self];
}

- (id)document
{
    return [[[self cardView] card] document];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [super viewWillDisappear:aDisappear];
    if ([_delegate needObserveStackChangesForPickPartOfCardAssistantPane:self]) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:HSCurrentCardInCardViewWillChange object:[self cardView]];
        [center removeObserver:self name:NSWindowDidResignMainNotification object:[[self cardView] window]];
        [center removeObserver:self name:@"HSActiveToolDidSelectionNotification" object:[HSToolManager sharedToolManager]];
        id stack = [[self document] stack];
        [stack removeObserver:self selector:@selector(HSAnimationSetupPickPartOfCardAssistantPane_cardsWillChange:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
        [stack removeObserver:self selector:@selector(HSAnimationSetupPickPartOfCardAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end
