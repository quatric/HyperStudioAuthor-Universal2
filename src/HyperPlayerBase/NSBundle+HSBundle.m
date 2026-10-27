#import "NSBundle+HSBundle.h"
@implementation NSBundle (HSBundle)
- (id)HS_buildVersion
{
    // "5.2.1534" -> "5"; short versions are returned whole
    NSString *version = [self objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    if ([version length] > 5)
        version = [[version componentsSeparatedByString:@"."] objectAtIndex:0];
    return version;
}
@end
