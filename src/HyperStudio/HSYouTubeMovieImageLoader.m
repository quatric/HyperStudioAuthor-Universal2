#import "HSYouTubeMovieImageLoader.h"

@implementation HSYouTubeMovieImageLoader

- (void)download:(id)aDownload didFailWithError:(id)aError
{
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] lock];
    [_destinationPath release];
    _destinationPath = nil;
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] unlockWithCondition:2715];
}

- (void)downloadDidFinish:(id)aFinish
{
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] lock];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_destinationPath]) {
        [_destinationPath release];
        _destinationPath = nil;
    }
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] unlockWithCondition:2715];
}

- (void)download:(id)aDownload didCreateDestination:(id)aDestination
{
    [_destinationPath release];
    _destinationPath = [aDestination copy];
}

- (void)download:(id)aDownload decideDestinationWithSuggestedFilename:(id)aFilename
{
    [aDownload setDestination:[NSTemporaryDirectory() stringByAppendingPathComponent:aFilename] allowOverwrite:YES];
}

- (void)download:(id)aDownload didReceiveDataOfLength:(NSUInteger)aLength
{
}

- (void)download:(id)aDownload didReceiveResponse:(id)aResponse
{
}

// The thumbnail if it exists, else the "loading" or "offline" icon while the
// image is queued or failed.
- (id)previewImageForYouTubeMovieImageUID:(id)aUID
{
    id image;
    if ([[HSThumbnailManager sharedThumbnailManager] thumbnailExistForUID:aUID])
        return [[HSThumbnailManager sharedThumbnailManager] thumbnailForUID:aUID originalImage:nil];
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] lock];
    if ([_youtubeMovieImageUIDQueue containsObject:aUID])
        image = [HSPlayerBaseID imageNamed:@"YouTubeObjectIcon"];
    else if ([_youtubeMovieImageInvalidUIDs containsObject:aUID])
        image = [HSPlayerBaseID imageNamed:@"YouTubeObjectOffIcon"];
    else
        image = nil;
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] unlock];
    return image;
}

- (void)cancelAllRequests
{
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] lock];
    [_urlDownload cancel];
    [_urlDownload release];
    _urlDownload = nil;
    [_youtubeMovieImageUIDQueue removeAllObjects];
    [_youtubeMovieImageURLQueue removeAllObjects];
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] unlock];
}

// Queues the request (moving an already queued one to the end, unless it is
// last already) and starts the loader thread if it is not running.
- (void)requestImageForYouTubeMovieImageUID:(id)aUID URL:(id)aURL
{
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] lock];
    BOOL alreadyLast = NO;
    if ([_youtubeMovieImageUIDQueue containsObject:aUID]) {
        NSUInteger index = [_youtubeMovieImageUIDQueue indexOfObject:aUID];
        if (index >= [_youtubeMovieImageUIDQueue count] - 1)
            alreadyLast = YES;
        else {
            [_youtubeMovieImageUIDQueue removeObjectAtIndex:index];
            [_youtubeMovieImageURLQueue removeObjectAtIndex:index];
        }
    }
    if (!alreadyLast) {
        [_youtubeMovieImageUIDQueue addObject:aUID];
        [_youtubeMovieImageURLQueue addObject:aURL];
    }
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] unlock];
    if (!_running) {
        _running = YES;
        [NSThread detachNewThreadSelector:@selector(loadQueuedImages:) toTarget:self withObject:nil];
    }
    if ([_delegate respondsToSelector:@selector(youtubeMovieImageLoaded:)])
        [_delegate performSelector:@selector(youtubeMovieImageLoaded:) withObject:aUID];
}

- (void)youTubeMovieImageOffline:(id)aOffline
{
    id uid = [aOffline objectForKey:@"YouTubeMovieImageUID"];
    if ([_delegate respondsToSelector:@selector(youtubeMovieImageLoaded:)])
        [_delegate performSelector:@selector(youtubeMovieImageLoaded:) withObject:uid];
}

- (void)youTubeMovieImageReady:(id)aReady
{
    id uid = [aReady objectForKey:@"YouTubeMovieImageUID"];
    id image = [aReady objectForKey:@"YouTubeMovieImage"];
    [[HSThumbnailManager sharedThumbnailManager] thumbnailForUID:uid originalImage:image];
    if ([_delegate respondsToSelector:@selector(youtubeMovieImageLoaded:)])
        [_delegate performSelector:@selector(youtubeMovieImageLoaded:) withObject:uid];
}

- (void)runYouTubeImageDownloadURL:(id)aURL
{
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] lock];
    _urlDownload = [[NSURLDownload alloc] initWithRequest:[NSURLRequest requestWithURL:aURL] delegate:(id)self];
    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] unlock];
}

// Loader thread: downloads the last queued image on the main thread, waits up
// to 30 seconds for it, then reports it ready or offline.
- (void)loadQueuedImages:(id)aImages
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (;;) {
        id uid = nil;
        id url = nil;
        [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] lock];
        if ([_youtubeMovieImageUIDQueue count]) {
            NSUInteger count = [_youtubeMovieImageUIDQueue count];
            uid = [[_youtubeMovieImageUIDQueue objectAtIndex:count - 1] copy];
            url = [[_youtubeMovieImageURLQueue objectAtIndex:count - 1] copy];
        }
        [_destinationPath release];
        _destinationPath = nil;
        [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] unlock];
        if (!uid) {
            [pool release];
            _running = NO;
            return;
        }
        NSAutoreleasePool *innerPool = [[NSAutoreleasePool alloc] init];
        [self performSelectorOnMainThread:@selector(runYouTubeImageDownloadURL:) withObject:url waitUntilDone:NO];
        BOOL loaded = NO;
        if ([(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] lockWhenCondition:2715 beforeDate:[NSDate dateWithTimeIntervalSinceNow:30.0]]) {
            [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] unlockWithCondition:0];
            if (_destinationPath) {
                [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] lock];
                NSImage *image = [[[NSImage alloc] initWithContentsOfFile:_destinationPath] autorelease];
                [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] unlock];
                if (image) {
                    id info = [[[NSDictionary alloc] initWithObjectsAndKeys:image, @"YouTubeMovieImage", uid, @"YouTubeMovieImageUID", nil] autorelease];
                    [self performSelectorOnMainThread:@selector(youTubeMovieImageReady:) withObject:info waitUntilDone:NO];
                    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] lock];
                    [_youtubeMovieImageUIDQueue removeObject:uid];
                    [_youtubeMovieImageURLQueue removeObject:url];
                    [_youtubeMovieImageInvalidUIDs removeObject:uid];
                    [_urlDownload release];
                    _urlDownload = nil;
                    [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] unlock];
                    loaded = YES;
                }
            }
        }
        if (!loaded) {
            [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] lock];
            if (![_youtubeMovieImageInvalidUIDs containsObject:uid])
                [_youtubeMovieImageInvalidUIDs addObject:uid];
            [_youtubeMovieImageUIDQueue removeObject:uid];
            [_youtubeMovieImageURLQueue removeObject:url];
            [_urlDownload release];
            _urlDownload = nil;
            [(NSConditionLock *)[self youtubeMovieImageLoadedConditionalLock] unlock];
            id info = [[[NSDictionary alloc] initWithObjectsAndKeys:uid, @"YouTubeMovieImageUID", nil] autorelease];
            [self performSelectorOnMainThread:@selector(youTubeMovieImageOffline:) withObject:info waitUntilDone:NO];
        }
        [url release];
        [uid release];
        [innerPool release];
    }
}

- (id)youtubeMovieImageLoadedConditionalLock
{
    if (!_youtubeMovieImageLoadedConditionalLock)
        _youtubeMovieImageLoadedConditionalLock = [NSConditionLock new];
    return _youtubeMovieImageLoadedConditionalLock;
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate) {
        [_delegate release];
        _delegate = [aDelegate retain];
    }
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_delegate release];
    [self cancelAllRequests];
    [_youtubeMovieImageUIDQueue release];
    [_youtubeMovieImageURLQueue release];
    [_youtubeMovieImageInvalidUIDs release];
    [_youtubeMovieImageLoadedConditionalLock release];
    [_destinationPath release];
    [super dealloc];
}

- (id)initWithDelegate:(id)aDelegate
{
    self = [super init];
    if (self) {
        [self setDelegate:aDelegate];
        _youtubeMovieImageUIDQueue = [[NSMutableArray alloc] init];
        _youtubeMovieImageURLQueue = [[NSMutableArray alloc] init];
        _youtubeMovieImageInvalidUIDs = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
