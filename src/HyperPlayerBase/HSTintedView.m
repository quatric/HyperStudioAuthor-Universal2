#import "HSTintedView.h"

// The eight box border images, loaded once, in drawing order.
static NSImage *sBoxImages[8];

// A view filled with a tint color or background image, with an optional
// border: a plain frame (style 0), the box images (1), a rounded stroke (2)
// or a custom rounded stroke (7, any other style). The HyperStudio copy of
// SMKTintedView.
@implementation HSTintedView

+ (id)boxStyleDefaultColor
{
    return [NSColor colorWithDeviceWhite:0 alpha:0.03];
}

// No context menu plug-ins while a sheet is up.
- (id)menuForEvent:(id)aEvent
{
    NSMenu *menu = [super menuForEvent:aEvent];
    if ([[self window] attachedSheet] != nil) {
        menu = [[menu copy] autorelease];
        [menu setAllowsContextMenuPlugIns:NO];
    }
    return menu;
}

// Quirk kept: the background cache of the view itself is invalidated too.
- (void)encodeWithCoder:(id)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_borderColor];
    [aCoder encodeObject:_tintColor];
    [aCoder encodeObject:_backgroundImage];
    float radius = 0;
    float thickness = 0;
    if (_smkFlags.borderStyle == 7) {
        radius = _cornerRadius;
        thickness = _borderThickness;
    }
    _smkFlags.backgroundCacheValid = 0;
    struct HyperPlayerBase_anon16 flags = _smkFlags;
    [aCoder encodeValueOfObjCType:"I" at:&flags];
    [aCoder encodeValueOfObjCType:"f" at:&radius];
    [aCoder encodeValueOfObjCType:"f" at:&thickness];
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self == nil)
        return nil;
    [self setBorderColor:[aCoder decodeObject]];
    [self setTintColor:[aCoder decodeObject]];
    [self setBackgroundImage:[aCoder decodeObject]];
    [aCoder decodeValueOfObjCType:"I" at:&_smkFlags];
    float radius, thickness;
    [aCoder decodeValueOfObjCType:"f" at:&radius];
    [aCoder decodeValueOfObjCType:"f" at:&thickness];
    if (_smkFlags.borderStyle == 7) {
        [self setBorderThickness:thickness];
        [self setCornerRadius:radius];
    } else {
        [self _setBorderStyle:_smkFlags.borderStyle force:YES];
    }
    return self;
}

// Re-added to its superview so the window notices the opacity change (it
// ends up frontmost).
- (void)setOpaque:(BOOL)aOpaque
{
    if (_smkFlags.isOpaque == (aOpaque != NO))
        return;
    [[self retain] autorelease];
    NSView *superview = [[[self superview] retain] autorelease];
    [self removeFromSuperview];
    _smkFlags.isOpaque = aOpaque != NO;
    [superview addSubview:self];
}

- (BOOL)isOpaque
{
    return _smkFlags.isOpaque;
}

- (void)setCornerRadius:(CGFloat)aRadius
{
    if (_smkFlags.borderStyle != 7)
        [self setBorderStyle:7];
    _cornerRadius = (float)aRadius;
    _smkFlags.backgroundCacheValid = 0;
}

- (CGFloat)cornerRadius
{
    return _smkFlags.borderStyle != 0 ? _cornerRadius : 0;
}

- (void)setBorderThickness:(CGFloat)aThickness
{
    if (_smkFlags.borderStyle != 7)
        [self setBorderStyle:7];
    _borderThickness = (float)aThickness;
    _smkFlags.backgroundCacheValid = 0;
    [_shapeBezier setLineWidth:aThickness];
    [self setNeedsDisplay:YES];
}

- (CGFloat)borderThickness
{
    return _smkFlags.borderStyle != 0 ? _borderThickness : 1;
}

- (void)setBorderStyle:(NSInteger)aStyle
{
    [self _setBorderStyle:aStyle force:NO];
}

- (void)_setBorderStyle:(NSInteger)aStyle force:(BOOL)aForce
{
    if (!aForce && [self borderStyle] == aStyle)
        return;
    _shapeInset = HSZeroInset;
    _smkFlags.backgroundCacheValid = 0;
    if (aStyle == 2) {
        _smkFlags.borderStyle = 2;
        _borderThickness = 2;
        _cornerRadius = 4;
    } else if (aStyle == 1) {
        _smkFlags.borderStyle = 1;
        _borderThickness = 1;
        _cornerRadius = 8;
        _shapeInset.left = 1;
        _shapeInset.top = 1;
        _shapeInset.right = 1;
        _shapeInset.bottom = 2;
    } else if (aStyle == 0) {
        _smkFlags.borderStyle = 0;
    } else {
        _smkFlags.borderStyle = 7;
    }
}

- (NSInteger)borderStyle
{
    return _smkFlags.borderStyle;
}

- (void)drawRect:(NSRect)aRect
{
    NSRect bounds = [self bounds];
    if (_smkFlags.drawsFill)
        [self renderFillWithBounds:bounds invalidRect:aRect];
    if (_smkFlags.drawsBorder)
        [self renderBorderWithBounds:bounds invalidRect:aRect];
}

- (void)renderBorderWithBounds:(NSRect)aBounds invalidRect:(NSRect)aRect
{
    if (_smkFlags.borderStyle == 1) {
        [self _drawBoxBorderWithBounds:aBounds operation:NSCompositeSourceOver];
        return;
    }
    [(NSColor *)[self borderColor] set];
    if (_smkFlags.borderStyle == 0)
        NSFrameRect(aBounds);
    else
        [[self _shapeBezierWithBounds:aBounds] stroke];
}

// The dirty rect is filled directly where no shape edge passes through it.
- (void)renderFillWithBounds:(NSRect)aBounds invalidRect:(NSRect)aRect
{
    if (_backgroundImage != nil) {
        [self _drawBackgroundImageInRect:aRect];
        return;
    }
    NSColor *tint = [self tintColor];
    [tint set];
    if (_smkFlags.borderStyle == 0) {
        NSRect rect = aBounds;
        if (_smkFlags.drawsBorder)
            rect = NSInsetRect(rect, 1, 1);
        rect = NSIntersectionRect(rect, aRect);
        if ([[self tintColor] alphaComponent] >= 1)
            NSRectFill(rect);
        else
            NSRectFillUsingOperation(rect, NSCompositeSourceOver);
        return;
    }
    if (_smkFlags.borderStyle == 1) {
        NSRect inner;
        if ([self getBoxBorderInnerPathRect:&inner] && NSContainsRect(inner, aRect) && [[self tintColor] alphaComponent] >= 1) {
            NSRectFill(aRect);
            return;
        }
    }
    [[self _shapeBezierWithBounds:aBounds] fill];
}

- (void)_drawBoxBorderWithBounds:(NSRect)aBounds operation:(NSUInteger)aOperation
{
    if (sBoxImages[0] == nil) {
        sBoxImages[0] = [self newImageWithName:@"topFill"];
        sBoxImages[1] = [self newImageWithName:@"rightTop_corner"];
        sBoxImages[2] = [self newImageWithName:@"right_vertFill"];
        sBoxImages[3] = [self newImageWithName:@"rightBottom_corner"];
        sBoxImages[4] = [self newImageWithName:@"fillBottom"];
        sBoxImages[5] = [self newImageWithName:@"leftBottom_corner"];
        sBoxImages[6] = [self newImageWithName:@"left_vertFill"];
        sBoxImages[7] = [self newImageWithName:@"leftTop_corner"];
    }
    [self _drawBorderWithBounds:aBounds images:sBoxImages operation:aOperation];
}

// images: top, right top, right, right bottom, bottom, left bottom, left,
// left top
- (void)_drawBorderWithBounds:(NSRect)aBounds images:(id *)aImages operation:(NSUInteger)aOperation
{
    NSRect to[8];
    NSRect from[8];
    for (int i = 0; i < 8; i++) {
        NSSize size = [(NSImage *)aImages[i] size];
        to[i] = NSZeroRect;
        to[i].size = size;
        from[i].origin = NSZeroPoint;
        from[i].size = size;
    }
    [self _alignRects:to forBounds:aBounds flippedView:[self isFlipped]];
    for (int i = 0; i < 8; i++)
        [aImages[i] drawInRect:to[i] fromRect:from[i] operation:aOperation fraction:1];
}

// Corners go to the corners and the fills stretch between them. Only
// unflipped views are handled.
- (void)_alignRects:(NSRect *)aRects forBounds:(NSRect)aBounds flippedView:(BOOL)aView
{
    if (aView)
        return;
    CGFloat minX = aBounds.origin.x;
    CGFloat minY = aBounds.origin.y;
    CGFloat maxX = NSMaxX(aBounds);
    CGFloat maxY = NSMaxY(aBounds);
    aRects[5].origin = NSMakePoint(minX, minY);
    aRects[7].origin.x = minX;
    aRects[7].origin.y = maxY - aRects[7].size.height;
    aRects[1].origin.x = maxX - aRects[1].size.width;
    aRects[1].origin.y = maxY - aRects[1].size.height;
    aRects[3].origin.x = maxX - aRects[3].size.width;
    aRects[3].origin.y = minY;
    aRects[4].origin.x = NSMaxX(aRects[5]);
    aRects[4].origin.y = minY;
    aRects[4].size.width = aRects[3].origin.x - NSMaxX(aRects[5]);
    aRects[6].origin.x = minX;
    aRects[6].origin.y = NSMaxY(aRects[5]);
    aRects[6].size.height = aRects[7].origin.y - NSMaxY(aRects[5]);
    aRects[0].origin.x = NSMaxX(aRects[7]);
    aRects[0].origin.y = maxY - aRects[0].size.height;
    aRects[0].size.width = aRects[1].origin.x - aRects[0].origin.x;
    aRects[2].origin.x = maxX - aRects[2].size.width;
    aRects[2].origin.y = NSMaxY(aRects[3]);
    aRects[2].size.height = aRects[1].origin.y - NSMaxY(aRects[3]);
}

// Returns +1.
- (id)newImageWithName:(id)aName
{
    NSString *path = [[NSBundle bundleForClass:[HSTintedView class]] pathForResource:aName ofType:@"tiff"];
    return [[NSImage alloc] initWithContentsOfFile:path];
}

// An image at least as large as the view is drawn once at the top left,
// clipped to the shape; a smaller one is tiled.
- (void)_drawBackgroundImageInRect:(NSRect)aRect
{
    NSRect bounds = [self bounds];
    if (_backgroundImage == nil)
        return;
    NSRect from = NSZeroRect;
    from.size = [_backgroundImage size];
    if (from.size.width < bounds.size.width || from.size.height < bounds.size.height) {
        [self _drawBackgroundImageAsPatternInRect:aRect];
        return;
    }
    from.origin.y = NSMaxY(from) - bounds.size.height;
    from.size = bounds.size;
    if (_smkFlags.borderStyle == 0) {
        [_backgroundImage drawInRect:bounds fromRect:from operation:NSCompositeSourceOver fraction:1];
        return;
    }
    [NSGraphicsContext saveGraphicsState];
    [[self _shapeBezierWithBounds:bounds] addClip];
    [_backgroundImage drawInRect:bounds fromRect:from operation:NSCompositeSourceOver fraction:1];
    [NSGraphicsContext restoreGraphicsState];
}

// The tiled image is drawn into an offscreen cache as tall as a whole number
// of tiles, so the tiles line up with the top of the view.
- (void)_drawBackgroundImageAsPatternInRect:(NSRect)aRect
{
    NSRect bounds = [self bounds];
    if (_backgroundImage == nil)
        return;
    NSRect cache = NSZeroRect;
    int tileHeight = (int)[_backgroundImage size].height;
    int height = (int)bounds.size.height;
    int padding = 0;
    NSAffineTransform *transform = nil;
    // Fixed: a zero-height image divided by zero.
    if (tileHeight != 0 && height % tileHeight != 0) {
        padding = tileHeight - height % tileHeight;
        height += padding;
        transform = [NSAffineTransform transform];
        [transform translateXBy:0 yBy:padding];
    }
    cache.size = NSMakeSize(bounds.size.width, height);
    BOOL redraw = _smkFlags.doesntCacheBackground || !_smkFlags.backgroundCacheValid;
    if (_offscreenCache == nil) {
        _offscreenCache = [[NSImage alloc] initWithSize:cache.size];
        [_offscreenCache setCachedSeparately:YES];
        [_offscreenCache setScalesWhenResized:NO];
        redraw = YES;
    } else if (!NSEqualSizes([_offscreenCache size], cache.size)) {
        [_offscreenCache setSize:cache.size];
        redraw = YES;
    }
    if (!NSEqualSizes(_boundsSizeForBackgroundCache, bounds.size)) {
        _boundsSizeForBackgroundCache = bounds.size;
        redraw = YES;
    }
    if (redraw) {
        [_offscreenCache lockFocus];
        NSRectFillUsingOperation(cache, NSCompositeClear);
        if (transform != nil) {
            [NSGraphicsContext saveGraphicsState];
            [transform concat];
        }
        [(NSColor *)[self _patternColor] set];
        if (_smkFlags.borderStyle == 0) {
            NSRect rect = cache;
            if (_smkFlags.drawsBorder)
                rect = NSInsetRect(rect, 1, 1);
            NSRectFillUsingOperation(rect, NSCompositeSourceOver);
        } else {
            [[self _shapeBezierWithBounds:bounds] fill];
        }
        if (transform != nil)
            [NSGraphicsContext restoreGraphicsState];
        [_offscreenCache unlockFocus];
        _smkFlags.backgroundCacheValid = 1;
    }
    NSRect from = NSMakeRect(0, 0, bounds.size.width, bounds.size.height);
    if (transform != nil)
        from.origin.y = padding;
    [_offscreenCache drawInRect:bounds fromRect:from operation:NSCompositeSourceOver fraction:1];
}

- (void)_invalidateShapeBezier
{
    [_shapeBezier release];
    _shapeBezier = nil;
}

// The box style's shape rect less its corners: what it fills completely.
- (BOOL)getBoxBorderInnerPathRect:(NSRect *)aRect
{
    if (_smkFlags.borderStyle != 1)
        return NO;
    NSRect rect = NSInsetRect([self bounds], _borderThickness - 1, _borderThickness - 1);
    rect.origin.x += _shapeInset.left;
    rect.size.width = MAX(0, rect.size.width - (_shapeInset.left + _shapeInset.right));
    rect.origin.y += _shapeInset.bottom;
    rect.size.height = MAX(0, rect.size.height - (_shapeInset.bottom + _shapeInset.top));
    rect = NSInsetRect(rect, _cornerRadius, _cornerRadius);
    if (aRect != NULL)
        *aRect = rect;
    return YES;
}

- (id)shapeBezierWithBounds:(NSRect)aBounds
{
    return [self _shapeBezierWithBounds:aBounds];
}

// A new path each time; the border is stroked inside the bounds.
- (id)_shapeBezierWithBounds:(NSRect)aBounds
{
    NSBezierPath *path;
    if (_cornerRadius >= 1) {
        NSRect rect = NSInsetRect(aBounds, _borderThickness - 1, _borderThickness - 1);
        rect.origin.x += _shapeInset.left;
        rect.size.width = MAX(0, rect.size.width - (_shapeInset.left + _shapeInset.right));
        rect.origin.y += _shapeInset.bottom;
        rect.size.height = MAX(0, rect.size.height - (_shapeInset.bottom + _shapeInset.top));
        path = [NSBezierPath hyperRoundedBorderPathWithRect:rect cornerRadius:_cornerRadius];
    } else {
        path = [NSBezierPath bezierPathWithRect:NSInsetRect(aBounds, 0.5, 0.5)];
    }
    [path setLineWidth:[self borderThickness]];
    return path;
}

// The background image as a pattern color, from the image itself when it
// is a separately cached one, else from a copy drawn into one.
- (id)_patternColor
{
    if (_patternColor != nil || _backgroundImage == nil)
        return _patternColor;
    NSImage *image;
    if ([[_backgroundImage bestRepresentationForDevice:nil] isKindOfClass:[NSCachedImageRep class]] && [_backgroundImage isCachedSeparately]) {
        image = [_backgroundImage retain];
    } else {
        NSRect rect = NSZeroRect;
        rect.size = [_backgroundImage size];
        image = [[NSImage alloc] initWithSize:rect.size];
        [image setCachedSeparately:YES];
        [image lockFocus];
        [_backgroundImage drawInRect:rect fromRect:rect operation:NSCompositeCopy fraction:1];
        [image unlockFocus];
    }
    _patternColor = [[NSColor colorWithPatternImage:image] retain];
    [image release];
    return _patternColor;
}

- (void)setBackgroundImage:(id)aImage
{
    if (_backgroundImage == aImage)
        return;
    [_backgroundImage release];
    [_patternColor release];
    _patternColor = nil;
    _smkFlags.backgroundCacheValid = 0;
    _backgroundImage = [aImage retain];
    [self setNeedsDisplayInRect:[self bounds]];
}

- (id)backgroundImage
{
    return _backgroundImage;
}

- (void)setTintColor:(id)aColor
{
    if (_tintColor == aColor)
        return;
    [_tintColor release];
    _tintColor = [aColor retain];
    if (_smkFlags.drawsFill)
        [self setNeedsDisplayInRect:[self bounds]];
}

- (id)tintColor
{
    return _tintColor != nil ? _tintColor : [NSColor colorWithCalibratedWhite:1 alpha:0.3];
}

- (void)setBorderColor:(id)aColor
{
    if (_borderColor == aColor)
        return;
    [_borderColor release];
    _borderColor = [aColor retain];
    if (_smkFlags.drawsBorder)
        [self setNeedsDisplayInRect:[self bounds]];
}

// Defaults to the tint color, opaque.
- (id)borderColor
{
    return _borderColor != nil ? _borderColor : [[self tintColor] colorWithAlphaComponent:1];
}

- (void)setCacheBackground:(BOOL)aBackground
{
    _smkFlags.doesntCacheBackground = !aBackground;
}

- (BOOL)cacheBackground
{
    return !_smkFlags.doesntCacheBackground;
}

- (void)setDrawsFill:(BOOL)aFill
{
    if (_smkFlags.drawsFill == (aFill != NO))
        return;
    _smkFlags.drawsFill = aFill != NO;
    [self setNeedsDisplayInRect:[self bounds]];
}

- (BOOL)drawsFill
{
    return _smkFlags.drawsFill;
}

- (void)setDrawsBorder:(BOOL)aBorder
{
    if (_smkFlags.drawsBorder == (aBorder != NO))
        return;
    _smkFlags.drawsBorder = aBorder != NO;
    [self setNeedsDisplayInRect:[self bounds]];
}

- (BOOL)drawsBorder
{
    return _smkFlags.drawsBorder;
}

- (void)dealloc
{
    [_borderColor release];
    [_tintColor release];
    [_backgroundImage release];
    [_shapeBezier release];
    [_patternColor release];
    [_offscreenCache release];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        _smkFlags.drawsFill = 1;
        _smkFlags.drawsBorder = 1;
    }
    return self;
}

@end
