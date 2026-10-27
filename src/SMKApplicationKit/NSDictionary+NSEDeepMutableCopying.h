#import "SMKApplicationKitPrefix.h"


@interface NSDictionary (NSEDeepMutableCopying) <NSEDeepCopying, NSEDeepMutableCopying>
- (id)NSE_mutableCopyToDepth:(NSUInteger)aDepth zone:(NSZone *)aZone;
- (id)NSE_deepMutableCopy;
- (id)NSE_copyToDepth:(NSUInteger)aDepth zone:(NSZone *)aZone;
- (id)NSE_deepCopy;
@end

@interface NSDictionary (NSEDictionaryLoading)
+ (void)load;
@end

