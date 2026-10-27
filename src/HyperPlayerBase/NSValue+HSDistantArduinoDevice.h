#import "HyperPlayerBasePrefix.h"


@interface NSValue (HSDistantArduinoDevice)
+ (id)HS_valueWithArduinoPinStateChangeToMode:(NSInteger)aMode value:(unsigned short)aValue atTime:(unsigned long long)aTime;
- (void)HS_getArduinoPinStateChangeToMode:(int *)aMode value:(unsigned short *)aValue atTime:(unsigned long long *)aTime;
- (id)HS_initWithArduinoPinStateChangeToMode:(NSInteger)aMode value:(unsigned short)aValue atTime:(unsigned long long)aTime;
@end

