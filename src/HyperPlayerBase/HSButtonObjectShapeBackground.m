#import "HSButtonObjectShapeBackground.h"

// Two sizes are the same within a relative tolerance of 1/2000.
static BOOL HSShapeBackgroundValuesEqual(CGFloat aValue1, CGFloat aValue2)
{
    CGFloat magnitude1 = aValue1 != 0 ? fabs(aValue1) : 1;
    CGFloat magnitude2 = aValue2 != 0 ? fabs(aValue2) : 1;
    return fabs(aValue1 - aValue2) <= MAX(magnitude1, magnitude2) * 0.0005;
}

static BOOL HSShapeBackgroundSizesEqual(NSSize aSize1, NSSize aSize2)
{
    return HSShapeBackgroundValuesEqual(aSize1.width, aSize2.width) && HSShapeBackgroundValuesEqual(aSize1.height, aSize2.height);
}

// The scale from a size component to another, 1 for a zero one.
static CGFloat HSShapeBackgroundScale(CGFloat aFrom, CGFloat aTo)
{
    CGFloat magnitude = aFrom != 0 ? fabs(aFrom) : 1;
    CGFloat tolerance = magnitude >= 1 ? magnitude * 0.0005 : 0.0005;
    return fabs(aFrom) > tolerance ? aTo / aFrom : 1;
}

// A button background drawn in a border path (a shape): graphics (a color
// or image) clipped to the path, and an optional border.
@implementation HSButtonObjectShapeBackground

- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo
{
    [super notifyChange:aChange ofAttribute:aAttribute withUserInfo:aInfo];
}

- (void)setHyperOutlineColor:(id)aColor
{
    [self notifyChange:1 ofAttribute:@protocol(HSOutlineColorAttribute) withUserInfo:nil];
    [self setBorderColor:aColor];
    [self notifyChange:2 ofAttribute:@protocol(HSOutlineColorAttribute) withUserInfo:nil];
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth
{
    [self notifyChange:1 ofAttribute:@protocol(HSOutlineWidthAttribute) withUserInfo:nil];
    [self setBorderWidth:aWidth];
    [self notifyChange:2 ofAttribute:@protocol(HSOutlineWidthAttribute) withUserInfo:nil];
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled
{
    [self setIsBorderless:!aEnabled];
}

- (id)hyperOutlineColor
{
    return [self borderColor];
}

- (CGFloat)hyperOutlineWidth
{
    return [(NSBezierPath *)[self borderPath] lineWidth];
}

- (BOOL)isHyperOutlineEnabled
{
    return ![self isBorderless];
}

// It renders and is the background itself; graphics interfaces go to the
// background graphics.
- (id)queryHyperInterface:(id)aInterface
{
    if (protocol_conformsToProtocol(aInterface, @protocol(HSBackgroundRenderer)) || protocol_conformsToProtocol(aInterface, @protocol(HSBackgroundAttributes)))
        return self;
    if (protocol_conformsToProtocol(aInterface, @protocol(HSGraphics)))
        return [[self backgroundGraphics] queryHyperInterface:aInterface];
    return [super queryHyperInterface:aInterface];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"backgroundGraphics", @"borderPath", [@"borderColor" extraKeyForMultiRepresentations], @"shapeButtonType", @"isBorderless", nil]];
}

- (id)undoManagerForGraphics:(id)aGraphics
{
    return [[self buttonObject] undoManager];
}

- (void)hyperVisualAttributesChanged:(id)aChanged
{
    [self notifyChange:2 ofAttribute:@protocol(HSVisualAttribute) withUserInfo:nil];
    [super hyperVisualAttributesChanged:aChanged];
}

- (void)setHyperDroppedSolidColor:(id)aColor
{
    [[self queryBackgroundGraphicsInterface:@protocol(HSMutableColor)] setHyperSolidColor:aColor];
}

// A dropped color object brings all of its settings; anything else is a
// plain color.
- (void)setHyperSolidColor:(id)aColor
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Fill Color" value:@"" table:@"UndoManager"]];
    id color = [self queryBackgroundGraphicsInterface:@protocol(HSMutableColor)];
    id source = [aColor queryHyperInterface:@protocol(HSMutableColor)];
    if (source == nil) {
        [color setHyperSolidColor:aColor];
        return;
    }
    [color setHyperClear:[source isHyperClear]];
    [color setHyperKind:[source hyperKind]];
    [color setHyperCacheEnabled:[source isHyperCacheEnabled]];
    [color setHyperStartColor:[source hyperStartColor]];
    [color setHyperEndColor:[source hyperEndColor]];
    [color setHyperAngle:[source hyperAngle]];
    // Fixed: the vertical center was copied from the horizontal one.
    [color setHyperCenterX:[source hyperCenterX] andY:[source hyperCenterY]];
}

- (id)hyperSolidColor
{
    id color = [[self backgroundGraphics] queryHyperInterface:@protocol(HSMutableColor)];
    if (color != nil && [color isHyperSolid])
        return [color hyperSolidColor];
    return nil;
}

- (void)setHyperBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject
{
    [self setBackgroundGraphics:aGraphics copyObject:aObject];
}

// The graphics are owned (and in the document while the background is).
- (void)_setBackgroundGraphics:(id)aGraphics
{
    if ([self backgroundGraphics] == aGraphics)
        return;
    if ([self isInDocument])
        [_backgroundGraphics willRemoveFromDocument];
    [self setBackgroundThumbnail:nil];
    [_backgroundGraphics setHyperOwner:nil];
    [_backgroundGraphics release];
    _backgroundGraphics = [aGraphics retain];
    [_backgroundGraphics setHyperOwner:self];
    if ([self isInDocument])
        [_backgroundGraphics didAddToDocument];
    [self setBackgroundThumbnail:nil];
    [[self buttonObject] linkAttribute:@protocol(HSBackgroundBoundsAttribute) toAttribute:@protocol(HSSizeAttribute)];
}

- (NSRect)backgroundBounds
{
    NSRect bounds;
    bounds.origin = NSZeroPoint;
    bounds.size = [self size];
    return bounds;
}

- (id)backgroundGraphics
{
    return _backgroundGraphics;
}

- (void)setBackgroundThumbnail:(id)aThumbnail
{
    if (_backgroundThumbnail == aThumbnail)
        return;
    [_backgroundThumbnail autorelease];
    _backgroundThumbnail = [aThumbnail retain];
}

// The background in its border path, scaled to fit and centred; cached for
// the last size.
- (id)hyperBackgroundThumbnailForSize:(NSSize)aSize
{
    if (_backgroundThumbnail != nil && NSEqualSizes(aSize, [_backgroundThumbnail size]))
        return _backgroundThumbnail;
    NSBezierPath *path = [self borderPath];
    NSRect bounds = [path bounds];
    CGFloat scaleY = aSize.height / bounds.size.height;
    CGFloat scaleX = aSize.width / bounds.size.width;
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:-((bounds.size.width - aSize.width) * 0.5 + bounds.origin.x) yBy:-((bounds.size.height - aSize.height) * 0.5 + bounds.origin.y)];
    CGFloat scale = MIN(scaleX, scaleY);
    [transform hyperPostscaleBy:NSMakeSize(scale, scale) aboutPoint:NSMakePoint(aSize.width * 0.5, aSize.height * 0.5)];
    // Fixed: the previous thumbnail was leaked.
    [_backgroundThumbnail release];
    _backgroundThumbnail = [[NSImage alloc] initWithSize:aSize];
    [_backgroundThumbnail lockFocus];
    [transform concat];
    [path addClip];
    [self hyperDrawBackgroundInROI:bounds ofBounds:bounds];
    [_backgroundThumbnail unlockFocus];
    return _backgroundThumbnail;
}

- (id)backgroundThumbnail
{
    return _backgroundThumbnail;
}

- (id)buttonType
{
    return [self shapeButtonType];
}

// Going to or from a freehand area changes the size attributes too.
- (void)setShapeButtonType:(id)aType
{
    if ([_shapeButtonType isEqualToString:aType])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Button background" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setShapeButtonType:_shapeButtonType];
    BOOL freehand = [_shapeButtonType isEqualToString:@"HSFreehandAreaShapeButtonType"] || [aType isEqualToString:@"HSFreehandAreaShapeButtonType"];
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSButtonObjectShapeButtonTypeAttribute), @protocol(HSSelectionKnobsProviderAttribute), freehand ? @protocol(HSWidthAttribute) : nil, freehand ? @protocol(HSHeightAttribute) : nil, nil];
    [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    [_shapeButtonType release];
    _shapeButtonType = [aType copy];
    [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
}

- (id)shapeButtonType
{
    if (_shapeButtonType == nil)
        _shapeButtonType = [@"HSFreehandAreaShapeButtonType" retain];
    return _shapeButtonType;
}

- (BOOL)isVisible
{
    return [self backgroundGraphics] != nil;
}

// The border path is scaled; nothing happens for an empty background.
- (void)setSize:(NSSize)aSize
{
    NSSize size = [self size];
    if (HSShapeBackgroundSizesEqual(size, aSize) || HSShapeBackgroundSizesEqual(size, NSZeroSize))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change background size" value:@"" table:@"UndoManager"]];
    [(HSButtonObjectShapeBackground *)[[self undoManager] prepareWithInvocationTarget:self] setSize:[self size]];
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSBorderPathAttribute), @protocol(HSWidthAttribute), @protocol(HSHeightAttribute), nil];
    [self notifyChange:1 ofAttributeSet:attributes withUserInfo:nil];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform scaleXBy:HSShapeBackgroundScale(size.width, aSize.width) yBy:HSShapeBackgroundScale(size.height, aSize.height)];
    [_borderPath transformUsingAffineTransform:transform];
    [self notifyChange:2 ofAttributeSet:attributes withUserInfo:nil];
    if ([[self buttonObject] respondsToSelector:@selector(shapeBackgroundSizeDidChange)])
        [[self buttonObject] shapeBackgroundSizeDidChange];
}

// A freehand area's path is half a point larger on each side.
- (NSSize)size
{
    if (_borderPath == nil)
        return NSZeroSize;
    NSRect bounds = [_borderPath bounds];
    if (NSIsEmptyRect(bounds))
        return NSZeroSize;
    if ([[self shapeButtonType] isEqualToString:@"HSFreehandAreaShapeButtonType"])
        bounds = NSInsetRect(bounds, -0.5, -0.5);
    return bounds.size;
}

- (id)backgroundStyle
{
    return @"HSButtonObjectShapeBackgroundStyle";
}

- (void)activateAlternativeBorder:(BOOL)aBorder
{
    if (_isAlternativeBorderActive == (aBorder != NO))
        return;
    [self notifyChange:1 ofAttribute:@protocol(HSButtonObjectShapeAlternativeBorderAttribute) withUserInfo:nil];
    _isAlternativeBorderActive = aBorder != NO;
    [self notifyChange:2 ofAttribute:@protocol(HSButtonObjectShapeAlternativeBorderAttribute) withUserInfo:nil];
}

- (BOOL)isAlternativeBorderActive
{
    return _isAlternativeBorderActive;
}

- (void)setShowsBorderInPlayer:(BOOL)aPlayer
{
    if (_showsBorderInPlayer == aPlayer)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change button is borderles" value:@"" table:@"UndoManager"]];
    // Fixed: the undo restored the borderless flag instead.
    [[[self undoManager] prepareWithInvocationTarget:self] setShowsBorderInPlayer:_showsBorderInPlayer];
    [self notifyChange:1 ofAttribute:@protocol(HSBorderShowingInPlayerAttribute) withUserInfo:nil];
    _showsBorderInPlayer = aPlayer;
    [self notifyChange:2 ofAttribute:@protocol(HSBorderShowingInPlayerAttribute) withUserInfo:nil];
}

- (BOOL)showsBorderInPlayer
{
    return _showsBorderInPlayer;
}

// The border is the path's line width.
- (void)setBorderWidth:(CGFloat)aWidth
{
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change background border width" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOutlineWidth:[self hyperOutlineWidth]];
    [self notifyChange:1 ofAttribute:@protocol(HSBorderWidthAttribute) withUserInfo:nil];
    [(NSBezierPath *)[self borderPath] setLineWidth:aWidth];
    [self notifyChange:2 ofAttribute:@protocol(HSBorderWidthAttribute) withUserInfo:nil];
    if ([[self owner] respondsToSelector:@selector(shapeBackgroundSizeDidChange)])
        [[self owner] shapeBackgroundSizeDidChange];
}

- (CGFloat)borderWidth
{
    return [(NSBezierPath *)[self borderPath] lineWidth];
}

- (void)setBorderColor:(id)aColor
{
    if ([_borderColor isEqual:aColor])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change background border color" value:@"" table:@"UndoManager"]];
    [(HSButtonObjectShapeBackground *)[[self undoManager] prepareWithInvocationTarget:self] setBorderColor:_borderColor];
    [self notifyChange:1 ofAttribute:@protocol(HSBorderColorAttribute) withUserInfo:nil];
    [_borderColor release];
    _borderColor = [aColor retain];
    [self notifyChange:2 ofAttribute:@protocol(HSBorderColorAttribute) withUserInfo:nil];
}

- (id)borderColor
{
    // Fixed: the default black wasn't retained, but is released in dealloc.
    if (_borderColor == nil)
        _borderColor = [[NSColor blackColor] retain];
    return _borderColor;
}

- (void)setBorderPath:(id)aPath
{
    if ([_borderPath isEqual:aPath])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change background border path" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setBorderPath:[[_borderPath copy] autorelease]];
    [self notifyChange:1 ofAttribute:@protocol(HSBorderPathAttribute) withUserInfo:nil];
    [self notifyChange:1 ofAttribute:@protocol(HSSizeAttribute) withUserInfo:nil];
    [_borderPath release];
    _borderPath = [aPath copy];
    [self notifyChange:2 ofAttribute:@protocol(HSBorderPathAttribute) withUserInfo:nil];
    [self notifyChange:2 ofAttribute:@protocol(HSSizeAttribute) withUserInfo:nil];
    if ([[self owner] respondsToSelector:@selector(shapeBackgroundSizeDidChange)])
        [[self owner] shapeBackgroundSizeDidChange];
}

- (id)borderPath
{
    return _borderPath;
}

- (void)setIsBorderless:(BOOL)aBorderless
{
    if (_isBorderless == aBorderless)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change button is borderles" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setIsBorderless:_isBorderless];
    [self notifyChange:1 ofAttribute:@protocol(HSBorderlessAttribute) withUserInfo:nil];
    _isBorderless = aBorderless;
    [self notifyChange:2 ofAttribute:@protocol(HSBorderlessAttribute) withUserInfo:nil];
}

- (BOOL)isBorderless
{
    return _isBorderless;
}

- (void)dealloc
{
    [_borderPath release];
    [_borderColor release];
    [_shapeButtonType release];
    [_backgroundGraphics setHyperOwner:nil];
    [_backgroundGraphics release];
    [_backgroundThumbnail release];
    [super dealloc];
}

- (id)initWithOwner:(id)aOwner
{
    self = [super initWithOwner:aOwner];
    if (self != nil)
        [_backgroundGraphics setHyperOwner:self];
    return self;
}

@end
