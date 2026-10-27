#import "HSMutableSnapOptionsAttributesImplementation.h"

// Drop-off snapping attributes backed by an HSMutableSnapOptionsNodeUnit.
@implementation HSMutableSnapOptionsAttributesImplementation
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit
{
    if (![aUnit isKindOfClass:[HSMutableSnapOptionsNodeUnit class]])
        return nil;
    return [[[self alloc] initWithNodeUnit:aUnit node:aNode] autorelease];
}
- (void)setSnappingOptions:(id)aOptions
{
    id media = [aOptions objectForKey:@"dropOffRewardSoundMediaKey"];
    [self setDropOffRewardSoundMedia:(media == [NSNull null]) ? nil : media];
    [self setPlayDropOffRewardSound:[[aOptions objectForKey:@"playDropOffRewardSoundKey"] boolValue]];
    [self setIsDropOffTarget:[[aOptions objectForKey:@"isDropOffTargetKey"] boolValue]];
    [self setDropOffSnappingRange:[[aOptions objectForKey:@"dropOffSnappingRangeKey"] intValue]];
    [self setIsDropOffSnappingEnabled:[[aOptions objectForKey:@"isDropOffSnappingEnabledKey"] boolValue]];
}
- (id)snappingOptions
{
    NSNumber *enabled = [NSNumber numberWithBool:[_nodeUnit isDropOffSnappingEnabled]];
    NSNumber *range = [NSNumber numberWithInt:(int)[_nodeUnit dropOffSnappingRange]];
    NSNumber *target = [NSNumber numberWithBool:[_nodeUnit isDropOffTarget]];
    NSNumber *playSound = [NSNumber numberWithBool:[_nodeUnit playDropOffRewardSound]];
    id media = [_nodeUnit dropOffRewardSoundMedia] ? [_nodeUnit dropOffRewardSoundMedia] : [NSNull null];
    return [NSDictionary dictionaryWithObjectsAndKeys:
            media, @"dropOffRewardSoundMediaKey",
            playSound, @"playDropOffRewardSoundKey",
            target, @"isDropOffTargetKey",
            range, @"dropOffSnappingRangeKey",
            enabled, @"isDropOffSnappingEnabledKey",
            nil];
}
- (void)setIsDropOffSnappingEnabled:(BOOL)aEnabled
{
    [_nodeUnit setIsDropOffSnappingEnabled:aEnabled];
}
- (BOOL)isDropOffSnappingEnabled
{
    return [_nodeUnit isDropOffSnappingEnabled];
}
- (void)setDropOffSnappingRange:(NSUInteger)aRange
{
    [_nodeUnit setDropOffSnappingRange:aRange];
}
- (NSUInteger)dropOffSnappingRange
{
    return [_nodeUnit dropOffSnappingRange];
}
- (void)setIsDropOffTarget:(BOOL)aTarget
{
    [_nodeUnit setIsDropOffTarget:aTarget];
}
- (BOOL)isDropOffTarget
{
    return [_nodeUnit isDropOffTarget];
}
- (void)setPlayDropOffRewardSound:(BOOL)aSound
{
    [_nodeUnit setPlayDropOffRewardSound:aSound];
}
- (BOOL)playDropOffRewardSound
{
    return [_nodeUnit playDropOffRewardSound];
}
- (void)setDropOffRewardSoundMedia:(id)aMedia
{
    [_nodeUnit setDropOffRewardSoundMedia:aMedia];
}
- (id)dropOffRewardSoundMedia
{
    return [_nodeUnit dropOffRewardSoundMedia];
}
- (void)setDropOffRewardSoundMediaUID:(id)aUID
{
    [_nodeUnit setDropOffRewardSoundMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID]];
}
- (id)dropOffRewardSoundMediaUID
{
    return [[_nodeUnit dropOffRewardSoundMedia] mediaUID];
}
- (void)setDropOffTargetUID:(id)aUID
{
    [_nodeUnit setDropOffTargetUID:aUID];
}
- (id)dropOffTargetUID
{
    return [_nodeUnit dropOffTargetUID];
}
- (id)attributeObservingController
{
    return _node;
}
- (id)hyperObject
{
    return _node;
}
- (id)node
{
    return _node;
}
- (void)dealloc
{
    [_node release];
    [_nodeUnit release];
    [super dealloc];
}
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode
{
    self = [super init];
    if (self == nil || aNode == nil || aUnit == nil) {
        [self release];
        return nil;
    }
    _node = [aNode retain];
    _nodeUnit = [aUnit retain];
    [_node associateImplementation:self withInterface:@protocol(HSMutableSnapOptionsAttributes)];
    [_node associateImplementation:self withInterface:@protocol(HSMutableSnappingTargetUIDIdentification)];
    return self;
}
- (BOOL)isEqualTo:(id)aObject
{
    if (![aObject isMemberOfClass:[self class]])
        return NO;
    if (![_nodeUnit isEqualTo:[aObject nodeUnit]])
        return NO;
    NSRect frame = [[_node queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
    NSRect otherFrame = [[[aObject node] queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
    return NSEqualRects(frame, otherFrame);
}

- (id)nodeUnit
{
    return _nodeUnit;
}

- (id)temporaryDropOffTarget
{
    return [_nodeUnit temporaryDropOffTarget];
}

- (void)setTemporaryDropOffTarget:(id)aTarget
{
    [_nodeUnit setTemporaryDropOffTarget:aTarget];
}

@end
