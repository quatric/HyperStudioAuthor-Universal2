#import "HSPlaybackUIItem.h"

@implementation HSPlaybackUIItem

- (id)isEnableForSorting
{
    return [NSNumber numberWithBool:[self isEnabled]];
}

- (NSInteger)localizedCompare:(id)aCompare
{
    return [[self displayName] localizedCompare:[aCompare displayName]];
}

- (id)playbackItem
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)duration
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)deviceName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)isTemporary
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isEnabled
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)isInAction
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (id)displayName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setPlaybackItemSupport:(id)aSupport
{
    if (_playbackItemSupport != aSupport) {
        [_playbackItemSupport release];
        _playbackItemSupport = [aSupport retain];
    }
}

- (id)playbackItemSupport
{
    return _playbackItemSupport;
}

- (void)dealloc
{
    [self setPlaybackItemSupport:nil];
    [super dealloc];
}

- (id)initWithPlaybackItemSupport:(id)aSupport
{
    self = [super init];
    if (self != nil)
        [self setPlaybackItemSupport:aSupport];
    return self;
}

@end
