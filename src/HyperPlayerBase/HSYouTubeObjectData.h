#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObjectData.h"


@interface HSYouTubeObjectData : HSShadowedObjectData
{
    NSString *_youTubeMovieID;
    NSURL *_youTubeMovieURL;
    NSURL *_youTubeMovieWatchURL;
    NSString *_youTubeMovieTitle;
    NSString *_youTubeMovieAuthor;
    NSURL *_youTubeMovieAuthorURL;
    double _youTubeMovieDuration;
    NSSize _youTubeMovieSize;
    NSImage *_youTubeMovieImage;
}
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setYouTubeMovieImageData:(id)aData;
- (id)youTubeMovieImageData;
- (void)setYouTubeMovieImage:(id)aImage;
- (id)youTubeMovieImage;
- (void)setYouTubeMovieSizeAsString:(id)aString;
- (id)youTubeMovieSizeAsString;
- (void)setYouTubeMovieSize:(NSSize)aSize;
- (NSSize)youTubeMovieSize;
- (void)setYouTubeMovieDuration:(double)aDuration;
- (double)youTubeMovieDuration;
- (void)setYouTubeMovieAuthorURL:(id)aURL;
- (id)youTubeMovieAuthorURL;
- (void)setYouTubeMovieAuthor:(id)aAuthor;
- (id)youTubeMovieAuthor;
- (void)setYouTubeMovieTitle:(id)aTitle;
- (id)youTubeMovieTitle;
- (void)setYouTubeMovieWatchURL:(id)aURL;
- (id)youTubeMovieWatchURL;
- (void)setYouTubeMovieURL:(id)aURL;
- (id)youTubeMovieURL;
- (void)setYouTubeMovieID:(id)aID;
- (id)youTubeMovieID;
- (void)dealloc;
@end

