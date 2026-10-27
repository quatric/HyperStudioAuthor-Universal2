#import "HyperPlayerBasePrefix.h"


@interface NSColor (EXColorValue)
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (BOOL)shouldUseHyperDefaultImplementationForKeyValueCoding;
- (BOOL)canBeExtraPostLoaded;
@end

@interface NSDictionary (EXColorValue)
+ (id)extraDictionaryWithColor:(id)aColor;
@end

@interface NSObject (EXColorValue)
- (id)extraColorValueForKey:(id)aKey;
- (id)extraColorValue;
@end

