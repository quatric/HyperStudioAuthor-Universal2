#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSArduinoWatcherAction : HSNBAAction <HSArduinoWatcherActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSArduinoPinConfigurationRangeMappingsAttribute>
{
    HSArduinoDevice *_device;
    struct __CFDictionary *_digitalPinConfigurationRangeMappings;
    struct __CFDictionary *_analogPinConfigurationRangeMappings;
}
- (void)startInContext:(id)aContext;
- (void)setDigitalPinConfigurationRangeMappings:(struct __CFDictionary *)aMappings analogPinConfigurationRangeMappings:(struct __CFDictionary *)aMappings2;
- (void)HSArduinoWatcherAction_setDigitalPinConfigurationDictionary:(struct __CFDictionary *)aDictionary analogPinConfigurationRangeMappings:(struct __CFDictionary *)aMappings;
- (struct __CFDictionary *)analogPinConfigurationRangeMappings;
- (struct __CFDictionary *)digitalPinConfigurationRangeMappings;
- (void)removePinConfigurationRangesForObjectWithUID:(id)aUID;
- (void)setDigitalPinConfigurationRanges:(struct __CFDictionary *)aRanges analogPinConfigurationRanges:(struct __CFDictionary *)aRanges2 forObjectWithUID:(id)aUID;
- (void)HSArduinoWatcherAction_setDigitalConfigurationRanges:(struct __CFDictionary *)aRanges analogConfigurationRanges:(struct __CFDictionary *)aRanges2 forObjectWithUID:(id)aUID withPreviousDigitalConfigurationRanges:(struct __CFDictionary *)aRanges3 previousAnalogConfigurationRanges:(struct __CFDictionary *)aRanges4;
- (void)HSArduinoWatcherAction_setDigitalConfigurationRanges:(struct __CFDictionary *)aRanges analogConfigurationRanges:(struct __CFDictionary *)aRanges2 forObjectWithUID:(id)aUID;
- (struct __CFDictionary *)analogPinConfigurationRangesForObjectWithUID:(id)aUID;
- (struct __CFDictionary *)digitalPinConfigurationRangesForObjectWithUID:(id)aUID;
- (void)removeConfigurationRangeForObjectWithUID:(id)aUID analogPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forObjectWithUID:(id)aUID analogPin:(unsigned char)aPin;
- (void)HSArduinoWatcherAction_setConfigurationRange:(NSUInteger)aRange forObjectWithUID:(id)aUID analogPin:(unsigned char)aPin toConfigurationRangeDictionary:(struct __CFDictionary *)aDictionary withPreviousConfigurationRange:(NSUInteger)aRange2;
- (void)HSArduinoWatcherAction_setConfigurationRange:(NSUInteger)aRange forObjectWithUID:(id)aUID analogPin:(unsigned char)aPin;
- (void)removeConfigurationRangeForObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin;
- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin;
- (void)HSArduinoWatcherAction_setConfigurationRange:(NSUInteger)aRange forObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin toConfigurationRangeDictionary:(struct __CFDictionary *)aDictionary withPreviousConfigurationRange:(NSUInteger)aRange2;
- (void)HSArduinoWatcherAction_setConfigurationRange:(NSUInteger)aRange forObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin;
- (void)HSArduinoWatcherAction_notifyUndoOrRedoChange:(NSInteger)aChange withUserInfo:(id)aInfo;
- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forObjectWithUID:(id)aUID analogPin:(unsigned char)aPin;
- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin;
- (void)mergeInArduinoWatcherAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (BOOL)isAbleToStartInInvalidState;
- (BOOL)isValid;
- (void)setAnalogPinConfigurationRangeMappingsAsStringsDictionary:(id)aDictionary;
- (void)setDigitalPinConfigurationRangeMappingsAsStringsDictionary:(id)aDictionary;
- (void)setPinConfigurationRangeMappingsAsStringsDictionary:(id)aDictionary;
- (id)pinConfigurationRangeMappingsAsStringsDictionary;
- (id)analogPinConfigurationRangeMappingsAsStringsDictionary;
- (id)digitalPinConfigurationRangeMappingsAsStringsDictionary;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

@interface __HSArduinoWatchers : NSObject <HSArduinoWatchers, NSObject>
{
    NSMutableArray *_objects;
    struct __CFArray *_digitalPinConfigurationRanges;
    struct __CFArray *_analogPinConfigurationRanges;
    NSMutableIndexSet *_triggeredObjectInexes;
}
- (id)triggeringWatchers;
- (id)triggeringWatchersForAnalogPin:(unsigned char)aPin;
- (id)triggeringWatchersForDigitalPin:(unsigned char)aPin;
- (BOOL)__HSArduinoWatchers_isTriggeringWatcherAtIndex:(NSUInteger)aIndex withDigitalPinConfigurationRanges:(struct __CFDictionary *)aRanges analogPinConfigurationRanges:(struct __CFDictionary *)aRanges2;
- (void)addWatcher:(id)aWatcher withDigitalPinConfigurationRanges:(struct __CFDictionary *)aRanges analogPinConfigurationRanges:(struct __CFDictionary *)aRanges2;
- (void)dealloc;
@end

