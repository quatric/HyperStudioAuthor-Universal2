#import "HyperPlayerBasePrefix.h"
#import "HSCursorSynchronizer.h"


@interface HSCursor (EXCursor)
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (BOOL)canBeExtraPostLoaded;
@end

