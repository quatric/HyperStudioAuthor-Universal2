#import "HyperStudioPrefix.h"


@interface HSChoosableItemProvider : NSObject <HSIconsGridDataSource>
{
    id<HSChooserDataSource> _dataSource;
    BOOL _shouldDisplayLabels;
    Class _objectClass;
}
- (BOOL)shouldDisplayLabels;
- (void)setShouldDisplayLabels:(BOOL)aLabels;
- (id)dataSource;
- (void)setDataSource:(id)aSource;
- (id)iconAtIndex:(NSInteger)aIndex inIconsGrid:(id)aGrid;
- (NSUInteger)iconsCountInIconsGrid:(id)aGrid;
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt;
- (NSInteger)numberOfItemsInGridControl:(id)aControl;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (id)imageForChoosableItemAtIndex:(NSUInteger)aIndex;
- (id)initWithDestinationObjectClass:(Class)aClass;
@end

