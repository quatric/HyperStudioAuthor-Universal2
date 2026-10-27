#import "HSChoosableItemProvider.h"

@implementation HSChoosableItemProvider

- (BOOL)shouldDisplayLabels
{
    return _shouldDisplayLabels;
}

- (void)setShouldDisplayLabels:(BOOL)aLabels
{
    _shouldDisplayLabels = aLabels;
}

- (id)dataSource
{
    return _dataSource;
}

- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}

- (id)iconAtIndex:(NSInteger)aIndex inIconsGrid:(id)aGrid
{
    return [self imageForChoosableItemAtIndex:aIndex];
}

- (NSUInteger)iconsCountInIconsGrid:(id)aGrid
{
    return [[self dataSource] countOfChoosableItems];
}

- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt
{
    return [self imageForChoosableItemAtIndex:aAt];
}

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    if (!_shouldDisplayLabels)
        return nil;
    return [[self dataSource] labelForChoosableItemAtIndex:aAt];
}

- (NSInteger)numberOfItemsInGridControl:(id)aControl
{
    return [[self dataSource] countOfChoosableItems];
}

- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    if ([[aColumn identifier] isEqualToString:@"ImageColumn"])
        return [self imageForChoosableItemAtIndex:aRow];
    if ([[aColumn identifier] isEqualToString:@"StringColumn"])
        return [[self dataSource] labelForChoosableItemAtIndex:aRow];
    if (![[aColumn identifier] isEqualToString:@"DurationColumn"])
        return nil;
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    HSMovie *movie = [[[HSMovie alloc] initWithURL:[[self dataSource] URLForChoosableItemAtIndex:aRow] error:NULL] autorelease];
    unsigned int seconds = movie != nil ? (unsigned int)[movie duration] : 0;
    [pool release];
    return [NSCalendarDate dateWithYear:0 month:0 day:0 hour:0 minute:0 second:seconds timeZone:nil];
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return [[self dataSource] countOfChoosableItems];
}

- (id)imageForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return [[[self dataSource] mediaForChoosableItemAtIndex:aIndex] image];
}

- (id)initWithDestinationObjectClass:(Class)aClass
{
    self = [super init];
    if (self != nil)
        _objectClass = aClass;
    return self;
}

@end
