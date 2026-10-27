#import "HSUID.h"

@implementation HSUID
+ (id)UID
{
    return [[_HSCFUUID new] autorelease];
}
+ (id)UIDWithString:(id)aString
{
    return [[[_HSCFUUID alloc] initWithString:aString] autorelease];
}
- (void)encodeWithCoder:(id)aCoder
{
    [aCoder encodeObject:[(_HSCFUUID *)self stringValue] forKey:@"stringValue"];
}
- (id)initWithCoder:(id)aCoder
{
    self = [self init];
    if (self)
        [(_HSCFUUID *)self setStringValue:[aCoder decodeObjectForKey:@"stringValue"]];
    return self;
}
- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] UIDWithString:[(_HSCFUUID *)self stringValue]] retain];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    static NSArray *sKeys = nil;
    if (!sKeys)
        sKeys = [[NSArray alloc] initWithObjects:@"stringValue", nil];
    return sKeys;
}
- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[HSUID class]])
        return [super isEqual:aEqual];
    return [[(_HSCFUUID *)self stringValue] isEqual:[aEqual stringValue]];
}
@end

@implementation _HSCFUUID
- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithUUID:[self UUID]];
}
- (id)description
{
    return [(NSString *)CFCopyDescription([self UUID]) autorelease];
}
- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[_HSCFUUID class]])
        return [super isEqual:aEqual];
    return CFEqual([self UUID], [(_HSCFUUID *)aEqual UUID]);
}
- (NSUInteger)hash
{
    return CFHash([self UUID]);
}
- (void)setStringValue:(id)aValue
{
    CFUUIDRef uuid = aValue ? CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)aValue) : NULL;
    [self setUUID:(struct __CFUUID *)uuid];
    if (uuid)
        CFRelease(uuid);
}
- (id)stringValue
{
    return [(NSString *)CFUUIDCreateString(kCFAllocatorDefault, [self UUID]) autorelease];
}
- (void)setUUID:(struct __CFUUID *)aUUID
{
    if (_UUID == aUUID)
        return;
    if (_UUID)
        CFRelease(_UUID);
    _UUID = aUUID ? (struct __CFUUID *)CFRetain(aUUID) : NULL;
}
- (struct __CFUUID *)UUID
{
    if (!_UUID)
        _UUID = (struct __CFUUID *)CFUUIDCreate(kCFAllocatorDefault);
    return _UUID;
}
- (void)dealloc
{
    if (_UUID)
        CFRelease(_UUID);
    [super dealloc];
}
- (id)initWithString:(id)aString
{
    self = [self init];
    if (self)
        [self setStringValue:aString];
    return self;
}
- (id)initWithUUID:(struct __CFUUID *)aUUID
{
    self = [self init];
    if (self)
        [self setUUID:aUUID];
    return self;
}
@end
