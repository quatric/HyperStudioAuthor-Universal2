#import "HSArrowTool.h"

@implementation HSArrowTool

- (BOOL)shouldResetToolOnSelectObjects
{
    return NO;
}

- (BOOL)preservesActiveInPlaceEditors
{
    return YES;
}

- (BOOL)allowsActiveInPlaceEditors
{
    return YES;
}

- (BOOL)allowsSelection
{
    return YES;
}

@end
