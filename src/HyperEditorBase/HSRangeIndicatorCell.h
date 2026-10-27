#import "HyperEditorBasePrefix.h"


@interface HSRangeIndicatorCell : NSActionCell
{
    NSImage *_activeIndicatorImage;
    NSImage *_indicatorImage;
    NSImage *_indicatorBoundImage;
    NSImage *_activeIndicatorBoundImage;
    id _parent;
}
+ (NSSize)minimalCellSize;
- (void)setParent:(id)aParent;
- (id)parent;
- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView;
- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView;
- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)controlTintDidChange:(id)aChange;
- (void)setupImages;
- (void)dealloc;
- (id)init;
@end

