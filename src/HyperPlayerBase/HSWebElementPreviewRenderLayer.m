#import "HSWebElementPreviewRenderLayer.h"
// A web element's preview image, or a "Loading..." placeholder.
@implementation HSWebElementPreviewRenderLayer
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    if (context == NULL)
        return;
    NSSize size = [_sizeAttributes size];
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGImageRef image = [_webElementAttributes previewImage];
    if (image != NULL) {
        CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, rect.origin.y * 2 + rect.size.height));
        CGContextDrawImage(context, rect, image);
        return;
    }
    CGContextSetRGBFillColor(context, 0.25, 0.5, 0.75, 0.25);
    CGContextFillRect(context, rect);
    CGContextSetLineWidth(context, 1.0);
    CGRect border = CGRectMake(rect.origin.x + 0.5, rect.origin.y + 0.5, rect.size.width - 1.0, rect.size.height - 1.0);
    CGContextSetRGBStrokeColor(context, 0.25, 0.25, 0.25, 0.25);
    CGContextStrokeRect(context, border);
    border = CGRectMake(border.origin.x + 1.0, border.origin.y + 1.0, border.size.width - 2.0, border.size.height - 2.0);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.25);
    CGContextStrokeRect(context, border);
    NSString *text = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Loading..." value:@"" table:@"HyperPlayerBase"];
    if (text == nil)
        return;
    NSColor *color = [NSColor whiteColor];
    NSFont *font = [NSFont boldSystemFontOfSize:[NSFont systemFontSize]];
    if (color == nil || font == nil)
        return;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    if (string == nil)
        return;
    NSRange range = NSMakeRange(0, [text length]);
    [string addAttribute:NSForegroundColorAttributeName value:color range:range];
    [string addAttribute:NSFontAttributeName value:font range:range];
    NSSize textSize = [string size];
    [string drawAtPoint:NSMakePoint(rect.origin.x + (rect.size.width - textSize.width) * 0.5,
                                    rect.origin.y + (rect.size.height - textSize.height) * 0.5)];
    [string release];
}
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}
- (id)calculateBoundingRegion
{
    NSSize size = [_sizeAttributes size];
    return [HSRegion regionWithRect:NSMakeRect(0, 0, size.width, size.height)];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id hyperObject = [self hyperObject];
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:hyperObject];
    [aSet addAttribute:@protocol(HSWebElementPreviewImageAttribute) forObject:hyperObject];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSSizeAttribute) forObject:[self hyperObject]];
}
- (void)dealloc
{
    [_webElementAttributes release];
    [_sizeAttributes release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self != nil) {
        _sizeAttributes = [[aObject queryHyperInterface:@protocol(HSSizeAttributes)] retain];
        if (_sizeAttributes != nil) {
            _webElementAttributes = [[aObject queryHyperInterface:@protocol(HSWebElementAttributes)] retain];
            if (_webElementAttributes != nil)
                return self;
        }
        [self release];
    }
    return nil;
}
@end
