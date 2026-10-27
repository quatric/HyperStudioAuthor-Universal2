#import "HyperPlayerBasePrefix.h"


@interface NSString (EXMacTypes)
+ (id)extraStringWithPascalString:(char *)aString;
+ (id)extraStringWithFourCharCode:(NSUInteger)aCode;
- (NSUInteger)extraFourCharCode;
- (id)extraInitWithPascalString:(char *)aString;
@end

@interface NSMutableString (EXReplacement)
- (BOOL)extraReplaceString:(id)aString withString:(id)aString2 searchOptions:(NSUInteger)aOptions replaceOptions:(NSInteger)aOptions2;
- (BOOL)extraReplaceString:(id)aString withString:(id)aString2 replaceOptions:(NSInteger)aOptions;
- (BOOL)extraReplaceString:(id)aString withString:(id)aString2 searchOptions:(NSUInteger)aOptions;
- (BOOL)extraReplaceString:(id)aString withString:(id)aString2;
- (BOOL)extraReplaceString:(id)aString withString:(id)aString2 searchOptions:(NSUInteger)aOptions replaceOptions:(NSInteger)aOptions2 range:(NSRange)aRange;
- (BOOL)extraReplaceString:(id)aString withString:(id)aString2 searchOptions:(NSUInteger)aOptions replaceOptions:(NSInteger)aOptions2 range:(NSRange)aRange delimiterCharacters:(id)aCharacters wordCharacters:(id)aCharacters2;
@end

@interface NSString (EXSeparation)
- (id)extraComponentsSeparatedByCharacterFromSet:(id)aSet options:(NSUInteger)aOptions range:(NSRange)aRange;
- (id)extraComponentsSeparatedByCharacterFromSet:(id)aSet options:(NSUInteger)aOptions;
- (id)extraComponentsSeparatedByCharacterFromSet:(id)aSet;
@end

@interface NSMutableString (EXMutableStringExtensions)
- (void)extraClear;
@end

@interface NSString (EXUniqueFilename)
+ (id)extraCreateUniqueFilename:(id)aFilename extension:(id)aExtension;
@end

@interface NSString (EXSearching)
- (id)extraStringByReplacingURLEscapedSymbolsWithUnderscores;
- (id)extraStringByTrimmingWhitespaceCharacters;
- (id)_pumaStringByTrimmingCharactersInSet:(id)aSet;
- (NSUInteger)extraCountOfCharacterFromSet:(id)aSet options:(NSUInteger)aOptions;
- (NSUInteger)extraCountOfCharacterFromSet:(id)aSet;
- (NSUInteger)extraCountOfString:(id)aString options:(NSUInteger)aOptions;
- (NSUInteger)extraCountOfString:(id)aString;
- (NSUInteger)extraLocationOfString:(id)aString options:(NSUInteger)aOptions;
- (NSUInteger)extraLocationOfString:(id)aString;
- (NSUInteger)extraIndexOfCharacter:(unsigned short)aCharacter;
- (BOOL)extraContainsString:(id)aString;
@end

@interface NSString (EXValueSupport)
+ (id)extraStringWithInt:(NSInteger)aInt;
@end

@interface NSString (EXCharacters)
+ (id)extraNewlineString;
@end

