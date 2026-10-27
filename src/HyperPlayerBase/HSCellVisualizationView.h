#import "HyperPlayerBasePrefix.h"
#import "HSVisualizationAuxiliaryView.h"


@interface HSCellVisualizationView : HSVisualizationAuxiliaryView
{
    NSCell *_cell;
    NSRect _cellFrame;
}
- (void)drawRect:(NSRect)aRect;
- (void)setCellFrame:(NSRect)aFrame;
- (NSRect)cellFrame;
- (void)setCell:(id)aCell;
- (id)cell;
- (void)dealloc;
@end

