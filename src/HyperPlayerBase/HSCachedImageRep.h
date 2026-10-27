#import "HyperPlayerBasePrefix.h"


@interface HSCachedImageRep : NSImageRep
{
    NSCachedImageRep *_cachedImageRep;
}
- (BOOL)draw;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (id)initWithCachedImageRep:(id)aRep;
- (id)initWithWindow:(id)aWindow rect:(NSRect)aRect;
- (id)init;
@end

