#import "HSFoundObjectsListController.h"

@implementation HSFoundObjectsListController

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return 0;
}

- (id)findUIDsMatchingTerm:(id)aTerm
{
    return [NSSet set];
}

- (void)updateUIWithSearchResultsIfNeeded
{
    if (_hasPendingUpdateUIRequest) {
        _hasPendingUpdateUIRequest = NO;
        [self updateUIWithSearchResultsLazily:NO];
    }
}

- (void)updateUIWithSearchResultsLazily:(BOOL)aLazily
{
    if ((aLazily && [_searchResultsCountField window] == nil) || _searchResultsCountField == nil) {
        _hasPendingUpdateUIRequest = YES;
        return;
    }
    id foundUIDs = [self foundUIDs];
    NSString *text;
    if ([foundUIDs count] == 0)
        text = [[NSBundle mainBundle] localizedStringForKey:@"No objects found" value:@"" table:nil];
    else
        text = [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"%u objects found" value:@"" table:nil], (unsigned int)[foundUIDs count]];
    [_searchResultsCountField setStringValue:text];
    [[self tableView] reloadData];
}

- (void)invalidateSearchResultsLazily:(BOOL)aLazily
{
    [_foundUIDs release];
    _foundUIDs = nil;
    [self updateUIWithSearchResultsLazily:aLazily];
}

- (id)foundUIDs
{
    if (_foundUIDs == nil)
        _foundUIDs = [[self findUIDsMatchingTerm:_searchTerm != nil ? _searchTerm : @""] retain];
    return _foundUIDs;
}

- (void)willMountIntoWindow:(id)aWindow
{
    [super willMountIntoWindow:aWindow];
    [self updateUIWithSearchResultsIfNeeded];
}

- (void)didChangeNumberOfDisplayedItems
{
    [self updateUIWithSearchResultsLazily:YES];
}

- (void)didChangeTopLevelParent
{
    [self updateUIWithSearchResultsLazily:YES];
}

- (void)setSearchTerm:(id)aTerm
{
    if (![_searchTerm isEqualToString:aTerm]) {
        [_searchTerm release];
        _searchTerm = [aTerm copy];
        [self updateUIWithSearchResultsLazily:NO];
    }
}

- (id)searchTerm
{
    return _searchTerm;
}

- (void)didLoadNib
{
    [super didLoadNib];
    [self updateUIWithSearchResultsIfNeeded];
}

- (id)nibName
{
    return @"FoundObjectsList";
}

- (void)dealloc
{
    [_searchTerm release];
    [_foundUIDs release];
    [super dealloc];
}

@end
