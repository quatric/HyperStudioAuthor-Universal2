#import "HyperEditorBasePrefix.h"
#import "HSAppearanceButtonCell.h"


@interface HSTrackingButtonCell : HSAppearanceButtonCell <HSTrackingButtonCell>
{
    id<HSTrackingButtonCellDelegate> _delegate;
}
+ (BOOL)trackingButtonCell:(id)aCell trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp;
- (BOOL)trackMouse:(id)aMouse inRect:(NSRect)aRect ofView:(id)aView untilMouseUp:(BOOL)aUp;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
@end

