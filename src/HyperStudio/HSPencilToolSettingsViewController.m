#import "HSPencilToolSettingsViewController.h"

@implementation HSPencilToolSettingsViewController

- (void)validateBackgroundColor
{
    [_pseudoImageView setBackgroundColor:[self backgroundColorForPreviewColor:[[[HSToolManager sharedToolManager] toolSettings] drawColor]]];
}

// The pencil's sample stroke comes from the tool's settings and is drawn in the current color.
- (void)updatePreview
{
    if (_previewPath == nil) {
        HSToolManager *manager = [HSToolManager sharedToolManager];
        id dictionary = [[[[manager toolSettings] settingsForTool:[manager currentTool]] objectForKey:kToolInformationKey] objectForKey:@"previewPath"];
        if (dictionary != nil)
            _previewPath = [[NSObject objectWithExtraDictionary:dictionary] retain];
    }
    NSImage *image = nil;
    if (_previewPath != nil) {
        NSBezierPath *path = _previewPath;
        NSRect bounds = [path hyperVisualBounds];
        NSAffineTransform *transform = [NSAffineTransform hyperTranslationBy:NSMakeSize(-bounds.origin.x, -bounds.origin.y)];
        image = [[[NSImage alloc] initWithSize:bounds.size] autorelease];
        [image lockFocus];
        [transform concat];
        id color = [[[HSToolManager sharedToolManager] toolSettings] drawColor];
        id gradient = [color hyperGradientColor];
        if (gradient == nil) {
            [(NSColor *)color set];
            [path stroke];
        }
        else {
            float lineWidth = [path lineWidth];
            CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
            CGPathRef cgPath = [path hyperCGPath];
            NSRect rect = NSInsetRect(bounds, -lineWidth * 0.5f, -lineWidth * 0.5f);
            CGContextBeginPath(context);
            if (cgPath != NULL) {
                CGContextAddPath(context, cgPath);
                CGPathRelease(cgPath);
            }
            CGContextSetLineWidth(context, lineWidth);
            CGContextReplacePathWithStrokedPath(context);
            CGContextClip(context);
            [[gradient hyperHSColor] drawGradientInCGContext:context rect:rect ofBounds:rect];
        }
        [image unlockFocus];
    }
    [_previewView setImage:image];
}

- (id)colorPickingController
{
    return [[self toolView] queryHyperInterface:@protocol(HSColorPickingController)];
}

- (void)colorViewController:(id)aController changedColorTo:(id)aTo
{
    [[[HSToolManager sharedToolManager] toolSettings] setDrawColor:aTo];
    [self validateBackgroundColor];
}

- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController
{
    return YES;
}

- (void)lineWidthChanged:(id)aChanged
{
}

- (void)validateUserInterface
{
    [super validateUserInterface];
    [_colorViewController validateUserInterface];
}

- (void)updateUI
{
    [_colorViewController setColor:[[[HSToolManager sharedToolManager] toolSettings] drawColor]];
    [_pencilWidthSlider setEnabled:NO];
    [self updatePreview];
    [self validateBackgroundColor];
}

- (void)didMount
{
    [super didMount];
    [self updateUI];
}

- (id)pencilTool
{
    return [[[HSToolManager sharedToolManager] currentTool] bitmapTool];
}

- (void)didLoadNib
{
    [_colorViewController setDelegate:self];
    NSView *colorView = [_colorViewController colorView];
    [colorView setFrame:[_colorContainerView bounds]];
    [_colorContainerView addSubview:colorView];
    [[_colorViewController crayonsView] setNeedsForceLayout:YES];
}

- (id)nibName
{
    return @"PencilToolSettings";
}

- (void)dealloc
{
    [_colorViewController release];
    [super dealloc];
}

@end
