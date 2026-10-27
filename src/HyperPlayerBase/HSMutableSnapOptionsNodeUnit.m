#import "HSMutableSnapOptionsNodeUnit.h"

// Node unit storing an object's drop-off snapping options.
@implementation HSMutableSnapOptionsNodeUnit
+ (id)keysForStoring
{
    return [NSArray arrayWithObjects:@"dropOffTargetUID", @"isDropOffTarget", @"dropOffSnappingRange",
            @"isDropOffSnappingEnabled", @"playDropOffRewardSound", @"dropOffRewardSoundMediaUID", nil];
}
- (void)setIsDropOffSnappingEnabled:(BOOL)aEnabled
{
    _isDropOffSnappingEnabled = aEnabled ? 1 : 0;
}
- (BOOL)isDropOffSnappingEnabled
{
    return _isDropOffSnappingEnabled;
}
- (void)setDropOffSnappingRange:(NSUInteger)aRange
{
    _dropOffSnappingRange = (unsigned int)aRange;
}
- (NSUInteger)dropOffSnappingRange
{
    return _dropOffSnappingRange;
}
- (void)setIsDropOffTarget:(BOOL)aTarget
{
    _isDropOffTarget = aTarget;
}
- (BOOL)isDropOffTarget
{
    return _isDropOffTarget;
}
- (void)setPlayDropOffRewardSound:(BOOL)aSound
{
    _playDropOffRewardSound = aSound;
}
- (BOOL)playDropOffRewardSound
{
    return _playDropOffRewardSound;
}
- (void)setDropOffRewardSoundMedia:(id)aMedia
{
    if (_dropOffRewardSoundMedia != aMedia) {
        [_dropOffRewardSoundMedia release];
        _dropOffRewardSoundMedia = [aMedia retain];
    }
}
- (id)dropOffRewardSoundMedia
{
    return _dropOffRewardSoundMedia;
}
- (void)setDropOffRewardSoundMediaUID:(id)aUID
{
    [self setDropOffRewardSoundMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID]];
}
- (id)dropOffRewardSoundMediaUID
{
    return [[self dropOffRewardSoundMedia] mediaUID];
}
- (void)setDropOffTargetUID:(id)aUID
{
    [aUID retain];
    [_dropOffTargetUID release];
    _dropOffTargetUID = aUID;
}
- (id)dropOffTargetUID
{
    return _dropOffTargetUID;
}
- (id)mediaUIDs
{
    if ([self dropOffRewardSoundMediaUID])
        return [NSSet setWithObject:[self dropOffRewardSoundMediaUID]];
    return [NSSet set];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[[self class] keysForStoring]];
}
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSMutableSnapOptionsAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSMutableSnappingTargetUIDIdentification), aInterface))
        return [HSMutableSnapOptionsAttributesImplementation class];
    return Nil;
}
- (BOOL)implementsHyperInterface:(id)aInterface
{
    return HSProtocolsAreEqual(@protocol(HSMutableSnapOptionsAttributes), aInterface)
        || HSProtocolsAreEqual(@protocol(HSMutableSnappingTargetUIDIdentification), aInterface);
}
- (id)implementedHyperInterfaces
{
    return [NSSet setWithObjects:[HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableSnapOptionsAttributes)],
                                 [HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableSnappingTargetUIDIdentification)], nil];
}
- (id)attributes
{
    return [NSEProtocolSet protocolSetWithProtocols:@protocol(HSMutableSnapOptionsAttributes), nil];
}
- (id)copyWithZone:(NSZone *)aZone
{
    HSMutableSnapOptionsNodeUnit *copy = [super copyWithZone:aZone];
    // Original overwrites the media the superclass copy already loaded (leaking it).
    copy->_dropOffRewardSoundMedia = [[HSNewMedia alloc] initWithMedia:_dropOffRewardSoundMedia type:[_dropOffRewardSoundMedia mediaType]];
    copy->_playDropOffRewardSound = _playDropOffRewardSound;
    copy->_isDropOffSnappingEnabled = _isDropOffSnappingEnabled;
    copy->_isDropOffTarget = _isDropOffTarget;
    copy->_dropOffSnappingRange = _dropOffSnappingRange;
    return copy;
}
- (void)dealloc
{
    [_dropOffRewardSoundMedia release];
    [_dropOffTargetUID release];
    [_temporaryDropOffTarget release];
    [super dealloc];
}
- (BOOL)isEqualTo:(id)aObject
{
    if (![aObject isMemberOfClass:[self class]])
        return NO;
    if (_playDropOffRewardSound != [aObject playDropOffRewardSound]
        || (_isDropOffSnappingEnabled ? YES : NO) != [aObject isDropOffSnappingEnabled]
        || _isDropOffTarget != [aObject isDropOffTarget]
        || _dropOffSnappingRange != [aObject dropOffSnappingRange])
        return NO;
    NSString *name = [_dropOffRewardSoundMedia mediaName];
    NSString *otherName = [[aObject dropOffRewardSoundMedia] mediaName];
    if (name == nil && otherName != nil)
        return NO;
    if (name != nil && otherName == nil)
        return NO;
    if (name != nil && ![name isEqualToString:otherName])
        return NO;
    return YES;
}

- (id)temporaryDropOffTarget
{
    return _temporaryDropOffTarget;
}

- (void)setTemporaryDropOffTarget:(id)aTarget
{
    if (_temporaryDropOffTarget != aTarget) {
        [_temporaryDropOffTarget release];
        _temporaryDropOffTarget = [aTarget retain];
    }
}

@end
