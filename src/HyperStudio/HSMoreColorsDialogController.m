#import "HSMoreColorsDialogController.h"

@implementation HSMoreColorsDialogController

- (void)willCloseWindow
{
    [_sampleView unbind:@"color"];
}

- (void)willShowWindow
{
    [_matrix selectCellAtRow:_initialRow column:_initialColumn];
    [_sampleView bind:@"color" toObject:_matrix withKeyPath:@"selectedColor" options:nil];
}

- (id)nibName
{
    return @"MoreColorsDialog";
}

- (NSInteger)selectedColumn
{
    return [_matrix selectedColumn];
}

- (NSInteger)selectedRow
{
    return [_matrix selectedRow];
}

- (id)initWithRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    self = [super init];
    // Fix: super's init result was not checked.
    if (self != nil) {
        _initialRow = (int)aRow;
        _initialColumn = (int)aColumn;
    }
    return self;
}

@end
