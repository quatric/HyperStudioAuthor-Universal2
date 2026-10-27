#import "HyperStudioPrefix.h"


@interface HSImportDialogImportedPaneBrowseController : NSObject <NSTableViewDataSource, NSObject, NSTableViewDelegate, NSControlTextEditingDelegate>
{
    NSArray *_predefinedLocations;
    NSArray *_fileTypes;
    NSString *_defaultsKey;
    NSString *_defaultPath;
    NSString *_currentEnclosedDirectoryPathForSelection;
    NSString *_currentFilenameForSelection;
    BOOL _canReleasePathForSelection;
    int _lastSelectedRow;
    NSIndexSet *_draggedCustomLocations;
    id _delegate;
}
- (void)openPanelDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)tableViewSelectionDidChange:(id)aChange;
- (BOOL)tableView:(id)aView acceptDrop:(id)aDrop row:(NSInteger)aRow dropOperation:(NSUInteger)aOperation;
- (NSUInteger)tableView:(id)aView validateDrop:(id)aDrop proposedRow:(NSInteger)aRow proposedDropOperation:(NSUInteger)aOperation;
- (CGFloat)tableView:(id)aView heightOfRow:(NSInteger)aRow;
- (BOOL)tableView:(id)aView shouldSelectRow:(NSInteger)aRow;
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow;
- (void)setDefaultPath:(id)aPath;
- (id)defaultPath;
- (NSInteger)tableRowForDirectoryPath:(id)aPath;
- (id)directoryPathForTableRow:(NSInteger)aRow;
- (id)predefinedImageLocations;
- (void)insertCustomImageLocation:(id)aLocation atIndex:(NSUInteger)aIndex;
- (id)customImageLocationAtIndex:(NSUInteger)aIndex;
- (void)setCustomImageLocationAliasData:(id)aData forLocation:(id)aLocation;
- (id)customImageLocationAliases;
- (void)setCustomImageLocations:(id)aLocations;
- (id)customImageLocations;
- (void)removeDraggedOutRowsFromTableView:(id)aView;
- (BOOL)tableView:(id)aView writeRowsWithIndexes:(id)aIndexes toPasteboard:(id)aPasteboard;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (id)currentFilenameForSelection;
- (id)currentEnclosedDirectoryPathForSelection;
- (void)configureTableView:(id)aView;
- (void)setCurrentPath:(id)aPath forTableView:(id)aView;
- (id)currentPathForTableView:(id)aView;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)initWithPredefinedLocations:(id)aLocations userLocationsDefaultsKey:(id)aKey fileTypes:(id)aTypes;
- (void)dealloc;
- (id)customImageLocationBookmarkData;
- (void)setCustomImageLocationBookmarkData:(id)aData forLocation:(id)aLocation;
@end

