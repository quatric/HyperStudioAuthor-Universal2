#import "HSSystemTextView+KeynoteImporting.h"

@implementation HSSystemTextView (KeynoteImporting)

+ (BOOL)shouldImportFromKeynoteObject:(id)aObject
{
    if (![aObject conformsToProtocol:@protocol(KeynoteTextContainer)])
        return NO;
    return [aObject exportsText];
}

// Widens the text (up to 10pt, recentring by half a point per step) when the Keynote box is too small for it.
- (void)applyKeynoteGeometry:(id)aGeometry
{
    [super applyKeynoteGeometry:aGeometry];

    NSSize size = [(KeynoteGeometry *)aGeometry size];
    id applier = [[self queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    NSTextStorage *storage = [[[NSTextStorage alloc] initWithAttributedString:[self hyperText]] autorelease];
    NSSize adapted = [self adaptResizingOfKeynoteTextStorage:storage toSize:size withGeometryBehaviorApplier:applier];

    if (adapted.height <= size.height)
        return;

    CGFloat width = size.width;
    CGFloat offset = -0.5f;
    int i;

    for (i = 0; (float)i < 10.0f; i++) {
        width += 1.0f;
        adapted = [self adaptResizingOfKeynoteTextStorage:storage toSize:NSMakeSize(width, size.height) withGeometryBehaviorApplier:applier];
        if (adapted.height <= size.height) {
            [applier setSize:adapted withLayoutGuidingContext:nil];
            [applier moveBy:NSMakeSize(offset, 0.0f) withLayoutGuidingContext:nil];
            return;
        }
        offset -= 0.5f;
    }
}

- (NSSize)adaptResizingOfKeynoteTextStorage:(id)aStorage toSize:(NSSize)aSize withGeometryBehaviorApplier:(id)aApplier
{
    NSSize adapted = [[aApplier geometryBehaviorAdaptor] adaptSize:aSize withLayoutGuidingContext:nil];
    CGFloat width = MAX(NSSizeFromString([self hyperSizeMinValue]).width, aSize.width);
    NSSize fitted = [NSTextStorage hyperSizeForTextStorage:aStorage withWidth:width fixedWidth:YES];

    return NSMakeSize(fitted.width, MAX(adapted.height, fitted.height));
}

- (void)setTextColorForKeynoteObject:(id)aObject
{
    [self notifyChange:1 ofAttribute:@protocol(HSTextColorAttribute) withUserInfo:nil];
    [[self systemTextViewForSetAccessor] setTextColor:aObject];
    [self notifyChange:2 ofAttribute:@protocol(HSTextColorAttribute) withUserInfo:nil];
}

- (void)importKeynoteOpacity:(CGFloat)aOpacity
{
    NSColor *color = [[self queryHyperInterface:@protocol(HSTextAttributes)] textColor];
    [self setTextColorForKeynoteObject:[color colorWithAlphaComponent:aOpacity]];
}

- (void)importFromKeynoteObject:(id)aObject
{
    if (![aObject conformsToProtocol:@protocol(KeynoteTextContainer)])
        return;

    id text = [aObject text];
    if (text != nil) {
        [self setHyperText:text];
        [super importFromKeynoteObject:aObject];
    }
    [self setHasVerticalScroller:NO];
    [self setScrollable:NO];
    [self setBackgroundColor:[aObject textBackgroundColor]];
}

@end
