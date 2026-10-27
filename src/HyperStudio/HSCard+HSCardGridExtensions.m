#import "HSCard+HSCardGridExtensions.h"

@implementation HSCard (HSCardGridExtensions)

- (id)editorLayoutGrid
{
    return [[[self stack] gridSettings] layoutGrid];
}

@end
