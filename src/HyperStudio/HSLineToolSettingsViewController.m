#import "HSLineToolSettingsViewController.h"

@implementation HSLineToolSettingsViewController

- (void)validateBackgroundColor
{
    [_pseudoImageView setBackgroundColor:[self backgroundColorForPreviewColor:[[[HSToolManager sharedToolManager] toolSettings] drawColor]]];
}

// Draws a horizontal stroke at the current width, stretched to fill the preview.
- (void)updatePreview
{
    NSBezierPath *path = [NSBezierPath bezierPath];
    float lineWidth = [[[HSToolManager sharedToolManager] toolSettings] strokeWidth];
    NSPoint end = NSMakePoint(lineWidth, 0.0);
    [path setLineCapStyle:NSLineCapStyleRound];
    [path moveToPoint:NSZeroPoint];
    [path lineToPoint:end];
    [path setLineWidth:lineWidth];
    NSRect bounds = [path hyperVisualBounds];
    NSRect previewBounds = [_previewView bounds];
    CGFloat extra = previewBounds.size.width - bounds.size.width;
    if (extra > 0.0) {
        end.x += extra;
        [path setAssociatedPoints:&end atIndex:1];
        bounds = [path hyperVisualBounds];
    }
    NSAffineTransform *transform = [NSAffineTransform hyperTranslationBy:NSMakeSize(-bounds.origin.x, -bounds.origin.y)];
    NSImage *image = [[[NSImage alloc] initWithSize:bounds.size] autorelease];
    [image lockFocus];
    [transform concat];
    id color = [[[HSToolManager sharedToolManager] toolSettings] drawColor];
    id gradient = [color hyperGradientColor];
    if (gradient == nil) {
        [(NSColor *)color set];
        [path stroke];
    }
    else {
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
    [_previewView setImage:image];
}

- (id)colorPickingController
{
    return [[self toolView] queryHyperInterface:@protocol(HSColorPickingController)];
}

- (void)colorViewController:(id)aController changedColorTo:(id)aTo
{
    [[[HSToolManager sharedToolManager] toolSettings] setDrawColor:aTo];
    [self updatePreview];
    [self validateBackgroundColor];
}

- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController
{
    return YES;
}

- (void)lineWidthChanged:(id)aChanged
{
    [[[HSToolManager sharedToolManager] toolSettings] setStrokeWidth:(float)(int)HSNonLinearValueForSlider(aChanged)];
}

- (void)validateUserInterface
{
    [super validateUserInterface];
    [_colorViewController validateUserInterface];
}

- (void)updateUI
{
    [_colorViewController setColor:[[[HSToolManager sharedToolManager] toolSettings] drawColor]];
    [self updatePreview];
    [self validateBackgroundColor];
}

- (void)didMount
{
    [super didMount];
    [_lineWidthSlider setFloatValue:HSLinearValueForSliderFromNonLinear(_lineWidthSlider, [[[HSToolManager sharedToolManager] toolSettings] strokeWidth])];
    [self updateUI];
}

- (id)lineTool
{
    return [[[HSToolManager sharedToolManager] currentTool] bitmapTool];
}

- (void)didLoadNib
{
    [_colorViewController setDelegate:self];
    [[_colorViewController colorView] setFrame:[_colorContainerView bounds]];
    [_colorContainerView addSubview:[_colorViewController colorView]];
    [[_colorViewController crayonsView] setNeedsForceLayout:YES];
}

- (id)nibName
{
    return @"LineToolSettings";
}

- (void)dealloc
{
    [_colorViewController release];
    [super dealloc];
}

@end
