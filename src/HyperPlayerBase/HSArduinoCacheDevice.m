#import "HSArduinoCacheDevice.h"
// An Arduino whose pin modes and values are kept here; subclasses send them
// to a real board. Digital pins are 2-13, analog pins 0-5; a mode of -1 means
// the pin's state isn't known.
@implementation HSArduinoCacheDevice
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forAnalogPin:(unsigned char)aPin
{
    if (_analogPinModes[aPin] == -1)
        return NO;
    if (aMode != NULL)
        *aMode = _analogPinModes[aPin];
    if (aValue != NULL)
        *aValue = _analogPinValues[aPin];
    return YES;
}
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin
{
    if (_analogPinModes[aPin] == aMode) {
        if (_analogPinValues[aPin] == aValue)
            return;
    } else
        [self sendMode:aMode forAnalogPin:aPin];
    if (aMode != 0 && aMode != 2)
        [self sendValue:aValue forAnalogPin:aPin];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSIndexSet indexSetWithIndex:aPin], HSArduinoDeviceNotificationInfoAnalogPins, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSArduinoDevicePinStateDidChangeNotification object:self userInfo:info];
}
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forDigitalPin:(unsigned char)aPin
{
    int mode = _digitalPinModes[aPin - 2];
    if (mode == -1)
        return NO;
    if (aMode != NULL)
        *aMode = mode;
    if (aValue != NULL)
        *aValue = _digitalPinValues[aPin - 2];
    return YES;
}
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin
{
    if (_digitalPinModes[aPin - 2] == aMode) {
        if (_digitalPinValues[aPin - 2] == aValue)
            return;
    } else
        [self sendMode:aMode forDigitalPin:aPin];
    if (aMode != 0)
        [self sendValue:aValue forDigitalPin:aPin];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSIndexSet indexSetWithIndex:aPin], HSArduinoDeviceNotificationInfoDigitalPins, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSArduinoDevicePinStateDidChangeNotification object:self userInfo:info];
}
- (void)sendValue:(unsigned short)aValue forAnalogPin:(unsigned char)aPin
{
    _analogPinValues[aPin] = aValue;
}
- (void)sendMode:(NSInteger)aMode forAnalogPin:(unsigned char)aPin
{
    _analogPinModes[aPin] = (signed char)aMode;
}
- (void)sendValue:(unsigned short)aValue forDigitalPin:(unsigned char)aPin
{
    _digitalPinValues[aPin - 2] = aValue;
}
- (void)sendMode:(NSInteger)aMode forDigitalPin:(unsigned char)aPin
{
    _digitalPinModes[aPin - 2] = (signed char)aMode;
}
- (void)setPinStatesFromDevice:(id)aDevice
{
    int mode;
    unsigned short value;
    for (unsigned char pin = 2; pin < 14; pin++) {
        if ([aDevice getMode:&mode value:&value forDigitalPin:pin])
            [self setMode:mode value:value forDigitalPin:pin];
    }
    for (unsigned char pin = 0; pin < 6; pin++) {
        if ([aDevice getMode:&mode value:&value forAnalogPin:pin])
            [self setMode:mode value:value forAnalogPin:pin];
    }
}
- (id)init
{
    self = [super init];
    if (self != nil) {
        memset(_digitalPinModes, -1, sizeof(_digitalPinModes));
        memset(_analogPinModes, -1, sizeof(_analogPinModes));
    }
    return self;
}
@end
