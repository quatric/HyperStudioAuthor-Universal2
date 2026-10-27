#import "SMKApplicationKitPrefix.h"


@interface NSWorkspace (NSEWorkspace)
- (BOOL)NSE_launchApplication:(id)aApplication options:(NSUInteger)aOptions configuration:(id)aConfiguration error:(id *)aError;
@end

