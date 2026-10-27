#import "HyperPlayerBasePrefix.h"


@interface HSEffectSettings : NSObject
{
    NSDictionary *_settings;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedSettings;
- (id)extendedSettings;
- (id)dependants;
- (id)intencitySettings;
- (id)settings;
- (id)adjustedSettings:(id)aSettings forName:(id)aName category:(id)aCategory additionalIntencity:(CGFloat)aIntencity;
- (id)adjustedSettings:(id)aSettings forName:(id)aName category:(id)aCategory frameSize:(NSSize)aSize;
- (id)defaultSettingsForName:(id)aName category:(id)aCategory center:(NSPoint)aCenter intencity:(CGFloat)aIntencity identifier:(id)aIdentifier;
- (NSPoint)centerPointForSettings:(id)aSettings category:(id)aCategory;
- (BOOL)isIntencitySupportedForName:(id)aName;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

