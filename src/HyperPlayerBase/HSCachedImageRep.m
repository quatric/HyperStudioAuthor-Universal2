#import "HSCachedImageRep.h"
// An image rep wrapping a cached (window) image rep; not archived.
@implementation HSCachedImageRep
- (BOOL)draw
{
    return [_cachedImageRep draw];
}
- (id)copyWithZone:(NSZone *)aZone
{
    NSCachedImageRep *copy = [_cachedImageRep copy];
    if (copy == nil)
        return nil;
    HSCachedImageRep *result = [[HSCachedImageRep alloc] initWithCachedImageRep:copy];
    [copy release];
    return result;
}
- (void)dealloc
{
    [_cachedImageRep release];
    [super dealloc];
}
- (void)encodeWithCoder:(id)aCoder
{
}
- (id)initWithCoder:(id)aCoder
{
    [self release];
    return nil;
}
- (id)initWithCachedImageRep:(id)aRep
{
    self = [super init];
    if (self != nil) {
        _cachedImageRep = [aRep retain];
        [super setSize:[_cachedImageRep size]];
        [super setAlpha:[_cachedImageRep hasAlpha]];
        [super setOpaque:[_cachedImageRep isOpaque]];
        [super setColorSpaceName:[_cachedImageRep colorSpaceName]];
        [super setBitsPerSample:[_cachedImageRep bitsPerSample]];
        [super setPixelsWide:[_cachedImageRep pixelsWide]];
        [super setPixelsHigh:[_cachedImageRep pixelsHigh]];
    }
    return self;
}
- (id)initWithWindow:(id)aWindow rect:(NSRect)aRect
{
    NSCachedImageRep *rep = [[NSCachedImageRep alloc] initWithWindow:aWindow rect:aRect];
    self = [self initWithCachedImageRep:rep];
    [rep release];
    return self;
}
- (id)init
{
    return [self initWithCachedImageRep:nil];
}
@end
