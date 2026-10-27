#import "HyperEditorBasePrefix.h"
#import "HSSegmentedCell.h"


@interface HSSegmentedTrackingButtonCell : HSSegmentedCell <HSTrackingButtonCell>
{
    id<HSTrackingButtonCellDelegate> _delegate;
}
- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
@end

@interface SMKBackgroundButtonCell (TrackingButtonAdditions)
- (void)setHyperCachesImages:(BOOL)aImages;
@end

