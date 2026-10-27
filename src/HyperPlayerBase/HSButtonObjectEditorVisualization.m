#import "HSButtonObjectEditorVisualization.h"
@implementation HSButtonObjectEditorVisualization
- (Class)backgroundRenderLayerClass
{
    return [HSButtonObjectBackgroundRenderlayerInEditor class];
}
@end
