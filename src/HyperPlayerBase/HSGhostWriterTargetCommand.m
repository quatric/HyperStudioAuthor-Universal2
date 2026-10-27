#import "HSGhostWriterTargetCommand.h"
#import "HSUID.h"
// A ghost writer command that moves typing to another text object.
@implementation HSGhostWriterTargetCommand
- (id)stringRepresentation
{
    return [NSString stringWithFormat:@"{goto %@}", [(id)_targetObjectUID stringValue]];
}
// The original doesn't call super's init.
- (id)initWithCoder:(id)aCoder
{
    _targetObjectUID = [[aCoder decodeObjectForKey:@"targetObjectUID"] retain];
    return self;
}
- (void)encodeWithCoder:(id)aCoder
{
    [aCoder encodeObject:_targetObjectUID forKey:@"targetObjectUID"];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObject:@"targetObjectUID"];
}
- (void)executeWithActionPerformer:(id)aPerformer
{
    [aPerformer setTargetObjectUID:_targetObjectUID];
}
- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[self class]])
        return NO;
    return [_targetObjectUID isEqual:[aEqual targetObjectUID]];
}
- (id)copyWithZone:(NSZone *)aZone
{
    id uid = [[self targetObjectUID] copy];
    id copy = [[[self class] alloc] initWithTargetObjectUID:uid];
    [uid release];
    return copy;
}
- (void)setTargetObjectUID:(id)aUID
{
    if ([aUID isEqual:_targetObjectUID])
        return;
    [_targetObjectUID release];
    _targetObjectUID = [aUID retain];
}
- (id)targetObjectUID
{
    return _targetObjectUID;
}
- (void)dealloc
{
    [_targetObjectUID release];
    [super dealloc];
}
- (id)initWithTargetObjectUID:(id)aUID
{
    self = [super init];
    if (self != nil)
        [self setTargetObjectUID:aUID];
    return self;
}
@end
