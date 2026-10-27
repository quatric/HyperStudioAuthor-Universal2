#import "HSGhostWriterStuffCommand.h"
// A ghost writer editing command: backspace, erase, or moving the insertion
// point left or right.
@implementation HSGhostWriterStuffCommand
- (id)stringRepresentation
{
    NSString *type = [self stuffType];
    if ([type isEqualToString:HSGhostWriterBackspace])
        return @"{backspace}";
    if ([type isEqualToString:HSGhostWriterErase])
        return @"{erase}";
    if ([type isEqualToString:HSGhostWriterMoveLeft])
        return @"{move left}";
    if ([type isEqualToString:HSGhostWriterMoveRight])
        return @"{move right}";
    return nil;
}
// Erasing follows the previous command at once.
- (BOOL)shouldRunWithoutDelayAfterCommand:(id)aCommand
{
    return [_stuffType isEqualToString:HSGhostWriterErase];
}
// The original doesn't call super's init.
- (id)initWithCoder:(id)aCoder
{
    _stuffType = [[aCoder decodeObjectForKey:@"stuffType"] retain];
    return self;
}
- (void)encodeWithCoder:(id)aCoder
{
    [aCoder encodeObject:_stuffType forKey:@"stuffType"];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObject:@"stuffType"];
}
- (void)executeWithActionPerformer:(id)aPerformer
{
    if ([_stuffType isEqualToString:HSGhostWriterBackspace])
        [aPerformer backspace];
    else if ([_stuffType isEqualToString:HSGhostWriterErase])
        [aPerformer erase];
    else if ([_stuffType isEqualToString:HSGhostWriterMoveLeft])
        [aPerformer moveLeft];
    else if ([_stuffType isEqualToString:HSGhostWriterMoveRight])
        [aPerformer moveRight];
}
- (id)copyWithZone:(NSZone *)aZone
{
    id type = [[self stuffType] copy];
    id copy = [[[self class] alloc] initWithStuffType:type];
    [type release];
    return copy;
}
- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    return [_stuffType isEqualToString:[aEqual stuffType]];
}
- (id)stuffType
{
    return _stuffType;
}
- (void)setStuffType:(id)aType
{
    if ([aType isEqualToString:_stuffType])
        return;
    [_stuffType release];
    _stuffType = [aType retain];
}
- (id)initWithStuffType:(id)aType
{
    self = [super init];
    if (self != nil)
        [self setStuffType:aType];
    return self;
}
// Not in the original (the type leaked).
- (void)dealloc
{
    [_stuffType release];
    [super dealloc];
}
@end
