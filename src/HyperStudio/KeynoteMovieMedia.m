#import "KeynoteMovieMedia.h"

@implementation KeynoteMovieMedia

- (double)endTime
{
    id value = [[self nodeAttributes] objectForKey:@"end-time"];
    return value != nil ? [value floatValue] : 3.4028234663852886e+38;
}

- (double)startTime
{
    id value = [[self nodeAttributes] objectForKey:@"start-time"];
    return value != nil ? [value floatValue] : 0.0;
}

- (BOOL)hasPlayRangeSettings
{
    id start = [[self nodeAttributes] objectForKey:@"start-time"];
    id end = [[self nodeAttributes] objectForKey:@"end-time"];
    return end != nil || start != nil;
}

- (CGFloat)volume
{
    id value = [[self nodeAttributes] objectForKey:@"volume"];
    return value != nil ? [value floatValue] : 1.0f;
}

@end
