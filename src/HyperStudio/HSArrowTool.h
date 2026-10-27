#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSArrowTool : HSTool
{
}
- (BOOL)shouldResetToolOnSelectObjects;
- (BOOL)preservesActiveInPlaceEditors;
- (BOOL)allowsActiveInPlaceEditors;
- (BOOL)allowsSelection;
@end

