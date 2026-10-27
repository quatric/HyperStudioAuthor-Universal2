#import "KeynoteImage.h"

@implementation KeynoteImage

- (NSSize)size
{
    id size = [self keynoteObjectForXMLPath:@"./size"];

    if (size == nil)
        return NSZeroSize;
    return [(KeynoteGeometry *)size size];
}

- (id)dataObject
{
    id data = [self keynoteObjectForXMLPath:@"./binary/data"];

    if (data == nil)
        data = [self keynoteObjectForXMLPath:@"./data"];
    if (data == nil) {
        id identifier = [[[self keynoteObjectForXMLPath:@"./binary-ref"] nodeAttributes] objectForKey:@"IDREF"];
        if (identifier != nil)
            data = [[[self cache] objectOfType:@"image" inCacheForId:identifier] dataObject];
    }
    if (data == nil)
        data = [[self keynoteObjectForXMLPath:@"./filtered-image"] dataObject];
    return data;
}

- (NSRect)croppedImageFrame
{
    KeynoteGeometry *geometry = [self geometry];
    KeynoteGeometry *crop = [self keynoteObjectForXMLPath:@"./crop-geometry"];
    NSPoint origin = [geometry origin];
    NSPoint cropOrigin = [crop origin];
    NSSize cropSize = [crop size];

    return NSMakeRect(cropOrigin.x - origin.x, cropOrigin.y - origin.y, cropSize.width, cropSize.height);
}

- (id)maskPath
{
    id bezier = [self keynoteObjectForXMLPath:@"./masking-shape-path-source/bezier-path/bezier"];
    id crop = [self keynoteObjectForXMLPath:@"./crop-geometry"];

    if (bezier == nil && crop != nil)
        return [NSBezierPath bezierPathWithRect:[self croppedImageFrame]];
    return nil;
}

// Maps the masking shape into the crop rectangle at natural image scale, then flips it vertically.
- (id)alphaPath
{
    NSString *string = [[[self keynoteObjectForXMLPath:@"./masking-shape-path-source/bezier-path/bezier"] nodeAttributes] objectForKey:@"path"];

    if (string == nil)
        return nil;

    NSBezierPath *path = [NSBezierPath hyperBezierPathWithString:string];
    KeynoteGeometry *geometry = [self geometry];
    NSSize naturalSize = [geometry naturalSize];
    NSSize size = [geometry size];
    NSRect crop = [self croppedImageFrame];
    float fx = naturalSize.width / size.width;
    float fy = naturalSize.height / size.height;
    NSRect bounds = [path bounds];
    float sx = bounds.size.width != 0.0f ? crop.size.width / bounds.size.width : 1.0f;
    float sy = bounds.size.height != 0.0f ? crop.size.height / bounds.size.height : 1.0f;
    CGAffineTransform scale = CGAffineTransformMake(sx * fx, fy * 0.0f, fx * 0.0f, sy * fy,
                                                    (crop.origin.x - bounds.origin.x * sx) * fx,
                                                    (crop.origin.y - bounds.origin.y * sy) * fy);

    [path transformUsingAffineTransform:[NSAffineTransform transformWithHyperCGAffineTransform:scale]];
    CGAffineTransform flip = CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, (float)(NSZeroPoint.y + NSZeroPoint.y + naturalSize.height));
    [path transformUsingAffineTransform:[NSAffineTransform transformWithHyperCGAffineTransform:flip]];
    return path;
}

- (void)didInitFromParser
{
    [super didInitFromParser];
    if ([self keynoteObjectForXMLPath:@"./filtered-image"] != nil)
        return;

    id node = [self keynoteObjectForXMLPath:@"./binary"];
    if (node == nil)
        node = self;
    [[self cache] addObject:self type:@"image" inCacheForId:[node nodeId]];
}

@end
