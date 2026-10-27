#import "HyperStudioPrefix.h"
#import "HSImportDialogMoviesPaneViewController.h"


@interface HSImportDialogMoviesInUsePaneViewController : HSImportDialogMoviesPaneViewController <HSNodeSupport, NSObject>
{
    NSArray *_playableObjectsInUse;
}
+ (void)load;
- (BOOL)isAttributesNotificationPostingDisabled;
- (id)cardGroupController;
- (id)delegate;
- (id)scriptController;
- (id)undoManager;
- (id)movieAtIndex:(NSUInteger)aIndex;
- (void)selectionDidChangeInGridControl:(id)aControl;
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt;
- (NSInteger)numberOfItemsInGridControl:(id)aControl;
- (id)playableObjectsInUse;
- (void)willUnmountFromDialogController:(id)aController;
- (void)willMountToDialogController:(id)aController;
- (id)paneUserOptions;
- (BOOL)isObjectValid;
- (id)paneFilePath;
- (id)paneTitle;
- (NSInteger)paneWeight;
- (id)paneView;
- (id)paneIdentifier;
- (id)paneViewNibName;
- (void)awakeFromNib;
- (void)dealloc;
@end

