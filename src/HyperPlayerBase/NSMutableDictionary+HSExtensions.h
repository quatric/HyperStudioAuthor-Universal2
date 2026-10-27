#import "HyperPlayerBasePrefix.h"


@interface NSMutableDictionary (HSExtensions)
- (void)refreshHyperUIDsAndIgnoreUIDsFromSet:(id)aSet;
- (void)refreshHyperUIDsWithReplacedUIDs:(id)aDs ignoreUIDs:(id)aDs2;
@end

@interface NSDictionary (HSExtensions)
- (id)hyperKeysOfDifferencesWithDictionary:(id)aDictionary;
- (BOOL)isHyperIdenticalToDictionary:(id)aDictionary;
@end

