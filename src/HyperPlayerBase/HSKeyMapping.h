#import "HyperPlayerBasePrefix.h"


@interface HSKeyMapping : NSObject <NSCopying>
{
    BOOL _useCommandKey;
    BOOL _useShiftKey;
    unsigned short _character;
}
+ (id)keyMappingWithCharacter:(unsigned short)aCharacter useCommandKey:(BOOL)aKey useShiftKey:(BOOL)aKey2;
+ (id)keyMappingForEvent:(id)aEvent;
- (id)copyWithZone:(NSZone *)aZone;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (void)setCharacter:(unsigned short)aCharacter;
- (unsigned short)character;
- (void)setUseShiftKey:(BOOL)aKey;
- (BOOL)useShiftKey;
- (void)setUseCommandKey:(BOOL)aKey;
- (BOOL)useCommandKey;
- (id)initWithCharacter:(unsigned short)aCharacter useCommandKey:(BOOL)aKey useShiftKey:(BOOL)aKey2;
@end

