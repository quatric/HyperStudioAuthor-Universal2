#import "HSComboBox.h"

@implementation HSComboBox

// The arrow keys step through the items without opening the list.
- (BOOL)textView:(id)aView doCommandBySelector:(SEL)aSelector
{
    NSInteger index;
    if (aSelector == @selector(moveDown:)) {
        index = [self indexOfSelectedItem];
        if (index + 1 < [self numberOfItems])
            index++;
    } else if (aSelector == @selector(moveUp:)) {
        index = [self indexOfSelectedItem];
        index = index < 1 ? 0 : index - 1;
    } else
        return NO;
    [self selectItemAtIndex:index];
    return NO;
}

@end
