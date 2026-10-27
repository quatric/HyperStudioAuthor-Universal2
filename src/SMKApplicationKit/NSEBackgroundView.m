#import "NSEBackgroundView.h"

// A rectangle moved to whole device pixels.
static NSRect integralInDevice(NSRect rect, CGAffineTransform ctm, CGAffineTransform inverse)
{
    CGRect r = CGRectIntegral(CGRectApplyAffineTransform(NSRectToCGRect(rect), ctm));
    return NSRectFromCGRect(CGRectApplyAffineTransform(r, inverse));
}

@implementation NSEBackgroundView

// The color fills the view; the image is drawn by _backgroundImageScaling (an
// NSImageScaling: 0 proportionally down, 1 axes independently, 2 none
// (centered), 3 proportionally up or down) on whole device pixels. A scaled
// image keeps its margins unscaled: it's drawn in nine parts.
- (void)drawRect:(NSRect)aRect
{
    if (_backgroundColor) {
        [_backgroundColor setFill];
        NSRectFillUsingOperation([self bounds], NSCompositingOperationSourceOver);
    }
    if (!_backgroundImage)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGAffineTransform ctm = CGContextGetCTM(context);
    CGAffineTransform inverse = CGAffineTransformInvert(ctm);
    NSRect bounds = [self bounds];
    NSSize size = [_backgroundImage size];
    NSRect dest = bounds;
    BOOL scaled;
    // half of 1/256 of a device pixel, in user space
    float slackX = 0, slackY = 0;
    if (_backgroundImageScaling == NSImageScaleAxesIndependently) {
        slackX = hypotf(ctm.a, ctm.b) * 0.5 / 256.0;
        slackY = hypotf(ctm.c, ctm.d) * 0.5 / 256.0;
        scaled = bounds.size.width < size.width - slackX || size.width + slackX < bounds.size.width
              || bounds.size.height < size.height - slackY || size.height + slackY < bounds.size.height;
    }
    else if (_backgroundImageScaling == NSImageScaleProportionallyDown || _backgroundImageScaling == NSImageScaleProportionallyUpOrDown) {
        float sx, sy;
        if (_backgroundImageScaling == NSImageScaleProportionallyUpOrDown) {
            sx = size.width > 0 ? bounds.size.width / size.width : 1.0;
            sy = size.height > 0 ? bounds.size.height / size.height : 1.0;
        }
        else {
            sx = bounds.size.width < size.width ? bounds.size.width / size.width : 1.0;
            sy = bounds.size.height < size.height ? bounds.size.height / size.height : 1.0;
        }
        float s = sx;
        if (sx != sy) {
            if (sy <= sx) {
                dest.size.width = size.width * sy;
                dest.origin.x = bounds.origin.x + (bounds.size.width - dest.size.width) * 0.5;
                s = sy;
            }
            else {
                dest.size.height = size.height * sx;
                dest.origin.y = bounds.origin.y + (bounds.size.height - dest.size.height) * 0.5;
            }
        }
        scaled = s < 0.9999 || 1.0001 < s;
    }
    else {
        dest = NSMakeRect(bounds.origin.x + (bounds.size.width - size.width) * 0.5,
                          bounds.origin.y + (bounds.size.height - size.height) * 0.5, size.width, size.height);
        scaled = NO;
    }
    NSRect d = integralInDevice(dest, ctm, inverse);
    if (scaled) {
        if (_backgroundImageScaling != NSImageScaleAxesIndependently) {
            slackX = hypotf(ctm.a, ctm.b) * 0.5 / 256.0;
            slackY = hypotf(ctm.c, ctm.d) * 0.5 / 256.0;
        }
        if (slackX < _leftUnscaledBackgroundImageMargin || slackX < _rightUnscaledBackgroundImageMargin
            || slackY < _topUnscaledBackgroundImageMargin || slackY < _bottomUnscaledBackgroundImageMargin) {
            // margins no larger than the image, or than the view (shrunk alike)
            float left = MIN(_leftUnscaledBackgroundImageMargin, size.width);
            float right = MIN(_rightUnscaledBackgroundImageMargin, size.width);
            if (d.size.width < left + right) {
                float f = d.size.width / (left + right);
                left *= f;
                right *= f;
            }
            float bottom = MIN(_bottomUnscaledBackgroundImageMargin, size.height);
            float top = MIN(_topUnscaledBackgroundImageMargin, size.height);
            if (d.size.height < top + bottom) {
                float f = d.size.height / (top + bottom);
                bottom *= f;
                top *= f;
            }
            NSRect inner = integralInDevice(NSMakeRect(d.origin.x + left, d.origin.y + bottom,
                                                       d.size.width - left - right, d.size.height - bottom - top), ctm, inverse);
            // the parts, on the pixel grid: their widths and heights in the view are the image's
            float leftW = NSMinX(inner) - NSMinX(d);
            float rightW = NSMaxX(d) - NSMaxX(inner);
            float bottomH = NSMinY(inner) - NSMinY(d);
            float topH = NSMaxY(d) - NSMaxY(inner);
            float middleW = size.width - leftW - rightW;
            float middleH = size.height - bottomH - topH;
            float topY = bottomH + middleH;
            float rightX = leftW + middleW;
            NSCompositingOperation op = NSCompositingOperationSourceOver;
            if (slackX < leftW) {
                if (slackY < bottomH)
                    [_backgroundImage drawInRect:NSMakeRect(NSMinX(d), NSMinY(d), leftW, bottomH)
                                        fromRect:NSMakeRect(0, 0, leftW, bottomH) operation:op fraction:1.0];
                if (slackY < topH)
                    [_backgroundImage drawInRect:NSMakeRect(NSMinX(d), NSMaxY(inner), leftW, topH)
                                        fromRect:NSMakeRect(0, topY, leftW, topH) operation:op fraction:1.0];
                [_backgroundImage drawInRect:NSMakeRect(NSMinX(d), NSMinY(inner), leftW, NSHeight(inner))
                                    fromRect:NSMakeRect(0, bottomH, leftW, middleH) operation:op fraction:1.0];
            }
            if (slackX < rightW) {
                if (slackY < bottomH)
                    [_backgroundImage drawInRect:NSMakeRect(NSMaxX(inner), NSMinY(d), rightW, bottomH)
                                        fromRect:NSMakeRect(rightX, 0, rightW, bottomH) operation:op fraction:1.0];
                if (slackY < topH)
                    [_backgroundImage drawInRect:NSMakeRect(NSMaxX(inner), NSMaxY(inner), rightW, topH)
                                        fromRect:NSMakeRect(rightX, topY, rightW, topH) operation:op fraction:1.0];
                [_backgroundImage drawInRect:NSMakeRect(NSMaxX(inner), NSMinY(inner), rightW, NSHeight(inner))
                                    fromRect:NSMakeRect(rightX, bottomH, rightW, middleH) operation:op fraction:1.0];
            }
            if (slackY < bottomH)
                [_backgroundImage drawInRect:NSMakeRect(NSMinX(inner), NSMinY(d), NSWidth(inner), bottomH)
                                    fromRect:NSMakeRect(leftW, 0, middleW, bottomH) operation:op fraction:1.0];
            if (slackY < topH)
                [_backgroundImage drawInRect:NSMakeRect(NSMinX(inner), NSMaxY(inner), NSWidth(inner), topH)
                                    fromRect:NSMakeRect(leftW, topY, middleW, topH) operation:op fraction:1.0];
            [_backgroundImage drawInRect:inner fromRect:NSMakeRect(leftW, bottomH, middleW, middleH) operation:op fraction:1.0];
            return;
        }
    }
    [_backgroundImage drawInRect:d fromRect:NSMakeRect(0, 0, size.width, size.height)
                       operation:NSCompositingOperationSourceOver fraction:1.0];
}

// Opaque with a nearly opaque color that isn't a pattern.
- (BOOL)isOpaque
{
    if (!_backgroundColor || [_backgroundColor type] == NSColorTypePattern)
        return NO;
    return 0.9980469 <= [_backgroundColor alphaComponent];
}

- (void)setBottomUnscaledBackgroundImageMargin:(CGFloat)aMargin
{
    if (_bottomUnscaledBackgroundImageMargin != (float)aMargin) {
        _bottomUnscaledBackgroundImageMargin = aMargin;
        if (_backgroundImage)
            [self setNeedsDisplay:YES];
    }
}

- (CGFloat)bottomUnscaledBackgroundImageMargin
{
    return _bottomUnscaledBackgroundImageMargin;
}

- (void)setTopUnscaledBackgroundImageMargin:(CGFloat)aMargin
{
    if (_topUnscaledBackgroundImageMargin != (float)aMargin) {
        _topUnscaledBackgroundImageMargin = aMargin;
        if (_backgroundImage)
            [self setNeedsDisplay:YES];
    }
}

- (CGFloat)topUnscaledBackgroundImageMargin
{
    return _topUnscaledBackgroundImageMargin;
}

- (void)setRightUnscaledBackgroundImageMargin:(CGFloat)aMargin
{
    if (_rightUnscaledBackgroundImageMargin != (float)aMargin) {
        _rightUnscaledBackgroundImageMargin = aMargin;
        if (_backgroundImage)
            [self setNeedsDisplay:YES];
    }
}

- (CGFloat)rightUnscaledBackgroundImageMargin
{
    return _rightUnscaledBackgroundImageMargin;
}

- (void)setLeftUnscaledBackgroundImageMargin:(CGFloat)aMargin
{
    if (_leftUnscaledBackgroundImageMargin != (float)aMargin) {
        _leftUnscaledBackgroundImageMargin = aMargin;
        if (_backgroundImage)
            [self setNeedsDisplay:YES];
    }
}

- (CGFloat)leftUnscaledBackgroundImageMargin
{
    return _leftUnscaledBackgroundImageMargin;
}

- (void)setBackgroundImageScaling:(NSUInteger)aScaling
{
    if (_backgroundImageScaling != aScaling) {
        _backgroundImageScaling = (unsigned int)aScaling;
        if (_backgroundImage)
            [self setNeedsDisplay:YES];
    }
}

- (NSUInteger)backgroundImageScaling
{
    return _backgroundImageScaling;
}

- (void)setBackgroundColor:(id)aColor
{
    if (_backgroundColor == aColor)
        return;
    NSColor *color = nil;
    if (aColor && !(color = [aColor copy]))
        return;
    [_backgroundColor release];
    _backgroundColor = color;
}

- (id)backgroundColor
{
    return _backgroundColor;
}

- (void)setBackgroundImage:(id)aImage
{
    if (_backgroundImage != aImage) {
        [aImage retain];
        [_backgroundImage release];
        _backgroundImage = aImage;
    }
}

- (id)backgroundImage
{
    return _backgroundImage;
}

- (void)dealloc
{
    [_backgroundImage release];
    [_backgroundColor release];
    [super dealloc];
}

@end
