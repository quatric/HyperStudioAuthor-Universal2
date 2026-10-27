#import "HyperPlayerBasePrefix.h"


@interface HSText : NSObject <HSTextAttributes, HSAttributes, HyperInterface, NSObject, HSGenericFontAttributes, HSSystemFontPanelAdaptionInterface, HSGenericFontAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSGenericFontAttributesAttribute, HSTextColorAttribute, HSBaseTextAttribute, HSBackgroundColorAttribute, HSTextViewTextAttribute, HSCoreTextParent, HSSystemTextViewFontTraitsAttributes>
{
    HSCoreText *_text;
    NSFont *_font;
    NSDictionary *_textAttributesBackup;
    HSNode *_owner;
    unsigned int _lastAccessMultipleValues:1;
}
- (void)setHyperSpaceBetweenLines:(CGFloat)aLines;
- (CGFloat)hyperSpaceBetweenLines;
- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters;
- (CGFloat)hyperSpaceBetweenCharacters;
- (void)setHyperShadowBlurRadius:(CGFloat)aRadius;
- (void)setHyperShadowOffset:(NSSize)aOffset;
- (void)setHyperShadowAngle:(CGFloat)aAngle;
- (void)setHyperShadowDistance:(CGFloat)aDistance;
- (CGFloat)hyperShadowDistance;
- (CGFloat)hyperShadowBlurRadius;
- (NSSize)hyperShadowOffset;
- (CGFloat)hyperShadowAngle;
- (void)setHyperShadowEnabled:(BOOL)aEnabled;
- (BOOL)isHyperShadowEnabled;
- (BOOL)hasMultipleShadowStyles;
- (void)setHyperAlignment:(NSInteger)aAlignment;
- (NSInteger)hyperAlignment;
- (void)finishOutlineMutating:(BOOL)aMutating;
- (void)startOutlineMutating;
- (void)setHyperOutlineWidth:(CGFloat)aWidth;
- (CGFloat)hyperOutlineWidth;
- (void)setHyperOutlineColor:(id)aColor;
- (id)hyperOutlineColor;
- (void)setHyperOutlineEnabled:(BOOL)aEnabled;
- (BOOL)isHyperOutlineEnabled;
- (void)setHyperExpanded:(BOOL)aExpanded;
- (BOOL)isHyperExpanded;
- (void)setHyperCondensed:(BOOL)aCondensed;
- (BOOL)isHyperCondensed;
- (void)setHyperItalic:(BOOL)aItalic;
- (BOOL)isHyperItalic;
- (void)setHyperBold:(BOOL)aBold;
- (BOOL)isHyperBold;
- (void)setHyperUnderlined:(BOOL)aUnderlined;
- (BOOL)isHyperUnderlined;
- (void)setHyperFontSize:(CGFloat)aSize;
- (CGFloat)hyperFontSize;
- (void)setHyperFontFamily:(id)aFamily;
- (id)hyperFontFamily;
- (id)attributeObservingController;
- (void)applySystemFontPanelDocumentBackgroundColor:(id)aColor;
- (id)hyperTextAttributes;
- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter;
- (void)applyFontWithFontConverter:(id)aConverter;
- (id)fontForSystemFontPanelIsMultiple:(BOOL *)aMultiple;
- (void)setHyperTextAttributes:(id)aAttributes;
- (void)setHyperTextAttributes:(id)aAttributes range:(NSRange)aRange;
- (void)setHyperFont:(id)aFont;
- (id)hyperFont;
- (void)applyHyperTextAttributesDictionary:(id)aDictionary;
- (void)setHyperPlainText:(id)aText;
- (id)hyperPlainText;
- (void)replaceTextInRange:(NSRange)aRange withAttributedString:(id)aString;
- (void)setHyperText:(id)aText;
- (id)hyperText;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (void)setTextColor:(id)aColor;
- (id)textColor;
- (id)hyperString;
- (void)text:(id)aText didChangeTextBlockAttribute:(id)aAttribute withUndoActionName:(id)aName;
- (void)text:(id)aText didChangeAttribute:(id)aAttribute affectingSize:(BOOL)aSize withUndoActionName:(id)aName;
- (void)text:(id)aText didChangeTextWithUndoActionName:(id)aName;
- (void)textDidChangeAttributes:(id)aAttributes;
- (void)textWillChangeAttributes:(id)aAttributes;
- (void)textDidChangeText:(id)aText;
- (void)textWillChangeText:(id)aText;
- (id)undoManager;
- (void)setFont:(id)aFont;
- (id)font;
- (void)backupTextAttributes;
- (void)restoreTextAttributes;
- (void)dealloc;
- (void)setOwner:(id)aOwner;
- (id)initWithOwner:(id)aOwner;
- (id)hyperObject;
@end

