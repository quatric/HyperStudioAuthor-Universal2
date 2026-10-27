#import "HSExecutableResourceProvider.h"
@implementation HSExecutableResourceProvider
static HSExecutableResourceProvider *sSharedInstance;
+ (id)sharedInstance
{
    if (sSharedInstance == nil)
        sSharedInstance = [HSExecutableResourceProvider new];
    return sSharedInstance;
}
// The executable bundle when one was set, the main bundle otherwise.
- (id)objectForInfoDictionaryKey:(id)aKey
{
    NSBundle *bundle = _executableBundle != nil ? _executableBundle : [NSBundle mainBundle];
    return [bundle objectForInfoDictionaryKey:aKey];
}
- (id)localizedStringForKey:(id)aKey value:(id)aValue table:(id)aTable
{
    NSBundle *bundle = _executableBundle != nil ? _executableBundle : [NSBundle mainBundle];
    return [bundle localizedStringForKey:aKey value:aValue table:aTable];
}
- (void)setExecutableBundle:(id)aBundle
{
    [aBundle retain];
    [_executableBundle release];
    _executableBundle = aBundle;
}
- (void)dealloc
{
    [_executableBundle release];
    [super dealloc];
}
@end
