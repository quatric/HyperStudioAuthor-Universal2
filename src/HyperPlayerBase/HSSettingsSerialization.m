#import "HSSettingsSerialization.h"

// Key-value store of tool settings; keeps a lazily built "tool inputs"
// dictionary (converted values under input keys) in sync with the settings.
@implementation HSSettingsSerialization
+ (id)toolInputsWithDictionaryRepresentation:(id)aRepresentation delegate:(id)aDelegate
{
    id serialization = [[self class] new];
    [serialization setDelegate:aDelegate];
    [serialization loadExtraDictionaryRepresentation:aRepresentation];
    id toolInputs = [[serialization toolInputs] retain];
    [serialization release];
    return [toolInputs autorelease];
}
+ (id)settingsWithDictionaryRepresentation:(id)aRepresentation
{
    id serialization = [[[self class] alloc] initWithExtraDictionary:aRepresentation];
    id settings = [[serialization settings] retain];
    [serialization release];
    return [settings autorelease];
}
+ (id)toolInputsWithSettings:(id)aSettings delegate:(id)aDelegate
{
    id serialization = [[self class] new];
    [serialization setDelegate:aDelegate];
    [serialization setSettings:aSettings];
    id toolInputs = [[serialization toolInputs] retain];
    [serialization release];
    return [toolInputs autorelease];
}
- (id)mediaUIDs
{
    NSMutableSet *mediaUIDs = [NSMutableSet set];
    [[self settings] HSSettingsSerialization_addMediaUIDs:mediaUIDs];
    return mediaUIDs;
}
- (id)extraValueForUndefinedKey:(id)aKey
{
    return [self valueForUndefinedKey:aKey];
}
- (void)setExtraValue:(id)aValue forUndefinedKey:(id)aKey
{
    [self setValue:aValue forUndefinedKey:aKey];
}
- (void)setValue:(id)aValue forUndefinedKey:(id)aKey
{
    if (_settings == nil)
        _settings = [[NSMutableDictionary alloc] init];
    if ([_delegate respondsToSelector:@selector(setting:willChangeInSerialization:)])
        [_delegate setting:aKey willChangeInSerialization:self];
    [_settings setObject:aValue ? aValue : [NSNull null] forKey:aKey];
    if ([_delegate respondsToSelector:@selector(setting:didChangeInSerialization:)])
        [_delegate setting:aKey didChangeInSerialization:self];
    id inputKey = [self inputKeyForKey:aKey];
    if (inputKey && _toolInputs)
        [_toolInputs setObject:aValue ? [self convertValue:aValue forKey:aKey] : [NSNull null] forKey:inputKey];
}
- (id)valueForUndefinedKey:(id)aKey
{
    id value = [_settings objectForKey:aKey];
    return value == [NSNull null] ? nil : value;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [_settings allKeys];
}
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    if (_toolInputs == nil)
        return;
    for (id key in [(NSDictionary *)aRepresentation keyEnumerator]) {
        id inputKey = [self inputKeyForKey:key];
        if (inputKey == nil)
            continue;
        id value = [[self settings] objectForKey:key];
        id input = (value && value != [NSNull null]) ? [self convertValue:value forKey:key] : [NSNull null];
        [_toolInputs setObject:input forKey:inputKey];
    }
}
- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}
- (id)delegate
{
    return _delegate;
}
- (id)toolInputForKey:(id)aKey
{
    id input = [[self toolInputs] objectForKey:aKey];
    return input == [NSNull null] ? nil : input;
}
- (id)toolInputs
{
    if (_toolInputs == nil && _settings && [_settings count]) {
        _toolInputs = [[NSMutableDictionary alloc] initWithCapacity:[_settings count]];
        for (id key in [_settings keyEnumerator]) {
            id value = [_settings objectForKey:key];
            if (value != [NSNull null])
                value = [self convertValue:[_settings objectForKey:key] forKey:key];
            id inputKey = [self inputKeyForKey:key];
            if (inputKey && value)
                [_toolInputs setObject:value forKey:inputKey];
        }
    }
    return _toolInputs;
}
- (void)setSetting:(id)aSetting forKey:(id)aKey
{
    if (_settings == nil)
        _settings = [[NSMutableDictionary alloc] init];
    if ([_delegate respondsToSelector:@selector(setting:willChangeInSerialization:)])
        [_delegate setting:aKey willChangeInSerialization:self];
    [_settings setObject:aSetting ? aSetting : [NSNull null] forKey:aKey];
    id inputKey = [self inputKeyForKey:aKey];
    if (inputKey && _toolInputs)
        [_toolInputs setObject:aSetting ? [self convertValue:aSetting forKey:aKey] : [NSNull null] forKey:inputKey];
    if ([_delegate respondsToSelector:@selector(setting:didChangeInSerialization:)])
        [_delegate setting:aKey didChangeInSerialization:self];
}
- (void)setSettings:(id)aSettings
{
    if (_settings == aSettings)
        return;
    if ([_delegate respondsToSelector:@selector(setting:willChangeInSerialization:)])
        [_delegate setting:nil willChangeInSerialization:self];
    [_settings release];
    _settings = [[NSMutableDictionary alloc] initWithDictionary:aSettings copyItems:NO];
    [_toolInputs release];
    _toolInputs = nil;
    if ([_delegate respondsToSelector:@selector(setting:didChangeInSerialization:)])
        [_delegate setting:nil didChangeInSerialization:self];
}
- (id)settings
{
    return _settings;
}
- (void)dealloc
{
    [_settings release];
    [_toolInputs release];
    [super dealloc];
}
- (id)inputKeyForKey:(id)aKey
{
    return [aKey isEqualTo:@"info"] ? nil : aKey;
}
- (id)convertValue:(id)aValue forKey:(id)aKey
{
    return aValue;
}
@end

@implementation NSArray (HSSettingsSerialization)
- (void)HSSettingsSerialization_addMediaUIDs:(id)aDs
{
    for (id object in self) {
        if ([object respondsToSelector:@selector(HSSettingsSerialization_addMediaUIDs:)])
            [object HSSettingsSerialization_addMediaUIDs:aDs];
    }
}
@end

@implementation NSDictionary (HSSettingsSerialization)
// Values under keys ending in "UID" are media UID strings.
- (void)HSSettingsSerialization_addMediaUIDs:(id)aDs
{
    for (id key in [self keyEnumerator]) {
        id value = [self objectForKey:key];
        if (value == [NSNull null])
            continue;
        if ([key hasSuffix:@"UID"])
            [aDs addObject:[HSUID UIDWithString:value]];
        else if ([value respondsToSelector:@selector(HSSettingsSerialization_addMediaUIDs:)])
            [value HSSettingsSerialization_addMediaUIDs:aDs];
    }
}
@end
