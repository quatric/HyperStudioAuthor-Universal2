#import "HSSystemTextViewVisualization.h"
@implementation HSSystemTextViewVisualization
- (id)precreateSystemViewRenderLayerForVisualizationOptions:(id)aOptions
{
    return [[HSSystemTextViewRenderLayer alloc] initWithHyperObject:[self hyperObject] cachingPolicy:0
                                                drawPlaceholderView:[self drawsPlaceholderView]];
}
- (BOOL)ignoresTransparency
{
    return NO;
}
@end
