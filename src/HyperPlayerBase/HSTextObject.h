#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObject.h"


@interface HSTextObject : HSShadowedObject <HSTextObjectSizingAttributes, HSMutableOpacityAttributes, HSOpacityAttributes, HSAttributes, HyperInterface, NSObject, HSOpacityAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSCoreTextParent, HSTextObjectAttributesImplementationParent, HSTextLayoutAttributes, HSTextMaximumVisibleBoundsAttribute, HSTextLayoutAttribute, HSTextObjectVerticalAlignmentAttribute, HSCocoaTextStorageAccessing, HSStringContentAttributes, HSStringValueAttribute, HSAttributedStringValueAttribute, HSGenericObjectStringAttribute, HSGeometryBehaviorSubattributes, HSDefaultSizeSubattributes>
{
    unsigned int _isInited:1;
    int _rectSide;
}
+ (CGFloat)widthOfTextContainerForTextObjectWithSize:(NSSize)aSize;
+ (id)textImplementationInterfaces;
+ (Class)nodeDataClass;
+ (id)defaultUnitClassNames;
- (id)valuesForMDAttribute:(id)aAttribute;
- (id)supportedMDAttributes;
- (void)replaceObjectString:(id)aString inRanges:(id)aRanges;
- (void)setObjectString:(id)aString;
- (id)objectString;
- (void)setHyperAttributedStringValue:(id)aValue;
- (id)hyperAttributedStringValue;
- (void)setHyperStringValue:(id)aValue;
- (id)hyperStringValue;
- (id)hyperSizeMinValue;
- (id)queryTextObjectHitTester;
- (id)queryEditorHitTester;
- (id)queryInteractiveHitTester;
- (id)queryDefaultHitTester;
- (void)text:(id)aText didChangeTextBlockAttribute:(id)aAttribute withUndoActionName:(id)aName;
- (void)text:(id)aText didChangeAttribute:(id)aAttribute affectingSize:(BOOL)aSize withUndoActionName:(id)aName;
- (void)text:(id)aText didChangeTextWithUndoActionName:(id)aName;
- (void)textDidChangeAttributes:(id)aAttributes;
- (void)textWillChangeAttributes:(id)aAttributes;
- (void)textDidChangeText:(id)aText;
- (void)textWillChangeText:(id)aText;
- (id)undoManager;
- (void)hyperAutoSizeToFitTextWithUndoActionName:(id)aName;
- (NSSize)hyperParentSize;
- (id)cocoaTextStorage;
- (NSInteger)stickyHorizontalSideForAutoresizing;
- (struct HSTextObjectAutoresizingOptions)hyperAutoresizingOptions;
- (void)hyperAutoSizeToFitText;
- (NSInteger)hyperAutoresizingMode;
- (void)setTextBlockVerticalAlignment:(NSInteger)aAlignment;
- (NSInteger)textBlockVerticalAlignment;
- (NSRect)maximumVisibleBoundsForText;
- (void)setHyperOpacity:(CGFloat)aOpacity;
- (CGFloat)hyperOpacity;
- (void)setOpacity:(CGFloat)aOpacity;
- (CGFloat)opacity;
- (void)setFontFamily:(id)aFamily;
- (id)fontFamily;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setVerticalAlignment:(NSInteger)aAlignment;
- (NSInteger)verticalAlignment;
- (void)setHeightSetByUser:(BOOL)aUser;
- (BOOL)heightSetByUser;
- (void)setWidthSetByUser:(BOOL)aUser;
- (BOOL)widthSetByUser;
- (void)setTextStorageContainsDummyString:(BOOL)aString;
- (BOOL)textStorageContainsDummyString;
- (void)setTextStyleAttributes:(id)aAttributes;
- (id)textStyleAttributes;
- (void)setSerializedText:(id)aText;
- (id)serializedText;
- (BOOL)canMoveVertically;
- (BOOL)canMoveHorizontally;
- (BOOL)canRotate;
- (BOOL)canSkew;
- (BOOL)canFlipVertically;
- (BOOL)canFlipHorizontally;
- (BOOL)canScaleVertically;
- (BOOL)canScaleHorizontally;
- (BOOL)canBreakSizeScaleAspectRatio;
- (BOOL)prefersResizingToScaling;
- (NSSize)defaultSize;
- (void)setHyperHeightSetByUser:(BOOL)aUser;
- (void)setPrimitiveHeightSetByUser:(BOOL)aUser;
- (void)setHyperWidthSetByUser:(BOOL)aUser;
- (BOOL)hyperHeightSetByUser;
- (BOOL)hyperWidthSetByUser;
- (id)nameBaseTemplates;
- (BOOL)isEmpty;
- (id)coreTextInterface;
- (id)text;
- (void)setText:(id)aText;
- (id)queryNewHyperInterface:(id)aInterface;
- (id)init;
@end

