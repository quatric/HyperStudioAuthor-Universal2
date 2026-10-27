#import "HSHeadlineObject.h"
#import "HSHeadlineObjectData.h"
#import "HSHeadlineObjectVisualization.h"
#import "NSAffineTransform+HSKeyValueCoding.h"

@implementation HSHeadlineObject

+ (id)sharedRenderingLayoutManager
{
    static NSLayoutManager *sLayoutManager = nil;
    if (sLayoutManager == nil) {
        NSTextContainer *container = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(1000000.0, 1000000.0)] autorelease];
        [container setWidthTracksTextView:NO];
        [container setHeightTracksTextView:NO];
        sLayoutManager = [[NSLayoutManager alloc] init];
        [sLayoutManager addTextContainer:container];
    }
    return sLayoutManager;
}

+ (id)backgroundAttributesSerializationKey
{
    return @"backgroundGraphics";
}

+ (Class)nodeDataClass
{
    return [HSHeadlineObjectData class];
}

- (void)setOutlineColor:(id)aColor
{
    if ([(HSHeadlineObjectData *)[self nodeData] outlineColor] != aColor)
        [(HSHeadlineObjectData *)[self nodeData] setOutlineColor:aColor];
}

- (id)outlineColor
{
    return [(HSHeadlineObjectData *)[self nodeData] outlineColor];
}

- (id)hyperBackgroundThumbnailForSize:(NSSize)aSize
{
    if ([(HSHeadlineObjectData *)[self nodeData] backgroundThumbnail] == nil
        || !NSEqualSizes(aSize, [(NSImage *)[(HSHeadlineObjectData *)[self nodeData] backgroundThumbnail] size])) {
        // Draw a 30x20 sample of the background, scaled to fit and centered.
        NSBezierPath *clip = [NSBezierPath bezierPathWithRect:NSMakeRect(0.0, 0.0, 30.0, 20.0)];
        NSRect bounds = [clip bounds];
        CGFloat scaleY = (float)(aSize.height / bounds.size.height);
        CGFloat scaleX = (float)(aSize.width / bounds.size.width);
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:-((bounds.size.width - aSize.width) * 0.5f + bounds.origin.x)
                            yBy:-((bounds.size.height - aSize.height) * 0.5f + bounds.origin.y)];
        CGFloat scale = MIN(scaleX, scaleY);
        [transform hyperPostscaleBy:NSMakeSize(scale, scale)
                         aboutPoint:NSMakePoint(aSize.width * 0.5f + NSZeroPoint.x, aSize.height * 0.5f + NSZeroPoint.y)];
        [(HSHeadlineObjectData *)[self nodeData] setBackgroundThumbnail:[[[NSImage alloc] initWithSize:aSize] autorelease]];
        [[(HSHeadlineObjectData *)[self nodeData] backgroundThumbnail] lockFocus];
        [transform concat];
        [clip addClip];
        [self hyperDrawBackgroundInROI:bounds ofBounds:bounds];
        [[(HSHeadlineObjectData *)[self nodeData] backgroundThumbnail] unlockFocus];
    }
    return [(HSHeadlineObjectData *)[self nodeData] backgroundThumbnail];
}

- (void)setHyperBackgroundGraphics:(id)aGraphics copyObject:(BOOL)aObject
{
    [self setBackgroundGraphics:aGraphics copyObject:aObject];
}

- (void)setBackgroundThumbnail:(id)aThumbnail
{
    if ([(HSHeadlineObjectData *)[self nodeData] backgroundThumbnail] != aThumbnail)
        [(HSHeadlineObjectData *)[self nodeData] setBackgroundThumbnail:aThumbnail];
}

- (id)backgroundThumbnail
{
    return [(HSHeadlineObjectData *)[self nodeData] backgroundThumbnail];
}

- (void)_setBackgroundGraphics:(id)aGraphics
{
    if ([(HSHeadlineObjectData *)[self nodeData] backgroundGraphics] == aGraphics)
        return;
    if ([self isInDocument])
        [[(HSHeadlineObjectData *)[self nodeData] backgroundGraphics] willRemoveFromDocument];
    [(HSHeadlineObjectData *)[self nodeData] setBackgroundGraphics:aGraphics];
    if ([self isInDocument])
        [[(HSHeadlineObjectData *)[self nodeData] backgroundGraphics] didAddToDocument];
    [self setBackgroundThumbnail:nil];
}

- (id)backgroundGraphics
{
    return [(HSHeadlineObjectData *)[self nodeData] backgroundGraphics];
}

- (NSRect)backgroundBounds
{
    id geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NSZeroRect;
    return [geometry boundingRect];
}

- (void)setHyperOutlineColor:(id)aColor
{
    if ([(HSHeadlineObjectData *)[self nodeData] outlineColor] == aColor || [[(HSHeadlineObjectData *)[self nodeData] outlineColor] isEqual:aColor])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Outline Color" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOutlineColor:[(HSHeadlineObjectData *)[self nodeData] outlineColor]];
    [self notifyChange:1 ofAttribute:@protocol(HSOutlineColorAttribute) withUserInfo:nil];
    [(HSHeadlineObjectData *)[self nodeData] setOutlineColor:aColor];
    [self notifyChange:2 ofAttribute:@protocol(HSOutlineColorAttribute) withUserInfo:nil];
}

- (id)hyperOutlineColor
{
    return [(HSHeadlineObjectData *)[self nodeData] outlineColor];
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth
{
    float current = (float)[(HSHeadlineObjectData *)[self nodeData] outlineWidth];
    float width = (float)aWidth;
    // Relative float comparison, as in the original.
    float magnitude = MAX(current != 0.0f ? fabsf(current) : 1.0f, width != 0.0f ? fabsf(width) : 1.0f);
    if (fabsf(current - width) <= magnitude * 0.0005f)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Outline Width" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOutlineWidth:(float)[(HSHeadlineObjectData *)[self nodeData] outlineWidth]];
    [self notifyChange:1 ofAttribute:@protocol(HSOutlineWidthAttribute) withUserInfo:nil];
    [(HSHeadlineObjectData *)[self nodeData] setOutlineWidth:aWidth];
    [self notifyChange:2 ofAttribute:@protocol(HSOutlineWidthAttribute) withUserInfo:nil];
}

- (CGFloat)hyperOutlineWidth
{
    return (float)[(HSHeadlineObjectData *)[self nodeData] outlineWidth];
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled
{
    if ([(HSHeadlineObjectData *)[self nodeData] isOutlineEnabled] == aEnabled)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Outline Availability" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setHyperOutlineEnabled:[(HSHeadlineObjectData *)[self nodeData] isOutlineEnabled]];
    [self notifyChange:1 ofAttribute:@protocol(HSOutlineAvailabilityAttribute) withUserInfo:nil];
    [(HSHeadlineObjectData *)[self nodeData] setOutlineEnabled:aEnabled];
    [self notifyChange:2 ofAttribute:@protocol(HSOutlineAvailabilityAttribute) withUserInfo:nil];
}

- (BOOL)isHyperOutlineEnabled
{
    return [(HSHeadlineObjectData *)[self nodeData] isOutlineEnabled];
}

- (id)bezierPath
{
    NSTextStorage *textStorage = [self cocoaTextStorage];
    if ([textStorage length]) {
        NSLayoutManager *layoutManager = [[self class] sharedRenderingLayoutManager];
        NSTextContainer *container = [[layoutManager textContainers] extraFirstObject];
        [container setContainerSize:NSMakeSize([self maximumVisibleBoundsForText].size.width, FLT_MAX)];
        [textStorage addLayoutManager:layoutManager];
        NSRange glyphRange = [layoutManager glyphRangeForTextContainer:container];
        if (glyphRange.length == 0) {
            [textStorage removeLayoutManager:layoutManager];
        } else {
            NSBezierPath *path = [layoutManager hyperRenderingPathWithGlyphRange:glyphRange textContainerOrigin:NSZeroPoint];
            [path setLineWidth:[(HSHeadlineObjectData *)[self nodeData] outlineWidth]];
            [textStorage removeLayoutManager:layoutManager];
            if (path != nil)
                return path;
        }
    }
    return [NSBezierPath bezierPath];
}

- (id)fillGraphics
{
    return [(HSHeadlineObjectData *)[self nodeData] backgroundGraphics];
}

- (id)strokeColor
{
    if ([(HSHeadlineObjectData *)[self nodeData] isOutlineEnabled])
        return [(HSHeadlineObjectData *)[self nodeData] outlineColor];
    return [NSColor clearColor];
}

- (void)setOutlineEnabled:(BOOL)aEnabled
{
    [(HSHeadlineObjectData *)[self nodeData] setOutlineEnabled:aEnabled];
}

- (BOOL)isOutlineEnabled
{
    return [(HSHeadlineObjectData *)[self nodeData] isOutlineEnabled];
}

- (void)setOutlineWidth:(CGFloat)aWidth
{
    [(HSHeadlineObjectData *)[self nodeData] setOutlineWidth:aWidth];
}

- (CGFloat)outlineWidth
{
    return (float)[(HSHeadlineObjectData *)[self nodeData] outlineWidth];
}

- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSProtocolsAreEqual(@protocol(HSVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSEditorVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSPlayerVisualization), aInterface)
        || HSProtocolsAreEqual(@protocol(HSObjectListPaletteVisualization), aInterface))
        return [[[HSHeadlineObjectVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    return [super queryNewHyperInterface:aInterface];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraLoadingWithCodingContext:aContext]];
    [keys addObject:[HSHeadlineObject backgroundAttributesSerializationKey]];
    [keys addObject:@"outlineEnabled"];
    [keys addObject:@"outlineWidth"];
    [keys addObject:[@"outlineColor" extraKeyForMultiRepresentations]];
    return keys;
}

- (id)init
{
    self = [super init];
    [self linkAttribute:@protocol(HSBezierPathVectorAttribute) toAttribute:@protocol(HSTextAttribute)];
    [self linkAttribute:@protocol(HSBezierPathVectorAttribute) toAttribute:@protocol(HSTextLayoutAttribute)];
    [self linkAttribute:@protocol(HSBezierPathVectorAttribute) toAttribute:@protocol(HSOutlineWidthAttribute)];
    [self linkAttribute:@protocol(HSStrokeColorVectorAttribute) toAttribute:@protocol(HSOutlineAvailabilityAttribute)];
    [self linkAttribute:@protocol(HSStrokeColorVectorAttribute) toAttribute:@protocol(HSOutlineColorAttribute)];
    [self linkAttribute:@protocol(HSFillGraphicsVectorAttribute) toAttribute:@protocol(HSBackgroundAttribute)];
    return self;
}

@end
