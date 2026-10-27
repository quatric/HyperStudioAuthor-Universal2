#import "HSGenericWebPagePlaceholderRenderLayer.h"
// A web page object while it loads (or can't): a translucent blue box with
// an icon over a label, centered.
@implementation HSGenericWebPagePlaceholderRenderLayer
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[_geometryAttributes boundingRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:[self hyperObject]];
}
- (BOOL)requiresTransparencyLayer
{
    return YES;
}
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    if ([_webPageAttributes loadState] == 0)
        return;
    NSRect bounds = [_geometryAttributes boundingRect];
    [NSBezierPath clipRect:bounds];
    [[NSColor colorWithCalibratedRed:0.25 green:0.5 blue:0.75 alpha:0.25] set];
    [[NSBezierPath bezierPathWithRect:bounds] fill];
    NSRect frame = bounds;
    frame.size.width -= 0.5f;
    frame.size.height -= 0.5f;
    [[NSColor colorWithCalibratedRed:0.25 green:0.25 blue:0.25 alpha:0.25] set];
    [[NSBezierPath bezierPathWithRect:frame] stroke];
    [[NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:0.25] set];
    [[NSBezierPath bezierPathWithRect:NSInsetRect(frame, 1, 1)] stroke];

    NSString *text = nil;
    NSImage *icon = nil;
    [self getPlaceholderLabel:&text icon:&icon];
    NSMutableAttributedString *label = nil;
    NSSize labelSize = NSZeroSize;
    if (text != nil) {
        NSUInteger length = [text length];
        label = [[[NSMutableAttributedString alloc] initWithString:text] autorelease];
        [label addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, length)];
        [label addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]] range:NSMakeRange(0, length)];
        labelSize = [label size];
    }
    NSSize iconSize = icon != nil ? [icon size] : NSZeroSize;
    float space = bounds.size.height - (iconSize.height + labelSize.height + 10.0);
    float top = space > 0 ? space * 0.5f : 0;
    if (icon != nil) {
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [[NSAffineTransform transformWithHyperCGAffineTransform:CGAffineTransformMake(1, 0, 0, -1, 0, bounds.size.height + bounds.origin.y + bounds.origin.y)] concat];
        float x = bounds.origin.x;
        if (iconSize.width < bounds.size.width)
            x += (bounds.size.width - iconSize.width) * 0.5;
        [icon drawAtPoint:NSMakePoint(x, (bounds.origin.y + bounds.size.height) - (iconSize.height + top))
                 fromRect:NSMakeRect(0, 0, iconSize.width, iconSize.height) operation:NSCompositingOperationSourceOver fraction:1.0];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    BOOL flip = ![context isFlipped];
    float offset;
    if (flip) {
        [context saveGraphicsState];
        CGContextConcatCTM([context CGContext], CGAffineTransformMake(1, 0, 0, -1, 0, bounds.size.height + bounds.origin.y + bounds.origin.y));
        offset = top;
    } else
        offset = bounds.size.height - (top + labelSize.height);
    float x = bounds.origin.x;
    if (labelSize.width < bounds.size.width)
        x += (bounds.size.width - labelSize.width) * 0.5;
    [label drawAtPoint:NSMakePoint(x, MAX(bounds.origin.y, bounds.origin.y + offset))];
    if (flip)
        [context restoreGraphicsState];
}
// By load state: connecting (1), offline (2), else just the name.
- (void)getPlaceholderLabel:(id *)aLabel icon:(id *)aIcon
{
    NSInteger state = [_webPageAttributes loadState];
    NSString *label, *iconName;
    if (state == 1) {
        label = @"Connecting...";
        iconName = @"WebObjectIcon";
    } else if (state == 2) {
        label = @"Camera Offline";
        iconName = @"WebObjectOffIcon";
    } else {
        label = @"Web Cam";
        iconName = @"WebObjectIcon";
    }
    if (aLabel != NULL)
        *aLabel = [[NSBundle bundleForClass:[self class]] localizedStringForKey:label value:@"" table:@"HyperPlayerBase"];
    if (aIcon != NULL) {
        *aIcon = [HSPlayerBaseID imageNamed:iconName];
        [*aIcon setCacheMode:NSImageCacheNever];
    }
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSWebPageContentAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSWebPageLoadStateAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSWebPageCropPathAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSWebPageRectAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:object];
}
- (void)dealloc
{
    [_webPageAttributes release];
    [_geometryAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _webPageAttributes = [[aObject queryHyperInterface:@protocol(HSWebPageAttributes)] retain];
        if (_webPageAttributes != nil) {
            _geometryAttributes = [[aObject queryHyperInterface:@protocol(HSGeometryAttributes)] retain];
            if (_geometryAttributes != nil)
                return self;
        }
        [self release];
    }
    return nil;
}
@end
