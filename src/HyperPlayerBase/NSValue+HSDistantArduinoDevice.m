#import "NSValue+HSDistantArduinoDevice.h"

// a pin's change, as the Arduino server sends it
struct __HSArduinoPinStateChange {
    unsigned long long time;
    unsigned short value;
    char mode;
};

@implementation NSValue (HSDistantArduinoDevice)
+ (id)HS_valueWithArduinoPinStateChangeToMode:(NSInteger)aMode value:(unsigned short)aValue atTime:(unsigned long long)aTime
{
    struct __HSArduinoPinStateChange change = {aTime, aValue, (char)aMode};
    return [self valueWithBytes:&change objCType:@encode(struct __HSArduinoPinStateChange)];
}
- (void)HS_getArduinoPinStateChangeToMode:(int *)aMode value:(unsigned short *)aValue atTime:(unsigned long long *)aTime
{
    struct __HSArduinoPinStateChange change;
    [self getValue:&change];
    if (aMode != NULL)
        *aMode = change.mode;
    if (aValue != NULL)
        *aValue = change.value;
    if (aTime != NULL)
        *aTime = change.time;
}
- (id)HS_initWithArduinoPinStateChangeToMode:(NSInteger)aMode value:(unsigned short)aValue atTime:(unsigned long long)aTime
{
    struct __HSArduinoPinStateChange change = {aTime, aValue, (char)aMode};
    return [self initWithBytes:&change objCType:@encode(struct __HSArduinoPinStateChange)];
}
@end
