#import "HSButton.h"

@implementation HSButton

+ (Class)cellClass
{
    return [SMKBackgroundButtonCell class];
}

- (void)awakeFromNib
{
    [self setCell:[NSCell hyperCellOfClass:[HSButton cellClass] withCell:[self cell]]];
    HSButtonBackgroundRenderer *renderer = [HSButtonBackgroundRenderer new];
    [[self cell] setBackgroundRenderer:renderer];
    [renderer release];
}

@end
