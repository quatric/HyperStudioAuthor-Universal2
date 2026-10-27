#import "HyperPlayerBasePrefix.h"
#import "HSGhostWriterCommand.h"


@interface HSGhostWriterTargetCommand : HSGhostWriterCommand <HSGhostWriterTargetCommandInterface, HyperInterface, NSObject, NSCoding>
{
    HSUID *_targetObjectUID;
}
- (id)stringRepresentation;
- (id)initWithCoder:(id)aCoder;
- (void)encodeWithCoder:(id)aCoder;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)executeWithActionPerformer:(id)aPerformer;
- (BOOL)isEqual:(id)aEqual;
- (id)copyWithZone:(NSZone *)aZone;
- (void)setTargetObjectUID:(id)aUID;
- (id)targetObjectUID;
- (void)dealloc;
- (id)initWithTargetObjectUID:(id)aUID;
@end

