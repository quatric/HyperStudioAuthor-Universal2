#import "HSStackChoosableItemsDataSource.h"

// Orders media by name.
static NSInteger HSStackChoosableItemsCompareMediaUIDs(id aUID, id anotherUID, void *aContext)
{
    HSNewMediaAccessor *accessor = [HSNewMediaAccessor sharedMediaAccessor];
    id media = [accessor mediaForUID:aUID];
    id anotherMedia = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:anotherUID];
    return [(NSString *)[media mediaName] compare:[anotherMedia mediaName]];
}

@implementation HSStackChoosableItemsDataSource

- (void)updateChoosableItemsIfNeeded
{
    [_sortedMediaUIDs release];
    _sortedMediaUIDs = nil;
}

- (id)URLForChoosableItemAtIndex:(NSUInteger)aIndex
{
    NSString *path = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[[self sortedMediaUIDs] objectAtIndex:aIndex]] fullPathToMediaFile];
    return path ? [NSURL fileURLWithPath:path] : nil;
}

- (id)labelForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return [[self mediaForChoosableItemAtIndex:aIndex] mediaName];
}

- (id)mediaForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[[self sortedMediaUIDs] objectAtIndex:aIndex]];
}

- (NSUInteger)countOfChoosableItems
{
    return [[self sortedMediaUIDs] count];
}

- (BOOL)excludesUnusedMedia
{
    return YES;
}

- (void)setMediaGroup:(NSInteger)aGroup
{
    if (_mediaGroup != aGroup) {
        _mediaGroup = (int)aGroup;
        [_sortedMediaUIDs release];
        _sortedMediaUIDs = nil;
    }
}

- (NSInteger)mediaGroup
{
    return _mediaGroup;
}

- (id)sortedMediaUIDs
{
    if (!_sortedMediaUIDs)
        _sortedMediaUIDs = [[[[self mediaUIDs] allObjects] sortedArrayUsingFunction:HSStackChoosableItemsCompareMediaUIDs context:NULL] retain];
    return _sortedMediaUIDs;
}

- (id)mediaUIDs
{
    return [[HSNewMediaAccessor sharedMediaAccessor] allMediaUIDsForGroup:[self mediaGroup] excludeUnused:[self excludesUnusedMedia]];
}

- (void)stopObserveNotificationFromStack:(id)aStack
{
}

- (void)startObserveNotificationFromStack:(id)aStack
{
}

- (void)setStack:(id)aStack
{
    if (_stack != aStack) {
        if (_stack)
            [self stopObserveNotificationFromStack:_stack];
        [_stack release];
        _stack = [aStack retain];
        if (_stack)
            [self startObserveNotificationFromStack:_stack];
        [_sortedMediaUIDs release];
        _sortedMediaUIDs = nil;
    }
}

- (id)stack
{
    return _stack;
}

- (void)dealloc
{
    [self stopObserveNotificationFromStack:_stack];
    [_stack release];
    [super dealloc];
}

- (id)initWithStack:(id)aStack
{
    self = [super init];
    if (self)
        [self setStack:aStack];
    return self;
}

@end
