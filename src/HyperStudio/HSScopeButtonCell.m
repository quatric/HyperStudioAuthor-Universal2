#import "HSScopeButtonCell.h"

@implementation HSScopeButtonCell

- (void)mouseExited:(id)aExited
{
    _isMouseInside = NO;
    [super mouseExited:aExited];
}

- (void)mouseEntered:(id)aEntered
{
    _isMouseInside = YES;
    [super mouseEntered:aEntered];
}

// The pre-Leopard title drawing through the text field cell is dropped.
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    [super drawWithFrame:aFrame inView:aView];
}

- (void)dealloc
{
    [_textFieldCell release];
    [super dealloc];
}

- (id)textFieldCell
{
    if (_textFieldCell == nil) {
        _textFieldCell = [NSTextFieldCell new];
        [_textFieldCell setAlignment:NSTextAlignmentCenter];
        [_textFieldCell setFont:[NSFont systemFontOfSize:11.0]];
        [_textFieldCell setTitle:[self title]];
    }
    return _textFieldCell;
}

@end
