#import "HSButtonObjectBackgroundRenderlayerInPlayer.h"
@implementation HSButtonObjectBackgroundRenderlayerInPlayer
- (id)preferredBackgroundRenderLayer
{
    NSString *style = [(id<HSButtonObjectAttributes>)[self buttonAttributes] backgroundStyle];
    Class layerClass;
    if ([style isEqualToString:@"HSButtonObjectSystemBackgroundStyle"])
        layerClass = [HSBackgroundCellRenderLayer class];
    else
        // the original also compares with HSButtonObjectShapeBackgroundStyle,
        // but makes the shape layer whatever the result
        layerClass = [HSButtonObjectShapeBackgroundRenderlayerInPlayer class];
    return [[[layerClass alloc] initWithHyperObject:[self hyperObject]] autorelease];
}
@end
