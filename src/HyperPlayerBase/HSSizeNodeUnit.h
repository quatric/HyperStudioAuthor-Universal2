#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSSizeNodeUnit : HSNodeUnit <HSSizeNodeStorage, NSObject>
{
    NSSize _size;
}
- (NSSize)roundSizeIfNeeded:(NSSize)aNeeded;
- (void)setSize:(NSSize)aSize;
- (NSSize)size;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (void)setSizeAsString:(id)aString;
- (id)sizeAsString;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)copyWithZone:(NSZone *)aZone;
@end

