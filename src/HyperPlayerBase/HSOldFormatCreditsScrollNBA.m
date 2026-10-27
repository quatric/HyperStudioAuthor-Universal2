#import "HSOldFormatCreditsScrollNBA.h"
// HyperStudio 4's Credits Scroll add-on: scrolls a named text box. Its data
// is either text ("<name, 16 chars> speed steps flags") or a 24-byte
// big-endian record.
@implementation HSOldFormatCreditsScrollNBA
- (id)autoScrollAction
{
    id action = [HSAutoScrollAction action];
    [self parseParametersIfNeeded];
    if (_parametersValid) {
        id attributes = [action queryHyperInterface:@protocol(HSAutoScrollActionAttributes)];
        [attributes setNumberOfSteps:_steps];
        [attributes setStepsPerSecond:_speed];
        [attributes setScrollAmount:_pixels];
        [attributes setIgnoreMouseClicks:_isScrollIgnoreClicks];
        [attributes setScrollUnits:_isScrollLines ? 1 : 0];
        [attributes setScrollDirection:_isScrollHorizontally ? 1 : 0];
    }
    return action;
}
- (id)targetTextBoxName
{
    [self parseParametersIfNeeded];
    return _parametersValid ? _textBoxName : nil;
}
- (void)setTargetTextBoxName:(id)aName
{
    if (_textBoxName != aName) {
        [_textBoxName release];
        _textBoxName = [aName retain];
    }
}
- (void)parseParametersIfNeeded
{
    if (_parametersParsed)
        return;
    [self parseParametersFromStringData];
    if (!_parametersValid)
        [self parseParametersFromBinaryData];
    _parametersParsed = YES;
}
// steps, speed, pixels, by-pixels flag (16 bits each), then the name as a
// Pascal string (under 16 characters).
- (void)parseParametersFromBinaryData
{
    if ([_data length] != 24)
        return;
    unsigned char bytes[24];
    [_data getBytes:bytes length:24];
    if (bytes[8] >= 16)
        return;
    [self setTargetTextBoxName:[NSString hyperStringWithASCIIData:[NSData dataWithBytes:bytes + 9 length:bytes[8]]]];
    _speed = (unsigned short)(bytes[2] << 8 | bytes[3]);
    _steps = (unsigned short)(bytes[0] << 8 | bytes[1]);
    _pixels = (unsigned short)(bytes[4] << 8 | bytes[5]);
    _isScrollLines = (bytes[6] << 8 | bytes[7]) == 0;
    _parametersValid = YES;
}
// The flags: pixels in the low byte, then lines (bit 8), horizontally
// (bit 9), ignoring clicks (bit 11). The name's leading spaces are kept,
// its trailing ones dropped.
- (void)parseParametersFromStringData
{
    NSString *string = [NSString hyperStringWithASCIIData:_data];
    if (string == nil || [string length] <= 16)
        return;
    NSMutableString *values = [NSMutableString stringWithString:[string substringFromIndex:16]];
    while ([values replaceOccurrencesOfString:@"  " withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [values length])] != 0)
        ;
    NSArray *parts = [values componentsSeparatedByString:@" "];
    if ([parts count] <= 2)
        return;
    _speed = [[parts objectAtIndex:0] intValue];
    _steps = [[parts objectAtIndex:1] intValue];
    int flags = [[parts objectAtIndex:2] intValue];
    _pixels = flags & 0xff;
    _isScrollLines = (flags >> 8) & 1;
    _isScrollIgnoreClicks = (flags >> 11) & 1;
    _isScrollHorizontally = (flags >> 9) & 1;
    NSString *name = [string substringToIndex:16];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSUInteger start = [name rangeOfCharacterFromSet:[whitespace invertedSet]].location;
    NSString *leading = start == NSNotFound ? @"" : [name substringToIndex:start];
    [self setTargetTextBoxName:[leading stringByAppendingString:[name stringByTrimmingCharactersInSet:whitespace]]];
    _parametersValid = YES;
}
- (void)dealloc
{
    [_data release];
    [_textBoxName release];
    [super dealloc];
}
- (id)initWithData:(id)aData
{
    self = [super init];
    if (self != nil)
        _data = [aData retain];
    return self;
}
- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}
@end
