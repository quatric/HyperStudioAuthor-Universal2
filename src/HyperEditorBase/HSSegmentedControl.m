#import "HSSegmentedControl.h"

// A matrix of segment cells drawn by a background renderer (kept by class
// name when archived), with the renderer's separators between the cells.

@implementation HSSegmentedControl

- (void)encodeWithCoder:(id)aCoder
{
    [super encodeWithCoder:aCoder];
    if ([aCoder allowsKeyedCoding] && _backgroundRenderer != nil) {
        NSString *className = NSStringFromClass([_backgroundRenderer class]);
        if (className != nil)
            [aCoder encodeObject:className forKey:@"HSBackgroundRendererClassName"];
    }
}

- (id)initWithCoder:(id)aCoder
{
    if ((self = [super initWithCoder:aCoder]) && [aCoder allowsKeyedCoding]) {
        NSString *className = [aCoder decodeObjectForKey:@"HSBackgroundRendererClassName"];
        Class rendererClass = className != nil ? NSClassFromString(className) : Nil;
        if ([rendererClass respondsToSelector:@selector(sharedBackgroundRenderer)]
                && [[rendererClass sharedBackgroundRenderer] conformsToProtocol:@protocol(SMKBackgroundRenderer)])
            [self setBackgroundRenderer:[rendererClass sharedBackgroundRenderer]];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    HSSegmentedControl *copy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
#pragma clang diagnostic pop
    if (copy != nil)
        [copy setBackgroundRenderer:_backgroundRenderer];
    return [copy retain];
}

- (void)awakeFromNib
{
    [self setupOnDidLoad];
}

- (void)setupOnDidLoad
{
    [self fixCellCaps];
    [self setMode:[self mode]];
    [[self cells] makeObjectsPerformSelector:@selector(setBackgroundRenderer:) withObject:[self backgroundRenderer]];
}

// Highlight matrices get momentary cells, the others push-on/push-off ones.
- (void)setMode:(NSUInteger)aMode
{
    [super setMode:aMode];
    BOOL highlight = [self mode] == NSHighlightModeMatrix;
    for (NSButtonCell *cell in [self cells])
        [cell setButtonType:highlight ? NSButtonTypeMomentaryLight : NSButtonTypePushOnPushOff];
}

- (void)setIntercellSpacing:(NSSize)aSpacing
{
    float width = aSpacing.width;
    [self getAllowedIntercellWidth:&width];
    aSpacing.width = width;
    [super setIntercellSpacing:aSpacing];
}

// 1 point between cells when the renderer draws separators, else none.
- (BOOL)getAllowedIntercellWidth:(float *)aWidth
{
    BOOL separators = [[self backgroundRenderer] respondsToSelector:@selector(drawSeparatorWithBounds:selected:)];
    if (aWidth != NULL)
        *aWidth = separators ? 1.0f : 0.0f;
    return separators;
}

- (void)fixCellCaps
{
    [[self cells] makeObjectsPerformSelector:@selector(setLeftCap:) withObject:nil];
    [[self cells] makeObjectsPerformSelector:@selector(setRightCap:) withObject:nil];
    if ([self numberOfRows] > 0 && [self numberOfColumns] > 0) {
        [(id)[self cellAtRow:0 column:0] setLeftCap:YES];
        [(id)[self cellAtRow:0 column:[self numberOfColumns] - 1] setRightCap:YES];
    }
    [self setNeedsDisplay:YES];
}

- (void)setBackgroundRenderer:(id)aRenderer
{
    if (_backgroundRenderer == aRenderer)
        return;
    [_backgroundRenderer autorelease];
    _backgroundRenderer = [aRenderer retain];
    [[self cells] makeObjectsPerformSelector:@selector(setBackgroundRenderer:) withObject:_backgroundRenderer];
    [self setIntercellSpacing:[self intercellSpacing]];
    [self setNeedsDisplay:YES];
}

- (id)backgroundRenderer
{
    if (_backgroundRenderer == nil)
        [self setBackgroundRenderer:[HSControlBackgroundRenderer sharedBackgroundRenderer]];
    return _backgroundRenderer;
}

- (void)updateCellInside:(id)aInside
{
    [super updateCellInside:aInside];
    [self updateSeparatorForCell:aInside];
}

- (void)updateCell:(id)aCell
{
    [super updateCell:aCell];
    [self updateSeparatorForCell:aCell];
}

- (void)mouseDown:(id)aDown
{
    [super mouseDown:aDown];
    if ([self mode] == NSHighlightModeMatrix)
        [self setNeedsDisplay:YES];
}

// The cell and its separators.
- (void)updateSeparatorForCell:(id)aCell
{
    float width = 0;
    NSInteger row = 0, column = 0;
    if (![self getAllowedIntercellWidth:&width] || ![self getRow:&row column:&column ofCell:aCell])
        return;
    [self setNeedsDisplayInRect:NSInsetRect([self cellFrameAtRow:row column:column], -width, 0)];
}

// The separator images between the cells, selected beside a selected cell.
- (void)drawRect:(NSRect)aRect
{
    [super drawRect:aRect];
    if (![self getAllowedIntercellWidth:NULL])
        return;
    NSInteger count = [self numberOfColumns];
    if (count < 2)
        return;
    for (NSInteger column = 0; column < count - 1; column++) {
        BOOL nextSelected = [(id)[self cellAtRow:0 column:column + 1] isSelected];
        BOOL selected = [(id)[self cellAtRow:0 column:column] isSelected];
        NSRect next = [self cellFrameAtRow:0 column:column + 1];
        NSRect frame = [self cellFrameAtRow:0 column:column];
        NSRect separator = next;
        separator.origin.x = frame.origin.x + frame.size.width;
        separator.size.width = next.origin.x - separator.origin.x;
        separator.size.height = [[self backgroundRenderer] segmentHeightForObject:nil];
        NSImage *image = [[self backgroundRenderer] imageForSeparatorSelected:selected || nextSelected];
        if (NSIsEmptyRect(separator) || image == nil)
            continue;
        NSRect from;
        from.origin = NSZeroPoint;
        from.size = [image size];
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:0 yBy:from.size.height];
        [transform scaleXBy:1.0 yBy:-1.0];
        [transform concat];
        [image drawAtPoint:separator.origin fromRect:from operation:NSCompositingOperationSourceOver fraction:1.0];
        [NSGraphicsContext restoreGraphicsState];
    }
}

- (void)dealloc
{
    [_backgroundRenderer release];
    [super dealloc];
}

@end
