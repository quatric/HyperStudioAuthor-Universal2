#import "HSControlRectangularBackgroundRenderer.h"
// A nine-part image background: corners (0 2 6 8, top row first), edges (1
// top, 3 left, 5 right, 7 bottom) and the centre (4). Corners keep their
// size (at most half the rect when scaling to fit); edges and the centre
// stretch, or tile when asked. Each part is drawn pixel-aligned in the view.
@implementation HSControlRectangularBackgroundRenderer
- (void)setShouldTileMiddleParts:(BOOL)aParts
{
    _shouldTileMiddleParts = aParts;
}
- (BOOL)shouldTileMiddleParts
{
    return _shouldTileMiddleParts;
}
- (void)setFraction:(CGFloat)aFraction
{
    if ([self fraction] != aFraction) {
        _fraction = aFraction;
        _fractionValid = YES;
    }
}
- (CGFloat)fraction
{
    if (!_fractionValid)
        _fraction = 1.0f;
    return _fraction;
}
- (void)drawInRect:(NSRect)aRect invalidRect:(NSRect)aRect2 inView:(id)aView
{
    BOOL scales = [self scalesImagesToFit];
    [(NSColor *)[self backgroundColor] set];
    [NSBezierPath fillRect:aRect2];

    NSRect source[9];
    NSRect dest[9];
    memset(source, 0, sizeof(source));
    memset(dest, 0, sizeof(dest));
    CGFloat halfWidth = aRect.size.width * 0.5f;
    CGFloat halfHeight = aRect.size.height * 0.5f;
    CGFloat minX = aRect.origin.x, minY = aRect.origin.y;
    CGFloat maxX = minX + aRect.size.width, maxY = minY + aRect.size.height;
    NSSize size;

    // Corners.
    static const int corners[4] = { 0, 2, 6, 8 };
    for (int i = 0; i < 4; i++) {
        int part = corners[i];
        if (_textures[part] == nil)
            continue;
        size = [(NSImage *)_textures[part] size];
        source[part].size = size;
        CGFloat width = scales && halfWidth < size.width ? halfWidth : size.width;
        CGFloat height = scales && halfHeight < size.height ? halfHeight : size.height;
        dest[part].size = NSMakeSize(width, height);
        dest[part].origin.x = (part == 0 || part == 6) ? minX : maxX - width;
        dest[part].origin.y = (part == 0 || part == 2) ? maxY - height : minY;
    }
    // Top and bottom edges.
    if (_textures[1] != nil) {
        size = [(NSImage *)_textures[1] size];
        source[1].size = size;
        CGFloat height = scales && halfHeight < size.height ? halfHeight : size.height;
        dest[1] = NSMakeRect(dest[0].origin.x + dest[0].size.width, maxY - height,
                             aRect.size.width - dest[0].size.width - dest[2].size.width, height);
        dest[1] = [self correctedDestinationRectForTexture:1 destinationRect:dest[1]];
    }
    if (_textures[7] != nil) {
        size = [(NSImage *)_textures[7] size];
        source[7].size = size;
        CGFloat height = scales && halfHeight < size.height ? halfHeight : size.height;
        dest[7] = NSMakeRect(dest[6].origin.x + dest[6].size.width, minY,
                             aRect.size.width - dest[6].size.width - dest[8].size.width, height);
        dest[7] = [self correctedDestinationRectForTexture:7 destinationRect:dest[7]];
    }
    // Left and right edges.
    if (_textures[3] != nil) {
        size = [(NSImage *)_textures[3] size];
        source[3].size = size;
        CGFloat width = scales && halfWidth < size.width ? halfWidth : size.width;
        dest[3] = NSMakeRect(minX, dest[6].origin.y + dest[6].size.height, width,
                             aRect.size.height - dest[0].size.height - dest[6].size.height);
        dest[3] = [self correctedDestinationRectForTexture:3 destinationRect:dest[3]];
    }
    if (_textures[5] != nil) {
        size = [(NSImage *)_textures[5] size];
        source[5].size = size;
        CGFloat width = scales && halfWidth < size.width ? halfWidth : size.width;
        dest[5] = NSMakeRect(maxX - width, dest[8].origin.y + dest[8].size.height, width,
                             aRect.size.height - dest[2].size.height - dest[8].size.height);
        dest[5] = [self correctedDestinationRectForTexture:5 destinationRect:dest[5]];
    }
    // Centre.
    if (_textures[4] != nil) {
        source[4].size = [(NSImage *)_textures[4] size];
        dest[4] = NSMakeRect(dest[3].origin.x + dest[3].size.width, dest[7].origin.y + dest[7].size.height,
                             aRect.size.width - dest[3].size.width - dest[5].size.width,
                             aRect.size.height - dest[1].size.height - dest[7].size.height);
    }

    for (int part = 0; part < 9; part++) {
        NSImage *texture = _textures[part];
        if (texture == nil || !NSIntersectsRect(aRect2, dest[part]))
            continue;
        NSRect rect = [aView convertRect:NSIntegralRect([aView convertRect:dest[part] toView:nil]) fromView:nil];
        BOOL tiled = _shouldTileMiddleParts && part != 0 && part != 2 && part != 6 && part != 8;
        if (!tiled) {
            [texture drawInRect:rect
                       fromRect:source[part]
                      operation:NSCompositingOperationSourceOver
                       fraction:[self fraction]];
            continue;
        }
        NSGraphicsContext *context = [NSGraphicsContext currentContext];
        [context saveGraphicsState];
        [[NSBezierPath bezierPathWithRect:rect] addClip];
        NSSize tile = NSMakeSize(MIN(source[part].size.width, rect.size.width),
                                 MIN(source[part].size.height, rect.size.height));
        long rows = lroundf(rect.size.height / source[part].size.height + 0.5f);
        for (long row = 0; row < rows; row++) {
            long columns = lroundf(rect.size.width / source[part].size.width + 0.5f);
            for (long column = 0; column < columns; column++)
                [texture drawInRect:NSMakeRect(rect.origin.x + column * tile.width,
                                               rect.origin.y + row * tile.height, tile.width, tile.height)
                           fromRect:source[part]
                          operation:NSCompositingOperationSourceOver
                           fraction:[self fraction]];
        }
        [context restoreGraphicsState];
    }
}
- (void)setScalesImagesToFit:(BOOL)aFit
{
    _scalesImagesToFit = aFit;
}
- (BOOL)scalesImagesToFit
{
    return _scalesImagesToFit;
}
- (void)setBackgroundColor:(id)aColor
{
    if (_backgroundColor != aColor) {
        [_backgroundColor release];
        _backgroundColor = [aColor retain];
    }
}
- (id)backgroundColor
{
    return _backgroundColor != nil ? _backgroundColor : [NSColor clearColor];
}
// For subclasses: adjusts an edge's rect.
- (NSRect)correctedDestinationRectForTexture:(NSInteger)aTexture destinationRect:(NSRect)aRect
{
    return aRect;
}
- (void)setImage:(id)aImage forType:(NSInteger)aType
{
    if (_textures[aType] != aImage) {
        [_textures[aType] release];
        _textures[aType] = [aImage retain];
    }
}
- (id)imageForType:(NSInteger)aType
{
    return _textures[aType];
}
// (The original leaked the background colour.)
- (void)dealloc
{
    for (int i = 0; i < 9; i++)
        [_textures[i] release];
    [_backgroundColor release];
    [super dealloc];
}
@end
