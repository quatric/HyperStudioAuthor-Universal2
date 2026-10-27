#import "HyperStudioPrefix.h"


@interface HSDoubleActionSegmentedCell : HSSegmentedCell
{
    SEL _doubleAction;
    BOOL _isDoubleClicked;
}
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp;
- (void)setDoubleClicked:(BOOL)aClicked;
- (BOOL)isDoubleClicked;
- (SEL)doubleAction;
- (void)setDoubleAction:(SEL)aAction;
@end

