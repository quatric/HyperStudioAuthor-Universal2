#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObject.h"


@interface HSVectorBrushObject : HSShadowedObject <HSStandaloneSizeAttributes, HSSizeAttributes, HSAttributes, HyperInterface, NSObject, HSWidthAttribute, HSSizeAttribute, HSGeometryAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSHeightAttribute, HSStandaloneResizingBehaviorAttributes, HSResizingBehaviorAttributes, HSSizeAspectRatioMaintainingPreferenceAttribute, HSGeometryBehaviorAttribute, HSMutableOpacityAttributes, HSOpacityAttributes, HSOpacityAttribute>
{
}
+ (id)defaultUnitClassNames;
+ (Class)nodeDataClass;
- (BOOL)shouldBeExportedAsImage;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (void)HSVectorBrushObject_toolBoundsDidChange:(id)aChange;
- (id)queryVectorGraphicObjectHitTester;
- (id)queryEditorHitTester;
- (id)queryInteractiveHitTester;
- (id)queryDefaultHitTester;
- (void)setHyperOpacity:(CGFloat)aOpacity;
- (CGFloat)hyperOpacity;
- (BOOL)prefersToMaintainSizeAspectRatio;
- (BOOL)canResizeVertically;
- (BOOL)canResizeHorizontally;
- (BOOL)canBreakSizeAspectRatio;
- (NSSize)size;
- (NSSize)defaultSize;
- (CGFloat)height;
- (CGFloat)width;
- (NSSize)HSVectorBrushObject_brushSize;
- (id)nonLocalizedObjectKindKey;
- (id)queryNewHyperInterface:(id)aInterface;
- (void)dealloc;
- (void)setToolSettings:(id)aSettings touchStorage:(id)aStorage geometryTransform:(CGAffineTransform)aTransform geometryFlippedHorizontally:(BOOL)aHorizontally settingsWrapperInitialDelegate:(id)aDelegate;
- (id)initWithToolSettings:(id)aSettings touchStorage:(id)aStorage geometryTransform:(CGAffineTransform)aTransform geometryFlippedHorizontally:(BOOL)aHorizontally settingsWrapperInitialDelegate:(id)aDelegate;
- (id)init;
@end

