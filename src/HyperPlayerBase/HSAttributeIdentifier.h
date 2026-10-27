#import "HyperPlayerBasePrefix.h"


@interface HSAttributeIdentifier : NSObject <NSCopying>
{
    Protocol *_interface;
    SEL _selector;
    unsigned int _hash;
}
+ (id)attributeIdentifierWithInterface:(id)aInterface selector:(SEL)aSelector;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (SEL)selector;
- (id)interface;
- (id)copyWithZone:(NSZone *)aZone;
- (id)init;
- (id)initWithInterface:(id)aInterface selector:(SEL)aSelector;
@end

