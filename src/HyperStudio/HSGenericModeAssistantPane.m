#import "HSGenericModeAssistantPane.h"

@implementation HSGenericModeAssistantPane

- (void)toolWillChange:(id)aChange
{
    if ([self shouldLeavePaneOnToolChange])
        [self dismiss:YES];
}

- (void)undoManagerWillUndoOrRedo:(id)aRedo
{
    [self dismiss:YES];
}

- (id)modeToolTags
{
    return nil;
}

- (BOOL)shouldDismissWhenDisappearedByDefault
{
    return NO;
}

- (void)setShouldLeavePaneOnToolChange:(BOOL)aChange
{
    _shouldNotLeavePaneOnToolChange = !aChange;
}

- (BOOL)shouldLeavePaneOnToolChange
{
    return !_shouldNotLeavePaneOnToolChange;
}

- (void)leaveCurrentModeWithSelectingToolWithTag:(NSInteger)aTag
{
    [(HSToolManager *)[HSToolManager sharedToolManager] selectToolWithTag:aTag];
}

- (id)document
{
    return [[HSEditorController sharedDocumentController] currentDocument];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[self assistant] setSupportsSettingsOnTheSpotMode:_initialSupportSettingsOnTheSpotMode];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSUInteger currentTag = [HSToolManager toolTagForIdentifier:[[[HSToolManager sharedToolManager] currentTool] toolIdentifier]];
    NSEnumerator *enumerator = [[self modeToolTags] objectEnumerator];
    NSNumber *tag;
    while ((tag = [enumerator nextObject]) != nil) {
        if ([tag unsignedIntValue] == currentTag) {
            currentTag = 1;
            break;
        }
    }
    [super viewWillDisappear:aDisappear];
    [self leaveCurrentModeWithSelectingToolWithTag:currentTag];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setDontShowThisMessageAgainSwitchVisible:NO];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    _initialSupportSettingsOnTheSpotMode = [[self assistant] supportsSettingsOnTheSpotMode];
    [[self assistant] setSupportsSettingsOnTheSpotMode:NO];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSUndoManager *undoManager = [[[self document] queryHyperInterface:@protocol(HSNodeSupport)] undoManager];
    [center addObserver:self selector:@selector(toolWillChange:) name:@"HSActiveToolWillChangeNotification" object:[HSToolManager sharedToolManager]];
    [center addObserver:self selector:@selector(undoManagerWillUndoOrRedo:) name:NSUndoManagerWillUndoChangeNotification object:undoManager];
    [center addObserver:self selector:@selector(undoManagerWillUndoOrRedo:) name:NSUndoManagerWillRedoChangeNotification object:undoManager];
}

@end
