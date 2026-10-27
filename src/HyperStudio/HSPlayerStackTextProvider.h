#import "HyperStudioPrefix.h"
#import "HSStackTextProvider.h"


@interface HSPlayerStackTextProvider : HSStackTextProvider
{
}
- (void)deactivateCurrentItem;
- (void)selectCurrentItemNameWithRange:(NSRange)aRange;
- (void)selectCurrentItemStringWithRange:(NSRange)aRange;
- (void)activateInspectorOfCurrentItem;
- (void)activateCurrentItem;
- (NSRange)selectedRangeForCurrentItemName;
- (NSRange)selectedRangeForCurrentItem;
- (id)hyperNameForCurrentItem;
- (id)hyperTextForCurrentItem;
- (void)selectionChanged:(id)aChanged;
- (void)setIncludeObjectNames:(BOOL)aNames;
- (void)refreshCurrentItem;
- (BOOL)shouldEnableIncludeObjectNamesButton;
- (void)setCurrentItem:(id)aItem;
- (BOOL)canBecomeCurrentItem:(id)aItem;
- (id)initWithWindowController:(id)aController selectionController:(id)aController2;
@end

