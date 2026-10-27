#import "HyperStudioPrefix.h"
#import "HSObjectListController.h"


@interface HSFoundObjectsListController : HSObjectListController
{
    NSTextField *_searchResultsCountField;
    NSString *_searchTerm;
    NSSet *_foundUIDs;
    BOOL _hasPendingUpdateUIRequest;
}
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (id)findUIDsMatchingTerm:(id)aTerm;
- (void)updateUIWithSearchResultsIfNeeded;
- (void)updateUIWithSearchResultsLazily:(BOOL)aLazily;
- (void)invalidateSearchResultsLazily:(BOOL)aLazily;
- (id)foundUIDs;
- (void)willMountIntoWindow:(id)aWindow;
- (void)didChangeNumberOfDisplayedItems;
- (void)didChangeTopLevelParent;
- (void)setSearchTerm:(id)aTerm;
- (id)searchTerm;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

