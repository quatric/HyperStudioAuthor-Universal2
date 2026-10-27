#import "HyperStudioPrefix.h"


@interface HSIconsGrid : NSMatrix
{
    id<HSIconsGridDataSource> _dataSource;
}
- (void)sizeToCells;
- (void)mouseDown:(id)aDown;
- (void)reloadData;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
- (id)makeCellAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (Class)cellClass;
- (void)drawRect:(NSRect)aRect;
- (BOOL)acceptsFirstResponder;
- (BOOL)isOpaque;
- (id)initWithFrame:(NSRect)aFrame;
@end

