#import "HSImagePopUpButton.h"

@implementation HSImagePopUpButton

+ (Class)cellClass
{
    return [HSImagePopUpButtonCell class];
}

- (void)awakeFromNib
{
    [self setCell:[NSCell hyperCellOfClass:[HSImagePopUpButton cellClass] withCell:[self cell]]];
    [[self cell] setBackgroundRenderer:[[HSPopUpButtonBackgroundRender new] autorelease]];
}

@end
