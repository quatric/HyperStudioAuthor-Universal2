#import "HSOpaqueView.h"

@implementation HSOpaqueView

- (BOOL)mouseDownCanMoveWindow
{
    return YES;
}

- (BOOL)isOpaque
{
    return YES;
}

@end
