#import "HSCellVisualizationView.h"
@implementation HSCellVisualizationView
- (void)drawRect:(NSRect)aRect
{
    if (!NSIsEmptyRect(_cellFrame))
        [_cell drawWithFrame:_cellFrame inView:self];
}
- (void)setCellFrame:(NSRect)aFrame
{
    _cellFrame = aFrame;
}
- (NSRect)cellFrame
{
    return _cellFrame;
}
- (void)setCell:(id)aCell
{
    if (_cell != aCell) {
        [aCell retain];
        [_cell release];
        _cell = aCell;
    }
}
- (id)cell
{
    return _cell;
}
- (void)dealloc
{
    [_cell release];
    [super dealloc];
}
@end
