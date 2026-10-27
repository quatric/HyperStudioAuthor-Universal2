#import "HyperPlayerBasePrefix.h"


@interface HSJavaScriptNamingStrategy : NSObject
{
    NSCharacterSet *_validCharactersForIdentifiers;
    NSCharacterSet *_validBeginningCharactersForIdentifiers;
    NSCharacterSet *_validBeginningCharactersForMechanicIdentifiers;
}
+ (id)defaultNamingStrategy;
+ (BOOL)isMechanicIdentifier:(id)aIdentifier;
+ (id)mechanicPrefix;
+ (Class)lexerClass;
- (id)lettersCharacterSet;
- (id)nonZeroDigitsCharacterSet;
- (id)digitsCharacterSet;
- (unsigned short)validFirstCharacterForMechanicIdentifier;
- (id)validBeginningCharactersForMechanicIdentifiers;
- (id)validBeginningCharactersForIdentifiers;
- (id)validCharactersForIdentifiers;
- (id)regularExpressionPatternForUIDName;
- (id)objectNameForMechanicName:(id)aName;
- (id)mechanicNameForObjectName:(id)aName;
- (id)prefix;
- (void)dealloc;
- (BOOL)isMechanicIdentifier:(id)aIdentifier;
@end

