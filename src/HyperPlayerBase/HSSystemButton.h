#import "HyperPlayerBasePrefix.h"
#import "HSSystemObject.h"


@interface HSSystemButton : HSSystemObject <HSSystemButtonAttributes, HSAttributes, HyperInterface, NSObject, HSTitleMutableAttributes, HSTitleAttributes, HSTitleStringAttribute, HSTitleAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSTitleFontAttribute, HSTitleRectAttribute, HSSystemControlSizeAttribute, HSSystemButtonBorderAttribute, HSSystemTransparencyAttribute, HSSystemButtonContinuousAttribute, HSSystemEnabledAttribute, HSSystemObjectTitleAttributes, HSSystemObjectTitleAvailabilityAttribute, HSSystemObjectTitleAlignmentAttribute, HSSystemButtonInteractiveModeAttributes, HSSystemButtonInteractiveHighlightAttribute, HSSystemButtonSpecialAccessHighlightAttributes, HSSystemButtonSpecialAccessHighlightAttribute, HSGenericFontAttributes, HSSystemFontPanelAdaptionInterface, HSGenericFontAttribute, HSGenericFontAttributesAttribute>
{
    BOOL _isSpecialAccessHighlightActive;
}
+ (Class)nodeDataClass;
- (id)valuesForMDAttribute:(id)aAttribute;
- (id)supportedMDAttributes;
- (void)setObjectName:(id)aName;
- (id)objectName;
- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter;
- (void)applyFontWithFontConverter:(id)aConverter;
- (id)fontForSystemFontPanelIsMultiple:(BOOL *)aMultiple;
- (void)applySystemFontPanelDocumentBackgroundColor:(id)aColor;
- (BOOL)isHyperExpanded;
- (BOOL)isHyperCondensed;
- (BOOL)isHyperItalic;
- (BOOL)isHyperBold;
- (CGFloat)hyperFontSize;
- (id)hyperFontFamily;
- (void)setHyperExpanded:(BOOL)aExpanded;
- (void)setHyperCondensed:(BOOL)aCondensed;
- (void)setHyperItalic:(BOOL)aItalic;
- (void)setHyperBold:(BOOL)aBold;
- (void)setHyperFontSize:(CGFloat)aSize;
- (void)setHyperFontFamily:(id)aFamily;
- (void)setHyperFont:(id)aFont;
- (id)hyperTextAttributes;
- (id)hyperFont;
- (NSSize)defaultSize;
- (void)setSpecialAccessHighlightActive:(BOOL)aActive;
- (BOOL)isSpecialAccessHighlightActive;
- (void)setHyperHighlightedInInteractiveMode:(BOOL)aMode;
- (BOOL)isHyperHighlightedInInteractiveMode;
- (void)hyperAutoSizeToFitTitle;
- (NSUInteger)hyperTitleAlignment;
- (void)setTitleFont:(id)aFont;
- (id)titleFont;
- (BOOL)hasHyperTitle;
- (BOOL)canBeDraggable;
- (BOOL)canBeResizable;
- (BOOL)canBeRotatable;
- (void)setEnabled:(BOOL)aEnabled;
- (BOOL)isEnabled;
- (void)setContinuous:(BOOL)aContinuous;
- (BOOL)isContinuous;
- (void)setTransparent:(BOOL)aTransparent;
- (BOOL)isTransparent;
- (void)setBordered:(BOOL)aBordered;
- (BOOL)isBordered;
- (void)hyperSizeToFitContentHorizontally:(BOOL)aHorizontally vertically:(BOOL)aVertically;
- (void)hyperSizeToFitContent;
- (NSRect)untransformedTitleRect;
- (void)setControlSize:(NSUInteger)aSize;
- (NSUInteger)controlSize;
- (void)setTitle:(id)aTitle;
- (id)title;
- (id)queryNewHyperInterface:(id)aInterface;
- (void)setSelected:(BOOL)aSelected;
- (BOOL)isSelected;
- (CGFloat)fontSize;
- (id)nameBaseTemplates;
- (id)queryButtonObjectHitTester;
- (id)queryInteractivePlayerItem;
- (id)attributeToNotificationMapForCodingOperation:(id)aOperation;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

