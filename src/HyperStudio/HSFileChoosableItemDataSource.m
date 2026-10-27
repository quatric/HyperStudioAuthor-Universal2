#import "HSFileChoosableItemDataSource.h"

@implementation HSFileChoosableItemDataSource

- (void)updateChoosableItemsIfNeeded
{
}

- (id)URLForChoosableItemAtIndex:(NSUInteger)aIndex
{
    NSString *path = [self path];
    if (path == nil)
        return nil;
    return [NSURL fileURLWithPath:path];
}

- (id)labelForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return [[self media] mediaName];
}

- (id)mediaForChoosableItemAtIndex:(NSUInteger)aIndex
{
    return [self media];
}

- (NSUInteger)countOfChoosableItems
{
    return [[self path] length] != 0;
}

- (id)media
{
    if (_isPathChanged) {
        // Fix: the original stored the autoreleased media without a retain.
        [_media release];
        _media = [[HSNewMedia mediaWithPath:[self path]] retain];
        _isPathChanged = NO;
    }
    return _media;
}

- (id)path
{
    return _path;
}

- (void)setPath:(id)aPath
{
    if (![aPath isEqualToString:_path]) {
        [_path release];
        _path = [aPath retain];
        _isPathChanged = YES;
    }
}

- (void)dealloc
{
    [_path release];
    [_media release];
    [super dealloc];
}

- (id)initWithPath:(id)aPath
{
    self = [super init];
    if (self != nil)
        [self setPath:aPath];
    return self;
}

@end
