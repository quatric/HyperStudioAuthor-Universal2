#import "HyperStudioPrefix.h"
#import <Quartz/Quartz.h>


@protocol HSATemplateChooserDelegate <NSObject>
@optional
- (void)templateChooser:(id)aChooser didChooseTemplateAtPath:(id)aPath;
@end

@interface HSATemplateChooser : NSObject <NSMenuDelegate>
{
    NSWindow *_window;
    IKImageBrowserView *_imageBrowserView;
    NSArray *_templatesBrowseItems;
    NSPopUpButton *_openRecentButton;
    NSArray *_recentDocuments;
    id<HSATemplateChooserDelegate> _delegate;
    HSSlider *_zoomSlider;
}
+ (id)sharedTemplateChooser;
- (id)window;
- (void)windowDidLoad;
- (void)showWindow;
- (void)close;
- (id)templatesBrowseItems;
- (void)setTemplatesBrowseItems:(id)aItems;
- (id)templatesBrowseItemsList;
- (id)recentDocuments;
- (void)setRecentDocuments:(id)aDocuments;
- (id)openRecentButton;
- (void)setOpenRecentButton:(id)aButton;
- (id)delegate;
- (void)setDelegate:(id)aDelegate;
- (id)zoomSlider;
- (void)setZoomSlider:(id)aSlider;
- (id)pathForTemplateWithName:(id)aName;
- (id)pathForTemplateImageWithName:(id)aName;
- (void)configureOpenRecentMenu;
- (void)updateRecentDocuments;
- (void)openTemplateWithName:(id)aName;
- (IBAction)recentDocumentMenuItemClick:(id)aSender;
- (IBAction)clearRecentDocuments:(id)aSender;
- (IBAction)choose:(id)aSender;
- (IBAction)cancel:(id)aSender;
- (IBAction)openExistingFile:(id)aSender;
- (IBAction)minimumZoom:(id)aSender;
- (IBAction)maximumZoom:(id)aSender;
- (NSUInteger)numberOfItemsInImageBrowser:(id)aBrowser;
- (id)imageBrowser:(id)aBrowser itemAtIndex:(NSUInteger)aIndex;
- (void)imageBrowser:(id)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)aIndex;
- (void)dealloc;
@end
