#import "HSWebPageObjectData.h"

@implementation HSWebPageObjectData

- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    // The original refuses to decode web page objects: it returns nil
    // (and leaks the receiver).
    return nil;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"pageURL"];
    [keys addObject:@"pageSizeAsString"];
    [keys addObject:@"pageCropPath"];
    [keys addObject:@"opacity"];
    [keys addObject:@"pageTitle"];
    [keys addObject:@"pageRefreshRate"];
    [keys addObject:@"pageCameraID"];
    [keys addObject:@"pageLocation"];
    [keys addObject:@"pageTimeZone"];
    [keys addObject:@"pageCopyright"];
    [keys addObject:@"webPageImageData"];
    return keys;
}

- (void)setWebPageImageData:(id)aData
{
    [self setWebPageImage:[[[NSImage alloc] initWithData:aData] autorelease]];
}

- (id)webPageImageData
{
    return [_webPageImage TIFFRepresentation];
}

- (void)setWebPageImage:(id)aImage
{
    [aImage retain];
    [_webPageImage release];
    _webPageImage = aImage;
}

- (id)webPageImage
{
    return _webPageImage;
}

- (void)setPageCopyright:(id)aCopyright
{
    [aCopyright retain];
    [_pageCopyright release];
    _pageCopyright = aCopyright;
}

- (id)pageCopyright
{
    return _pageCopyright;
}

- (void)setPageTimeZone:(id)aZone
{
    [aZone retain];
    [_pageTimeZone release];
    _pageTimeZone = aZone;
}

- (id)pageTimeZone
{
    return _pageTimeZone;
}

- (void)setPageLocation:(id)aLocation
{
    [aLocation retain];
    [_pageLocation release];
    _pageLocation = aLocation;
}

- (id)pageLocation
{
    return _pageLocation;
}

- (void)setPageCameraID:(id)aID
{
    [aID retain];
    [_pageCameraID release];
    _pageCameraID = aID;
}

- (id)pageCameraID
{
    return _pageCameraID;
}

- (void)setPageRefreshRate:(CGFloat)aRate
{
    _pageRefreshRate = aRate;
}

- (CGFloat)pageRefreshRate
{
    return _pageRefreshRate;
}

- (void)setPageTitle:(id)aTitle
{
    [aTitle retain];
    [_pageTitle release];
    _pageTitle = aTitle;
}

- (id)pageTitle
{
    return _pageTitle;
}

- (void)setPageCropPath:(id)aPath
{
    [aPath retain];
    [_pageCropPath release];
    _pageCropPath = aPath;
}

- (id)pageCropPath
{
    return _pageCropPath;
}

- (void)setPageSizeAsString:(id)aString
{
    _pageSize = NSSizeFromString(aString);
}

- (id)pageSizeAsString
{
    return NSStringFromSize(_pageSize);
}

- (void)setPageSize:(NSSize)aSize
{
    _pageSize = aSize;
}

- (NSSize)pageSize
{
    return _pageSize;
}

- (void)setPageURL:(id)aURL
{
    [aURL retain];
    [_pageURL release];
    _pageURL = aURL;
}

- (id)pageURL
{
    return _pageURL;
}

- (void)dealloc
{
    [_pageCropPath release];
    [_pageURL release];
    [_pageTitle release];
    [_pageCameraID release];
    [_pageLocation release];
    [_pageTimeZone release];
    [_pageCopyright release];
    [_webPageImage release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _pageSize = NSZeroSize;
        _pageTitle = [@"--" retain];
        _pageCameraID = [@"--" retain];
        _pageLocation = [@"--" retain];
        _pageTimeZone = [@"--" retain];
        _pageCopyright = [@"--" retain];
        _pageRefreshRate = 0.25f;
        _webPageImage = nil;
    }
    return self;
}

@end
