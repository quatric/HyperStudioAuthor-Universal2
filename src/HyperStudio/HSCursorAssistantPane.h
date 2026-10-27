#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"
#import "HSCommentsTextView.h"


@interface HSCursorAssistantPane : HSObjectAssistantPaneWithApplier <NSMatrixDelegate, NSControlTextEditingDelegate, NSObject, HSIconsGridDataSource>
{
    NSView *_gridContentView;
    NSView *_placeholderView;
    NSView *_folderTabPlaceholderView;
    NSView *_folderTabView;
    HSSegmentedControl *_sourceMatrix;
    NSView *_containerView;
    HSIconsGrid *_gridControl;
    NSImageView *_imageView;
    NSTextField *_currentPath;
    NSView *_folderTabContainerView;
    HSObjectAssistantNavigationPaneSwitcher *_paneSwitcher;
    id<HSCursorAssistantPaneDataSource> _stackCursorsDataSource;
    id<HSCursorAssistantPaneDataSource> _folderCursorsDataSource;
    id<HSCursorAssistantPaneDataSource> _dataSource;
    NSView *_currentContentView;
    NSView *_currentFolderTabContentView;
}
+ (id)defaultCursorsDataSorce;
- (void)mountFolderTabContentView:(id)aView;
- (void)mountContentView:(id)aView;
- (id)helpTopicKey;
- (id)contentViewForDataSource:(id)aSource;
- (id)contentViewForHyperDataSource:(id)aSource;
- (id)contentViewForFolderDataSource:(id)aSource;
- (id)contentSubviewForFolderDataSource:(id)aSource;
- (void)validatePaneSwither;
- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher;
- (id)navigationPaneSwitcher;
- (void)selectItemWithCursor:(id)aCursor;
- (void)cursorDataSourceDidChange:(id)aChange;
- (void)doubleClickAtIndex:(NSInteger)aIndex inIconsGrid:(id)aGrid;
- (void)selectionDidChangeInIconsGrid:(id)aGrid;
- (id)dataSource;
- (void)setDataSource:(id)aSource;
- (id)folderCursorsDataSource;
- (id)stackCursorsDataSource;
- (void)setStackCursorsDataSource:(id)aSource;
- (void)changeFolder:(id)aFolder;
- (void)chooseFromFolder:(id)aFolder;
- (void)chooseFromBundle:(id)aBundle;
- (void)chooseFromStack:(id)aStack;
- (NSUInteger)tagForCurrentDataSource;
- (void)updateUI;
- (void)viewDidAppear:(BOOL)aAppear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (id)iconAtIndex:(NSInteger)aIndex inIconsGrid:(id)aGrid;
- (NSUInteger)iconsCountInIconsGrid:(id)aGrid;
- (id)HSCursorAssistantPane_applier;
- (Class)applierClass;
- (void)dealloc;
- (id)init;
@end

@interface HSCursorAssistantPaneApplier : HSAssistantPaneApplier
{
    HSCursor *_initialCursor;
    HSCursor *_currentCursor;
}
- (BOOL)areSettingsEqual;
- (BOOL)canApplyCurrentSettings;
- (void)setHyperCursor:(id)aCursor;
- (id)hyperCursor;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (void)dealloc;
- (id)undoActionName;
- (id)cursorAttributes;
@end

