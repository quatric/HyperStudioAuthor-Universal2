#import "HyperStudioPrefix.h"


@interface HSYouTubeMovieImageLoader : NSObject
{
    NSMutableArray *_youtubeMovieImageUIDQueue;
    NSMutableArray *_youtubeMovieImageURLQueue;
    NSMutableArray *_youtubeMovieImageInvalidUIDs;
    NSString *_destinationPath;
    NSConditionLock *_youtubeMovieImageLoadedConditionalLock;
    NSURLDownload *_urlDownload;
    BOOL _running;
    id _delegate;
}
- (void)download:(id)aDownload didFailWithError:(id)aError;
- (void)downloadDidFinish:(id)aFinish;
- (void)download:(id)aDownload didCreateDestination:(id)aDestination;
- (void)download:(id)aDownload decideDestinationWithSuggestedFilename:(id)aFilename;
- (void)download:(id)aDownload didReceiveDataOfLength:(NSUInteger)aLength;
- (void)download:(id)aDownload didReceiveResponse:(id)aResponse;
- (id)previewImageForYouTubeMovieImageUID:(id)aUID;
- (void)cancelAllRequests;
- (void)requestImageForYouTubeMovieImageUID:(id)aUID URL:(id)aURL;
- (void)youTubeMovieImageOffline:(id)aOffline;
- (void)youTubeMovieImageReady:(id)aReady;
- (void)runYouTubeImageDownloadURL:(id)aURL;
- (void)loadQueuedImages:(id)aImages;
- (id)youtubeMovieImageLoadedConditionalLock;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
- (id)initWithDelegate:(id)aDelegate;
@end

