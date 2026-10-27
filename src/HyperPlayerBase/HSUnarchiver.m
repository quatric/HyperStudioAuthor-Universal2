#import "HSUnarchiver.h"
// A minimal coder pair for doubles ("d", stored big-endian) and 64-bit
// integers ("Q", stored in the host's order); everything else is ignored.
@implementation HSUnarchiver
- (NSInteger)versionForClassName:(id)aName
{
    return 0;
}
- (id)decodeDataObject
{
    return nil;
}
- (void)decodeValueOfObjCType:(char *)aType at:(void *)aAt
{
    if (aAt == NULL)
        return;
    NSUInteger length = [_data length];
    const uint8_t *bytes = [_data bytes];
    if (strcmp(aType, "d") == 0) {
        if (_offset + 8 <= length) {
            uint64_t bits;
            memcpy(&bits, bytes + _offset, 8);
            bits = CFSwapInt64BigToHost(bits);
            memcpy(aAt, &bits, 8);
            _offset += 8;
        }
    } else if (strcmp(aType, "Q") == 0 && _offset + 8 <= length) {
        memcpy(aAt, bytes + _offset, 8);
        _offset += 8;
    }
}
- (void)encodeDataObject:(id)aObject
{
}
- (void)encodeValueOfObjCType:(char *)aType at:(void *)aAt
{
}
- (void)dealloc
{
    [_data release];
    [super dealloc];
}
- (id)initForReadingWithData:(id)aData
{
    self = [super init];
    if (self != nil)
        _data = [aData retain];
    return self;
}
@end
@implementation HSArchiver
- (NSInteger)versionForClassName:(id)aName
{
    return 0;
}
- (id)decodeDataObject
{
    return nil;
}
- (void)decodeValueOfObjCType:(char *)aType at:(void *)aAt
{
}
- (void)encodeDataObject:(id)aObject
{
}
- (void)encodeValueOfObjCType:(char *)aType at:(void *)aAt
{
    uint64_t bits;
    if (strcmp(aType, "d") == 0) {
        memcpy(&bits, aAt, 8);
        bits = CFSwapInt64HostToBig(bits);
    } else if (strcmp(aType, "Q") == 0)
        memcpy(&bits, aAt, 8);
    else
        return;
    [_data appendBytes:&bits length:8];
}
- (id)archiverData
{
    return _data;
}
- (void)dealloc
{
    [_data release];
    [super dealloc];
}
- (id)initForWritingWithMutableData:(id)aData
{
    self = [super init];
    if (self != nil)
        _data = aData != nil ? [aData retain] : [[NSMutableData alloc] init];
    return self;
}
- (id)init
{
    self = [super init];
    if (self != nil)
        _data = [[NSMutableData alloc] init];
    return self;
}
@end
