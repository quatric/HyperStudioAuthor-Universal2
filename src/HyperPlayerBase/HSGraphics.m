#import "HSGraphics.h"
// Base class of an object's graphics (a background or frame style). It
// draws nothing; subclasses do. Graphics of the same class are equal, and
// the owner (not retained) supplies undo and hears about changes.

@implementation HSGraphics

- (NSUInteger)hash
{
    return (NSUInteger)[self class];
}

- (BOOL)isEqual:(id)aEqual
{
    return [self hash] == [aEqual hash] && [aEqual isMemberOfClass:[self class]];
}

- (id)copyWithZone:(NSZone *)aZone
{
    id copy = [[[self class] allocWithZone:aZone] init];
    if (copy)
        [copy setHyperOwner:[self owner]];
    return copy;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}

- (void)willRemoveFromDocument
{
}

- (void)didAddToDocument
{
}

- (void)hyperDrawHighlightedInRect:(NSRect)aRect ofBounds:(NSRect)aBounds
{
    [self hyperDrawInRect:aRect ofBounds:aBounds];
    [[[NSColor grayColor] colorWithAlphaComponent:0.5] set];
    NSRectFillUsingOperation(aRect, NSCompositeSourceOver);
}

- (void)hyperDrawInRect:(NSRect)aRect ofBounds:(NSRect)aBounds
{
}

- (void)postDidChange
{
    [[self owner] hyperVisualAttributesChanged:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSGraphicsDidChangeNotification" object:self];
}

- (id)hyperMutableCopyWithZone:(NSZone *)aZone
{
    return [self copyWithZone:aZone];
}

- (id)undoManager
{
    return [[self owner] undoManagerForGraphics:self];
}

- (void)setHyperOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

- (id)initWithOwner:(id)aOwner
{
    self = [self init];
    if (self)
        _owner = aOwner;
    return self;
}

- (id)init
{
    return [super init];
}

@end
