#import "HSOldFormatDocument+HSOtherRecreation.h"
@implementation HSOldFormatDocument (HSOtherRecreation)
- (void)processPostCorrection
{
    [self processPostCorrectionActions];
    [self processPostCorrectionStackCursor];
    [self processPostCorrectionNoClickAndDropOff];
}
@end
