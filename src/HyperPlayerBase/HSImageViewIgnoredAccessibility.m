#import "HSImageViewIgnoredAccessibility.h"
@implementation HSImageViewIgnoredAccessibility
// Invisible to accessibility: the parent stands in for it, its subviews are
// the parent's children.
- (id)accessibilityFocusedUIElement
{
    return NSAccessibilityUnignoredAncestor([self superview]);
}
- (BOOL)accessibilityIsIgnored
{
    return YES;
}
- (id)accessibilityHitTest:(NSPoint)aTest
{
    return NSAccessibilityUnignoredAncestor([self superview]);
}
- (BOOL)accessibilityIsAttributeSettable:(id)aSettable
{
    return NO;
}
- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityChildrenAttribute])
        return NSAccessibilityUnignoredChildren([self subviews]);
    if ([aValue isEqualToString:NSAccessibilityParentAttribute])
        return NSAccessibilityUnignoredAncestor([self superview]);
    return [super accessibilityAttributeValue:aValue];
}
@end
