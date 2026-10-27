#import "HSDoubleActionSegmentedCell.h"

@implementation HSDoubleActionSegmentedCell

- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    [super drawInteriorWithFrame:aFrame inView:aView];
}

- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp
{
    BOOL sendsDoubleAction = NO;
    BOOL result;

    if ([(NSEvent *)aMouse type] == NSEventTypeLeftMouseDown) {
        if ([aMouse clickCount] == 2) {
            if (_doubleAction != NULL) {
                [self setDoubleClicked:YES];
                sendsDoubleAction = YES;
            }
        }
        else
            [self setDoubleClicked:NO];
    }
    result = [super trackMouse:aMouse inRect:aRect ofView:aView untilMouseUp:aUp];
    if (sendsDoubleAction)
        [NSApp sendAction:_doubleAction to:[self target] from:aView];
    return result;
}

- (void)setDoubleClicked:(BOOL)aClicked
{
    if (_isDoubleClicked != aClicked) {
        _isDoubleClicked = aClicked;
        [[self controlView] setNeedsDisplay:YES];
    }
}

- (BOOL)isDoubleClicked
{
    return _isDoubleClicked;
}

- (SEL)doubleAction
{
    return _doubleAction;
}

- (void)setDoubleAction:(SEL)aAction
{
    _doubleAction = aAction;
}

@end
