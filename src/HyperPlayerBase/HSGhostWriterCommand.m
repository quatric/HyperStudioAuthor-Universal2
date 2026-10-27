#import "HSGhostWriterCommand.h"
@implementation HSGhostWriterCommand
+ (id)commandType
{
    return NSStringFromClass(self);
}
- (id)stringRepresentation
{
    return @"";
}
- (BOOL)shouldRunWithoutDelayAfterCommand:(id)aCommand
{
    return YES;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return nil;
}
// Abstract: every command overrides it.
- (void)executeWithActionPerformer:(id)aPerformer
{
    [self doesNotRecognizeSelector:_cmd];
}
@end
