#import "HyperPlayerBasePrefix.h"


@interface HSImageViewIgnoredAccessibility : NSImageView
{
}
- (id)accessibilityFocusedUIElement;
- (BOOL)accessibilityIsIgnored;
- (id)accessibilityHitTest:(NSPoint)aTest;
- (BOOL)accessibilityIsAttributeSettable:(id)aSettable;
- (id)accessibilityAttributeValue:(id)aValue;
@end

