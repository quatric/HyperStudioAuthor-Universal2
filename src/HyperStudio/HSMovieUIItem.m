#import "HSMovieUIItem.h"

@implementation HSMovieUIItem

- (id)playbackItem
{
    return _moviePlaybackItem;
}

- (id)duration
{
    return [self movieDuration];
}

- (BOOL)isTemporary
{
    return [_moviePlaybackItem isTemporary];
}

- (BOOL)isEnabled
{
    return [_moviePlaybackItem isEnabled];
}

- (BOOL)isInAction
{
    return YES;
}

- (id)displayName
{
    id movieObject = [_moviePlaybackItem movieObjectForCard:nil];
    id name = [movieObject hyperName];
    if (name == nil)
        name = [[movieObject media] mediaName];
    return name;
}

- (void)setMoviePlaybackItem:(id)aItem
{
    if (_moviePlaybackItem != aItem) {
        [_moviePlaybackItem release];
        _moviePlaybackItem = [aItem retain];
    }
}

- (id)moviePlaybackItem
{
    return _moviePlaybackItem;
}

- (id)movieDuration
{
    if (_movieDuration == nil) {
        id movieObject = [[self moviePlaybackItem] movieObjectForCard:nil];
        NSUInteger seconds = movieObject != nil ? (NSUInteger)[movieObject hyperDuration] : 0;
        _movieDuration = [[NSCalendarDate dateWithYear:0 month:0 day:0 hour:0 minute:0 second:seconds timeZone:nil] retain];
    }
    return _movieDuration;
}

- (void)dealloc
{
    [self setMoviePlaybackItem:nil];
    [_movieDuration release];
    [super dealloc];
}

- (id)initWithMoviePlaybackItem:(id)aItem playbackItemSupport:(id)aSupport
{
    self = [super initWithPlaybackItemSupport:aSupport];
    if (self != nil)
        [self setMoviePlaybackItem:aItem];
    return self;
}

@end
