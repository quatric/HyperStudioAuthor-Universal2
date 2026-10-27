#import "HSTransparentGroupButton.h"

@implementation HSTransparentGroupButton

+ (Class)cellClass
{
    return [NSActionCell class];
}

- (BOOL)acceptsFirstResponder
{
    return NO;
}

- (void)mouseUp:(id)aUp
{
    [self sendAction:[self action] to:[self target]];
}

- (void)mouseDown:(id)aDown
{
}

- (void)awakeFromNib
{
    [self setCell:[NSCell hyperCellOfClass:[HSTransparentGroupButton cellClass] withCell:[self cell]]];
}

@end
