#import "HSSmallColorMatrix.h"

@implementation HSSmallColorMatrix

// Lets the user repoint the clicked swatch at another palette position.
- (void)handleDoubleClick
{
    NSInteger row = [self selectedRow];
    NSInteger column = [self selectedColumn];
    id provider = [self dataProvider];
    HSMatrixPosition *position = [provider referencedPositionAtRow:row column:column];
    HSMoreColorsDialogController *dialog = [[HSMoreColorsDialogController alloc] initWithRow:[position row] column:[position column]];
    if ([dialog runModal] == 1)
        [provider setReferencedPosition:[HSMatrixPosition positionWithRow:[dialog selectedRow] column:[dialog selectedColumn]] atRow:row column:column];
    [dialog release];
    [super handleDoubleClick];
}

- (id)initWithFrame:(NSRect)aFrame
{
    return [super initWithFrame:aFrame dataProvider:[HSSmallColorMatrixDataProvider sharedDataProvider]];
}

@end
