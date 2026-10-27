#import "HyperStudioPrefix.h"
#import "KeynoteItem.h"


@interface KeynoteMedia : KeynoteItem
{
    NSString *_path;
}
- (id)maskPath;
- (id)cropGeometry;
- (id)alphaPath;
- (id)filteredImage;
- (double)endTime;
- (double)startTime;
- (BOOL)hasPlayRangeSettings;
- (NSInteger)playLoopMode;
- (CGFloat)volume;
- (id)path;
- (BOOL)pathIsRelative;
- (id)data;
- (NSInteger)mediaType;
- (id)posterImage;
- (id)internalMovieMedia;
- (void)didDetail;
- (void)didInitFromParser;
- (void)dealloc;
@end

