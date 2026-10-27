#import "HSOldFormatDocument+HSObjectRecreation.h"
@implementation HSOldFormatDocument (HSObjectRecreation)
- (void)processBy_itemHeader_itemstatflags_WithParser:(id)aParser value:(id)aValue parameters:(id)aParameters
{
    unsigned short flags = [aValue unsignedShortValue];
    _isSharedItem = (flags >> 4) & 1;
    _isHiddenItem = (flags >> 5) & 1;
    _isLocked = (flags & 8) != 0;
}
@end
