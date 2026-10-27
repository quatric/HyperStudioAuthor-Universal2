#import "HSGhostWriterSpeedCommand.h"
// Ghost writer command: change the typing speed.
@implementation HSGhostWriterSpeedCommand
- (id)stringRepresentation
{
    return [NSString stringWithFormat:@"{%i}", (int)[self speed]];
}
// HSGhostWriterCommand doesn't adopt NSCoding: no super call, as in the original.
- (id)initWithCoder:(id)aCoder
{
    _speed = [aCoder decodeIntForKey:@"speed"];
    return self;
}
- (void)encodeWithCoder:(id)aCoder
{
    [aCoder encodeInt:_speed forKey:@"speed"];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObject:@"speed"];
}
- (void)executeWithActionPerformer:(id)aPerformer
{
    [aPerformer setTypingSpeed:_speed];
}
- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] alloc] initWithSpeed:[self speed]];
}
// The original read the other speed as a float (a selector type clash at
// compile time); compared as integers here.
- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    return _speed == [(HSGhostWriterSpeedCommand *)aEqual speed];
}
- (void)setSpeed:(NSInteger)aSpeed
{
    _speed = (int)aSpeed;
}
- (NSInteger)speed
{
    return _speed;
}
- (id)initWithSpeed:(NSInteger)aSpeed
{
    self = [super init];
    if (self != nil)
        _speed = (int)aSpeed;
    return self;
}
@end
