#import "SMKApplicationKitPrefix.h"


@interface NSEvent (NSEEventPartial)
- (BOOL)NSE_hasModifierFlags;
@end

@interface NSEvent (NSEEventLoading)
+ (void)load;
@end

