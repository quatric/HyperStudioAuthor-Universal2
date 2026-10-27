#import "HSButtonObjectBackgroundRenderlayerInEditor.h"
@implementation HSButtonObjectBackgroundRenderlayerInEditor
- (id)preferredBackgroundRenderLayer
{
    NSString *style = [(id<HSButtonObjectAttributes>)[self buttonAttributes] backgroundStyle];
    Class layerClass;
    if ([style isEqualToString:@"HSButtonObjectSystemBackgroundStyle"])
        layerClass = [HSBackgroundCellRenderLayerInEditor class];
    else
        // the original also compares with HSButtonObjectShapeBackgroundStyle,
        // but makes the shape layer whatever the result
        layerClass = [HSButtonObjectShapeBackgroundRenderlayerInEditor class];
    return [[[layerClass alloc] initWithHyperObject:[self hyperObject]] autorelease];
}
@end
