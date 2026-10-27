#import "HyperPlayerBasePrefix.h"


@interface NSTextTab (EXTextTab)
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (BOOL)canBeExtraPostLoaded;
@end

