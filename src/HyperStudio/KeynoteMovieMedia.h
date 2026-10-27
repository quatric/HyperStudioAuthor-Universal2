#import "HyperStudioPrefix.h"
#import "KeynoteMedia.h"


@interface KeynoteMovieMedia : KeynoteMedia
{
}
- (double)endTime;
- (double)startTime;
- (BOOL)hasPlayRangeSettings;
- (CGFloat)volume;
@end

