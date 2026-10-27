#import "HyperPlayerBasePrefix.h"


@interface NSURL (HSExtensions)
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (BOOL)canBeExtraPostLoaded;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

