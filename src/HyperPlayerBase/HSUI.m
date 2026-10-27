#import "HSUI.h"

static HSUI *HSUISharedUI = nil;

@implementation HSUI
+ (BOOL)isCardIndexOpenedInApplicationDefaults:(id)aDefaults
{
    NSDictionary *settings = [aDefaults objectForKey:HSUIUserDefaultsEntryKey];
    if (!settings)
        return NO;
    id currentMode = [settings objectForKey:HSUICurrentModeKey];
    if (!currentMode)
        return NO;
    NSString *modeKey = [NSString stringWithFormat:@"%d", [currentMode intValue]];
    id value = [[[settings objectForKey:HSUIModeSettingsKey] objectForKey:modeKey] objectForKey:HSUIModeIsCardIndexShown];
    return value ? [value boolValue] : NO;
}
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (!HSUISharedUI) {
            HSUISharedUI = [super allocWithZone:aZone];
            return HSUISharedUI;
        }
    }
    return nil;
}
+ (id)sharedUI
{
    @synchronized(self) {
        if (!HSUISharedUI)
            [[self alloc] init];
    }
    return HSUISharedUI;
}
- (id)backgroundAttributes
{
    return nil;
}
- (void)setBackgroundGraphics:(id)aGraphics
{
    [self loadSettingsIfNeeded];
    id representation = [aGraphics extraDictionaryRepresentation];
    if (!representation)
        return;
    [_settings setObject:representation forKey:HSUIModeCoverDesktopBackgroundKey];
    [[NSUserDefaults standardUserDefaults] setObject:_settings forKey:HSUIUserDefaultsEntryKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSUICoverDesktopBackgroundDidChangeNotification object:self];
}
- (id)backgroundGraphics
{
    [self loadSettingsIfNeeded];
    id representation = [_settings objectForKey:HSUIModeCoverDesktopBackgroundKey];
    return representation ? [NSObject objectWithExtraDictionary:representation] : nil;
}
- (void)setSettings:(id)aSettings forKey:(id)aKey mode:(NSInteger)aMode
{
    if ([[self settingsForKey:aKey mode:aMode] isEqual:aSettings])
        return;
    NSDictionary *modeSettings = [_settings objectForKey:HSUIModeSettingsKey];
    NSMutableDictionary *newModeSettings = modeSettings ? [[modeSettings mutableCopy] autorelease] : [NSMutableDictionary dictionaryWithCapacity:2];
    [_settings setObject:newModeSettings forKey:HSUIModeSettingsKey];
    NSString *modeKey = [NSString stringWithFormat:@"%d", (int)aMode];
    NSDictionary *settings = [newModeSettings objectForKey:modeKey];
    NSMutableDictionary *newSettings = settings ? [[settings mutableCopy] autorelease] : [NSMutableDictionary dictionary];
    [newModeSettings setObject:newSettings forKey:modeKey];
    [newSettings setObject:aSettings forKey:aKey];
    [[NSUserDefaults standardUserDefaults] setObject:_settings forKey:HSUIUserDefaultsEntryKey];
    // The notification carries the current mode, not the mode that changed.
    [[NSNotificationCenter defaultCenter] postNotificationName:HSUIModeSettingsDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:_currentMode], HSUIModeModeIDKey, aKey, HSUIModeModeSettingsKeyKey, nil]];
}
// Mode 1 has no stored settings: everything is on.
- (id)settingsForKey:(id)aKey mode:(NSInteger)aMode
{
    [self loadSettingsIfNeeded];
    if (aMode == 1)
        return (id)kCFBooleanTrue;
    return [[[_settings objectForKey:HSUIModeSettingsKey] objectForKey:[NSString stringWithFormat:@"%d", (int)aMode]] objectForKey:aKey];
}
- (void)setSettings:(id)aSettings forKey:(id)aKey
{
    [self setSettings:aSettings forKey:aKey mode:[self currentMode]];
}
- (id)settingsForKey:(id)aKey
{
    return [self settingsForKey:aKey mode:[self currentMode]];
}
- (void)setCurrentMode:(NSInteger)aMode
{
    [self loadSettingsIfNeeded];
    if (_currentMode == aMode)
        return;
    _currentMode = (int)aMode;
    NSNumber *mode = [NSNumber numberWithInt:(int)aMode];
    // Mode 1 is never remembered.
    if ([mode intValue] != 1) {
        [_settings setObject:mode forKey:HSUICurrentModeKey];
        [[NSUserDefaults standardUserDefaults] setObject:_settings forKey:HSUIUserDefaultsEntryKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:HSUIModeDidChangeNotification object:self userInfo:nil];
}
- (NSInteger)currentMode
{
    [self loadSettingsIfNeeded];
    return _currentMode;
}
- (void)loadSettingsIfNeeded
{
    if (_settings)
        return;
    _settings = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:HSUIUserDefaultsEntryKey] mutableCopy];
    if (!_settings)
        _settings = [[NSMutableDictionary alloc] initWithCapacity:2];
    _currentMode = [[_settings objectForKey:HSUICurrentModeKey] intValue];
}
- (id)autorelease
{
    return self;
}
- (void)release
{
}
- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}
- (id)retain
{
    return self;
}
- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}
@end
