#import "HyperPlayerBasePrefix.h"


@interface NSFileWrapper (HSExtensions)
- (id)hyperWrapperContents;
- (id)hyperWrapperContentsWithRootWrapperPath:(id)aPath;
- (id)hyperWrapperForPath:(id)aPath;
- (id)originalPreferredHyperFilename;
- (id)initWithHyperDictionary:(id)aDictionary;
- (id)hyperDictionaryRepresentation;
@end

