#import "HyperStudioPrefix.h"


@interface HSDoubleActionButton : NSButton
{
    SEL _doubleAction;
}
+ (Class)cellClass;
- (BOOL)sendAction:(SEL)aAction to:(id)aTo;
- (void)setDoubleAction:(SEL)aAction;
- (SEL)doubleAction;
@end

@interface HSDoubleActionButton (Accessibility)
- (id)accessibilityAttributeValue:(id)aValue;
- (id)accessibilityFocusedUIElement;
- (id)accessibilityHitTest:(NSPoint)aTest;
- (BOOL)accessibilityIsIgnored;
@end

