#import "HyperStudioPrefix.h"


@interface HSColorMatrix : NSMatrix
{
    id<HSColorMatrixDataProvider> _dataProvider;
}
- (NSRect)selectionRectForCellAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (id)selectionColor;
- (void)handleDoubleClick;
- (void)handleSingleClickWithSelectionChange:(BOOL)aChange;
- (void)handleMouseTracking;
- (void)reloadData;
- (void)dataProviderDidColorChange:(id)aChange;
- (void)setSelectedColor:(id)aColor;
- (id)selectedColor;
- (id)dataProvider;
- (void)mouseDown:(id)aDown;
- (BOOL)getRow:(int *)aRow column:(int *)aColumn forPoint:(NSPoint)aPoint;
- (void)deselectSelectedCell;
- (BOOL)selectCellWithTag:(NSInteger)aTag;
- (void)selectCellAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (void)drawRect:(NSRect)aRect;
- (BOOL)isOpaque;
- (void)dealloc;
- (void)viewWillMoveToSuperview:(id)aSuperview;
- (id)initWithFrame:(NSRect)aFrame dataProvider:(id)aProvider;
@end

