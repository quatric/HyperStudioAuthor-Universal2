#import "HyperStudioPrefix.h"


@interface HSMediaStripItemGeometry : NSObject
{
    HSMediaStripView *_owner;
    NSRect _frame;
    NSRect _imageFrame;
    NSRect _imageBorderFrame;
    NSRect _labelFrame;
    NSRect _sourceFrame;
    NSRect _destinationFrame;
}
- (id)accessibilityFocusedUIElement;
- (id)accessibilityHitTest:(NSPoint)aTest;
- (BOOL)accessibilityIsIgnored;
- (void)accessibilityPerformAction:(id)aAction;
- (id)accessibilityActionDescription:(id)aDescription;
- (id)accessibilityActionNames;
- (void)accessibilitySetValue:(id)aValue forAttribute:(id)aAttribute;
- (BOOL)accessibilityIsAttributeSettable:(id)aSettable;
- (id)accessibilityAttributeValue:(id)aValue;
- (id)accessibilityAttributeNames;
- (void)invalidateAnimation;
- (void)endAnimation;
- (void)animateWithProgress:(CGFloat)aProgress;
- (void)animateToFrame:(NSRect)aFrame;
- (void)offsetByPoint:(NSPoint)aPoint;
- (id)description;
- (void)setImageBorderFrame:(NSRect)aFrame;
- (NSRect)imageBorderFrame;
- (void)setLabelFrame:(NSRect)aFrame;
- (NSRect)labelFrame;
- (void)setImageFrame:(NSRect)aFrame;
- (NSRect)imageFrame;
- (void)setFrame:(NSRect)aFrame;
- (NSRect)frame;
- (id)initWithOwner:(id)aOwner;
@end

