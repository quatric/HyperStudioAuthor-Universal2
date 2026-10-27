#import "HSUniqueNameGenerator.h"
// Makes a name unique among a data source's items (enumeratorForGenerator:,
// names read with the item name selector or the items themselves) by asking
// the naming strategy for step 1, 2, … until no other item has that name.
@implementation HSUniqueNameGenerator
// Items identical to the omitted one, or sharing its node data, are skipped.
- (BOOL)containsItemWithName:(id)aName omittingItemIdenticalTo:(id)aTo
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    BOOL found = NO;
    NSEnumerator *enumerator = [_dataSource enumeratorForGenerator:self];
    id item;
    while (!found && (item = [enumerator nextObject]) != nil) {
        if (item == aTo)
            continue;
        if ([item respondsToSelector:@selector(nodeData)] && [aTo respondsToSelector:@selector(nodeData)]
            && [item nodeData] == [aTo nodeData])
            continue;
        id name = _itemNameAccessor != NULL ? [item performSelector:_itemNameAccessor] : item;
        found = [name isEqual:aName];
    }
    [pool release];
    return found;
}
- (void)setNamingStrategy:(id)aStrategy
{
    if (_namingStrategy != aStrategy) {
        [_namingStrategy release];
        _namingStrategy = [aStrategy retain];
    }
}
- (id)namingStrategy
{
    if (_namingStrategy == nil)
        [self setNamingStrategy:[HSUniqueDisplayNamingStrategy defaultNamingStrategy]];
    return _namingStrategy;
}
- (void)setUniqueSeparator:(id)aSeparator
{
    if (_uniqueSeparator != aSeparator) {
        [_uniqueSeparator release];
        _uniqueSeparator = [aSeparator retain];
    }
}
- (id)uniqueSeparator
{
    return _uniqueSeparator;
}
- (id)uniqueName:(id)aName
{
    return [self uniqueName:aName omittingItemIdenticalTo:nil];
}
- (id)uniqueName:(id)aName omittingItemIdenticalTo:(id)aTo
{
    id name = aName;
    NSInteger step = 1;
    while ([self containsItemWithName:name omittingItemIdenticalTo:aTo])
        name = [[self namingStrategy] uniqueName:aName step:step++ uniqueSeparator:_uniqueSeparator];
    return name;
}
- (void)dealloc
{
    [_uniqueSeparator release];
    [_namingStrategy release];
    [super dealloc];
}
// The data source is not retained. An empty separator means " ".
- (id)initWithDataSource:(id)aSource itemNameSelector:(SEL)aSelector separator:(id)aSeparator
{
    self = [super init];
    if (self != nil) {
        _dataSource = aSource;
        _itemNameAccessor = aSelector;
        _uniqueSeparator = [([aSeparator length] != 0 ? aSeparator : @" ") retain];
    }
    return self;
}
- (id)initWithDataSource:(id)aSource itemNameSelector:(SEL)aSelector
{
    return [self initWithDataSource:aSource itemNameSelector:aSelector separator:@" "];
}
- (id)initWithDataSource:(id)aSource
{
    return [self initWithDataSource:aSource itemNameSelector:NULL];
}
- (id)init
{
    return [self initWithDataSource:nil];
}
@end
