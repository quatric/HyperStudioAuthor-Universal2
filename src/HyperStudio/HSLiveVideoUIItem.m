#import "HSLiveVideoUIItem.h"
#import "HSQTKit.h"
#import "HSCaptureDeviceList.h"

@implementation HSLiveVideoUIItem

- (id)playbackItem
{
    return _liveVideoPlaybackItem;
}

- (BOOL)isTemporary
{
    return [_liveVideoPlaybackItem isTemporary];
}

- (BOOL)isEnabled
{
    return [_liveVideoPlaybackItem isEnabled];
}

- (BOOL)isInAction
{
    return YES;
}

- (id)displayName
{
    return [_liveVideoPlaybackItem liveVideoName];
}

- (void)setLiveVideoPlaybackItem:(id)aItem
{
    if (_liveVideoPlaybackItem != aItem) {
        [_liveVideoPlaybackItem release];
        _liveVideoPlaybackItem = [aItem retain];
    }
}

- (id)liveVideoPlaybackItem
{
    return _liveVideoPlaybackItem;
}

- (id)deviceName
{
    if ([[HSSystem sharedSystem] isQTKitCapturingAvailable]) {
        NSArray *mediaTypes = [NSArray arrayWithObjects:QTMediaTypeVideo, QTMediaTypeMuxed, nil];
        HSCaptureDeviceList *deviceList;
        if (mediaTypes != nil && (deviceList = [HSCaptureDeviceList captureDeviceListForMediaTypes:mediaTypes]) != nil) {
            NSUInteger index = [[self liveVideoPlaybackItem] liveVideoDeviceIndex];
            if (index < [deviceList captureDeviceCount])
                return [deviceList localizedDisplayNameForCaptureDeviceAtIndex:index];
        }
    }
    return nil;
}

- (id)duration
{
    if (_duration == nil)
        _duration = [[NSCalendarDate dateWithYear:0 month:0 day:0 hour:0 minute:0 second:0 timeZone:nil] retain];
    return _duration;
}

- (void)dealloc
{
    [self setLiveVideoPlaybackItem:nil];
    [_duration release];
    [super dealloc];
}

- (id)initWithLiveVideoPlaybackItem:(id)aItem playbackItemSupport:(id)aSupport
{
    self = [super initWithPlaybackItemSupport:aSupport];
    if (self != nil)
        [self setLiveVideoPlaybackItem:aItem];
    return self;
}

@end
