#import "HyperPlayerBasePrefix.h"


@interface HSUniqueNameGenerator : NSObject
{
    id _dataSource;
    SEL _itemNameAccessor;
    NSString *_uniqueSeparator;
    id<HSUniqueNaming> _namingStrategy;
}
- (BOOL)containsItemWithName:(id)aName omittingItemIdenticalTo:(id)aTo;
- (void)setNamingStrategy:(id)aStrategy;
- (id)namingStrategy;
- (void)setUniqueSeparator:(id)aSeparator;
- (id)uniqueSeparator;
- (id)uniqueName:(id)aName;
- (id)uniqueName:(id)aName omittingItemIdenticalTo:(id)aTo;
- (void)dealloc;
- (id)initWithDataSource:(id)aSource itemNameSelector:(SEL)aSelector separator:(id)aSeparator;
- (id)initWithDataSource:(id)aSource itemNameSelector:(SEL)aSelector;
- (id)initWithDataSource:(id)aSource;
- (id)init;
@end

