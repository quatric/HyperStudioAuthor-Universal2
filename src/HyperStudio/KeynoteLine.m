#import "KeynoteLine.h"

@implementation KeynoteLine

- (CGFloat)angle
{
    id angle = [[[self keynoteObjectForXMLPath:@"./geometry"] nodeAttributes] objectForKey:@"angle"];
    double degrees = angle != nil ? [angle floatValue] * 3.141592653589793 : 0.0;
    return (float)(degrees / -180.0 + 3.141592653589793);
}

// Uses the head and tail points when present, else the geometry's origin,
// width and angle.
- (id)bezierPath
{
    id head = [self keynoteObjectForXMLPath:@"./head"];
    id tail = [self keynoteObjectForXMLPath:@"./tail"];
    NSBezierPath *path = [NSBezierPath bezierPath];
    if (head == nil || tail == nil) {
        KeynoteGeometry *geometry = [self keynoteObjectForXMLPath:@"./geometry"];
        NSPoint origin = [geometry origin];
        NSSize size = [geometry size];
        double angle = [self angle];
        float sine = (float)sin(angle), cosine = (float)cos(angle);
        [path moveToPoint:origin];
        [path relativeLineToPoint:NSMakePoint(size.width * cosine, sine * size.width)];
    } else {
        [path moveToPoint:[KeynoteTools pointWithAttributesDictionary:[head nodeAttributes]]];
        [path lineToPoint:[KeynoteTools pointWithAttributesDictionary:[tail nodeAttributes]]];
    }
    return path;
}

- (BOOL)isLine
{
    return YES;
}

- (BOOL)exportsBezierPath
{
    return YES;
}

@end
