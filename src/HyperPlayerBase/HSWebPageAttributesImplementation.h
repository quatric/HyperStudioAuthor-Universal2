#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSWebPageAttributesImplementation : HSWeaklyReferencedObject <HSWebPageAttributes, HSAttributes, HyperInterface, NSObject, HSWebPageURLAttribute, HSAttribute, HSWebPageSizeAttribute, HSWebPageCropPathAttribute, HSVisualAttribute, HSUndoableAttribute, HSWebPageContentAttribute, HSWebPageRectAttribute, HSWebPageTitleAttribute, HSWebPageRefreshRateAttribute, HSWebPageCameraIDAttribute, HSWebPageLocationAttribute, HSWebPageTimeZoneAttribute, HSWebPageLoadStateAttribute, HSWebPageCopyrightAttribute, HSWebPageImageAttribute>
{
    HSWebPageObject *_webPageObject;
    id<HSSizeAttributes> _sizeAttributes;
    HSWebPageRenderer *_renderer;
    int _loadState;
}
- (void)webCamValidityStateDidChange:(id)aChange;
- (void)validateWebCam;
- (id)attributeObservingController;
- (BOOL)isLoading;
- (void)reload;
- (void)stopLoading;
- (void)startLoading;
- (void)HSWebPageAttributesImplementation_webPageDidUpdateNotification:(id)aNotification;
- (id)webPageRenderer;
- (void)setWebPageImage:(id)aImage;
- (void)setWebPageCopyright:(id)aCopyright;
- (void)setWebPageLoadState:(NSInteger)aState;
- (void)setWebPageTimeZone:(id)aZone;
- (void)setWebPageLocation:(id)aLocation;
- (void)setWebPageCameraID:(id)aID;
- (void)setWebPageRefreshRate:(CGFloat)aRate;
- (void)setWebPageTitle:(id)aTitle;
- (void)setWebPageCropPath:(id)aPath;
- (void)setWebPageSize:(NSSize)aSize;
- (void)setWebPageURL:(id)aURL;
- (id)webPageImage;
- (id)webPageCopyright;
- (NSInteger)loadState;
- (id)webPageTimeZone;
- (id)webPageLocation;
- (id)webPageCameraID;
- (CGFloat)webPageRefreshRate;
- (id)webPageTitle;
- (NSRect)webPageRect;
- (id)webPageCropPath;
- (NSSize)webPageSize;
- (id)webPageURL;
- (id)hyperObject;
- (id)webPageObject;
- (void)HSWebPageAttributesImplementation_webPageObjectDidChangePageSize:(id)aSize;
- (void)HSWebPageAttributesImplementation_webPageObjectDidChangePageURL:(id)aURL;
- (void)dealloc;
- (void)HSWebPageAttributesImplementation_invalidateRenderer;
- (id)initWithWebPageObject:(id)aObject;
@end

