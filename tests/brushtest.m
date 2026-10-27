// Paints with BTBrushTool into a bitmap context: touch spacing and bounds, a
// solid square pad, a round shape pad (clip mask), an offset shadow, erasing,
// and a touch storage archive round trip.
#import <Cocoa/Cocoa.h>
#import "BTBrushTouchStorage.h"

static int failures = 0;

static void check(BOOL aCondition, NSString *aWhat)
{
    if (!aCondition) {
        NSLog(@"FAIL: %@", aWhat);
        failures++;
    }
}

static const uint8_t *pixelAt(CGContextRef aContext, int aX, int aY)
{
    const uint8_t *data = CGBitmapContextGetData(aContext);
    size_t height = CGBitmapContextGetHeight(aContext);
    return data + (height - 1 - aY) * CGBitmapContextGetBytesPerRow(aContext) + aX * 4;
}

static CGContextRef newContext(void)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, 64, 64, 8, 64 * 4, space, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(space);
    return context;
}

static CGColorRef newColor(CGFloat aRed, CGFloat aGreen, CGFloat aBlue)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat components[4] = { aRed, aGreen, aBlue, 1.0 };
    CGColorRef color = CGColorCreate(space, components);
    CGColorSpaceRelease(space);
    return color;
}

static BTBrushTouchStorage *stroke(BTBrushTool *aBrush, CGPoint aFrom, CGPoint aTo, CGRect *aBounds)
{
    BTBrushTouchStorage *storage = [[[BTBrushTouchStorage alloc] init] autorelease];
    CGPoint points[2] = { aFrom, aTo };
    *aBounds = [aBrush recordAlongPolylineWithPoints:points count:2 withAlternateColor:NO withPressure:1.0 to:storage];
    return storage;
}

int main(void)
{
    @autoreleasepool {
        CGRect bounds = CGRectMake(0, 0, 64, 64);
        CGColorRef red = newColor(1, 0, 0);
        CGColorRef blue = newColor(0, 0, 1);

        BTBrushTool *brush = [[BTBrushTool alloc] init];
        check(NSEqualSizes([brush size], NSMakeSize(20, 20)), @"default size");
        check([brush opacity] == 1.0 && [brush padding], @"default opacity and padding");
        [brush setColor:(id)red];
        check([brush color] != nil, @"color is kept");
        [brush setSize:NSMakeSize(8, 8)];
        [brush setSpacing:4.0];

        // Touches every 4 units from x 10 to 50 (the first one step in).
        CGRect touched;
        BTBrushTouchStorage *storage = stroke(brush, CGPointMake(10, 20), CGPointMake(50, 20), &touched);
        // Ten steps of 0.1 fall just short of the end in doubles, so the end point gets its own touch.
        check([storage numberOfTouches] == 11, [NSString stringWithFormat:@"11 touches, got %lu", (unsigned long)[storage numberOfTouches]]);
        check(CGRectEqualToRect(touched, CGRectMake(10, 16, 44, 8)), [NSString stringWithFormat:@"stroke bounds %@", NSStringFromRect(NSRectFromCGRect(touched))]);

        CGContextRef context = newContext();
        [brush drawWithTouchProvider:storage inContext:context withBounds:bounds];
        const uint8_t *p = pixelAt(context, 30, 20);
        check(p[0] == 255 && p[1] == 0 && p[3] == 255, @"square pad paints red");
        check(pixelAt(context, 30, 40)[3] == 0, @"nothing painted off the stroke");
        check(pixelAt(context, 52, 23)[3] == 255, @"pad covers its corner");

        // Erasing: no color and no image clears through the pad.
        [brush setColor:nil];
        CGRect erased;
        BTBrushTouchStorage *eraser = stroke(brush, CGPointMake(30, 20), CGPointMake(30, 20), &erased);
        [brush drawWithTouchProvider:eraser inContext:context withBounds:bounds];
        check(pixelAt(context, 30, 20)[3] == 0, @"eraser clears");
        check(pixelAt(context, 40, 20)[3] == 255, @"eraser leaves the rest");
        CGContextRelease(context);

        // A round pad leaves the square's corners unpainted.
        [brush setColor:(id)blue];
        [brush setSize:NSMakeSize(16, 16)];
        CGPathRef circle = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, 1, 1), NULL);
        [brush setShapePrototypePath:(id)circle];
        CGPathRelease(circle);
        context = newContext();
        CGRect dot;
        [brush drawWithTouchProvider:stroke(brush, CGPointMake(32, 32), CGPointMake(32, 32), &dot) inContext:context withBounds:bounds];
        check(pixelAt(context, 32, 32)[2] == 255, @"round pad paints its center");
        check(pixelAt(context, 25, 25)[3] == 0, @"round pad skips its corner");

        // A hard shadow offset to the right shows past the pad. Cached pads
        // only carry masked shadows, so the pad is drawn directly.
        [brush setShapePrototypePath:nil];
        [brush setPadding:NO];
        [brush setShadowColor:(id)red];
        [brush setShadowOffset:NSMakeSize(10, 0)];
        CGContextClearRect(context, bounds);
        [brush drawWithTouchProvider:stroke(brush, CGPointMake(20, 32), CGPointMake(20, 32), &dot) inContext:context withBounds:bounds];
        check(pixelAt(context, 20, 32)[2] == 255, @"pad over its shadow");
        check(pixelAt(context, 32, 32)[0] > 200 && pixelAt(context, 32, 32)[2] < 50, @"shadow past the pad");
        check(dot.origin.x <= 12 && CGRectGetMaxX(dot) >= 38, @"bounds include the shadow");
        CGContextRelease(context);

        // Touch storage archives.
        NSData *archive = [NSArchiver archivedDataWithRootObject:storage];
        BTBrushTouchStorage *copy = [NSUnarchiver unarchiveObjectWithData:archive];
        check([copy numberOfTouches] == [storage numberOfTouches], @"archive keeps touches");
        CGPoint first, again;
        [storage position:&first sizeDeviation:NULL rotationAngleDeviation:NULL opacityDeviation:NULL alternateColor:NULL
            colorHSVADeviation:NULL colorNativeDeviation:NULL shadowColorHSVADeviation:NULL shadowColorNativeDeviation:NULL forTouchAtIndex:3];
        [copy position:&again sizeDeviation:NULL rotationAngleDeviation:NULL opacityDeviation:NULL alternateColor:NULL
            colorHSVADeviation:NULL colorNativeDeviation:NULL shadowColorHSVADeviation:NULL shadowColorNativeDeviation:NULL forTouchAtIndex:3];
        check(CGPointEqualToPoint(first, again), @"archive keeps positions");

        [brush release];
        CGColorRelease(red);
        CGColorRelease(blue);
    }
    if (failures == 0)
        printf("brushtest passed\n");
    return failures != 0;
}
