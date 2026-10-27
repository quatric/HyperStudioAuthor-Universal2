#import "HSCrayonItem.h"

@implementation HSCrayonItem

+ (id)sharedCrayonShadow
{
    static NSShadow *shadow = nil;
    if (shadow == nil) {
        shadow = [NSShadow new];
        [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.75]];
        [shadow setShadowOffset:NSZeroSize];
        [shadow setShadowBlurRadius:2.5];
    }
    return shadow;
}

+ (id)sharedCrayonsBlinksRasterImage
{
    static NSImage *image = nil;
    if (image == nil)
        image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Crayon_light_shadow" ofType:@"png"]];
    return image;
}

+ (id)sharedCrayonShapePath
{
    static NSBezierPath *path = nil;
    if (path == nil)
        path = [[NSBezierPath hyperBezierPathWithContentsOfBinaryFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"crayon_shape" ofType:@"hspath"]] retain];
    return path;
}

// The hit path is in the flipped image's coordinates.
- (BOOL)hitTestPoint:(NSPoint)aPoint
{
    if (!NSPointInRect(aPoint, _frame))
        return NO;
    return [_hitZonePath containsPoint:NSMakePoint(aPoint.x - _frame.origin.x, _frame.size.height - (aPoint.y - _frame.origin.y))];
}

- (void)drawInView:(id)aView
{
    [[self imageForView:aView] drawInRect:_frame fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
}

// Renders the crayon once: the shape filled with the color under a shadow, scaled to the
// frame's width and set 2.5 points above the bottom, with the light shading on top.
- (id)imageForView:(id)aView
{
    if (_image == nil) {
        NSSize size = [aView convertSize:_frame.size toView:nil];
        _image = [[NSImage alloc] initWithSize:size];
        [_image setFlipped:YES];
        [_image lockFocus];
        [[NSGraphicsContext currentContext] saveGraphicsState];
        [(NSShadow *)[[self class] sharedCrayonShadow] set];
        NSBezierPath *shape = [[self class] sharedCrayonShapePath];
        NSRect bounds = [shape bounds];
        float height = bounds.size.height * (size.width / bounds.size.width);
        NSAffineTransform *transform = [NSAffineTransform hyperTransitionFromRect:[shape bounds] toRect:NSMakeRect(0.0, (size.height - height) - 2.5f, size.width, height)];
        [transform concat];
        [(NSColor *)[self color] set];
        [shape fill];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
        _hitZonePath = [shape copy];
        [_hitZonePath transformUsingAffineTransform:transform];
        [[[self class] sharedCrayonsBlinksRasterImage] drawInRect:[_hitZonePath bounds] fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
        [_image unlockFocus];
    }
    return _image;
}

- (void)setFrame:(NSRect)aFrame
{
    _frame = aFrame;
}

- (NSRect)frame
{
    return _frame;
}

- (id)color
{
    return _color;
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)dealloc
{
    [_color release];
    [_image release];
    [_hitZonePath release];
    [super dealloc];
}

- (id)initWithColor:(id)aColor frame:(NSRect)aFrame
{
    self = [super init];
    if (self != nil) {
        _color = [aColor retain];
        _frame = aFrame;
    }
    return self;
}

@end
