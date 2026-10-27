#import "HSUserObjectInPlayerPreviewView.h"
@implementation HSUserObjectInPlayerPreviewView
+ (id)retrieveRendererFromObject:(id)aObject
{
    return [[aObject queryHyperInterface:@protocol(HSPlayerVisualization)] queryRenderer];
}
@end
