#import "HyperStudioPrefix.h"
#import "HSTextTool.h"


@interface HSHeadlineTool : HSTextTool
{
}
+ (id)allowedEditorInterfaces;
+ (id)allowedPrototypeInterfaces;
+ (Class)userObjectClass;
- (void)setTextColor:(id)aColor;
- (id)defaultToolCursorName;
@end

