#import "HSSystemPushButtonData.h"
@implementation HSSystemPushButtonData
- (id)templateCocoaView
{
    return [HSVisualSystemViewLoader cocoaViewWithNibName:@"VisualSystemPushButton"];
}
@end
