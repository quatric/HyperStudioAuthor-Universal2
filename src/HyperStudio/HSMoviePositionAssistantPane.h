#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"
#import "HSHelpAssistantPane.h"


@interface HSMoviePositionAssistantPane : HSHelpAssistantPane <HSNodeSupport, NSObject, HSPlaybackItemSupport>
{
    int _previousToolTag;
    HSNode *_positionallyNode;
    HSPlayMovieActionPositionTool *_playMovieActionTool;
    HSMoviePositionApplier *_applier;
    id<HSPlaybackItemAttributes> _playbackItemAttributes;
    id _selectedObject;
    HSObjectAssistantNavigationPaneSwitcher *_navigationPaneSwitcher;
    id<HSPlaybackItemSupport> _oldPlaybackItemSupport;
    NSUndoManager *_paneUndoManager;
}
- (void)toolWillChange:(id)aChange;
- (BOOL)isAttributesNotificationPostingDisabled;
- (id)cardGroupController;
- (id)delegate;
- (id)scriptController;
- (id)undoManager;
- (id)objectForAction;
- (void)moviePlaybackDidFinish:(id)aFinish;
- (id)nodeSupportForMovie;
- (id)itemAttributeNotificationCenter;
- (id)stackForAction;
- (id)cardForAction;
- (void)userDidFinishPlayMovieActionSetupTool:(id)aTool;
- (void)playMovieActionPositionToolDidFinish:(id)aFinish;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)positionallyNodeGeometryDidChage:(id)aChage;
- (id)paneUndoManager;
- (void)switchToPreviousTool;
- (id)applier;
- (void)setApplier:(id)aApplier;
- (id)undoManagerForApplier:(id)aApplier;
- (void)setPositionallyNode:(id)aNode;
- (id)positionallyNode;
- (void)setPlaybackItemAttributes:(id)aAttributes;
- (id)playbackItemAttributes;
- (id)assistantPaneUndoManager;
- (BOOL)needsToBeSavedInHistory;
- (BOOL)shouldShowCancelButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (BOOL)shouldDismissWhenDisappearedByDefault;
- (void)viewDidLoad;
- (id)navigationPaneSwitcher;
- (void)dealloc;
@end

@interface HSMoviePositionApplier : HSAssistantPaneApplier
{
    id<HSPlaybackItemAttributes> _playbackItemAttributes;
    CGAffineTransform _initialTransform;
    CGAffineTransform _currentTransform;
    NSSize _initialSize;
    NSSize _currentSize;
}
- (BOOL)areSettingsEqual;
- (void)setSize:(NSSize)aSize;
- (void)setAffineTransform:(CGAffineTransform)aTransform;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (id)undoActionName;
- (id)playbackItemAttributes;
- (void)dealloc;
- (id)initWithNode:(id)aNode playbackItemAttributes:(id)aAttributes;
@end

