#import "HyperStudioPrefix.h"
#import "HSColorMatrix.h"


@interface HSBigColorMatrix : HSColorMatrix
{
    BOOL _isActive;
}
- (void)dataProviderDidActiveViewChange:(id)aChange;
- (void)colorPanelDidColorChange:(id)aChange;
- (void)reloadData;
- (void)handleMouseTracking;
- (void)handleDoubleClick;
- (void)handleSingleClickWithSelectionChange:(BOOL)aChange;
- (void)setActive:(BOOL)aActive;
- (BOOL)isActive;
- (id)dataProvider;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

