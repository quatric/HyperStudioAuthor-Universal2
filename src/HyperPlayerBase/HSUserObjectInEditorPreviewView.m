#import "HSUserObjectInEditorPreviewView.h"
@implementation HSUserObjectInEditorPreviewView
+ (id)retrieveRendererFromObject:(id)aObject
{
    return [[aObject queryHyperInterface:@protocol(HSEditorVisualization)] queryRenderer];
}
@end
