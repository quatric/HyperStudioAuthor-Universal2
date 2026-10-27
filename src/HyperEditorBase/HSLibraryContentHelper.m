#import "HSLibraryContentHelper.h"

@implementation HSLibraryContentHelper

// Files from the built-in animations library become animations.
+ (BOOL)shouldFileBeCreatedAsAnimationAtPath:(id)aPath
{
    NSString *animations = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Media Library/Animation/Animations"] stringByResolvingSymlinksInPath];
    if (animations == nil)
        return NO;
    return [[aPath stringByResolvingSymlinksInPath] hasPrefix:animations];
}

@end
