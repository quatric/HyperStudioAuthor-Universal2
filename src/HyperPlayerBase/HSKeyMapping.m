#import "HSKeyMapping.h"
// A key equivalent: one character with or without command and shift.
// Immutable in use, so copies are the same object.
@implementation HSKeyMapping
+ (id)keyMappingWithCharacter:(unsigned short)aCharacter useCommandKey:(BOOL)aKey useShiftKey:(BOOL)aKey2
{
    return [[[[self class] alloc] initWithCharacter:aCharacter useCommandKey:aKey useShiftKey:aKey2] autorelease];
}
// Only single-character, non-repeated key downs with no control or option.
// Shift (or caps lock) counts except for '*' and '+', which need it on
// some keyboards anyway.
+ (id)keyMappingForEvent:(id)aEvent
{
    if ([aEvent isARepeat])
        return nil;
    NSUInteger flags = [aEvent modifierFlags];
    NSString *characters = [aEvent characters];
    if ((flags & 0xff0c0000) != 0 || [characters length] != 1)
        return nil;
    unichar c = [characters characterAtIndex:0];
    BOOL shift = (flags & (NSEventModifierFlagShift | NSEventModifierFlagCapsLock)) != 0
              && (unsigned short)(c - '*') >= 2;
    return [[[self alloc] initWithCharacter:c
                              useCommandKey:(flags & NSEventModifierFlagCommand) != 0
                                useShiftKey:shift] autorelease];
}
- (id)copyWithZone:(NSZone *)aZone
{
    return [self retain];
}
- (NSUInteger)hash
{
    return ((NSUInteger)_character << 16) | (_useCommandKey ? 0x100 : 0) | (_useShiftKey ? 1 : 0);
}
- (BOOL)isEqual:(id)aEqual
{
    if (self == aEqual)
        return YES;
    if (aEqual == nil || ![aEqual isKindOfClass:[self class]])
        return NO;
    return [(HSKeyMapping *)aEqual character] == _character
        && [aEqual useCommandKey] == _useCommandKey
        && [aEqual useShiftKey] == _useShiftKey;
}
- (void)setCharacter:(unsigned short)aCharacter
{
    _character = aCharacter;
}
- (unsigned short)character
{
    return _character;
}
- (void)setUseShiftKey:(BOOL)aKey
{
    _useShiftKey = aKey != NO;
}
- (BOOL)useShiftKey
{
    return _useShiftKey;
}
- (void)setUseCommandKey:(BOOL)aKey
{
    _useCommandKey = aKey != NO;
}
- (BOOL)useCommandKey
{
    return _useCommandKey;
}
- (id)initWithCharacter:(unsigned short)aCharacter useCommandKey:(BOOL)aKey useShiftKey:(BOOL)aKey2
{
    self = [super init];
    if (self != nil) {
        [self setCharacter:aCharacter];
        [self setUseCommandKey:aKey];
        [self setUseShiftKey:aKey2];
    }
    return self;
}
@end
