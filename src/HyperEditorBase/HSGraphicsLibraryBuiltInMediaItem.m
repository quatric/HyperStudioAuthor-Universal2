#import "HSGraphicsLibraryBuiltInMediaItem.h"

// A library item wrapping another (its subitems wrapped too), with the
// media type of its library.

@implementation HSGraphicsLibraryBuiltInMediaItem

+ (id)itemWithMediaItem:(id)aItem mediaType:(id)aType
{
    return [[[HSGraphicsLibraryBuiltInMediaItem alloc] initWithMediaItem:aItem mediaType:aType] autorelease];
}

- (id)children
{
    if (_children == nil) {
        NSInteger count = [_mediaItem numberOfSubitems];
        for (NSInteger i = 0; i < count; i++) {
            id item = [HSGraphicsLibraryBuiltInMediaItem itemWithMediaItem:[_mediaItem subitemAtIndex:i] mediaType:[self mediaType]];
            if (item == nil)
                continue;
            if (_children == nil)
                _children = [[NSMutableArray alloc] initWithCapacity:0];
            [_children addObject:item];
        }
    }
    return _children;
}

- (id)initWithMediaItem:(id)aItem mediaType:(id)aType
{
    if ((self = [super init])) {
        _mediaItem = [aItem retain];
        _mediaType = [aType retain];
    }
    return self;
}

- (id)subitemAtIndex:(NSUInteger)aIndex
{
    NSArray *children = [self children];
    return aIndex < [children count] ? [children objectAtIndex:aIndex] : nil;
}

- (NSUInteger)numberOfSubitems
{
    return [[self children] count];
}

- (id)actionTarget
{
    return [_mediaItem actionTarget];
}

- (SEL)actionSelector
{
    return [_mediaItem actionSelector];
}

- (id)actionImage
{
    return [_mediaItem actionImage];
}

- (id)displayName
{
    return [_mediaItem displayName];
}

- (id)icon
{
    return [_mediaItem icon];
}

- (id)mediaItem
{
    return _mediaItem;
}

- (id)mediaType
{
    return _mediaType;
}

- (void)dealloc
{
    [_mediaItem release];
    [_mediaType release];
    [_children release];
    [super dealloc];
}

@end
