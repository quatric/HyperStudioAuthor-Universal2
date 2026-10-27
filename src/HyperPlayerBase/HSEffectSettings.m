#import "HSEffectSettings.h"
// Singleton holding the Core Image effect defaults from
// EffectsSettings.plist: per-effect intensity ranges ("Intencity" Min/Max),
// inputs that depend on the frame size or centre ("Dependants"), and
// per-identifier extra settings ("Extensions").

static HSEffectSettings *HSEffectSettingsSharedSettings = nil;

@implementation HSEffectSettings

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (!HSEffectSettingsSharedSettings) {
            HSEffectSettingsSharedSettings = [super allocWithZone:aZone];
            return HSEffectSettingsSharedSettings;
        }
    }
    return nil;
}

+ (id)sharedSettings
{
    @synchronized(self) {
        if (!HSEffectSettingsSharedSettings)
            [[self alloc] init];
    }
    return HSEffectSettingsSharedSettings;
}

- (id)extendedSettings
{
    return [[self settings] objectForKey:@"Extensions"];
}

- (id)dependants
{
    return [[self settings] objectForKey:@"Dependants"];
}

- (id)intencitySettings
{
    return [[self settings] objectForKey:@"Intencity"];
}

- (id)settings
{
    if (!_settings) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"EffectsSettings" ofType:@"plist"];
        _settings = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return _settings;
}

// Moves each ranged numeric input by aIntencity of its range, keeping its
// current position in the range (capped at the top).
- (id)adjustedSettings:(id)aSettings forName:(id)aName category:(id)aCategory additionalIntencity:(CGFloat)aIntencity
{
    NSDictionary *minimums = [[[self intencitySettings] objectForKey:@"Min"] objectForKey:aName];
    NSDictionary *maximums = [[[self intencitySettings] objectForKey:@"Max"] objectForKey:aName];
    NSMutableDictionary *result = [[aSettings mutableCopy] autorelease];
    NSMutableSet *keys = [NSMutableSet setWithArray:[minimums allKeys]];
    [keys addObjectsFromArray:[maximums allKeys]];
    NSEnumerator *enumerator = [keys objectEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        id value = [aSettings objectForKey:key];
        id minimum = [minimums objectForKey:key];
        id maximum = [maximums objectForKey:key];
        if (![minimum isKindOfClass:[NSNumber class]] || ![maximum isKindOfClass:[NSNumber class]])
            continue;
        float low = [minimum floatValue];
        float range = [maximum floatValue] - low;
        if (fabsf(range) <= 0)
            continue;
        float current = [value isKindOfClass:[NSNumber class]] ? [value floatValue] : 0;
        float position = MIN((current - low) / range, 1.0f);
        [result setObject:[NSNumber numberWithFloat:(position + aIntencity) * range + low] forKey:key];
    }
    return result;
}

// Scales the frame-dependent inputs (given for a 100×100 frame) to aSize.
- (id)adjustedSettings:(id)aSettings forName:(id)aName category:(id)aCategory frameSize:(NSSize)aSize
{
    NSMutableDictionary *result = [[aSettings mutableCopy] autorelease];
    NSDictionary *dependants = [[self dependants] objectForKey:aName];
    float scaleY = aSize.height / 100.0f;
    float scaleX = aSize.width / 100.0f;
    float scale = MIN(scaleX, scaleY);
    NSEnumerator *enumerator = [[dependants objectForKey:@"frame"] objectEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        id value = [aSettings objectForKey:key];
        // (The original stops at the first input missing from aSettings.)
        if (!value)
            break;
        if ([value isKindOfClass:[NSNumber class]])
            [result setObject:[NSNumber numberWithFloat:ceilf([value floatValue] * scale)] forKey:key];
    }
    if ([[dependants objectForKey:@"inputCenter"] boolValue]) {
        id center = [aSettings objectForKey:@"inputCenter"];
        if (center) {
            NSPoint point = [center extraPointValue];
            [result setObject:[NSDictionary extraDictionaryWithPoint:NSMakePoint(point.x * scaleX, point.y * scaleY)] forKey:@"inputCenter"];
        }
    }
    return result;
}

// Defaults at aIntencity of each input's range; the centre (in a 100×100
// frame) and an angle pointing from the middle, plus any extensions for
// aIdentifier.
- (id)defaultSettingsForName:(id)aName category:(id)aCategory center:(NSPoint)aCenter intencity:(CGFloat)aIntencity identifier:(id)aIdentifier
{
    NSDictionary *minimums = [[[self intencitySettings] objectForKey:@"Min"] objectForKey:aName];
    NSDictionary *maximums = [[[self intencitySettings] objectForKey:@"Max"] objectForKey:aName];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:[minimums count]];
    NSMutableSet *keys = [NSMutableSet setWithArray:[minimums allKeys]];
    [keys addObjectsFromArray:[maximums allKeys]];
    NSEnumerator *enumerator = [keys objectEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        id minimum = [minimums objectForKey:key];
        id maximum = [maximums objectForKey:key];
        if ([minimum isEqual:maximum]) {
            [result setObject:minimum forKey:key];
        } else if (!minimum != !maximum) {
            [result setObject:minimum ? minimum : maximum forKey:key];
        } else if ([minimum isKindOfClass:[NSNumber class]] && [maximum isKindOfClass:[NSNumber class]]) {
            float low = [minimum floatValue];
            [result setObject:[NSNumber numberWithFloat:([maximum floatValue] - low) * aIntencity + low] forKey:key];
        }
    }

    NSDictionary *dependants = [[self dependants] objectForKey:aName];
    if ([[dependants objectForKey:@"inputCenter"] boolValue]) {
        [result setObject:[NSDictionary extraDictionaryWithPoint:aCenter] forKey:@"inputCenter"];
        if ([[dependants objectForKey:@"inputAngle"] boolValue]) {
            float dx = aCenter.x - 50.0f;
            float dy = aCenter.y - 50.0f;
            float angle = (dx != 0 || dy != 0) ? acosf(dx / sqrtf(dx * dx + dy * dy)) : 0;
            double inputAngle = dy >= 0 ? angle - M_PI : M_PI - angle;
            [result setObject:[NSNumber numberWithFloat:inputAngle] forKey:@"inputAngle"];
        }
    }
    if (aIdentifier) {
        NSDictionary *extensions = [[[self extendedSettings] objectForKey:aIdentifier] objectForKey:aName];
        if ([extensions count])
            [result addEntriesFromDictionary:extensions];
    }
    return result;
}

- (NSPoint)centerPointForSettings:(id)aSettings category:(id)aCategory
{
    id center = [aSettings objectForKey:@"inputCenter"];
    if (!center)
        return NSMakePoint(INFINITY, INFINITY);
    return [center extraPointValue];
}

- (BOOL)isIntencitySupportedForName:(id)aName
{
    NSDictionary *minimums = [[[self intencitySettings] objectForKey:@"Min"] objectForKey:aName];
    NSDictionary *maximums = [[[self intencitySettings] objectForKey:@"Max"] objectForKey:aName];
    return [minimums count] && [maximums count];
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
