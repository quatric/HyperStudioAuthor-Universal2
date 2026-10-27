#import "HSComboBoxCell.h"

// The font combo box's cell: the list comes from the shared font data
// source, drawn with image cells (font name samples).

@implementation HSComboBoxCell

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    if (![self usesDataSource])
        return 0;
    return [[HSFontComboboxDataSource sharedFontDataSource] numberOfItemsInComboBox:(NSComboBox *)[self controlView]];
}

- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    return [[HSFontComboboxDataSource sharedFontDataSource] comboBox:(NSComboBox *)[self controlView] objectValueForItemAtIndex:aRow];
}

- (void)setObjectValue:(id)aValue
{
    id name = [[HSFontComboboxDataSource sharedFontDataSource] fontNameKeyForItem:aValue];
    [super setObjectValue:name != nil ? name : aValue];
}

- (id)init
{
    if ((self = [super init])) {
        NSImageCell *cell = [[[NSImageCell alloc] init] autorelease];
        [cell setImageAlignment:NSImageAlignLeft];
        [cell setImageScaling:NSImageScaleNone];
        // NSComboBoxCell's private table view (_tableView) in the original.
        NSTableView *tableView = [self valueForKey:@"_tableView"];
        [[[tableView tableColumns] objectAtIndex:0] setDataCell:cell];
    }
    return self;
}

@end
