#import "PHelper.h"

@implementation PHelper

// Every supported system is past Tiger (Gestalt's system version > 0x103f).
+ (BOOL)isTigerOrGreater
{
    return YES;
}

@end
