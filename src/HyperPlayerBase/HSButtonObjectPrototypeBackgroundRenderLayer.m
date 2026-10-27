#import "HSButtonObjectPrototypeBackgroundRenderLayer.h"
@implementation HSButtonObjectPrototypeBackgroundRenderLayer
- (id)preferredBackgroundRenderLayer
{
    NSString *style = [(id<HSButtonObjectAttributes>)_buttonAttributes backgroundStyle];
    // prototypes draw only the system style; a shape style draws nothing
    if (![style isEqualToString:@"HSButtonObjectSystemBackgroundStyle"])
        return nil;
    return [[[HSBackgroundCellRenderLayer alloc] initWithHyperObject:[self hyperObject]] autorelease];
}
@end
