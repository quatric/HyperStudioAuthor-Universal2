#import "HyperPlayerBasePrefix.h"
#import "HSArduinoDevice.h"


@interface HSArduinoCacheDevice : HSArduinoDevice
{
    unsigned short _digitalPinValues[12];
    // modes, -1 when not known (BOOL in the original, which is bool on arm64)
    signed char _digitalPinModes[12];
    signed char _analogPinModes[6];
    unsigned short _analogPinValues[6];
}
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forAnalogPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin;
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forDigitalPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin;
- (void)sendValue:(unsigned short)aValue forAnalogPin:(unsigned char)aPin;
- (void)sendMode:(NSInteger)aMode forAnalogPin:(unsigned char)aPin;
- (void)sendValue:(unsigned short)aValue forDigitalPin:(unsigned char)aPin;
- (void)sendMode:(NSInteger)aMode forDigitalPin:(unsigned char)aPin;
- (void)setPinStatesFromDevice:(id)aDevice;
- (id)init;
@end

@interface HSDistantArduinoDevice : HSArduinoCacheDevice <HSDistantArduinoDeviceObserver>
{
    unsigned int _retainCount;
    NSString *_serialPortName;
    NSDistantObject<HSDistantArduinoDevice> *_deviceProxy;
    unsigned long long _digitalPinStateTimes[12];
    unsigned long long _analogPinStateTimes[6];
    unsigned char _digitalPinBeingChanged;
    unsigned char _analogPinBeingChanged;
    unsigned int _deviceConnectionStatus:16;
}
+ (id)deviceWithSerialPort:(NSUInteger)aPort;
+ (id)deviceWithSerialPortName:(id)aName;
+ (id)defaultDevice;
+ (id)allocWithZone:(NSZone *)aZone;
- (void)HSDistantArduinoDevice_updatePinCache;
- (void)deviceDidChangeConnectionStatus:(NSInteger)aStatus;
- (void)analogPinStateDidChange:(id)aChange;
- (void)digitalPinStateDidChange:(id)aChange;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin;
- (NSInteger)connectionStatus;
- (void)noteArduinoServerDidDisconnect;
- (void)noteArduinoServerDidConnect;
- (void)release;
- (id)retain;
- (void)dealloc;
- (id)HSDistantArduinoDevice_initWithSerialPortName:(id)aName;
- (id)init;
@end
