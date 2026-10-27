#import "HSSwitchCell.h"

@implementation HSSwitchCell

- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp
{
    return [super trackMouse:aMouse inRect:[self imageRectForBounds:aRect] ofView:aView untilMouseUp:aUp];
}

- (NSRect)imageRectForBounds:(NSRect)aBounds
{
    if (_currentCell == self)
        return [super imageRectForBounds:aBounds];
    return NSZeroRect;
}

- (void)setObjectValue:(id)aValue
{
    if ([aValue isKindOfClass:[NSNumber class]]) {
        _currentCell = self;
        [self setState:[aValue intValue]];
    }
    else {
        _currentCell = [self textFieldCell];
        [[self currentCell] setObjectValue:aValue];
    }
}

- (void)setFont:(id)aFont
{
    if ([self currentCell] == self)
        [super setFont:aFont];
    else
        [[self currentCell] setFont:aFont];
}

- (id)copyWithZone:(NSZone *)aZone
{
    HSSwitchCell *copy = [[HSSwitchCell allocWithZone:aZone] init];
    [copy applyDefaultSettings];
    [copy setControlSize:[self controlSize]];
    return copy;
}

- (void)highlight:(BOOL)aHighlight withFrame:(NSRect)aFrame inView:(id)aView
{
    if ([self currentCell] == self)
        [super highlight:aHighlight withFrame:aFrame inView:aView];
    else
        [[self currentCell] highlight:aHighlight withFrame:aFrame inView:aView];
}

- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    if ([self currentCell] == self)
        [super drawWithFrame:aFrame inView:aView];
    else
        [[self currentCell] drawWithFrame:aFrame inView:aView];
}

- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    if ([self currentCell] == self)
        [super drawInteriorWithFrame:aFrame inView:aView];
    else
        [[self currentCell] drawInteriorWithFrame:aFrame inView:aView];
}

- (id)currentCell
{
    if (_currentCell == nil)
        _currentCell = self;
    return _currentCell;
}

- (id)textFieldCell
{
    if (_textFieldCell == nil)
        _textFieldCell = [NSTextFieldCell new];
    return _textFieldCell;
}

- (id)init
{
    self = [super init];
    if (self != nil)
        [self setButtonType:NSButtonTypeSwitch];
    return self;
}

- (void)dealloc
{
    [_textFieldCell release];
    [super dealloc];
}

@end
