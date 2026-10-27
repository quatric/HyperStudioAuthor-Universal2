#import "HSVisualHitTester.h"
// Hit testing by drawing: the object's renderer draws the part of its region
// under the test rect into a small ARGB bitmap; any non-transparent pixel is a
// hit.
@implementation HSVisualHitTester
static id sSharedRenderDelegate;
+ (id)sharedRenderDelegate
{
    if (sSharedRenderDelegate == nil) {
        id cacheController = [[[HSGenericRenderCacheController alloc] init] autorelease];
        sSharedRenderDelegate = [[HSGenericRenderDelegate alloc] initWithDrawable:nil];
        [sSharedRenderDelegate setRenderCacheController:cacheController];
    }
    return sSharedRenderDelegate;
}
- (BOOL)hitTestUserRect:(NSRect)aRect
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    BOOL hit = NO;
    id region = [self userBoundingRegion];
    if (region != nil) {
        // the region's bounds in root user space
        CGAffineTransform transform = [self rendererToRootUserSpaceAffineTransform];
        CGRect bounds = CGRectApplyAffineTransform(NSRectToCGRect([region boundingRect]), transform);
        NSRect rect = NSIntegralRect(NSIntersectionRect(aRect, NSRectFromCGRect(bounds)));
        if (!NSIsEmptyRect(rect)) {
            size_t width = (size_t)rect.size.width, height = (size_t)rect.size.height;
            int size = (int)(rect.size.width * rect.size.height * 4);
            UInt8 *pixels = malloc(size);
            memset(pixels, 0, size);
            CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
            CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, (size_t)(rect.size.width * 4), space, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
            CGColorSpaceRelease(space);
            transform = [self rendererToRootUserSpaceAffineTransform];
            CGContextConcatCTM(context, CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(-rect.origin.x, -rect.origin.y)));
            NSGraphicsContext *previous = [[NSGraphicsContext currentContext] retain];
            [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:YES]];
            // the bitmap's area in the renderer's space
            HSMutableRegion *drawRegion = [HSMutableRegion regionWithRect:NSMakeRect(0, 0, rect.size.width, rect.size.height)];
            [drawRegion applyAffineTransform:CGAffineTransformMakeTranslation(rect.origin.x, rect.origin.y)];
            [drawRegion applyAffineTransform:CGAffineTransformInvert(transform)];
            [[self renderer] drawRegion:drawRegion withDelegate:[[self class] sharedRenderDelegate]];
            [NSGraphicsContext setCurrentContext:previous];
            [previous release];
            for (int i = 0; i < size; i += 4) {
                if (pixels[i] != 0) {
                    hit = YES;
                    break;
                }
            }
            CGContextRelease(context);
            free(pixels);
        }
    }
    [pool release];
    return hit;
}
// A 4×4 rect around the point.
- (BOOL)hitTestUserPoint:(NSPoint)aPoint
{
    return [self hitTestUserRect:NSInsetRect((NSRect){aPoint, NSZeroSize}, -2, -2)];
}
- (CGAffineTransform)rendererToRootUserSpaceAffineTransform
{
    return [[[[self renderer] visualization] queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
}
- (id)userBoundingRegion
{
    return [[self renderer] boundingRegion];
}
// The object's hit-testing visualization, or its plain one.
- (id)renderer
{
    if (_renderer == nil) {
        id visualization = [[self hyperObject] queryHyperInterface:_visualizationProtocol];
        if (visualization == nil)
            visualization = [[self hyperObject] queryHyperInterface:@protocol(HSVisualization)];
        _renderer = [[visualization queryRenderer] retain];
    }
    return _renderer;
}
- (id)geometryAttributes
{
    return [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
}
- (void)dealloc
{
    [_renderer release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject visualizationProtocol:(id)aProtocol
{
    self = [super initWithHyperObject:aObject];
    if (self != nil)
        _visualizationProtocol = aProtocol;
    return self;
}
- (id)initWithHyperObject:(id)aObject
{
    return [self initWithHyperObject:aObject visualizationProtocol:@protocol(HSHitTestingVisualization)];
}
@end
