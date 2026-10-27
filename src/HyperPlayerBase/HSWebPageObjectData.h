#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObjectData.h"


@interface HSWebPageObjectData : HSShadowedObjectData
{
    NSURL *_pageURL;
    NSSize _pageSize;
    NSBezierPath *_pageCropPath;
    NSString *_pageTitle;
    float _pageRefreshRate;
    NSString *_pageCameraID;
    NSString *_pageLocation;
    NSString *_pageTimeZone;
    NSString *_pageCopyright;
    NSImage *_webPageImage;
}
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setWebPageImageData:(id)aData;
- (id)webPageImageData;
- (void)setWebPageImage:(id)aImage;
- (id)webPageImage;
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
- (void)dealloc;
- (id)init;
@end

