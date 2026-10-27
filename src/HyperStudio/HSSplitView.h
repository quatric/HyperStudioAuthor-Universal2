#import "HyperStudioPrefix.h"


@interface HSSplitView : NSSplitView
{
    NSMutableDictionary *_viewsWithZeroSize;
    NSMutableDictionary *_collapsedSubviews;
    NSImage *_dividerBackgroundImage;
    NSImage *_dividerImage;
}
- (void)drawDividerInRect:(NSRect)aRect;
- (void)setDividerImage:(id)aImage;
- (id)dividerImage;
- (void)setDividerBackgroundImage:(id)aImage;
- (id)dividerBackgroundImage;
- (void)performDoubleClickInDividerAtIndex:(NSInteger)aIndex;
- (id)viewWithZeroSizeForSubviewAtndex:(NSInteger)aAtndex;
- (CGFloat)bottomBoundFromSubviewAtIndex:(NSInteger)aIndex;
- (NSInteger)collapsedViewIndexWithDividerAtIndex:(NSInteger)aIndex;
- (void)adjustSubviewsWithDividerAtIndex:(NSInteger)aIndex;
- (void)adjustSubviews;
- (id)collapsedSubviews;
- (BOOL)isCollapsedSubview:(id)aSubview;
- (BOOL)isCollapsedSubviewAtIndex:(NSInteger)aIndex;
- (void)uncollapseSubviewAtIndex:(NSInteger)aIndex withDividerAtIndex:(NSInteger)aIndex2;
- (void)collapseSubviewAtIndex:(NSInteger)aIndex withDividerAtIndex:(NSInteger)aIndex2;
- (CGFloat)constrainValueWithProposedDividerCoordinate:(CGFloat)aCoordinate withDividerAtIndex:(NSInteger)aIndex;
- (void)resizeSubviewsWithNewConstrainValue:(CGFloat)aValue withDividerAtIndex:(NSInteger)aIndex;
- (BOOL)isChangeCollapseStateWithMouseLocation:(CGFloat)aLocation withDividerAtIndex:(NSInteger)aIndex;
- (CGFloat)maxConstrainCoordinateWithDividerAtIndex:(NSInteger)aIndex;
- (CGFloat)minConstrainCoordinateWithDividerAtIndex:(NSInteger)aIndex;
- (NSInteger)hitTestIndexAtPoint:(NSPoint)aPoint;
- (void)trackDividerEvent:(id)aEvent;
- (void)mouseDown:(id)aDown;
- (void)dealloc;
@end

