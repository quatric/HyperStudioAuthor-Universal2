#import "HyperPlayerBasePrefix.h"
#import "HSGhostWriterCommand.h"


@interface HSGhostWriterStuffCommand : HSGhostWriterCommand <HSGhostWriterStuffCommandInterface, HyperInterface, NSObject, NSCoding>
{
    NSString *_stuffType;
}
- (id)stringRepresentation;
- (BOOL)shouldRunWithoutDelayAfterCommand:(id)aCommand;
- (id)initWithCoder:(id)aCoder;
- (void)encodeWithCoder:(id)aCoder;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)executeWithActionPerformer:(id)aPerformer;
- (id)copyWithZone:(NSZone *)aZone;
- (BOOL)isEqual:(id)aEqual;
- (id)stuffType;
- (void)setStuffType:(id)aType;
- (id)initWithStuffType:(id)aType;
@end

