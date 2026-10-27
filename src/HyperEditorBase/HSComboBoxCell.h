#import "HyperEditorBasePrefix.h"


@interface HSComboBoxCell : NSComboBoxCell
{
}
- (NSInteger)numberOfRowsInTableView:(id)aView;
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow;
- (void)setObjectValue:(id)aValue;
- (id)init;
@end

