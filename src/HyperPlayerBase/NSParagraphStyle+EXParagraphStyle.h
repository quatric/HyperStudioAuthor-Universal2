#import "HyperPlayerBasePrefix.h"


@interface NSParagraphStyle (EXParagraphStyle)
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (BOOL)canBeExtraPostLoaded;
- (id)hyperArrayFromDictionaryRepresentations:(id)aRepresentations;
- (id)hyperDictionaryRepresentationsFromArray:(id)aArray;
@end

