#import "HSUserObject+KeynoteImporting.h"

@implementation HSUserObject (KeynoteImporting)

+ (BOOL)shouldImportFromKeynoteObject:(id)aObject
{
    return YES;
}

- (void)importKeynoteStroke:(id)aStroke
{
    if (aStroke == nil)
        return;
    id outline = [self queryHyperInterface:@protocol(HSMutableOutlineAttributes)];
    if (outline == nil)
        return;
    NSString *pattern = [aStroke patternType];
    if (pattern == nil)
        return;
    float width = ceilf([(KeynoteStroke *)aStroke width]);
    if (width > 0.0f) {
        [outline setHyperOutlineWidth:width];
        [outline setHyperOutlineColor:[aStroke color]];
        [outline setHyperOutlineEnabled:![pattern isEqualToString:@""]];
    }
}

- (void)importKeynoteShadow:(id)aShadow
{
    if (![self isKindOfClass:[HSShadowedObject class]])
        return;
    if (aShadow != nil)
        [(HSShadowedObject *)self setShadow:aShadow];
    [(HSShadowedObject *)self setShadowEnabled:aShadow != nil];
}

- (void)importKeynoteTexturedFill:(id)aFill
{
    if (aFill == nil)
        return;
    id image = [[self queryHyperInterface:@protocol(HSMutableBackgroundAttributes)] queryBackgroundGraphicsInterface:@protocol(HSMutableImage)];
    id tintedImage = [aFill tintedImage];
    if (tintedImage == nil)
        return;
    [image setHyperImage:tintedImage];
    [image setHyperImageScaling:[aFill scaleType]];
    [image setHyperImageSize:[(KeynoteTexturedFill *)aFill size]];
}

- (void)importKeynoteAngleGradient:(id)aGradient
{
    if (aGradient == nil)
        return;
    id color = [[self queryHyperInterface:@protocol(HSMutableBackgroundAttributes)] queryBackgroundGraphicsInterface:@protocol(HSMutableColor)];
    [color setHyperStartColor:[aGradient startColor]];
    [color setHyperEndColor:[aGradient endColor]];
    [color setHyperAngle:[aGradient angle]];
    [color setHyperKind:0];
}

- (void)importKeynoteFillColor:(id)aColor fromGraphicStyle:(id)aStyle
{
    if (aColor == nil)
        return;
    [[[self queryHyperInterface:@protocol(HSMutableBackgroundAttributes)] queryBackgroundGraphicsInterface:@protocol(HSMutableColor)] setHyperSolidColor:aColor];
}

- (void)importKeynoteOpacity:(CGFloat)aOpacity
{
    [[self queryHyperInterface:@protocol(HSMutableOpacityAttributes)] setHyperOpacity:aOpacity];
}

- (void)applyKeynoteGraphicStyle:(id)aStyle
{
    if (aStyle == nil)
        return;
    [self importKeynoteOpacity:[(KeynoteGraphicStyle *)aStyle opacity]];
    [self importKeynoteFillColor:[aStyle fillColor] fromGraphicStyle:aStyle];
    [self importKeynoteAngleGradient:[aStyle angleGradient]];
    [self importKeynoteTexturedFill:[aStyle texturedFill]];
    [self importKeynoteShadow:[aStyle shadow]];
    [self importKeynoteStroke:[(KeynoteGraphicStyle *)aStyle stroke]];
}

- (void)importFromKeynoteObject:(id)aObject
{
}

@end
