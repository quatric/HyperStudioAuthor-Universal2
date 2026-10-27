#import "HSUIVideoMovieView.h"

@implementation HSUIVideoMovieView

- (void)setMoviePath:(id)aPath
{
    [self setMovie:[QTMovie movieWithFile:aPath error:nil]];
}

- (BOOL)isPlaying
{
    return _isPlaying;
}

- (void)stopPlaying
{
    [self pause:nil];
    _isPlaying = NO;
}

- (void)startPlaying
{
    [self play:nil];
    _isPlaying = YES;
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        _isPlaying = NO;
        [self setControllerVisible:NO];
        [self setPreservesAspectRatio:YES];
        [self setEditable:NO];
        [self setShowsResizeIndicator:NO];
    }
    return self;
}

@end
