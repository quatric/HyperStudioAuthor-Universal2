#import "HSToolSettingsViewController.h"

static BOOL HSToolSettingsGreater(float a, float b)
{
    float tolerance = MAX(a != 0.0f ? fabsf(a) : 1.0f, b != 0.0f ? fabsf(b) : 1.0f) * 0.0005f;
    return a > b + tolerance;
}

@implementation HSToolSettingsViewController

- (void)validateUserInterface
{
}

- (void)updateUI
{
}

- (void)willUnMount
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSToolSettingsDidChangeNotification object:nil];
}

- (void)didMount
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI) name:HSToolSettingsDidChangeNotification object:[[HSToolManager sharedToolManager] toolSettings]];
}

- (void)willMount
{
}

- (void)didLoadNib
{
}

- (id)backgroundColorForPreviewColor:(id)aColor
{
    BOOL isLight = YES;
    NSColor *color = aColor;
    if ([aColor hyperGradientColor] != nil) {
        id hsColor = [[aColor hyperGradientColor] hyperHSColor];
        NSColor *start = [[hsColor hyperStartColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
        isLight = !HSToolSettingsGreater([start saturationComponent], 0.3f) && HSToolSettingsGreater([start brightnessComponent], 0.6f);
        color = [hsColor hyperEndColor];
    }
    NSColor *rgb = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if (rgb != nil) {
        isLight = isLight && !HSToolSettingsGreater([rgb saturationComponent], 0.3f) && HSToolSettingsGreater([rgb brightnessComponent], 0.6f);
    } else if ([[color colorSpaceName] isEqualToString:NSPatternColorSpace]) {
        NSBitmapImageRep *rep = [[color patternImage] hyperImageRepOfClass:[NSBitmapImageRep class]];
        NSInteger wide = [rep pixelsWide];
        NSInteger high = [rep pixelsHigh];
        if (rep != nil && wide >= 1 && high >= 1) {
            // Original quirk kept: the pattern samples decide on their own, ignoring the gradient start color.
            NSInteger xs[5] = { 0, wide - 1, 0, wide - 1, wide / 2 };
            NSInteger ys[5] = { 0, 0, high - 1, high - 1, high / 2 };
            float brightness = 0.0f, saturation = 0.0f;
            for (int i = 0; i < 5; i++) {
                brightness += [[rep colorAtX:xs[i] y:ys[i]] brightnessComponent];
                saturation += [[rep colorAtX:xs[i] y:ys[i]] saturationComponent];
            }
            if (!HSToolSettingsGreater(saturation / 5.0f, 0.3f) && HSToolSettingsGreater(brightness / 5.0f, 0.6f))
                return [NSColor darkGrayColor];
            return [NSColor whiteColor];
        }
    }
    return isLight ? [NSColor darkGrayColor] : [NSColor whiteColor];
}

- (void)setParent:(id)aParent
{
    _parent = aParent;
}

- (id)parent
{
    return _parent;
}

- (NSInteger)toolTag
{
    return 0;
}

- (id)toolView
{
    return [[[HSToolManager sharedToolManager] currentTool] view];
}

- (id)toolSettingsView
{
    if (_toolSettingsView == nil && [NSBundle loadNibNamed:[self nibName] owner:self])
        [self didLoadNib];
    return _toolSettingsView;
}

- (id)nibName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc
{
    [_toolSettingsView release];
    [super dealloc];
}

@end
