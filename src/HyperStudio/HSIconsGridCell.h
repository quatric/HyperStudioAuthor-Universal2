#import "HyperStudioPrefix.h"


@interface HSIconsGridCell : NSCell
{
    BOOL _initOnce;
}
- (NSRect)imageRectForBounds:(NSRect)aBounds;
- (NSSize)inset;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView;
- (void)drawImage:(id)aImage inRect:(NSRect)aRect fromRect:(NSRect)aRect2 operation:(NSUInteger)aOperation fraction:(CGFloat)aFraction flip:(BOOL)aFlip;
@end

