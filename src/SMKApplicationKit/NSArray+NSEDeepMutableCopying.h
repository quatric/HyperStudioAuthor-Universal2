#import "SMKApplicationKitPrefix.h"


@interface NSArray (NSEDeepMutableCopying) <NSEDeepCopying, NSEDeepMutableCopying>
- (id)NSE_mutableCopyToDepth:(NSUInteger)aDepth zone:(NSZone *)aZone;
- (id)NSE_deepMutableCopy;
- (id)NSE_copyToDepth:(NSUInteger)aDepth zone:(NSZone *)aZone;
- (id)NSE_deepCopy;
@end

@interface NSArray (NSEArrayLoading)
+ (void)load;
@end

