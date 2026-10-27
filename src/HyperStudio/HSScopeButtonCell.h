#import "HyperStudioPrefix.h"


@interface HSScopeButtonCell : NSButtonCell
{
    NSTextFieldCell *_textFieldCell;
    BOOL _isMouseInside;
}
- (void)mouseExited:(id)aExited;
- (void)mouseEntered:(id)aEntered;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)dealloc;
- (id)textFieldCell;
@end

