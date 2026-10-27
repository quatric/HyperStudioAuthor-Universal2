#import "HSYouTubeObjectData.h"

// Data of a YouTube object: the movie's identity, metadata and poster image.
@implementation HSYouTubeObjectData
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    if (_youTubeMovieID == nil) {
        // Older documents only stored the URL: the ID is its last path
        // component, up to any "&" parameters.
        id URL = [aRepresentation objectForKey:@"youTubeMovieURL"];
        if ([URL isKindOfClass:[NSDictionary class]]) {
            id string = [URL objectForKey:@"absoluteString"];
            if ([string isKindOfClass:[NSString class]]) {
                NSUInteger slash = [string rangeOfString:@"/" options:NSBackwardsSearch].location;
                if (slash != NSNotFound) {
                    NSUInteger start = slash + 1;
                    NSUInteger length = [string length] - start;
                    NSUInteger ampersand = [string rangeOfString:@"&" options:0 range:NSMakeRange(start, length)].location;
                    if (ampersand != NSNotFound)
                        length = ampersand - start;
                    _youTubeMovieID = [[string substringWithRange:NSMakeRange(start, length)] copy];
                }
            }
        }
    }
    if (_youTubeMovieTitle == nil) {
        id title = [aRepresentation objectForKey:@"youTubeMovieTitleURL"];
        if (title && [title isKindOfClass:[NSString class]])
            [self setYouTubeMovieTitle:title];
    }
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"youTubeMovieID"];
    [keys addObject:@"youTubeMovieURL"];
    [keys addObject:@"youTubeMovieWatchURL"];
    [keys addObject:@"youTubeMovieTitle"];
    [keys addObject:@"youTubeMovieAuthor"];
    [keys addObject:@"youTubeMovieAuthorURL"];
    [keys addObject:@"youTubeMovieDuration"];
    [keys addObject:@"youTubeMovieSizeAsString"];
    [keys addObject:@"youTubeMovieImageData"];
    return keys;
}
- (void)setYouTubeMovieImageData:(id)aData
{
    [self setYouTubeMovieImage:[[[NSImage alloc] initWithData:aData] autorelease]];
}
- (id)youTubeMovieImageData
{
    return [[self youTubeMovieImage] TIFFRepresentation];
}
- (void)setYouTubeMovieImage:(id)aImage
{
    if (_youTubeMovieImage != aImage) {
        [_youTubeMovieImage release];
        _youTubeMovieImage = [aImage retain];
    }
}
- (id)youTubeMovieImage
{
    return _youTubeMovieImage;
}
- (void)setYouTubeMovieSizeAsString:(id)aString
{
    [self setYouTubeMovieSize:NSSizeFromString(aString)];
}
- (id)youTubeMovieSizeAsString
{
    return NSStringFromSize([self youTubeMovieSize]);
}
- (void)setYouTubeMovieSize:(NSSize)aSize
{
    _youTubeMovieSize = aSize;
}
- (NSSize)youTubeMovieSize
{
    return _youTubeMovieSize;
}
- (void)setYouTubeMovieDuration:(double)aDuration
{
    _youTubeMovieDuration = aDuration;
}
- (double)youTubeMovieDuration
{
    return _youTubeMovieDuration;
}
- (void)setYouTubeMovieAuthorURL:(id)aURL
{
    if (_youTubeMovieAuthorURL != aURL) {
        [_youTubeMovieAuthorURL release];
        _youTubeMovieAuthorURL = [aURL retain];
    }
}
- (id)youTubeMovieAuthorURL
{
    return _youTubeMovieAuthorURL;
}
- (void)setYouTubeMovieAuthor:(id)aAuthor
{
    if (_youTubeMovieAuthor != aAuthor) {
        [_youTubeMovieAuthor release];
        _youTubeMovieAuthor = [aAuthor retain];
    }
}
- (id)youTubeMovieAuthor
{
    return _youTubeMovieAuthor;
}
- (void)setYouTubeMovieTitle:(id)aTitle
{
    if (_youTubeMovieTitle != aTitle) {
        [_youTubeMovieTitle release];
        _youTubeMovieTitle = [aTitle retain];
    }
}
- (id)youTubeMovieTitle
{
    return _youTubeMovieTitle;
}
- (void)setYouTubeMovieWatchURL:(id)aURL
{
    if (_youTubeMovieWatchURL != aURL) {
        [_youTubeMovieWatchURL release];
        _youTubeMovieWatchURL = [aURL retain];
    }
}
- (id)youTubeMovieWatchURL
{
    return _youTubeMovieWatchURL;
}
- (void)setYouTubeMovieURL:(id)aURL
{
    if (_youTubeMovieURL != aURL) {
        [_youTubeMovieURL release];
        _youTubeMovieURL = [aURL retain];
    }
}
- (id)youTubeMovieURL
{
    return _youTubeMovieURL;
}
- (void)setYouTubeMovieID:(id)aID
{
    if (_youTubeMovieID != aID) {
        [_youTubeMovieID release];
        _youTubeMovieID = [aID retain];
    }
}
- (id)youTubeMovieID
{
    return _youTubeMovieID;
}
- (void)dealloc
{
    [_youTubeMovieID release];
    [_youTubeMovieURL release];
    [_youTubeMovieWatchURL release];
    [_youTubeMovieTitle release];
    [_youTubeMovieAuthor release];
    [_youTubeMovieAuthorURL release];
    [_youTubeMovieImage release];
    [super dealloc];
}
@end
