#import "HyperPlayerBasePrefix.h"


@interface HSExecutableResourceProvider : NSObject
{
    NSBundle *_executableBundle;
}
+ (id)sharedInstance;
- (id)objectForInfoDictionaryKey:(id)aKey;
- (id)localizedStringForKey:(id)aKey value:(id)aValue table:(id)aTable;
- (void)setExecutableBundle:(id)aBundle;
- (void)dealloc;
@end

