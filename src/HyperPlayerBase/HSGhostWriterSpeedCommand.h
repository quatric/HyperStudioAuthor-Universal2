#import "HyperPlayerBasePrefix.h"
#import "HSGhostWriterCommand.h"


@interface HSGhostWriterSpeedCommand : HSGhostWriterCommand <HSGhostWriterSpeedCommandInterface, HyperInterface, NSObject, NSCoding>
{
    int _speed;
}
- (id)stringRepresentation;
- (id)initWithCoder:(id)aCoder;
- (void)encodeWithCoder:(id)aCoder;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)executeWithActionPerformer:(id)aPerformer;
- (id)copyWithZone:(NSZone *)aZone;
- (BOOL)isEqual:(id)aEqual;
- (void)setSpeed:(NSInteger)aSpeed;
- (NSInteger)speed;
- (id)initWithSpeed:(NSInteger)aSpeed;
@end

