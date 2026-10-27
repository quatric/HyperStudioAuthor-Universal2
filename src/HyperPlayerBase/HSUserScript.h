#import "HyperPlayerBasePrefix.h"


@interface HSUserScript : NSObject <NSCopying, EXKeyValueCoding>
{
    NSString *_javaScriptSource;
    NSSet *_usedUIDs;
    BOOL _usesValidUIDs;
    BOOL _isValid;
    BOOL _hasPotentialErrors;
}
+ (id)userScriptWithSource:(id)aSource;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)copyWithZone:(NSZone *)aZone;
- (BOOL)isEqual:(id)aEqual;
- (void)setUsesValidUIDs:(BOOL)aDs;
- (BOOL)usesValidUIDs;
- (void)setHasPotentialErrors:(BOOL)aErrors;
- (BOOL)hasPotentialErrors;
- (void)setValid:(BOOL)aValid;
- (BOOL)isValid;
- (void)setUsedUIDsArray:(id)aArray;
- (id)usedUIDsArray;
- (void)setUsedUIDs:(id)aDs;
- (id)usedUIDs;
- (void)setJavaScriptSource:(id)aSource;
- (id)javaScriptSource;
- (void)dealloc;
- (id)init;
@end

