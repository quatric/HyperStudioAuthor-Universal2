#import "HSOldFormatParser+HSOldFormatParserSimpleTypes.h"
#import "HSOldFormatParser+HSOldFormatParserKernel.h"

@implementation HSOldFormatParser (HSOldFormatParserSimpleTypes)
- (id)parseType_RGBColor:(id)aColor atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    long size = [[aTree objectForKey:@"size"] longValue];
    UInt16 rgb[3];
    [_data getBytes:rgb range:NSMakeRange(aOffset, 6)];
    NSColor *color = [NSColor colorWithCalibratedRed:(float)CFSwapInt16BigToHost(rgb[0]) / 65535.0f
                                               green:(float)CFSwapInt16BigToHost(rgb[1]) / 65535.0f
                                                blue:(float)CFSwapInt16BigToHost(rgb[2]) / 65535.0f
                                               alpha:1.0f];
    return [self parametersDictionaryWithValue:color name:[aTree objectForKey:@"name"] type:aColor size:[NSNumber numberWithLong:size]];
}
- (id)parseType_extended80:(id)aExtended80 atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:[aTree objectForKey:@"size"]];
    NSData *value = [_data subdataWithRange:NSMakeRange(aOffset, size)];
    return [self parametersDictionaryWithValue:value name:[aTree objectForKey:@"name"] type:aExtended80 size:[NSNumber numberWithLong:size]];
}
- (id)parseType_none:(id)aNone atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    return [self parametersDictionaryWithValue:@"none" name:@"none" type:@"none" size:[NSNumber numberWithLong:0]];
}
- (id)parseType_Rect:(id)aRect atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    long size = [[aTree objectForKey:@"size"] longValue];
    SInt16 rect[4] = {0, 0, 0, 0};   // top, left, bottom, right
    [_data getBytes:rect range:NSMakeRange(aOffset, 8)];
    SInt16 top = (SInt16)CFSwapInt16BigToHost(rect[0]);
    SInt16 left = (SInt16)CFSwapInt16BigToHost(rect[1]);
    SInt16 bottom = (SInt16)CFSwapInt16BigToHost(rect[2]);
    SInt16 right = (SInt16)CFSwapInt16BigToHost(rect[3]);
    NSString *value = [NSString stringWithFormat:@"{{%d, %d}, {%d, %d}}", left, top, right - left, bottom - top];
    return [self parametersDictionaryWithValue:value name:[aTree objectForKey:@"name"] type:aRect size:[NSNumber numberWithLong:size]];
}
- (id)parseType_FourCharCode:(id)aCode atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    long size = [[aTree objectForKey:@"size"] longValue];
    char chars[4] = {0, 0, 0, 0};
    [_data getBytes:chars range:NSMakeRange(aOffset, 4)];
    NSString *value = [[[NSString alloc] initWithBytes:chars length:4 encoding:NSMacOSRomanStringEncoding] autorelease];
    return [self parametersDictionaryWithValue:value name:[aTree objectForKey:@"name"] type:aCode size:[NSNumber numberWithLong:size]];
}
- (id)parseType_chars:(id)aChars atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    long size = [[aTree objectForKey:@"size"] longValue];
    char chars[4] = {0, 0, 0, 0};
    [_data getBytes:chars range:NSMakeRange(aOffset, 4)];
    NSString *value = [[[NSString alloc] initWithBytes:chars length:4 encoding:NSMacOSRomanStringEncoding] autorelease];
    return [self parametersDictionaryWithValue:value name:[aTree objectForKey:@"name"] type:aChars size:[NSNumber numberWithLong:size]];
}
- (id)parseType_data:(id)aData atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:[aTree objectForKey:@"size"]];
    NSData *value = [_data subdataWithRange:NSMakeRange(aOffset, size)];
    return [self parametersDictionaryWithValue:value name:[aTree objectForKey:@"name"] type:aData size:[NSNumber numberWithLong:size]];
}
- (id)parseType_ConstStr255Param:(id)aParam atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    NSInteger size = [self longEvaluate:[aTree objectForKey:@"size"]];
    unsigned char string[257];
    memset(string, 0, sizeof(string));
    // The original read `size` bytes into a 256-byte buffer unchecked.
    [_data getBytes:string range:NSMakeRange(aOffset, MIN(MAX(size, 0), 256))];
    p2cstrcpyMy(string, string);
    NSString *value = [NSString stringWithCString:(const char *)string encoding:NSMacOSRomanStringEncoding];
    return [self parametersDictionaryWithValue:value name:[aTree objectForKey:@"name"] type:aParam size:[NSNumber numberWithLong:size]];
}
- (id)parseType_UnsignedFixed:(id)aFixed atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    UInt32 value = 0;
    [_data getBytes:&value range:NSMakeRange(aOffset, 4)];
    value = CFSwapInt32BigToHost(value);
    return [self parametersDictionaryWithValue:[NSNumber numberWithUnsignedLong:value] name:[aTree objectForKey:@"name"] type:aFixed size:[NSNumber numberWithLong:4]];
}
- (id)parseType_Ptr:(id)aPtr atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    UInt32 value = 0;
    [_data getBytes:&value range:NSMakeRange(aOffset, 4)];
    value = CFSwapInt32BigToHost(value);
    return [self parametersDictionaryWithValue:[NSNumber numberWithUnsignedLong:value] name:[aTree objectForKey:@"name"] type:aPtr size:[NSNumber numberWithLong:4]];
}
- (id)parseType_unsigned_long:(id)aLong atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    UInt32 value = 0;
    [_data getBytes:&value range:NSMakeRange(aOffset, 4)];
    value = CFSwapInt32BigToHost(value);
    return [self parametersDictionaryWithValue:[NSNumber numberWithUnsignedLong:value] name:[aTree objectForKey:@"name"] type:aLong size:[NSNumber numberWithLong:4]];
}
- (id)parseType_Fixed:(id)aFixed atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    UInt32 value = 0;
    [_data getBytes:&value range:NSMakeRange(aOffset, 4)];
    value = CFSwapInt32BigToHost(value);
    return [self parametersDictionaryWithValue:[NSNumber numberWithLong:(SInt32)value] name:[aTree objectForKey:@"name"] type:aFixed size:[NSNumber numberWithLong:4]];
}
- (id)parseType_long:(id)aLong atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    UInt32 value = 0;
    [_data getBytes:&value range:NSMakeRange(aOffset, 4)];
    value = CFSwapInt32BigToHost(value);
    return [self parametersDictionaryWithValue:[NSNumber numberWithLong:(SInt32)value] name:[aTree objectForKey:@"name"] type:aLong size:[NSNumber numberWithLong:4]];
}
- (id)parseType_unsigned_short:(id)aShort atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    UInt16 value = 0;
    [_data getBytes:&value range:NSMakeRange(aOffset, 2)];
    value = CFSwapInt16BigToHost(value);
    return [self parametersDictionaryWithValue:[NSNumber numberWithUnsignedShort:value] name:[aTree objectForKey:@"name"] type:aShort size:[NSNumber numberWithLong:2]];
}
- (id)parseType_short:(id)aShort atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    UInt16 value = 0;
    [_data getBytes:&value range:NSMakeRange(aOffset, 2)];
    value = CFSwapInt16BigToHost(value);
    return [self parametersDictionaryWithValue:[NSNumber numberWithShort:(SInt16)value] name:[aTree objectForKey:@"name"] type:aShort size:[NSNumber numberWithLong:2]];
}
- (id)parseType_UInt8:(id)aInt8 atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    unsigned char value = 0;
    [_data getBytes:&value range:NSMakeRange(aOffset, 1)];
    return [self parametersDictionaryWithValue:[NSNumber numberWithUnsignedChar:value] name:[aTree objectForKey:@"name"] type:aInt8 size:[NSNumber numberWithLong:1]];
}
- (id)parseType_unsigned_char:(id)aChar atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    unsigned char value = 0;
    [_data getBytes:&value range:NSMakeRange(aOffset, 1)];
    return [self parametersDictionaryWithValue:[NSNumber numberWithUnsignedChar:value] name:[aTree objectForKey:@"name"] type:aChar size:[NSNumber numberWithLong:1]];
}
- (id)parseType_char:(id)aChar atDefinedTree:(id)aTree parent:(id)aParent atOffset:(NSInteger)aOffset
{
    unsigned char value = 0;
    [_data getBytes:&value range:NSMakeRange(aOffset, 1)];
    return [self parametersDictionaryWithValue:[NSNumber numberWithChar:(char)value] name:[aTree objectForKey:@"name"] type:aChar size:[NSNumber numberWithLong:1]];
}
@end
