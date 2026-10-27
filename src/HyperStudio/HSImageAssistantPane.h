#import "HyperStudioPrefix.h"
#import "HSAssistantPaneApplier.h"
#import "HSCommentsTextView.h"


@interface HSImageAssistantPane : HSObjectAssistantPaneWithApplier <NSMatrixDelegate, NSControlTextEditingDelegate, NSObject>
{
    HSIconsGrid *_gridControl;
    HSSegmentedControl *_sourceMatrix;
    NSView *_gridContentView;
    NSView *_containerView;
    NSView *_placeholderView;
    NSView *_folderTabPlaceholderView;
    NSView *_folderTabView;
    NSView *_folderTabContainerView;
    NSImageView *_imageView;
    NSTextField *_currentPath;
    NSView *_currentContentView;
    HSChoosableItemProvider *_chooser;
    HSStackImagesDataSource *_stackImagesDataSource;
    HSImageLibraryDataSource *_libraryImagesDataSource;
    HSFolderImagesDataSource *_folderImagesDataSource;
    HSObjectAssistantNavigationPaneSwitcher *_paneSwitcher;
}
- (void)validatePaneSwither;
- (id)helpTopicKey;
- (id)contentViewForDataSource:(id)aSource;
- (id)contentSubviewForDataSource:(id)aSource;
- (void)mountView:(id)aView inView:(id)aView2;
- (void)viewDidAppear:(BOOL)aAppear;
- (id)navigationPaneSwitcher;
- (BOOL)requiresDarkBottomArea;
- (void)doubleClickAtIndex:(NSInteger)aIndex inIconsGrid:(id)aGrid;
- (id)folderImagesDataSource;
- (void)changeFolder:(id)aFolder;
- (void)chooseFromFolder:(id)aFolder;
- (void)updateUI;
- (void)viewDidLoad;
- (void)imageDataSourceDidChange:(id)aChange;
- (void)selectionDidChangeInIconsGrid:(id)aGrid;
- (id)stackImagesDataSource;
- (id)libraryImagesDataSource;
- (void)chooseFromBundle:(id)aBundle;
- (void)chooseFromStack:(id)aStack;
- (void)setChooserDataSource:(id)aSource;
- (NSUInteger)tagForCurrentDataSource;
- (id)chooser;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (id)HSImageAssistantPane_applier;
- (Class)applierClass;
- (void)dealloc;
- (id)init;
@end

@interface HSImageAssistantPaneApplier : HSAssistantPaneApplier
{
    HSNewMedia *_initialMedia;
    HSNewMedia *_media;
}
- (BOOL)areSettingsEqual;
- (void)makeCurrentEqualToInitial;
- (void)makeInitialEqualToCurrent;
- (void)setInitialSettingsToObject;
- (void)setCurrentSettingsToObject;
- (void)setUpInitialSettings;
- (void)setMedia:(id)aMedia;
- (id)undoActionName;
- (id)mediaAttributes;
- (void)dealloc;
@end

