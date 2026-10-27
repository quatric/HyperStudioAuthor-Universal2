#import "HSButtonObjectShapeBackgroundRenderlayerInEditor.h"
// In the editor a button hidden in the editor shows nothing, and an
// invisible button shows its dashed border.
@implementation HSButtonObjectShapeBackgroundRenderlayerInEditor
- (id)calculateBoundingRegion
{
    if ([[self buttonAttributes] isHiddenInEditor])
        return [HSRegion region];
    return [super calculateBoundingRegion];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    id hyperObject = [self hyperObject];
    [super fillBoundingRegionAttributesSet:aSet];
    [aSet addAttribute:@protocol(HSButtonObjectHiddenInEditorAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSButtonObjectShapeAlternativeBorderAttribute) forObject:hyperObject];
}
- (BOOL)requiresTransparencyLayer
{
    if ([[self buttonAttributes] isHiddenInEditor])
        return NO;
    return [super requiresTransparencyLayer];
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if (![[self buttonAttributes] isHiddenInEditor])
        [super predrawRegion:aRegion withDelegate:aDelegate];
}
- (BOOL)isEmpty
{
    if ([[self buttonAttributes] isHiddenInEditor])
        return YES;
    if (![[self buttonAttributes] isButtonInvisible] && [[self borderAttributes] isBorderless])
        return [super isEmpty];
    return NO;
}
// A naturally invisible button with its alternative border active only
// gets the dashed border when its shape type is the invisible one.
- (void)drawBorderIfNeededInRegion:(id)aRegion withDelegate:(id)aDelegate
{
    id borderAttributes = [self borderAttributes];
    if ([borderAttributes isBorderless])
        return;
    [(NSColor *)[borderAttributes borderColor] set];
    id path = [borderAttributes borderPath];
    id type = [[[self hyperObject] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] shapeButtonType];
    if (![[self buttonAttributes] isButtonNaturallyInvisible]) {
        [HSButtonObjectShapeBackgroundRenderlayerInPlayer renderButtonBorderPath:path forShapeButtonType:type];
        return;
    }
    if ([[[self hyperObject] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] isAlternativeBorderActive]
        && ![type isEqualToString:@"HSInvisibleShapeButtonType"])
        return;
    [HSButtonObjectShapeBackgroundRenderlayerInPlayer renderInvisibleButtonBorderPath:path forShapeButtonType:type];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id hyperObject = [self hyperObject];
    [super fillVisualizationAttributesSet:aSet];
    [aSet addAttribute:@protocol(HSButtonObjectVisibilityAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSButtonObjectHiddenInEditorAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSButtonObjectShapeAlternativeBorderAttribute) forObject:hyperObject];
}
@end
