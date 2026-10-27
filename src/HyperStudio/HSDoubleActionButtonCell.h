#import "HyperStudioPrefix.h"


@interface HSDoubleActionButtonCell : NSButtonCell
{
    SEL _doubleAction;
    BOOL _isDoubleClicked;
}
- (void)drawDoubleClickedInRect:(NSRect)aRect;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp;
- (void)setDoubleClicked:(BOOL)aClicked;
- (BOOL)isDoubleClicked;
- (SEL)doubleAction;
- (void)setDoubleAction:(SEL)aAction;
@end

