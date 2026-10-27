#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObject.h"


@interface HSVectorGraphicsObject : HSShadowedObject <HSSizeNodeStorage, NSObject, HSLineEndingContainer, HSAttributes, HyperInterface, HSVectorGraphicsTailEndingAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSVectorGraphicsHeadEndingAttribute, HSMutableOpacityAttributes, HSOpacityAttributes, HSOpacityAttribute, HSGenericSolidColorAttributes, HSGenericSolidColorAttribute, HSBackgroundRenderer, HSMutableBackgroundAttributes, HSBackgroundAttributes, HSBackgroundGraphicsAttribute, HSBackgroundAttribute, HSBackgroundBoundsAttribute, HSBackgroundAttributesContainerPrimitives, HSGeometryBehaviorSubattributes>
{
}
+ (Class)concreteClassForBezierPath:(id)aPath;
+ (id)backgroundAttributesSerializationKey;
+ (Class)nodeDataClass;
+ (id)defaultUnitClassNames;
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (NSRect)boundsForXMLStoring;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)shouldBeExportedAsImage;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)queryVectorGraphicObjectHitTester;
- (id)queryEditorHitTester;
- (id)queryInteractiveHitTester;
- (id)queryDefaultHitTester;
- (NSRect)backgroundBounds;
- (id)hyperBackgroundThumbnailForSize:(NSSize)aSize;
- (void)setHyperBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject;
- (void)setBackgroundThumbnail:(id)aThumbnail;
- (id)backgroundThumbnail;
- (void)_setBackgroundGraphics:(id)aGraphics;
- (id)backgroundGraphics;
- (void)setHyperDroppedSolidColor:(id)aColor;
- (void)setHyperSolidColor:(id)aColor;
- (void)setHyperOpacity:(CGFloat)aOpacity;
- (id)hyperSolidColor;
- (CGFloat)hyperOpacity;
- (id)hyperTailEnding;
- (id)hyperHeadEnding;
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
- (void)setVg:(id)aVg;
- (id)vg;
- (id)tailEnding;
- (id)headEnding;
- (void)appendVectorGraphicsObject:(id)aObject;
- (void)setTailEnding:(id)aEnding;
- (void)setHeadEnding:(id)aEnding;
- (void)setSizeAsString:(id)aString;
- (id)sizeAsString;
- (void)setSize:(NSSize)aSize;
- (NSSize)size;
- (void)setObjectKindName:(id)aName;
- (id)objectKindName;
- (id)nonLocalizedObjectKindKey;
- (void)loadObjectStyleDictionaryRepresentation:(id)aRepresentation;
- (void)setStrokeColor:(id)aColor;
- (id)strokeColor;
- (void)setExtraBezierPath:(id)aPath;
- (void)setBezierPath:(id)aPath;
- (id)extraBezierPath;
- (id)bezierPath;
- (void)setLineDashInfoKey:(id)aKey;
- (void)setLineDashInfo:(id)aInfo;
- (id)lineDashInfoKey;
- (id)lineDashInfo;
- (id)attributeToNotificationMapForCodingOperation:(id)aOperation;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (void)setOpacity:(CGFloat)aOpacity;
- (CGFloat)opacity;
- (id)queryNewHyperInterface:(id)aInterface;
- (id)initWithBezierPath:(id)aPath originAtPoint:(NSPoint)aPoint;
@end

@interface HSCurveObject : HSVectorGraphicsObject
{
}
+ (id)extraClassNameForStoring;
@end

@interface HSShapeObject : HSCurveObject
{
}
@end

