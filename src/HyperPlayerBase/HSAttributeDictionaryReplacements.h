#import "HyperPlayerBasePrefix.h"


@interface HSAttributeDictionaryReplacements : NSObject <HSAttributeDictionaryReplacements>
{
    NSMutableDictionary *_dictionary;
}
+ (id)nullValue;
- (id)applyToDictionary:(id)aDictionary;
- (void)addAttributeReplacements:(id)aReplacements;
- (id)attributeNamesEnumerator;
- (id)replacementValueForAttributeName:(id)aName;
- (BOOL)containsValueForAttributeName:(id)aName;
- (BOOL)isEmpty;
- (void)registerValue:(id)aValue forAttributeName:(id)aName;
- (id)replacementsDictionary;
- (void)dealloc;
- (id)initWithCapacity:(NSUInteger)aCapacity;
@end

@interface HSAttributedStringReplacements : NSObject <HSAttributedStringReplacements>
{
    NSData *_rangesData;
    unsigned int _numberOfRanges;
    NSRange *_ranges;
    NSRange _wholeRange;
    NSArray *_actualAttributeDictionaries;
    NSMutableArray *_replacementObjects;
}
+ (id)dataWithAttributeRangesInAttributedString:(id)aString limitedToRange:(NSRange)aRange ranges:(NSRange **)aRanges numberOfRanges:(unsigned int *)aRanges2 actualAttributeDictionaries:(id *)aDictionaries;
- (void)cleanupAuxiliaryData;
- (id)allIncludedAttributes;
- (void)addAttributeReplacements:(id)aReplacements atReplacementIndex:(NSUInteger)aIndex;
- (BOOL)containsValueForAttributeName:(id)aName atReplacementIndex:(NSUInteger)aIndex;
- (void)registerValue:(id)aValue forAttributeName:(id)aName atReplacementIndex:(NSUInteger)aIndex;
- (id)actualAttributesAtReplacementIndex:(NSUInteger)aIndex;
- (id)replacementValueForAttributeName:(id)aName atReplacementIndex:(NSUInteger)aIndex;
- (id)attributeNamesEnumeratorAtReplacementIndex:(NSUInteger)aIndex;
- (BOOL)isEmpty;
- (id)replacementsAtReplacementIndex:(NSUInteger)aIndex;
- (NSRange)affectedRangeAtReplacementIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfReplacements;
- (void)dealloc;
- (id)initWithRange:(NSRange)aRange inAttributedString:(id)aString;
@end

@interface NSAttributedString (NSAttributedStringFittingExtension)
+ (id)textStorageFromAttributedString:(id)aString fittedToContainerSize:(NSSize)aSize;
@end

@interface NSMutableAttributedString (HSExtensions)
+ (id)hyperConvertAlignmentInParagraphStyle:(id)aStyle toAlignment:(NSUInteger)aAlignment;
+ (id)hyperConvertLineSpacingInParagraphStyle:(id)aStyle toLineSpacing:(CGFloat)aSpacing;
+ (id)hyperConvertCombinedLineSpacingInParagraphStyle:(id)aStyle toLineSpacing:(CGFloat)aSpacing;
+ (id)hyperConvertFont:(id)aFont toSize:(CGFloat)aSize;
+ (id)hyperConvertAlignmentInParagraphStyle:(id)aStyle toValue:(id)aValue;
+ (id)hyperConvertLineSpacingInParagraphStyle:(id)aStyle toValue:(id)aValue;
+ (id)hyperConvertCombinedLineSpacingInParagraphStyle:(id)aStyle toValue:(id)aValue;
+ (id)hyperConvertShadow:(id)aShadow toHaveDistanceValue:(id)aValue;
+ (id)hyperConvertShadow:(id)aShadow toHaveAngleValue:(id)aValue;
+ (id)hyperConvertShadow:(id)aShadow toHaveBlurRadiusValue:(id)aValue;
+ (id)hyperConvertShadow:(id)aShadow toHaveOffsetValue:(id)aValue;
+ (id)hyperConvertShadow:(id)aShadow toHaveDistance:(CGFloat)aDistance;
+ (id)hyperConvertShadow:(id)aShadow forEnablingShadowWithDefaultValue:(id)aValue;
+ (id)hyperConvertShadow:(id)aShadow toHaveAngle:(CGFloat)aAngle;
+ (id)hyperConvertShadow:(id)aShadow toHaveBlurRadius:(CGFloat)aRadius;
+ (id)hyperConvertShadow:(id)aShadow toHaveOffset:(NSSize)aOffset;
+ (id)hyperConvertFont:(id)aFont toFamilyInFont:(id)aFont2;
+ (id)hyperConvertFont:(id)aFont toFamily:(id)aFamily;
+ (id)hyperConvertFont:(id)aFont toSizeValue:(id)aValue;
+ (id)hyperConvertFont:(id)aFont toHaveTrait:(id)aTrait;
+ (id)hyperConvertFont:(id)aFont toNotHaveTrait:(id)aTrait;
- (void)hyperRemoveUnsupportedFormattingWithoutCheck;
- (void)hyperRemoveUnsupportedFormatting;
- (void)hyperApplyAttributeReplacements:(id)aReplacements range:(NSRange)aRange;
- (void)hyperReplaceAttributeValues:(id)aValues withAttributeValues:(id)aValues2 inRange:(NSRange)aRange;
- (void)hyperApplyAttribute:(id)aAttribute value:(id)aValue range:(NSRange)aRange;
- (void)hyperConvertActualAttribute:(id)aAttribute inRange:(NSRange)aRange toValue:(id)aValue convertAttributeSelector:(SEL)aSelector;
- (void)hyperConvertAttribute:(id)aAttribute inRange:(NSRange)aRange toValue:(id)aValue convertAttributeSelector:(SEL)aSelector;
- (void)hyperConvertAttribute:(id)aAttribute inRange:(NSRange)aRange toValue:(id)aValue convertAttributeSelector:(SEL)aSelector substituteWithDefaultValueIfNull:(BOOL)aNull;
@end

@interface NSAttributedString (HSExtensions)
+ (id)hyperActualAttribute:(id)aAttribute fromDictionary:(id)aDictionary;
+ (id)hyperAttribute:(id)aAttribute fromDictionary:(id)aDictionary;
+ (id)hyperAttribute:(id)aAttribute fromDictionary:(id)aDictionary substituteWithDefaultValueIfNull:(BOOL)aNull;
+ (id)hyperNullAttributes;
+ (id)hyperNullValueForAttribute:(id)aAttribute;
+ (BOOL)isHyperAttribute:(id)aAttribute equalToAttribute:(id)aAttribute2;
+ (BOOL)isHyperLineSpacingInParagraphStyle:(id)aStyle equalToParagraphStyle:(id)aStyle2;
+ (BOOL)isHyperCombinedLineSpacingInParagraphStyle:(id)aStyle equalToParagraphStyle:(id)aStyle2;
+ (BOOL)isHyperTextAlignmentInParagraphStyle:(id)aStyle equalToParagraphStyle:(id)aStyle2;
+ (BOOL)isHyperExpandedInFont:(id)aFont equalToExpandedInFont:(id)aFont2;
+ (BOOL)isHyperCondensedInFont:(id)aFont equalToCondensedInFont:(id)aFont2;
+ (BOOL)isHyperItalicInFont:(id)aFont equalToItalicInFont:(id)aFont2;
+ (BOOL)isHyperBoldInFont:(id)aFont equalToBoldInFont:(id)aFont2;
+ (BOOL)isHyperFamilyOfFont:(id)aFont equalToFamilyOfFont:(id)aFont2;
+ (BOOL)isHyperSizeOfFont:(id)aFont equalToSizeOfFont:(id)aFont2;
+ (id)hyperAttributeValuesForChangingAttributes:(id)aAttributes intoAttributes:(id)aAttributes2;
+ (id)hyperAttributeValuesAffectedByApplyingAttribute:(id)aAttribute value:(id)aValue inDictionary:(id)aDictionary;
+ (id)hyperAttributeValuesAffectedByApplyingOutlineValue:(id)aValue inDictionary:(id)aDictionary;
+ (id)hyperOutlineValueForEnablingOutlineInAttributeDictionary:(id)aDictionary;
+ (id)hyperDefaultOutlineValueForEnablingOutline;
+ (id)hyperDefaultOutlineColorValue;
+ (id)hyperAttributeValuesAffectedByChangingForegroundColorTo:(id)aTo inDictionary:(id)aDictionary;
+ (id)hyperAttributesDependentOnForegroundColor;
- (id)hyperActualAttribute:(id)aAttribute inRange:(NSRange)aRange appliedToWholeRange:(BOOL *)aRange2 comparator:(SEL)aComparator;
- (id)hyperAttribute:(id)aAttribute inRange:(NSRange)aRange appliedToWholeRange:(BOOL *)aRange2 comparator:(SEL)aComparator;
- (id)hyperAttribute:(id)aAttribute inRange:(NSRange)aRange appliedToWholeRange:(BOOL *)aRange2 comparator:(SEL)aComparator substituteWithDefaultValueIfNull:(BOOL)aNull;
- (id)hyperAttributedStringByRemovingUnsupportedFormatting;
- (BOOL)hyperHasUnsupportedFormatting;
- (id)hyperAttributedStringByConvertingGradientColorsToSolidColors;
- (id)hyperAttributedStringByApplyingColor:(id)aColor;
- (id)hyperReplacementsForAttributesInRange:(NSRange)aRange forAttributesWithAttributesConverter:(id)aConverter;
- (id)hyperReplacementsForAttributesInRange:(NSRange)aRange forFontWithFontConverter:(id)aConverter;
- (id)hyperReplacementsForAttributesInRange:(NSRange)aRange forApplyingOutlineValue:(id)aValue;
- (id)hyperReplacementsForForegroundColorDependentAttributesInRange:(NSRange)aRange forApplyingForegroundColor:(id)aColor;
- (id)hyperReplacementsAttributesInRange:(NSRange)aRange forApplyingAttribute:(id)aAttribute value:(id)aValue replaceIfAny:(BOOL)aAny withValue:(id)aValue2;
- (void)getHyperAttributesDictionary:(id *)aDictionary inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperSpaceBetweenCharacters:(float *)aCharacters inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperSpaceBetweenLines:(float *)aLines inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperTextAlignment:(unsigned int *)aAlignment inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperTextColor:(id *)aColor inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperShadowDistance:(float *)aDistance inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperShadowOffset:(NSSize *)aOffset inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperShadowBlurRadius:(float *)aRadius inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperShadowAngle:(float *)aAngle inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperShadowEnabled:(BOOL *)aEnabled inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperShadow:(id *)aShadow inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperOutlineColor:(id *)aColor inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperOutlineWidth:(float *)aWidth inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperOutlineEnabled:(BOOL *)aEnabled inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperExpanded:(BOOL *)aExpanded inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperCondensed:(BOOL *)aCondensed inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperUnderlined:(BOOL *)aUnderlined inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperItalic:(BOOL *)aItalic inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperBold:(BOOL *)aBold inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperFontSize:(float *)aSize inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperFontFamily:(id *)aFamily inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
- (void)getHyperFont:(id *)aFont inRange:(NSRange)aRange multipleValues:(BOOL *)aValues;
@end

@interface NSTextStorage (HSExtensions)
+ (NSSize)hyperTextBlockSizeForAttributedString:(id)aString ofHeight:(CGFloat)aHeight maxWidth:(CGFloat)aWidth;
+ (NSSize)hyperTextBlockSizeForTextStorage:(id)aStorage ofHeight:(CGFloat)aHeight maxWidth:(CGFloat)aWidth;
+ (NSSize)hyperSizeForAttributedString:(id)aString withWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2 padding:(CGFloat)aPadding;
+ (NSSize)hyperSizeForAttributedString:(id)aString withWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2;
+ (NSSize)hyperSizeForTextStorage:(id)aStorage withWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2;
+ (NSSize)hyperSizeForTextStorage:(id)aStorage withWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2 padding:(CGFloat)aPadding;
+ (NSSize)hyperSizeOfTextInTextContainer:(id)aContainer calculateOptimalSize:(BOOL)aSize;
@end

