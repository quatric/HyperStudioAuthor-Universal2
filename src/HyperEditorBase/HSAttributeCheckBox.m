#import "HSAttributeCheckBox.h"

@implementation HSAttributeCheckBox

// Clicking a mixed check box makes it a plain one.
- (BOOL)sendAction:(SEL)aAction to:(id)aTo
{
    if (_hasMultipleValues)
        [self setHasMultipleValues:NO];
    return [super sendAction:aAction to:aTo];
}

- (void)setState:(NSInteger)aState
{
    if (_hasMultipleValues)
        aState = [[HSMultipleUIValue multipleUIValue] stateValue];
    [super setState:aState];
    [super setNeedsDisplay:YES];
}

- (void)setHasMultipleValues:(BOOL)aValues
{
    if (_hasMultipleValues != aValues) {
        [self setAllowsMixedState:aValues];
        if (aValues)
            [self setState:[[HSMultipleUIValue multipleUIValue] stateValue]];
        _hasMultipleValues = aValues;
    }
}

- (BOOL)hasMultipleValues
{
    return _hasMultipleValues;
}

@end
