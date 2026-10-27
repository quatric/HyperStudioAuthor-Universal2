#import "HSButtonObjectShapeBackgroundRenderlayerInPlayer.h"
@implementation HSButtonObjectShapeBackgroundRenderlayerInPlayer
// An invisible button's border: a light then a dark dashed line, offset by
// one dash so they alternate.
+ (void)renderInvisibleButtonBorderPath:(id)aPath forShapeButtonType:(id)aType
{
    NSBezierPath *path = [[aPath copy] autorelease];
    [path setLineJoinStyle:NSLineJoinStyleRound];
    CGFloat dash[2] = { 2.0, 2.0 };
    [path setLineDash:dash count:2 phase:1.0];
    [[NSColor colorWithCalibratedWhite:1.0 alpha:0.8] set];
    [self renderButtonBorderPath:path forShapeButtonType:aType];
    [path setLineDash:dash count:2 phase:dash[0] + 1.0];
    [[[NSColor blackColor] colorWithAlphaComponent:0.8] set];
    [self renderButtonBorderPath:path forShapeButtonType:aType];
}
// Free hand areas are stroked as is; other shapes get the inner half of a
// double-width stroke (so the border stays inside the shape).
+ (void)renderButtonBorderPath:(id)aPath forShapeButtonType:(id)aType
{
    if ([aType isEqualToString:@"HSFreehandAreaShapeButtonType"]) {
        [aPath stroke];
        return;
    }
    CGFloat lineWidth = [aPath lineWidth];
    [aPath setLineWidth:lineWidth + lineWidth];
    [aPath addClip];
    [aPath stroke];
    [aPath setLineWidth:lineWidth];
}
- (BOOL)isEmpty
{
    return NO;
}
// A filled highlight (control tint, half transparent) while the button is
// highlighted in interactive mode or under special access highlighting.
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    [super predrawRegion:aRegion withDelegate:aDelegate];
    BOOL specialAccess = [[[self buttonAttributes] queryHyperInterface:@protocol(HSSystemButtonSpecialAccessHighlightAttributes)] isSpecialAccessHighlightActive];
    if ([[self backgroundAttributes] backgroundGraphics] == nil
        && ![[self buttonAttributes] isButtonInvisible] && !specialAccess)
        return;
    BOOL highlighted = [[[self hyperObject] queryHyperInterface:@protocol(HSSystemButtonInteractiveModeAttributes)] isHyperHighlightedInInteractiveMode]
        && [[self buttonAttributes] hasHighlight] && ![[self cardObjectAttributes] isDropOffOnly];
    if (!highlighted && !specialAccess)
        return;
    [[[NSColor colorForControlTint:[NSColor currentControlTint]] colorWithAlphaComponent:0.5] set];
    [[[self borderAttributes] borderPath] fill];
}
- (void)drawBorderIfNeededInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id shapeAttributes = [[self hyperObject] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)];
    if (![shapeAttributes showsBorderInPlayer])
        return;
    id borderAttributes = [self borderAttributes];
    [[borderAttributes borderColor] set];
    id path = [borderAttributes borderPath];
    id type = [shapeAttributes shapeButtonType];
    if ([[self buttonAttributes] isButtonNaturallyInvisible])
        [[self class] renderInvisibleButtonBorderPath:path forShapeButtonType:type];
    else
        [[self class] renderButtonBorderPath:path forShapeButtonType:type];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id hyperObject = [self hyperObject];
    [super fillVisualizationAttributesSet:aSet];
    [aSet addAttribute:@protocol(HSSystemButtonInteractiveHighlightAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSSystemButtonSpecialAccessHighlightAttribute) forObject:hyperObject];
}
@end
