#import "HyperPlayerBasePrefix.h"


@interface HSProtocolIdentifier : NSObject <NSCopying>
{
    Protocol *_protocol;
}
+ (id)identifierForProtocol:(id)aProtocol;
- (id)description;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (id)protocol;
- (id)copyWithZone:(NSZone *)aZone;
- (id)init;
- (id)initWithProtocol:(id)aProtocol;
@end

