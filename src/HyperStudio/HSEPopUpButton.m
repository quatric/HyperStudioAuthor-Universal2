#import "HSEPopUpButton.h"

@implementation HSEPopUpButton

// Typing past the menu's items raises a range exception; it is ignored.
- (void)keyDown:(id)aDown
{
    @try {
        [super keyDown:aDown];
    } @catch (NSException *exception) {
        if (![[exception name] isEqualToString:NSRangeException])
            [exception raise];
    }
}

@end
