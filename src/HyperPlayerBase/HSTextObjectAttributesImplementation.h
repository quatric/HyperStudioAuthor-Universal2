#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSTextObjectAttributesImplementation : HSWeaklyReferencedObject <HSTextObjectAttributes, HSAttributes, HyperInterface, NSObject, HSTextAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSGenericFontAttributes, HSSystemFontPanelAdaptionInterface, HSGenericFontAttribute, HSGenericFontAttributesAttribute, HSGenericSolidColorAttributes, HSGenericSolidColorAttribute>
{
    id<HSTextObjectAttributesImplementationParent> _hyperObject;
    NSSet *_allowedInterfaces;
    id<HSCoreMutableTextInterface> _text;
    BOOL _lastAccessMultipleValues;
    BOOL _didRegisterForTextNotifications;
}
- (id)attributeObservingController;
- (void)textDidChangeAttributes:(id)aAttributes;
- (void)textDidChangeText:(id)aText;
- (void)setHyperDroppedSolidColor:(id)aColor;
- (void)setHyperSolidColor:(id)aColor;
- (id)hyperSolidColor;
- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter;
- (void)applyFontWithFontConverter:(id)aConverter;
- (id)fontForSystemFontPanelIsMultiple:(BOOL *)aMultiple;
- (void)applySystemFontPanelDocumentBackgroundColor:(id)aColor;
- (id)hyperTextAttributes;
- (void)setHyperFont:(id)aFont;
- (id)hyperFont;
- (BOOL)isHyperEmpty;
- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters;
- (CGFloat)hyperSpaceBetweenCharacters;
- (void)setHyperSpaceBetweenLines:(CGFloat)aLines;
- (CGFloat)hyperSpaceBetweenLines;
- (void)setHyperTextAlignment:(NSUInteger)aAlignment;
- (NSUInteger)hyperTextAlignment;
- (void)hyperReplaceTextWithString:(id)aString inRange:(NSRange)aRange;
- (void)hyperReplaceTextWithString:(id)aString;
- (void)hyperReplaceText:(id)aText;
- (id)hyperText;
- (void)setHyperTextColor:(id)aColor;
- (id)hyperTextColor;
- (void)finishOutlineMutating:(BOOL)aMutating;
- (void)startOutlineMutating;
- (void)setHyperOutlineColor:(id)aColor;
- (id)hyperOutlineColor;
- (void)setHyperOutlineWidth:(CGFloat)aWidth;
- (CGFloat)hyperOutlineWidth;
- (void)setHyperOutlineEnabled:(BOOL)aEnabled;
- (BOOL)isHyperOutlineEnabled;
- (void)setHyperUnderlined:(BOOL)aUnderlined;
- (BOOL)isHyperUnderlined;
- (void)setHyperCondensed:(BOOL)aCondensed;
- (BOOL)isHyperCondensed;
- (void)setHyperExpanded:(BOOL)aExpanded;
- (BOOL)isHyperExpanded;
- (void)setHyperItalic:(BOOL)aItalic;
- (BOOL)isHyperItalic;
- (void)setHyperBold:(BOOL)aBold;
- (BOOL)isHyperBold;
- (void)setHyperFontSize:(CGFloat)aSize;
- (CGFloat)hyperFontSize;
- (void)setHyperFontFamilyWithFont:(id)aFont;
- (void)setHyperFontFamily:(id)aFamily;
- (id)hyperFontFamily;
- (id)coreTextInterface;
- (BOOL)lastHyperAccessDidReturnMultipleValues;
- (id)queryHyperInterface:(id)aInterface;
- (id)hyperObject;
- (void)dealloc;
- (id)initWithHyperObject:(id)aObject;
- (id)initWithHyperObject:(id)aObject interfaces:(id)aInterfaces;
@end

