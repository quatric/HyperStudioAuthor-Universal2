#import "HSATemplateImageBrowserCell.h"

@implementation HSATemplateImageBrowserCell

- (CGRect)CGRectFromRect:(NSRect)aRect
{
    return CGRectMake(aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
}

static NSRect HSATemplateCellPixelAlignedRect(NSRect aRect)
{
    return NSMakeRect(floorf(aRect.origin.x), floorf(aRect.origin.y), ceilf(aRect.size.width), ceilf(aRect.size.height));
}

- (NSRect)frame
{
    return HSATemplateCellPixelAlignedRect([super frame]);
}

- (NSRect)imageFrame
{
    return HSATemplateCellPixelAlignedRect([super imageFrame]);
}

- (NSRect)titleFrame
{
    NSRect title = [super titleFrame];
    NSRect image = self != nil ? [self imageFrame] : NSZeroRect;
    return NSMakeRect(title.origin.x, (image.origin.y - title.size.height) + -10.0f, title.size.width, title.size.height);
}

- (NSUInteger)imageAlignment
{
    return 5;
}

- (CGPathRef)selectionPathForRect:(NSRect)aRect
{
    return [[NSBezierPath bezierPathWithRoundedRect:NSInsetRect(aRect, -2.5f, -2.5f) xRadius:1.0f yRadius:1.0f] hyperCGPath];
}

- (id)layerForType:(id)aType
{
    NSRect frame = self != nil ? [self frame] : NSZeroRect;
    NSRect image = self != nil ? [self imageFrame] : NSZeroRect;
    NSRect imageInCell = NSMakeRect(image.origin.x - frame.origin.x, image.origin.y - frame.origin.y, image.size.width, image.size.height);
    id layer = nil;
    if (aType == IKImageBrowserCellForegroundLayer) {
        if ([self isSelected]) {
            CGPathRef path = [self selectionPathForRect:imageInCell];
            CAShapeLayer *outline = [CAShapeLayer layer];
            [outline setFrame:NSRectToCGRect(NSMakeRect(0, 0, frame.size.width, frame.size.height))];
            [outline setStrokeColor:[[NSColor colorWithDeviceRed:0.9372549f green:0.8117647f blue:0.2784314f alpha:1.0f] BT_coreGraphicsColor]];
            [outline setFillColor:[[NSColor clearColor] BT_coreGraphicsColor]];
            [outline setLineWidth:3.0f];
            [outline setPath:path];
            CGPathRelease(path);
            layer = outline;
        }
    }
    if (aType == IKImageBrowserCellSelectionLayer) {
        return [CALayer layer];
    }
    if (aType == IKImageBrowserCellBackgroundLayer) {
        layer = [CALayer layer];
        CALayer *reflection = [CALayer layer];
        CGRect imageRect = self != nil ? [self CGRectFromRect:imageInCell] : CGRectZero;
        CGRect container = self != nil ? [self imageContainerFrame] : CGRectZero;
        imageRect.size.height = ceilf(container.size.height * 0.25f);
        imageRect.origin.y = imageRect.origin.y - (CGRectGetHeight(imageRect) + 1.0f);
        [reflection setFrame:imageRect];
        [reflection setName:@"ReflectionLayer"];
        [reflection setDelegate:self];
        [reflection setNeedsDisplay];
        [layer addSublayer:reflection];
        CAGradientLayer *fade = [CAGradientLayer layer];
        [fade setColors:[NSArray arrayWithObjects:(id)[[[NSColor whiteColor] colorWithAlphaComponent:0.0f] BT_coreGraphicsColor], (id)[[[NSColor whiteColor] colorWithAlphaComponent:0.22f] BT_coreGraphicsColor], nil]];
        [fade setFrame:[reflection bounds]];
        [reflection setMask:fade];
        return layer;
    }
    if (layer != nil || aType == IKImageBrowserCellForegroundLayer) {
        return layer;
    }
    return [super layerForType:aType];
}

- (void)drawLayer:(id)aLayer inContext:(CGContextRef)aContext
{
    if (![[aLayer name] isEqualToString:@"ReflectionLayer"]) {
        return;
    }
    NSRect image = self != nil ? [self imageFrame] : NSZeroRect;
    CGRect imageRect = self != nil ? [self CGRectFromRect:image] : CGRectZero;
    CGImageRef cgImage = [[[self representedItem] imageRepresentation] CGImageForProposedRect:NULL context:nil hints:nil];
    CGContextSaveGState(aContext);
    CGContextTranslateCTM(aContext, 0, CGRectGetHeight([aLayer bounds]));
    CGContextScaleCTM(aContext, 1.0f, -1.0f);
    CGContextDrawImage(aContext, CGRectMake(0, 0, CGRectGetWidth(imageRect), CGRectGetHeight(imageRect)), cgImage);
    CGContextRestoreGState(aContext);
}

@end
