#import "HyperStudioPrefix.h"


@interface HSImportDialogBasePaneViewController : NSObject <HSImportDialogPaneViewController, NSObject>
{
    NSMutableDictionary *_mediaPathDictionary;
    NSMutableArray *_searchedMediaPathsHash;
    NSRecursiveLock *_searchedMediaPathsHashLock;
    BOOL _isObjectOptionsDisabled;
    NSDictionary *_optionsKeyToProcessingSelectorMap;
    HSImportDialogController *_dialogController;
}
- (void)setupDialogInterfaceWithOptions:(id)aOptions;
- (void)setObjectOptionsDisabled:(BOOL)aDisabled;
- (BOOL)isObjectOptionsDisabled;
- (BOOL)isObjectValid;
- (id)mutableFilteredMediaPathsForKey:(id)aKey;
- (id)filteredPathsWithArray:(id)aArray;
- (id)mediaPathsForKey:(id)aKey;
- (void)invalidateMediaPaths;
- (id)helpTopicKey;
- (void)restoreSelection;
- (void)storeSelection;
- (void)reloadMediaPaths;
- (id)filteredMediaPathsForKey:(id)aKey;
- (BOOL)mediaPathConformsToFilter:(id)aFilter;
- (id)paneHyperDocument;
- (id)dialogType;
- (id)supportedMediaTypes;
- (id)createMediaPathsForKey:(id)aKey;
- (BOOL)isPaneValid;
- (void)willUnmountFromDialogController:(id)aController;
- (void)willMountToDialogController:(id)aController;
- (void)paneDialogWillOpen;
- (void)paneDialogWillClose;
- (void)paneDialogWillCancel;
- (id)paneUserOptions;
- (id)paneFileDisplayName;
- (id)paneFilePath;
- (id)paneAccessoryView;
- (id)paneView;
- (id)paneTitle;
- (NSInteger)paneWeight;
- (id)paneIdentifier;
- (void)dealloc;
- (id)init;
@end

