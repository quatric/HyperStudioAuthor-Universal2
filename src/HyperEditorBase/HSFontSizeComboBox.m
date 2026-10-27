#import "HSFontSizeComboBox.h"

@implementation HSFontSizeComboBox

// The arrow keys step through the sizes; from a typed size not in the list
// they go to the next listed size up or down from it.
- (BOOL)textView:(id)aView doCommandBySelector:(SEL)aSelector
{
    NSInteger index;
    if (aSelector == @selector(moveDown:)) {
        index = [self indexOfSelectedItem];
        if (![self usesDataSource] && index == -1) {
            NSArray *values = [self objectValues];
            for (index = [self numberOfItems] - 1; index >= 0; index--)
                if ([[values objectAtIndex:index] intValue] < [self intValue])
                    break;
        }
        if (index + 1 < [self numberOfItems])
            index++;
    } else if (aSelector == @selector(moveUp:)) {
        index = [self indexOfSelectedItem];
        if (![self usesDataSource] && index == -1) {
            NSArray *values = [self objectValues];
            NSInteger count = [self numberOfItems];
            for (index = 0; index < count; index++)
                if ([self intValue] < [[values objectAtIndex:index] intValue])
                    break;
        }
        index = index < 1 ? 0 : index - 1;
    } else
        return NO;
    [self selectItemAtIndex:index];
    return NO;
}

@end
