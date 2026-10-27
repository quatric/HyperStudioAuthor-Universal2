#import "HSActionsPaneGoBackSwitcher.h"

@implementation HSActionsPaneGoBackSwitcher

// Original quirk kept: the button is enabled when going back is not possible.
- (void)setCanGoBack:(BOOL)aBack
{
    [_goBackButton setEnabled:!aBack];
}

- (id)init
{
    return [self initWithNibName:@"ActionsPaneGoBackSwitcher"];
}

@end
