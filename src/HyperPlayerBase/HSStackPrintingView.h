#import "HyperPlayerBasePrefix.h"
#import "HSPrintingView.h"


@interface HSStackPrintingView : HSPrintingView
{
    NSArray *_cards;
    BOOL _dontCenterPrintout;
    BOOL _inPlayerMode;
}
- (void)drawContent:(NSRect)aContent;
- (NSUInteger)countOfPages;
- (void)preparePrinting;
- (void)setInPlayerMode:(BOOL)aMode;
- (void)setDontCenterPrintout:(BOOL)aPrintout;
- (void)dealloc;
- (id)initWithCards:(id)aCards;
- (id)initWithStack:(id)aStack;
@end

