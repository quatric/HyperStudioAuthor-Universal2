#import "HyperPlayerBasePrefix.h"


@interface NSString (NSStringLinkRecognitionHSExtensions)
- (id)hyperRecognizedLinks;
- (id)hyperAttributedStringWithRecognizedLinks;
@end

@interface NSMutableString (HSExtensions)
- (void)hyperRemoveCharactersInSet:(id)aSet;
@end

@interface NSString (NSStringPathExtensionsHSExtensions)
- (id)relativePathToPath:(id)aPath;
- (id)pathWithLastComponents:(NSInteger)aComponents;
- (id)pathWithFirstComponents:(NSInteger)aComponents;
- (NSInteger)pathComponentsCount;
@end

@interface NSString (HSExtensions)
+ (id)hyperUIDString;
+ (id)hyperStringWithASCIIData:(id)aData;
- (id)hyperStringByReplacingUnderlineWithSlashes;
- (id)hyperStringByReplacingColonsWithSlashes;
- (id)hyperStringByReplacingSlashesWithColons;
- (id)hyperStringByReplacingString:(id)aString withString:(id)aString2;
- (NSRange)hyperRangeOfCharacterFromSet:(id)aSet options:(NSUInteger)aOptions range:(NSRange)aRange;
- (NSRange)hyperRangeOfCharacterFromSet:(id)aSet options:(NSUInteger)aOptions;
- (NSRange)hyperRangeOfCharacterFromSet:(id)aSet;
- (id)hyperStringByAddingEllipsis;
- (NSUInteger)hasHyperPrefixCaseInsensitive:(id)aInsensitive;
- (NSUInteger)hasHyperSubstringCaseInsensitive:(id)aInsensitive;
- (NSUInteger)hasHyperSubstring:(id)aSubstring;
- (NSInteger)hyperCaseInsensitiveNumericCompare:(id)aCompare;
- (id)hyperStringByRemovingCharactersInSet:(id)aSet;
- (NSRect)hyperRectValue;
- (NSSize)hyperSizeValue;
- (NSPoint)hyperPointValue;
- (BOOL)hyperBoolValue;
- (BOOL)hyperBooleanValue;
- (NSUInteger)hyperUnsignedValue;
- (unsigned short)hyperUnicharValue;
@end

