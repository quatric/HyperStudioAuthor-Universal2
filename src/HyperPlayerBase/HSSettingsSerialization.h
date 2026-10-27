#import "HyperPlayerBasePrefix.h"


@interface HSSettingsSerialization : NSObject <EXKeyValueCoding>
{
    NSMutableDictionary *_settings;
    NSMutableDictionary *_toolInputs;
    id _delegate;
}
+ (id)toolInputsWithDictionaryRepresentation:(id)aRepresentation delegate:(id)aDelegate;
+ (id)settingsWithDictionaryRepresentation:(id)aRepresentation;
+ (id)toolInputsWithSettings:(id)aSettings delegate:(id)aDelegate;
- (id)mediaUIDs;
- (id)extraValueForUndefinedKey:(id)aKey;
- (void)setExtraValue:(id)aValue forUndefinedKey:(id)aKey;
- (void)setValue:(id)aValue forUndefinedKey:(id)aKey;
- (id)valueForUndefinedKey:(id)aKey;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)toolInputForKey:(id)aKey;
- (id)toolInputs;
- (void)setSetting:(id)aSetting forKey:(id)aKey;
- (void)setSettings:(id)aSettings;
- (id)settings;
- (void)dealloc;
- (id)inputKeyForKey:(id)aKey;
- (id)convertValue:(id)aValue forKey:(id)aKey;
@end

@interface NSArray (HSSettingsSerialization)
- (void)HSSettingsSerialization_addMediaUIDs:(id)aDs;
@end

@interface NSDictionary (HSSettingsSerialization)
- (void)HSSettingsSerialization_addMediaUIDs:(id)aDs;
@end

