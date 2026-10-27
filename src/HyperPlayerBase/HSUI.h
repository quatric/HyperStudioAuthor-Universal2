#import "HyperPlayerBasePrefix.h"


@interface HSUI : NSObject
{
    int _currentMode;
    NSMutableDictionary *_settings;
}
+ (BOOL)isCardIndexOpenedInApplicationDefaults:(id)aDefaults;
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedUI;
- (id)backgroundAttributes;
- (void)setBackgroundGraphics:(id)aGraphics;
- (id)backgroundGraphics;
- (void)setSettings:(id)aSettings forKey:(id)aKey mode:(NSInteger)aMode;
- (id)settingsForKey:(id)aKey mode:(NSInteger)aMode;
- (void)setSettings:(id)aSettings forKey:(id)aKey;
- (id)settingsForKey:(id)aKey;
- (void)setCurrentMode:(NSInteger)aMode;
- (NSInteger)currentMode;
- (void)loadSettingsIfNeeded;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

