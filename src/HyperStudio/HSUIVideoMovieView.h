#import "HyperStudioPrefix.h"


@interface HSUIVideoMovieView : QTMovieView
{
    BOOL _isPlaying;
}
- (void)setMoviePath:(id)aPath;
- (BOOL)isPlaying;
- (void)stopPlaying;
- (void)startPlaying;
- (id)initWithFrame:(NSRect)aFrame;
@end

