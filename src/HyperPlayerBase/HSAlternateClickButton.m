#import "HSAlternateClickButton.h"
@implementation HSAlternateClickButton
+ (Class)cellClass
{
    return [NSButtonCell class];
}
- (void)setAlternateAction:(SEL)aAction
{
    if (_alternateAction != aAction)
        _alternateAction = aAction;
}
- (SEL)alternateAction
{
    return _alternateAction;
}
// An Option-click inside the button sends the alternate action instead.
- (void)mouseDown:(id)aDown
{
    SEL savedAction = NULL;
    BOOL swapped = NO;
    NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    if (NSPointInRect(point, [self bounds]) && ([aDown modifierFlags] & NSEventModifierFlagOption) != 0
        && _alternateAction != NULL) {
        savedAction = [self action];
        [self setAction:_alternateAction];
        swapped = YES;
    }
    [super mouseDown:aDown];
    if (swapped)
        [self setAction:savedAction];
}
- (void)dealloc
{
    [_alternateTarget release];
    [super dealloc];
}
@end
