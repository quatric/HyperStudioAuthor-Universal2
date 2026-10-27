#import "HyperStudioPrefix.h"
#import "HSCheckBoxCell.h"


@interface HSSwitchCell : HSCheckBoxCell
{
    NSTextFieldCell *_textFieldCell;
    NSCell *_currentCell;
}
- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp;
- (NSRect)imageRectForBounds:(NSRect)aBounds;
- (void)setObjectValue:(id)aValue;
- (void)setFont:(id)aFont;
- (id)copyWithZone:(NSZone *)aZone;
- (void)highlight:(BOOL)aHighlight withFrame:(NSRect)aFrame inView:(id)aView;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (id)currentCell;
- (id)textFieldCell;
- (id)init;
- (void)dealloc;
@end

