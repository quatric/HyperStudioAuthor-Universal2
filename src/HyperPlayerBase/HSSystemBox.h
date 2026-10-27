#import "HyperPlayerBasePrefix.h"
#import "HSSystemObject.h"


@interface HSSystemBox : HSSystemObject <HSSystemBoxAttributes, HSSystemBoxTitleMutableAttributes, HSSystemBoxTitleAttributes, HSTitleAttributes, HSAttributes, HyperInterface, NSObject, HSTitleStringAttribute, HSTitleAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSTitleFontAttribute, HSTitleRectAttribute, HSSystemBoxTitleVisibilityAttribute, HSTitleMutableAttributes, HSSystemBoxBorderTypeAttribute, HSSystemObjectTitleAttributes, HSSystemObjectTitleAvailabilityAttribute, HSSystemObjectTitleAlignmentAttribute, HSGenericObjectStringAttribute, HSDefaultSizeSubattributes>
{
}
+ (Class)nodeDataClass;
- (id)HTML5UnsupportedFunctionalityDescription;
- (id)valuesForMDAttribute:(id)aAttribute;
- (id)supportedMDAttributes;
- (void)replaceObjectString:(id)aString inRanges:(id)aRanges;
- (void)setObjectString:(id)aString;
- (id)objectString;
- (id)hyperSizeMinValue;
- (NSSize)defaultSize;
- (void)hyperAutoSizeToFitTitle;
- (NSUInteger)hyperTitleAlignment;
- (BOOL)hasHyperTitle;
- (void)setHyperTitleVisible:(BOOL)aVisible;
- (BOOL)canToggleTitleVisibility;
- (BOOL)isHyperTitleVisible;
- (NSRect)untransformedTitleRect;
- (void)setHyperBorderType:(NSUInteger)aType;
- (NSUInteger)hyperBorderType;
- (NSUInteger)hyperTitlePosition;
- (void)setTitleFont:(id)aFont;
- (id)titleFont;
- (void)setTitle:(id)aTitle;
- (id)title;
- (id)nameBaseTemplates;
- (id)queryGroupBoxObjectHitTester;
- (id)queryNewHyperInterface:(id)aInterface;
- (BOOL)canBeDraggable;
- (BOOL)canBeResizable;
- (BOOL)canBeRotatable;
- (void)setBorderType:(NSUInteger)aType;
- (NSUInteger)borderType;
- (void)setTitleVisible:(BOOL)aVisible;
- (BOOL)isTitleVisible;
- (void)setBoxTitlePosition:(NSUInteger)aPosition;
- (NSUInteger)boxTitlePosition;
- (void)didCreateSystemView;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
@end

