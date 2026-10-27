#import "HSWebCamImageLoader.h"

@interface NSObject (HSWebCamImageLoaderDelegate)
- (void)webcamImageLoaded:(id)aUID;
@end

@implementation HSWebCamImageLoader

- (void)reportError:(id)aError
{
    [[self delegate] reportError:aError];
}

- (id)previewImageForWebCamUID:(id)aUID
{
    if ([[HSThumbnailManager sharedThumbnailManager] thumbnailExistForUID:aUID])
        return [[HSThumbnailManager sharedThumbnailManager] thumbnailForUID:aUID originalImage:nil];
    [(NSConditionLock *)[self webcamLoadedConditionalLock] lock];
    id image = [HSPlayerBaseID imageNamed:[_webcamInvalidUIDs containsObject:aUID] ? @"WebObjectOffIcon" : @"WebObjectIcon"];
    [(NSConditionLock *)[self webcamLoadedConditionalLock] unlock];
    return image;
}

- (void)webCamClipInfoValidatingFailed:(id)aFailed
{
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    id uid = [aFailed object];
    [center removeObserver:self name:@"WCDPWebCamIsValidNotification" object:uid];
    [center removeObserver:self name:@"WCDPWebCamIsInvalidNotification" object:uid];
    [(NSConditionLock *)[self webcamLoadedConditionalLock] lock];
    if (![_webcamInvalidUIDs containsObject:uid])
        [_webcamInvalidUIDs addObject:uid];
    [(NSConditionLock *)[self webcamLoadedConditionalLock] unlock];
    NSDictionary *info = [[[NSDictionary alloc] initWithObjectsAndKeys:uid, @"webCamUID", nil] autorelease];
    [self performSelectorOnMainThread:@selector(webCamImageOffline:) withObject:info waitUntilDone:NO];
    id errorData = [[aFailed userInfo] objectForKey:WCDPErrorDataKey];
    if (errorData != nil) {
        NSError *error = [NSKeyedUnarchiver unarchiveObjectWithData:errorData];
        if (error != nil && [error code] != 0x900cd) {
            [self cancelAllRequests];
            [self reportError:error];
        }
    }
}

- (void)webCamClipInfoValidatingComplete:(id)aComplete
{
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    id uid = [aComplete object];
    [center removeObserver:self name:@"WCDPWebCamIsValidNotification" object:uid];
    [center removeObserver:self name:@"WCDPWebCamIsInvalidNotification" object:uid];
    NSDictionary *userInfo = [aComplete userInfo];
    NSImage *image = nil;
    if (userInfo != nil)
        image = [[[NSImage alloc] initWithData:[userInfo objectForKey:WCDPTIFFDataKey]] autorelease];
    [(NSConditionLock *)[self webcamLoadedConditionalLock] lock];
    NSDictionary *info;
    SEL selector;
    if (image == nil) {
        if (![_webcamInvalidUIDs containsObject:uid])
            [_webcamInvalidUIDs addObject:uid];
        [(NSConditionLock *)[self webcamLoadedConditionalLock] unlock];
        info = [[[NSDictionary alloc] initWithObjectsAndKeys:uid, @"webCamUID", nil] autorelease];
        selector = @selector(webCamImageOffline:);
    } else {
        [_webcamInvalidUIDs removeObject:uid];
        [(NSConditionLock *)[self webcamLoadedConditionalLock] unlock];
        info = [[[NSDictionary alloc] initWithObjectsAndKeys:image, @"webCamImage", uid, @"webCamUID", nil] autorelease];
        selector = @selector(webCamImageReady:);
    }
    [self performSelectorOnMainThread:selector withObject:info waitUntilDone:NO];
}

- (void)cancelAllRequests
{
    [(NSConditionLock *)[self webcamLoadedConditionalLock] lock];
    [_webcamUIDQueue removeAllObjects];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [(NSConditionLock *)[self webcamLoadedConditionalLock] unlock];
}

- (void)requestImageForWebCamUID:(id)aUID URL:(id)aURL
{
    [(NSConditionLock *)[self webcamLoadedConditionalLock] lock];
    BOOL enqueue = YES;
    if ([_webcamUIDQueue containsObject:aUID]) {
        NSUInteger index = [_webcamUIDQueue indexOfObject:aUID];
        if (index >= [_webcamUIDQueue count] - 1)
            enqueue = NO;
        else
            [_webcamUIDQueue removeObjectAtIndex:index];
    }
    if (enqueue)
        [_webcamUIDQueue addObject:aUID];
    [(NSConditionLock *)[self webcamLoadedConditionalLock] unlock];
    if (!_running) {
        _running = YES;
        [NSThread detachNewThreadSelector:@selector(loadQueuedImages:) toTarget:self withObject:nil];
    }
    if ([_delegate respondsToSelector:@selector(webcamImageLoaded:)])
        [_delegate performSelector:@selector(webcamImageLoaded:) withObject:aUID];
}

- (void)webCamImageOffline:(id)aOffline
{
    id uid = [aOffline objectForKey:@"webCamUID"];
    if ([_delegate respondsToSelector:@selector(webcamImageLoaded:)])
        [_delegate performSelector:@selector(webcamImageLoaded:) withObject:uid];
}

- (void)webCamImageReady:(id)aReady
{
    id uid = [aReady objectForKey:@"webCamUID"];
    [[HSThumbnailManager sharedThumbnailManager] thumbnailForUID:uid originalImage:[aReady objectForKey:@"webCamImage"]];
    if ([_delegate respondsToSelector:@selector(webcamImageLoaded:)])
        [_delegate performSelector:@selector(webcamImageLoaded:) withObject:uid];
}

- (void)loadQueuedImages:(id)aImages
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (;;) {
        [(NSConditionLock *)[self webcamLoadedConditionalLock] lock];
        id uid = [_webcamUIDQueue count] != 0 ? [[_webcamUIDQueue objectAtIndex:[_webcamUIDQueue count] - 1] copy] : nil;
        [(NSConditionLock *)[self webcamLoadedConditionalLock] unlock];
        if (uid == nil)
            break;
        NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(webCamClipInfoValidatingComplete:) name:@"WCDPWebCamIsValidNotification" object:uid suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
        [center addObserver:self selector:@selector(webCamClipInfoValidatingFailed:) name:@"WCDPWebCamIsInvalidNotification" object:uid suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
        [[HSWebCamDataProvider sharedWebCamDataProvider] performSelectorOnMainThread:@selector(validateClipForWebCam:) withObject:uid waitUntilDone:NO];
        [(NSConditionLock *)[self webcamLoadedConditionalLock] lock];
        [_webcamUIDQueue removeObject:uid];
        [(NSConditionLock *)[self webcamLoadedConditionalLock] unlock];
        [uid release];
    }
    [pool release];
    _running = NO;
}

- (id)webcamLoadedConditionalLock
{
    if (_webcamLoadedConditionalLock == nil)
        _webcamLoadedConditionalLock = [NSConditionLock new];
    return _webcamLoadedConditionalLock;
}

- (void)setDelegate:(id)aDelegate
{
    [_delegate release];
    _delegate = [aDelegate retain];
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [_delegate release];
    [_webcamUIDQueue release];
    [_webcamInvalidUIDs release];
    [_webcamLoadedConditionalLock release];
    [super dealloc];
}

- (id)initWithDelegate:(id)aDelegate
{
    self = [super init];
    if (self != nil) {
        [self setDelegate:aDelegate];
        _webcamUIDQueue = [[NSMutableArray alloc] init];
        _webcamInvalidUIDs = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
