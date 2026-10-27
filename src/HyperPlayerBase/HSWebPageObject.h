#import "HyperPlayerBasePrefix.h"
#import "HSCard.h"
#import "HSShadowedObject.h"


@interface HSWebPageObject : HSShadowedObject <HSDefaultSizeSubattributes, HSAttributes, HyperInterface, NSObject, HSMutableOpacityAttributes, HSOpacityAttributes, HSOpacityAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSEffectPerObjectAttributes, HSGeometryBehaviorSubattributes, HSWebPageObjectAttributes>
{
}
+ (Class)nodeDataClass;
+ (id)defaultUnitClassNames;
- (void)setHyperOpacity:(CGFloat)aOpacity;
- (CGFloat)hyperOpacity;
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
- (NSSize)HSWebPageObject_size;
- (id)queryWebObjectHitTester;
- (id)queryNewHyperInterface:(id)aInterface;
- (void)setWebPageImage:(id)aImage;
- (id)webPageImage;
- (void)setOpacity:(CGFloat)aOpacity;
- (CGFloat)opacity;
- (void)setPageCopyright:(id)aCopyright;
- (id)pageCopyright;
- (void)setPageTimeZone:(id)aZone;
- (id)pageTimeZone;
- (void)setPageLocation:(id)aLocation;
- (id)pageLocation;
- (void)setPageCameraID:(id)aID;
- (id)pageCameraID;
- (void)setPageRefreshRate:(CGFloat)aRate;
- (CGFloat)pageRefreshRate;
- (void)setPageTitle:(id)aTitle;
- (id)pageTitle;
- (void)setPageCropPath:(id)aPath;
- (id)pageCropPath;
- (void)setPageSizeAsString:(id)aString;
- (id)pageSizeAsString;
- (void)setPageSize:(NSSize)aSize;
- (NSSize)pageSize;
- (void)setPageURL:(id)aURL;
- (id)pageURL;
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (id)attributeToNotificationMapForCodingOperation:(id)aOperation;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (void)willDisconnectFromParent;
- (void)didConnectToParent;
- (id)init;
@end

@interface HSCard (HSWebPageObjectsRegistry)
- (void)stopLoadingWebPageObjects;
- (void)startLoadingWebPageObjects;
- (void)removeWebPageObject:(id)aObject;
- (void)addWebPageObject:(id)aObject;
@end

