#import "HSDoubleActionButton.h"

@implementation HSDoubleActionButton

+ (Class)cellClass
{
    return [NSButtonCell class];
}

- (BOOL)sendAction:(SEL)aAction to:(id)aTo
{
    if ([[[self window] currentEvent] clickCount] == 2)
        aAction = [self doubleAction];
    return [super sendAction:aAction to:aTo];
}

- (void)setDoubleAction:(SEL)aAction
{
    if (_doubleAction != aAction)
        _doubleAction = aAction;
}

- (SEL)doubleAction
{
    return _doubleAction;
}
@end

@implementation HSDoubleActionButton (Accessibility)

- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute])
        return NSAccessibilityButtonRole;
    return [super accessibilityAttributeValue:aValue];
}

- (id)accessibilityFocusedUIElement
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (id)accessibilityHitTest:(NSPoint)aTest
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

@end
