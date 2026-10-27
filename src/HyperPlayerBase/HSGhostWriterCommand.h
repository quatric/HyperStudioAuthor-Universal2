#import "HyperPlayerBasePrefix.h"
#import "HSObject.h"


@interface HSGhostWriterCommand : HSObject <EXKeyValueCoding>
{
}
+ (id)commandType;
- (id)stringRepresentation;
- (BOOL)shouldRunWithoutDelayAfterCommand:(id)aCommand;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)executeWithActionPerformer:(id)aPerformer;
@end

