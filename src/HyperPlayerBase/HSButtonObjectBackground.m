#import "HSButtonObjectBackground.h"
// Base class of a button's background style. The owner (not retained)
// maps it to its button object, which handles undo and change
// notifications. This base style has no type, size or visibility.

@implementation HSButtonObjectBackground

- (id)attributeObservingController
{
    return [[self buttonObject] attributeObservingController];
}

- (id)buttonType
{
    return nil;
}

- (BOOL)isVisible
{
    return NO;
}

- (void)setSize:(NSSize)aSize
{
}

- (NSSize)size
{
    return NSZeroSize;
}

- (BOOL)isInDocument
{
    return [[self buttonObject] isInDocument];
}

- (id)undoManager
{
    return [[self buttonObject] undoManager];
}

- (void)notifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet withUserInfo:(id)aInfo
{
    [[self buttonObject] notifyChange:aChange ofAttributeSet:aSet withUserInfo:aInfo];
}

- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo
{
    [[self buttonObject] notifyChange:aChange ofAttribute:aAttribute withUserInfo:aInfo];
}

- (id)backgroundStyle
{
    return nil;
}

- (id)buttonObject
{
    return [[self owner] buttonObjectForButtonObjectBackground:self];
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}

- (id)initWithOwner:(id)aOwner
{
    self = [self init];
    if (self)
        _owner = aOwner;
    return self;
}

@end
