#import "HyperStudioPrefix.h"
#import "HSImportDialogSoundPaneViewController.h"


@interface HSImportDialogSoundInUsePaneViewController : HSImportDialogSoundPaneViewController
{
    NSArray *_soundsInUse;
}
+ (void)load;
- (void)tableView:(id)aView didClickTableColumn:(id)aColumn;
- (void)tableView:(id)aView sortDescriptorsDidChange:(id)aChange;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (id)soundsInUse;
- (id)soundsForActor:(id)aActor;
- (void)willMountToDialogController:(id)aController;
- (id)paneFilePath;
- (id)paneFileDisplayName;
- (id)paneTitle;
- (NSInteger)paneWeight;
- (id)paneView;
- (id)paneIdentifier;
- (id)paneViewNibName;
- (void)dealloc;
@end

