#import "HSEmptyStoryboardItem.h"

@implementation HSEmptyStoryboardItem

+ (id)emptyImage
{
    static NSImage *emptyImage = nil;
    if (emptyImage == nil)
        emptyImage = [[NSImage alloc] init];
    return emptyImage;
}

- (id)cachedItemImage
{
    return [HSEmptyStoryboardItem emptyImage];
}

@end
