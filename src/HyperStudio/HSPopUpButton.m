#import "HSPopUpButton.h"

@implementation HSPopUpButton

+ (Class)cellClass
{
    return [HSPopUpButtonCell class];
}

- (void)awakeFromNib
{
    [self setCell:[NSCell hyperCellOfClass:[HSPopUpButton cellClass] withCell:[self cell]]];
    [[self cell] setBackgroundRenderer:[[HSPopUpButtonBackgroundRender new] autorelease]];
}

@end
