#import "HSObjectListPalettePreviewView.h"
@implementation HSObjectListPalettePreviewView
+ (id)retrieveRendererFromObject:(id)aObject
{
    return [[aObject queryHyperInterface:@protocol(HSObjectListPaletteVisualization)] queryRenderer];
}
@end
