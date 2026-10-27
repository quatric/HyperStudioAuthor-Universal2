#import "HyperPlayerBasePrefix.h"


@interface HSTransitionGridCell : NSCell
{
    NSShadow *_shadow;
    HSStringRenderer *_stringRenderer;
}
- (NSRect)titleRectForBounds:(NSRect)aBounds;
- (NSRect)imageRectForBounds:(NSRect)aBounds;
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView;
- (id)stringRenderer;
- (void)drawImage:(id)aImage inRect:(NSRect)aRect fromRect:(NSRect)aRect2 operation:(NSUInteger)aOperation fraction:(CGFloat)aFraction flip:(BOOL)aFlip;
- (id)shadow;
- (BOOL)isEmpty;
- (void)dealloc;
@end

@interface HSTransitionGridCell (NSAccessibility)
- (id)accessibilityAttributeValue:(id)aValue;
- (id)accessibilityAttributeNames;
@end

