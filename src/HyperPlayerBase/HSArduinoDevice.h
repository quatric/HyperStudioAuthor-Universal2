#import "HyperPlayerBasePrefix.h"


@interface HSArduinoDevice : NSObject
{
}
+ (id)deviceWithSerialPort:(NSUInteger)aPort;
+ (id)deviceWithSerialPortName:(id)aName;
+ (id)defaultDevice;
+ (void)HSArduinoDevice_arduinoServerConnectionDidDie:(id)aDie;
+ (void)HSArduinoDevice_arduinoServerDidTerminate:(id)aTerminate;
+ (void)HSArduinoDevice_arduinoServerDidStart:(id)aStart;
+ (void)HSArduinoDevice_connectToArduinoServerIfNeeded;
+ (BOOL)HSArduinoDevice_connectToArduinoServer;
+ (BOOL)HSArduinoDevice_launchArduinoServer;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin;
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forAnalogPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin;
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forDigitalPin:(unsigned char)aPin;
- (NSInteger)connectionStatus;
- (id)allAnalogPins;
- (id)allDigitalPins;
@end

// HSDistantArduinoDevice (implemented in HSArduinoDevice.m) subclasses HSArduinoCacheDevice
#import "HSArduinoCacheDevice.h"
