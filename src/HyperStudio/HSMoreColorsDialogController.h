#import "HyperStudioPrefix.h"


@interface HSMoreColorsDialogController : HSGenericModalController
{
    HSBigColorMatrix *_matrix;
    HSColorSwatchView *_sampleView;
    int _initialRow;
    int _initialColumn;
}
- (void)willCloseWindow;
- (void)willShowWindow;
- (id)nibName;
- (NSInteger)selectedColumn;
- (NSInteger)selectedRow;
- (id)initWithRow:(NSInteger)aRow column:(NSInteger)aColumn;
@end

