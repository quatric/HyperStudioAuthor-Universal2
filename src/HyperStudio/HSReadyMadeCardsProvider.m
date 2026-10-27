#import "HSReadyMadeCardsProvider.h"

static HSReadyMadeCardsProvider *sharedProvider;

static NSInteger HSCompareReadyMadeCardNames(id aName, id aOther, void *aContext)
{
    return [aName compare:aOther options:NSNumericSearch];
}

@implementation HSReadyMadeCardsProvider

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized (self) {
        if (sharedProvider == nil) {
            sharedProvider = [super allocWithZone:aZone];
            return sharedProvider;
        }
    }
    return nil;
}

+ (id)sharedReadyMadeCardsProvider
{
    @synchronized (self) {
        if (sharedProvider == nil)
            [[self alloc] init];
    }
    return sharedProvider;
}

- (void)awakeFromNib
{
    [self addReadyMadeCardsItems];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(readyMadeCardsChanged:) name:@"HSReadyMadeCardsDidChange" object:nil];
}

- (void)readyMadeCardsChanged:(id)aChanged
{
    [self removeReadyMadeCardsItems];
    [self addReadyMadeCardsItems];
}

// The first three menu items are fixed; everything after them was added from disk.
- (void)removeReadyMadeCardsItems
{
    for (NSInteger index = [_readyMadeCardsMenu numberOfItems] - 1; index > 2; index--)
        [_readyMadeCardsMenu removeItemAtIndex:index];
}

- (void)addReadyMadeCardsItems
{
    HSPathsProvider *paths = [HSPathsProvider sharedPathsProvider];
    [self addReadyMadeCardsItemsAtPath:[paths readyMadeCardsFolder] toMenu:_readyMadeCardsMenu recursively:YES withSeparator:NO];
    NSString *supportFolder = [paths readyMadeCardsSupportFolder];
    if ([[NSFileManager defaultManager] fileExistsAtPath:supportFolder])
        [self addReadyMadeCardsItemsAtPath:supportFolder toMenu:_readyMadeCardsMenu recursively:YES withSeparator:YES];
    NSString *localSupportFolder = [[HSPathsProvider sharedPathsProvider] readyMadeCardsLocalSupportFolder];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localSupportFolder])
        [self addReadyMadeCardsItemsAtPath:localSupportFolder toMenu:_readyMadeCardsMenu recursively:YES withSeparator:YES];
}

- (void)addReadyMadeCardsItemsAtPath:(id)aPath toMenu:(id)aMenu recursively:(BOOL)aRecursively withSeparator:(BOOL)aSeparator
{
    NSInteger insertIndex = [aMenu numberOfItems];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *names = [[fileManager contentsOfDirectoryAtPath:aPath error:NULL] sortedArrayUsingFunction:HSCompareReadyMadeCardNames context:NULL];
    BOOL added = NO;
    for (NSString *name in names) {
        NSString *path = [aPath stringByAppendingPathComponent:name];
        NSString *resolved = [fileManager hyperResolveAliasAtPath:path];
        if (resolved != nil) {
            name = [resolved lastPathComponent];
            path = resolved;
        }
        BOOL isDirectory = NO;
        [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
        if (isDirectory && aRecursively) {
            NSMenu *submenu = [[NSMenu alloc] initWithTitle:name];
            [self addReadyMadeCardsItemsAtPath:path toMenu:submenu recursively:YES withSeparator:NO];
            if ([submenu numberOfItems] != 0) {
                NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:name action:NULL keyEquivalent:@""];
                [item setSubmenu:submenu];
                [aMenu addItem:item];
                [item release];
                added = YES;
            }
            [submenu release];
            continue;
        }
        NSString *extension = [path pathExtension];
        NSString *fileType = [fileManager hyperFileTypeAtPath:path];
        if (![extension isEqualToString:@"stack"] && ![extension isEqualToString:@"stk"] && ![fileType isEqualToString:@"Stak"])
            continue;
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[name stringByDeletingPathExtension] action:@selector(addReadyMadeCards:) keyEquivalent:@""];
        [item setRepresentedObject:path];
        [aMenu addItem:item];
        [item release];
        added = YES;
    }
    if (aSeparator && added)
        [aMenu insertItem:[NSMenuItem separatorItem] atIndex:insertIndex];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)autorelease
{
    return self;
}

- (oneway void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
