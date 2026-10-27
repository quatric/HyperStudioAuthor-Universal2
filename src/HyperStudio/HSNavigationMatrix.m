#import "HSNavigationMatrix.h"

@implementation HSNavigationMatrix

- (void)navigateBackward
{
    NSInteger row = [self selectedRow];
    NSInteger column = [self selectedColumn];
    if (column < 1) {
        column = [self numberOfColumns];
        if (row < 1)
            row = [self numberOfRows];
        row--;
    }
    [[self cellAtRow:row column:column - 1] performClick:self];
}

- (void)navigateForward
{
    NSInteger row = [self selectedRow];
    NSInteger column = [self selectedColumn];
    if (column < [self numberOfColumns] - 1) {
        column++;
    } else {
        column = 0;
        row = row < [self numberOfRows] - 1 ? row + 1 : 0;
    }
    [[self cellAtRow:row column:column] performClick:self];
}

- (void)setBackwardKeyEquivalent:(id)aEquivalent
{
    if (![_backwardKeyEquivalent isEqual:aEquivalent]) {
        [_backwardKeyEquivalent release];
        _backwardKeyEquivalent = [aEquivalent retain];
    }
}

- (id)backwardKeyEquivalent
{
    return _backwardKeyEquivalent;
}

- (void)setForwardKeyEquivalent:(id)aEquivalent
{
    if (![_forwardKeyEquivalent isEqual:aEquivalent]) {
        [_forwardKeyEquivalent release];
        _forwardKeyEquivalent = [aEquivalent retain];
    }
}

- (id)forwardKeyEquivalent
{
    return _forwardKeyEquivalent;
}

- (BOOL)performKeyEquivalent:(id)aEquivalent
{
    id mapping = [HSKeyMapping keyMappingForEvent:aEquivalent];
    if (![mapping isEqual:_forwardKeyEquivalent] && ![mapping isEqual:_backwardKeyEquivalent])
        return [super performKeyEquivalent:aEquivalent];
    if ([mapping isEqual:_forwardKeyEquivalent])
        [self navigateForward];
    else
        [self navigateBackward];
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)dealloc
{
    [_forwardKeyEquivalent release];
    [_backwardKeyEquivalent release];
    [super dealloc];
}

@end
