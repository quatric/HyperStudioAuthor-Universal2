#import "HSRegistrationKeyEquivalentButton.h"

@implementation HSRegistrationKeyEquivalentButton

- (BOOL)canBecomeKeyView
{
    return NO;
}

@end

@implementation HSRegistrationLinkButton

- (void)resetCursorRects
{
    [self addCursorRect:[[self cell] drawingRectForBounds:[self bounds]] cursor:[NSCursor pointingHandCursor]];
}

@end
