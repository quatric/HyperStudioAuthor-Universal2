#import "HSSegmentedTrackingButtonCell.h"

@implementation HSSegmentedTrackingButtonCell

// Tracked like HSTrackingButtonCell, with the images redrawn throughout.
- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp
{
    [self setHyperCachesImages:NO];
    BOOL result = [HSTrackingButtonCell trackingButtonCell:self trackMouse:aMouse inRect:aRect ofView:aView untilMouseUp:aUp];
    [self setHyperCachesImages:YES];
    return result;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

@end

@implementation SMKBackgroundButtonCell (TrackingButtonAdditions)

- (void)setHyperCachesImages:(BOOL)aImages
{
    _smkBCFlags.dontCacheImages = !aImages;
}

@end
