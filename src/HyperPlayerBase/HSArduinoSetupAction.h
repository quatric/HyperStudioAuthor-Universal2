#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSArduinoSetupAction : HSNBAAction <HSArduinoSetupActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSArduinoPinConfigurationAttribute>
{
    HSArduinoDevice *_device;
    struct __CFDictionary *_digitalPinConfigurationDictionary;
    struct __CFDictionary *_analogPinConfigurationDictionary;
}
- (void)startInContext:(id)aContext;
- (void)setupDevice;
- (void)setAnalogPinConfigurationDictionary:(struct __CFDictionary *)aDictionary;
- (void)HSArduinoSetupAction_setAnalogPinConfigurationDictionary:(struct __CFDictionary *)aDictionary;
- (struct __CFDictionary *)analogPinConfigurationDictionary;
- (void)removeConfigurationForAnalogPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin;
- (void)HSArduinoSetupAction_setConfiguration:(NSUInteger)aConfiguration forAnalogPin:(NSUInteger)aPin withPreviousConfiguration:(NSUInteger)aConfiguration2;
- (void)HSArduinoSetupAction_setConfiguration:(NSUInteger)aConfiguration forAnalogPin:(NSUInteger)aPin;
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forAnalogPin:(unsigned char)aPin;
- (void)setDigitalPinConfigurationDictionary:(struct __CFDictionary *)aDictionary;
- (void)HSArduinoSetupAction_setDigitalPinConfigurationDictionary:(struct __CFDictionary *)aDictionary;
- (struct __CFDictionary *)digitalPinConfigurationDictionary;
- (void)removeConfigurationForDigitalPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin;
- (void)HSArduinoSetupAction_setConfiguration:(NSUInteger)aConfiguration forDigitalPin:(NSUInteger)aPin withPreviousConfiguration:(NSUInteger)aConfiguration2;
- (void)HSArduinoSetupAction_setConfiguration:(NSUInteger)aConfiguration forDigitalPin:(NSUInteger)aPin;
- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forDigitalPin:(unsigned char)aPin;
- (void)HSArduinoSetupAction_notifyUndoOrRedoChange:(NSInteger)aChange withUserInfo:(id)aInfo;
- (BOOL)isAbleToStartInInvalidState;
- (BOOL)isValid;
- (void)setAnalogPinConfigurationAsStringsDictionary:(id)aDictionary;
- (void)setDigitalPinConfigurationAsStringsDictionary:(id)aDictionary;
- (void)setPinConfigurationAsStringsDictionary:(id)aDictionary;
- (id)pinConfigurationAsStringsDictionary;
- (id)analogPinConfigurationAsStringsDictionary;
- (id)digitalPinConfigurationAsStringsDictionary;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

