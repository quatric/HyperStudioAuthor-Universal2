#import "HSButtonObjectPrototype.h"

static BOOL HSPrototypeIsProtocol(id aInterface, Protocol *aProtocol)
{
    return aInterface == aProtocol || protocol_isEqual(aInterface, aProtocol);
}

@implementation HSButtonObjectPrototype

+ (id)buttonObjetcPrototypeFromButtonObject:(id)aObject restrictedBySize:(NSSize)aSize
{
    HSButtonObjectPrototype *proto = [[[HSButtonObjectPrototype alloc] init] autorelease];
    [proto loadExtraDictionaryRepresentation:[aObject extraDictionaryRepresentation]];
    [proto setRestrictingSize:aSize];
    [[[proto queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveFrameBoundingRectOriginTo:NSZeroPoint withLayoutGuidingContext:nil];
    return proto;
}

+ (id)buttonObjetcPrototypeFromButtonObject:(id)aObject
{
    return [self buttonObjetcPrototypeFromButtonObject:aObject restrictedBySize:NSZeroSize];
}

- (id)queryNewHyperInterface:(id)aInterface
{
    if (HSPrototypeIsProtocol(aInterface, @protocol(HSVisualization))
        || HSPrototypeIsProtocol(aInterface, @protocol(HSEditorVisualization))
        || HSPrototypeIsProtocol(aInterface, @protocol(HSPlayerVisualization))
        || HSPrototypeIsProtocol(aInterface, @protocol(HSObjectListPaletteVisualization)))
        return [[[HSButtonObjectPrototypeVisualization alloc] initWithHyperObject:self visualizationProtocol:aInterface] autorelease];
    return [super queryNewHyperInterface:aInterface];
}

- (void)setBackgroundStyle:(id)aStyle
{
    [super setBackgroundStyle:aStyle];
    [self resetSize];
}

- (void)setIconPosition:(NSUInteger)aPosition
{
    [super setIconPosition:aPosition];
    [self resetSize];
}

- (void)setIconVisible:(BOOL)aVisible
{
    [super setIconVisible:aVisible];
    [self resetSize];
}

- (void)setIconFromPath:(id)aPath
{
    [super setIconFromPath:aPath];
    [self resetSize];
}

- (void)setIcon:(id)aIcon
{
    [super setIcon:aIcon];
    [self resetSize];
}

- (void)setTitleFont:(id)aFont
{
    [super setTitleFont:aFont];
    [self resetSize];
}

- (void)setTitle:(id)aTitle
{
    [super setTitle:aTitle];
    [self resetSize];
}

- (void)setTitleVisible:(BOOL)aVisible
{
    [super setTitleVisible:aVisible];
    [self resetSize];
}

- (void)resetSize
{
    NSButtonCell *cell = [NSButtonCell new];
    [cell setTitle:[self isTitleVisible] ? [self title] : @" "];
    [cell setFont:[self titleFont]];
    if ([self isIconVisible]) {
        [cell setImage:[self icon]];
        [cell setImagePosition:[self iconPosition]];
    } else {
        [cell setImage:nil];
    }
    NSSize cellSize = [cell cellSize];
    NSRect cellRect = { NSZeroPoint, cellSize };
    NSRect restrictingRect = { NSZeroPoint, _restrictingSize };
    NSSize size = NSEqualSizes(NSZeroSize, _restrictingSize) ? cellSize : NSIntersectionRect(cellRect, restrictingRect).size;
    [cell release];
    [self setSize:size];
}

- (void)setRestrictingSize:(NSSize)aSize
{
    if (!NSEqualSizes(_restrictingSize, aSize)) {
        _restrictingSize = aSize;
        [self resetSize];
    }
}

- (NSSize)restrictingSize
{
    return _restrictingSize;
}

@end
