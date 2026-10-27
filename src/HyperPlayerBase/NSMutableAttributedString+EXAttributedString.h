#import "HyperPlayerBasePrefix.h"


@interface NSMutableAttributedString (EXAttributedString)
- (void)replaceOccurencesOfString:(id)aString withString:(id)aString2;
@end

@interface NSAttributedString (EXAttributedString)
+ (id)hyperAcceptableStringAttributesForStoring;
+ (id)extraAttributedStringWithImage:(id)aImage;
- (BOOL)isExtraEqualToAttributedString:(id)aString;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (BOOL)canBeExtraPostLoaded;
- (id)hyperArrayRepresentation;
- (id)hyperAttributesFromDictionaryRepresentation:(id)aRepresentation;
- (id)hyperDictionaryRepresentationFromAttributes:(id)aAttributes;
@end

